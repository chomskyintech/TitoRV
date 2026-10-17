`timescale 1ns/1ps
`default_nettype none

// Generic flat-binary execution harness. The program is linked at address 0
// and converted to 32-bit little-endian words for $readmemh. A word store of
// 1 to 0x20000000 is the harness-specific PASS convention; this is not yet
// the official RISC-V ACT4 RVMODEL_HALT_PASS protocol.
module tb_riscv_elf;
    localparam integer WORDS = 16384;
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
    reg finished = 1'b0;
    reg [8*256-1:0] rom_file;

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
        if ((instr_addr[31:16] == 16'd0) && (instr_addr[15:2] < WORDS))
            instr_rdata = rom[instr_addr[15:2]];
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
        end else begin
            cycles <= cycles + 1;
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
                            dmem[commit_addr[15:2]][lane*8 +: 8] <= commit_data[lane*8 +: 8];
                end
                aw_seen <= 1'b0;
                w_seen <= 1'b0;
                bvalid <= 1'b1;
            end
            if (bvalid && bready)
                bvalid <= 1'b0;

            if (arvalid && arready && !rvalid) begin
                rdata <= dmem[araddr[15:2]];
                rvalid <= 1'b1;
            end
            if (rvalid && rready)
                rvalid <= 1'b0;

            if (trap_valid) begin
                $display("FAIL: core reported trap pc=%08x cause=%08x", trap_pc, trap_cause);
                $fatal(1);
            end
        end
    end

    initial begin
        for (i = 0; i < WORDS; i = i + 1) begin
            rom[i] = 32'h00000013;
            dmem[i] = 32'd0;
        end
        if (!$value$plusargs("ROM=%s", rom_file)) begin
            $display("FAIL: provide +ROM=program.hex");
            $fatal(1);
        end
        $readmemh(rom_file, rom);
        repeat (5) @(posedge clk);
        resetb = 1'b1;
        wait (finished);
        #20;
        $finish;
    end

    initial begin
        #200000;
        if (!finished) begin
            $display("FAIL: ELF execution timeout pc=%08x", dut.pc);
            $fatal(1);
        end
    end
endmodule

`default_nettype wire
