`timescale 1ns/1ps
`default_nettype none

// Generic flat-binary execution harness. The program is linked at address 0
// and converted to 32-bit little-endian words for $readmemh. A word store of
// 1 to 0x20000000 is the harness-specific PASS convention; this is not yet
// the official RISC-V ACT4 RVMODEL_HALT_PASS protocol.
module tb_riscv_elf;
    // AXI-backed simulation RAM; 256 KiB accommodates larger official ACT4 ELFs.
    localparam integer WORDS = 65536;
    localparam [31:0] PASS_ADDR = 32'h20000000;

    reg clk = 1'b0;
    reg resetb = 1'b0;
    always #5 clk = ~clk;

    wire [31:0] instr_addr;
    reg [31:0] instr_rdata;
    wire trap_valid;
    wire [31:0] trap_pc, trap_cause;

    wire [31:0] awaddr, wdata, araddr;
    wire [3:0] wstrb;
    wire awvalid, wvalid, bready, arvalid, rready;
    reg awready = 1'b0, wready = 1'b0, bvalid = 1'b0;
    reg arready = 1'b0, rvalid = 1'b0;
    reg [31:0] rdata = 32'd0;
    reg [1:0] bresp = 2'b00, rresp = 2'b00;

    reg [31:0] rom [0:WORDS-1];
    reg [31:0] dmem [0:WORDS-1];
    reg aw_seen = 1'b0, w_seen = 1'b0;
    reg [31:0] saved_awaddr = 32'd0, saved_wdata = 32'd0;
    reg [3:0] saved_wstrb = 4'd0;
    integer i;
    integer cycles = 0;
    integer retired_count = 0;
    integer stall_cycles = 0;
    integer load_count = 0;
    integer store_count = 0;
    integer have_metrics = 0;
    real cpi_proxy;
    integer file_handle, line_chars, rom_word_count;
    integer sig_file_handle, sig_i;
    reg [31:0] sig_start_addr, sig_end_addr;
    reg [8*256-1:0] line_buffer;
    reg finished = 1'b0;
    reg [8*256-1:0] rom_file;
    reg [8*256-1:0] sig_out_file;
    reg have_sig_start, have_sig_end, have_sig_out;

    riscv_core dut (
        .clk(clk), .resetb(resetb),
        .instr_addr(instr_addr), .instr_rdata(instr_rdata),
        .trap_valid(trap_valid), .trap_pc(trap_pc), .trap_cause(trap_cause),
        .M_AXI_AWADDR(awaddr), .M_AXI_AWVALID(awvalid), .M_AXI_AWREADY(awready),
        .M_AXI_WDATA(wdata), .M_AXI_WSTRB(wstrb), .M_AXI_WVALID(wvalid), .M_AXI_WREADY(wready),
        .M_AXI_BRESP(bresp), .M_AXI_BVALID(bvalid), .M_AXI_BREADY(bready),
        .M_AXI_ARADDR(araddr), .M_AXI_ARVALID(arvalid), .M_AXI_ARREADY(arready),
        .M_AXI_RDATA(rdata), .M_AXI_RRESP(rresp), .M_AXI_RVALID(rvalid), .M_AXI_RREADY(rready)
    );

    always @* begin
        if ((instr_addr[31:18] == 14'd0) && (instr_addr[17:2] < WORDS))
            instr_rdata = rom[instr_addr[17:2]];
        else
            instr_rdata = 32'h00000013; // ADDI x0,x0,0
    end

    always @(posedge clk) begin
        if (!resetb) begin
            awready <= 1'b0;
            wready <= 1'b0;
            arready <= 1'b0;
            bvalid <= 1'b0;
            rvalid <= 1'b0;
            rdata <= 32'd0;
            aw_seen <= 1'b0;
            w_seen <= 1'b0;
            saved_awaddr <= 32'd0;
            saved_wdata <= 32'd0;
            saved_wstrb <= 4'd0;
            cycles <= 0;
            retired_count <= 0;
            stall_cycles <= 0;
            load_count <= 0;
            store_count <= 0;
        end else begin
            cycles <= cycles + 1;
            if (dut.pipe_stall)
                stall_cycles <= stall_cycles + 1;
            // This proxy counts non-NOP execute slots. The benchmark programs
            // contain no architectural NOPs; flush bubbles are therefore excluded.
            if (dut.ex_valid && !dut.pipe_stall && (dut.ex_insn != 32'h00000013)) begin
                retired_count <= retired_count + 1;
                case (dut.ex_insn[6:0])
                    7'b0000011: load_count <= load_count + 1;
                    7'b0100011: store_count <= store_count + 1;
                    default: begin end
                endcase
            end
            // Always-ready request channels. Responses are registered below.
            awready <= 1'b1;
            wready <= 1'b1;
            arready <= 1'b1;

            if (awvalid && awready) begin
                aw_seen <= 1'b1;
                saved_awaddr <= awaddr;
            end
            if (wvalid && wready) begin
                w_seen <= 1'b1;
                saved_wdata <= wdata;
                saved_wstrb <= wstrb;
            end

            if (!bvalid &&
                (aw_seen || (awvalid && awready)) &&
                (w_seen || (wvalid && wready))) begin : commit_write
                reg [31:0] commit_addr;
                reg [31:0] commit_data;
                reg [3:0] commit_strb;
                integer lane;
                commit_addr = (awvalid && awready) ? awaddr : saved_awaddr;
                commit_data = (wvalid && wready) ? wdata : saved_wdata;
                commit_strb = (wvalid && wready) ? wstrb : saved_wstrb;
                if (commit_addr == PASS_ADDR) begin
                    if (commit_data == 32'd1) begin
                        $display("PASS: ELF program wrote the PASS token after %0d cycles.", cycles);
                        finished <= 1'b1;
                    end else begin
                        $display("FAIL: unexpected completion token %08x at %08x", commit_data, commit_addr);
                        $fatal(1);
                    end
                end else begin
                    for (lane = 0; lane < 4; lane = lane + 1)
                        if (commit_strb[lane])
                            dmem[commit_addr[17:2]][lane*8 +: 8] <= commit_data[lane*8 +: 8];
                end
                aw_seen <= 1'b0;
                w_seen <= 1'b0;
                bvalid <= 1'b1;
            end
            if (bvalid && bready)
                bvalid <= 1'b0;

            if (arvalid && arready && !rvalid) begin
                // CoreMark's simulation-only timer reads elapsed RTL cycles.
                // This is deliberately not a calibrated wall-clock timer.
                if (araddr == 32'h20000004)
                    rdata <= cycles;
                else
                    rdata <= dmem[araddr[17:2]];
                rvalid <= 1'b1;
            end
            if (rvalid && rready)
                rvalid <= 1'b0;

            if (trap_valid && !finished) begin
                // riscv-tests uses the standard machine-mode ecall exit ABI:
                // a7=93 and a0=0 means pass; a nonzero a0 is a test failure.
                if ((trap_cause == 32'd11) && (dut.rf[17] == 32'd93)) begin
                    if (dut.rf[10] == 32'd0) begin
                        $display("PASS: public RISC-V test exited successfully after %0d cycles.", cycles);
                        finished <= 1'b1;
                    end else begin
                        $display("FAIL: public RISC-V test exit code=%0d pc=%08x", dut.rf[10], trap_pc);
                        $fatal(1);
                    end
                end else begin
                    $display("FAIL: unexpected core trap pc=%08x cause=%08x", trap_pc, trap_cause);
                    $fatal(1);
                end
            end
        end
    end

    initial begin
        have_metrics = $test$plusargs("METRICS");
        have_sig_start = $value$plusargs("SIG_START=%h", sig_start_addr);
        have_sig_end = $value$plusargs("SIG_END=%h", sig_end_addr);
        have_sig_out = $value$plusargs("SIG_OUT=%s", sig_out_file);
        if ((have_sig_start || have_sig_end || have_sig_out) &&
            !(have_sig_start && have_sig_end && have_sig_out)) begin
            $display("FAIL: SIG_START, SIG_END, and SIG_OUT must be supplied together");
            $fatal(1);
        end
        if (have_sig_start &&
            ((sig_start_addr[1:0] != 2'b00) ||
             (sig_end_addr[1:0] != 2'b00) ||
             (sig_end_addr <= sig_start_addr) ||
             (sig_end_addr > WORDS * 4))) begin
            $display("FAIL: invalid signature bounds start=%08x end=%08x", sig_start_addr, sig_end_addr);
            $fatal(1);
        end

        for (i = 0; i < WORDS; i = i + 1) begin
            rom[i] = 32'h00000013;
            dmem[i] = 32'd0;
        end
        if (!$value$plusargs("ROM=%s", rom_file)) begin
            $display("FAIL: provide +ROM=program.hex");
            $fatal(1);
        end
        $readmemh(rom_file, rom);

        // Mirror the loaded flat image into data memory as well. Count the
        // actual hex words first so zero-initialized BSS remains zero.
        file_handle = $fopen(rom_file, "r");
        if (file_handle == 0) begin
            $display("FAIL: cannot open ROM image %0s", rom_file);
            $fatal(1);
        end
        rom_word_count = 0;
        while (!$feof(file_handle)) begin
            line_chars = $fgets(line_buffer, file_handle);
            if (line_chars > 0)
                rom_word_count = rom_word_count + 1;
        end
        $fclose(file_handle);
        for (i = 0; (i < rom_word_count) && (i < WORDS); i = i + 1)
            dmem[i] = rom[i];

        repeat (5) @(posedge clk);
        resetb = 1'b1;
        wait (finished);
        #1;
        if (have_metrics) begin
            cpi_proxy = (retired_count == 0) ? 0.0 : (1.0 * cycles) / retired_count;
            $display("BENCHMARK-METRICS cycles=%0d executed_non_nop=%0d stall_cycles=%0d loads=%0d stores=%0d CPI_proxy=%0.3f",
                     cycles, retired_count, stall_cycles, load_count, store_count, cpi_proxy);
        end
        #19;
        // Emit the DUT's signature words in the same format as ACT4's Sail
        // reference signature so CI can compare architectural results.
        if (have_sig_start) begin
            sig_file_handle = $fopen(sig_out_file, "w");
            if (sig_file_handle == 0) begin
                $display("FAIL: cannot open signature output %0s", sig_out_file);
                $fatal(1);
            end
            for (sig_i = sig_start_addr >> 2; sig_i < (sig_end_addr >> 2); sig_i = sig_i + 1)
                $fdisplay(sig_file_handle, "%08x", dmem[sig_i]);
            $fclose(sig_file_handle);
            $display("SIGNATURE: wrote %0d words from %08x to %08x",
                     (sig_end_addr - sig_start_addr) >> 2, sig_start_addr, sig_end_addr);
        end
        $finish;
    end

    initial begin
        // Large C workloads such as CoreMark need more cycles than the short
        // hand-written microbenchmarks. Two million cycles at the current clock.
        #20000000;
        if (!finished) begin
            $display("FAIL: ELF execution timeout pc=%08x", dut.pc);
            $fatal(1);
        end
    end
endmodule

`default_nettype wire
