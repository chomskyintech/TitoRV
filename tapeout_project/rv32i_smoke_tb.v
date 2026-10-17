`timescale 1ns/1ps
`default_nettype none

module rv32i_smoke_tb;
    reg clk = 1'b0;
    reg resetb = 1'b0;
    wire [31:0] instr_addr;
    reg [31:0] instr_rdata;

    wire [31:0] awaddr, wdata, araddr;
    wire [3:0] wstrb;
    wire awvalid, wvalid, bready, arvalid, rready;
    wire [1:0] bresp, rresp;
    reg awready = 1'b0, wready = 1'b0, bvalid = 1'b0;
    reg arready = 1'b0, rvalid = 1'b0;
    reg [31:0] rdata = 32'b0;

    reg [31:0] rom [0:63];
    integer i;
    integer cycles;

    always #5 clk = ~clk;

    function [31:0] addi;
        input [4:0] rd, rs1;
        input integer imm;
        begin addi = {imm[11:0], rs1, 3'b000, rd, 7'b0010011}; end
    endfunction

    function [31:0] arith_r;
        input [4:0] rd, rs1, rs2;
        input [2:0] funct3;
        input [6:0] funct7;
        begin arith_r = {funct7, rs2, rs1, funct3, rd, 7'b0110011}; end
    endfunction

    function [31:0] lui;
        input [4:0] rd;
        input [19:0] imm;
        begin lui = {imm, rd, 7'b0110111}; end
    endfunction

    always @* begin
        if (instr_addr[1:0] != 2'b00)
            instr_rdata = 32'h00000013;
        else
            instr_rdata = rom[instr_addr[7:2]];
    end

    riscv_core dut (
        .clk(clk), .resetb(resetb),
        .instr_addr(instr_addr), .instr_rdata(instr_rdata),
        .M_AXI_AWADDR(awaddr), .M_AXI_AWVALID(awvalid), .M_AXI_AWREADY(awready),
        .M_AXI_WDATA(wdata), .M_AXI_WSTRB(wstrb), .M_AXI_WVALID(wvalid), .M_AXI_WREADY(wready),
        .M_AXI_BRESP(bresp), .M_AXI_BVALID(bvalid), .M_AXI_BREADY(bready),
        .M_AXI_ARADDR(araddr), .M_AXI_ARVALID(arvalid), .M_AXI_ARREADY(arready),
        .M_AXI_RDATA(rdata), .M_AXI_RRESP(rresp), .M_AXI_RVALID(rvalid), .M_AXI_RREADY(rready)
    );

    assign bresp = 2'b00;
    assign rresp = 2'b00;

    initial begin
        for (i = 0; i < 64; i = i + 1) rom[i] = 32'h00000013;
        rom[0] = addi(5'd1, 5'd0, 5);
        rom[1] = addi(5'd2, 5'd0, 10);
        rom[2] = arith_r(5'd3, 5'd1, 5'd2, 3'b000, 7'b0000000); // ADD
        rom[3] = arith_r(5'd4, 5'd2, 5'd1, 3'b000, 7'b0100000); // SUB
        rom[4] = lui(5'd5, 20'h12345);

        repeat (5) @(posedge clk);
        resetb <= 1'b1;
        repeat (80) @(posedge clk);

        if (dut.rf[0] !== 32'd0) $fatal(1, "x0 changed: %h", dut.rf[0]);
        if (dut.rf[1] !== 32'd5) $fatal(1, "ADDI x1 failed: %h", dut.rf[1]);
        if (dut.rf[2] !== 32'd10) $fatal(1, "ADDI x2 failed: %h", dut.rf[2]);
        if (dut.rf[3] !== 32'd15) $fatal(1, "ADD x3 failed: %h", dut.rf[3]);
        if (dut.rf[4] !== 32'd5) $fatal(1, "SUB x4 failed: %h", dut.rf[4]);
        if (dut.rf[5] !== 32'h12345000) $fatal(1, "LUI x5 failed: %h", dut.rf[5]);

        $display("RV32I BASELINE SMOKE PASS");
        $finish;
    end

    initial begin
        repeat (200) @(posedge clk);
        $fatal(1, "Simulation timeout");
    end
endmodule

`default_nettype wire
