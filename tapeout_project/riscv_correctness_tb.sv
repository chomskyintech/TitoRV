// Directed correctness smoke test for the current tapeout_project/riscv_core.v.
// This tests only the instruction subset implemented by that RTL revision.
`timescale 1ns/1ps
`default_nettype none

module tb_riscv_correctness;
    reg clk = 1'b0;
    reg resetb = 1'b0;
    always #5 clk = ~clk;

    wire [31:0] instr_addr;
    reg  [31:0] instr_rdata;

    wire [31:0] M_AXI_AWADDR;
    wire        M_AXI_AWVALID;
    reg         M_AXI_AWREADY = 1'b1;
    wire [31:0] M_AXI_WDATA;
    wire [3:0]  M_AXI_WSTRB;
    wire        M_AXI_WVALID;
    reg         M_AXI_WREADY = 1'b1;
    reg  [1:0]  M_AXI_BRESP = 2'b00;
    reg         M_AXI_BVALID = 1'b0;
    wire        M_AXI_BREADY;

    wire [31:0] M_AXI_ARADDR;
    wire        M_AXI_ARVALID;
    reg         M_AXI_ARREADY = 1'b1;
    reg  [31:0] M_AXI_RDATA = 32'd0;
    reg  [1:0]  M_AXI_RRESP = 2'b00;
    reg         M_AXI_RVALID = 1'b0;
    wire        M_AXI_RREADY;

    reg [31:0] rom  [0:255];
    reg [31:0] dmem [0:255];

    integer i;
    integer lane;
    reg finished = 1'b0;

    riscv_core dut (
        .clk(clk),
        .resetb(resetb),
        .instr_addr(instr_addr),
        .instr_rdata(instr_rdata),
        .M_AXI_AWADDR(M_AXI_AWADDR),
        .M_AXI_AWVALID(M_AXI_AWVALID),
        .M_AXI_AWREADY(M_AXI_AWREADY),
        .M_AXI_WDATA(M_AXI_WDATA),
        .M_AXI_WSTRB(M_AXI_WSTRB),
        .M_AXI_WVALID(M_AXI_WVALID),
        .M_AXI_WREADY(M_AXI_WREADY),
        .M_AXI_BRESP(M_AXI_BRESP),
        .M_AXI_BVALID(M_AXI_BVALID),
        .M_AXI_BREADY(M_AXI_BREADY),
        .M_AXI_ARADDR(M_AXI_ARADDR),
        .M_AXI_ARVALID(M_AXI_ARVALID),
        .M_AXI_ARREADY(M_AXI_ARREADY),
        .M_AXI_RDATA(M_AXI_RDATA),
        .M_AXI_RRESP(M_AXI_RRESP),
        .M_AXI_RVALID(M_AXI_RVALID),
        .M_AXI_RREADY(M_AXI_RREADY)
    );

    always @* instr_rdata = rom[instr_addr[9:2]];

    // Simple single-outstanding AXI-Lite memory model.
    // The core under test issues AW and W together; both READY signals are
    // held high. Responses remain asserted until their VALID/READY handshake.
    always @(posedge clk) begin
        if (!resetb) begin
            M_AXI_BVALID <= 1'b0;
            M_AXI_RVALID <= 1'b0;
            M_AXI_RDATA  <= 32'd0;
        end else begin
            if (M_AXI_BVALID && M_AXI_BREADY)
                M_AXI_BVALID <= 1'b0;
            else if (M_AXI_AWVALID && M_AXI_AWREADY &&
                     M_AXI_WVALID && M_AXI_WREADY &&
                     !M_AXI_BVALID) begin
                for (lane = 0; lane < 4; lane = lane + 1)
                    if (M_AXI_WSTRB[lane])
                        dmem[M_AXI_AWADDR[9:2]][lane*8 +: 8]
                            <= M_AXI_WDATA[lane*8 +: 8];
                M_AXI_BVALID <= 1'b1;
                M_AXI_BRESP  <= 2'b00;
            end

            if (M_AXI_RVALID && M_AXI_RREADY)
                M_AXI_RVALID <= 1'b0;
            else if (M_AXI_ARVALID && M_AXI_ARREADY && !M_AXI_RVALID) begin
                M_AXI_RDATA  <= dmem[M_AXI_ARADDR[9:2]];
                M_AXI_RRESP  <= 2'b00;
                M_AXI_RVALID <= 1'b1;
            end
        end
    end

    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            rom[i]  = 32'h00000013; // NOP
            dmem[i] = 32'd0;
        end

        // ADDI, ADD, SUB, LUI, SW, LW, and JAL self-loop.
        rom[0]  = 32'h00500093; // addi x1, x0, 5
        rom[1]  = 32'h00A00113; // addi x2, x0, 10
        rom[2]  = 32'h002081B3; // add  x3, x1, x2 => 15
        rom[3]  = 32'h40110233; // sub  x4, x2, x1 => 5
        rom[4]  = 32'h12345337; // lui  x6, 0x12345 => 0x12345000
        rom[5]  = 32'h00302023; // sw   x3, 0(x0)
        rom[6]  = 32'h00002283; // lw   x5, 0(x0) => 15
        rom[7]  = 32'h3FC00413; // addi x8, x0, 1020
        rom[8]  = 32'h05500493; // addi x9, x0, 85 (0x55)
        rom[9]  = 32'h00942023; // sw   x9, 0(x8): completion signature
        rom[10] = 32'h0000006F; // jal  x0, 0

        repeat (5) @(posedge clk);
        resetb = 1'b1;
    end

    // Signature is written to byte address 1020 (word index 255).
    always @(posedge clk) begin
        if (resetb && !finished && dmem[255] == 32'h00000055) begin
            finished = 1'b1;
            #1;
            $display("TitoRV directed correctness test results:");
            $display("x1=%08h x2=%08h x3=%08h x4=%08h", dut.rf[1], dut.rf[2], dut.rf[3], dut.rf[4]);
            $display("x5=%08h x6=%08h x8=%08h x9=%08h", dut.rf[5], dut.rf[6], dut.rf[8], dut.rf[9]);
            $display("mem[0]=%08h signature=%08h", dmem[0], dmem[255]);

            if (dut.rf[1] !== 32'd5 ||
                dut.rf[2] !== 32'd10 ||
                dut.rf[3] !== 32'd15 ||
                dut.rf[4] !== 32'd5 ||
                dut.rf[5] !== 32'd15 ||
                dut.rf[6] !== 32'h12345000 ||
                dut.rf[8] !== 32'd1020 ||
                dut.rf[9] !== 32'd85 ||
                dut.rf[0] !== 32'd0 ||
                dmem[0] !== 32'd15 ||
                dmem[255] !== 32'd85) begin
                $display("FAIL: one or more architectural state checks mismatched.");
                $fatal(1);
            end else begin
                $display("PASS: directed instruction, register, load/store, and x0 checks passed.");
                $finish;
            end
        end
    end

    initial begin
        #10000;
        $display("FAIL: timeout before completion signature was written.");
        $display("PC=%08h AXI state=%0d", dut.pc, dut.axi_state);
        $fatal(1);
    end
endmodule

`default_nettype wire
