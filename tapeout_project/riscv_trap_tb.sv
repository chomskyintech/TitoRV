`timescale 1ns/1ps
`default_nettype none

module tb_riscv_trap #(parameter integer TRAP_CASE = 0);
    reg clk = 1'b0;
    reg resetb = 1'b0;
    always #5 clk = ~clk;

    wire [31:0] instr_addr;
    wire trap_valid;
    wire [31:0] trap_pc, trap_cause;
    reg [31:0] instr_rdata;
    wire [31:0] awaddr, wdata, araddr;
    wire [3:0] wstrb;
    wire awvalid, wvalid, bready, arvalid, rready;
    reg awready = 1'b0, wready = 1'b0, bvalid = 1'b0;
    reg arready = 1'b0, rvalid = 1'b0;
    reg [31:0] rdata = 32'd0;
    reg [1:0] bresp = 2'b00, rresp = 2'b00;
    reg [31:0] rom [0:31];
    integer i;

    function [31:0] csr_insn(input [11:0] csr, input [4:0] rs1_or_zimm,
                              input [2:0] f3, input [4:0] rd);
        csr_insn = {csr, rs1_or_zimm, f3, rd, 7'b1110011};
    endfunction

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

    always @* instr_rdata = rom[instr_addr[6:2]];

    initial begin
        for (i = 0; i < 32; i = i + 1) rom[i] = 32'h00000013;
        rom[0]  = 32'h04000093; // addi x1,x0,64: trap handler at byte address 64
        rom[1]  = csr_insn(12'h305, 5'd1, 3'b001, 5'd0); // csrrw x0,mtvec,x1
        rom[2]  = csr_insn(12'h300, 5'd8, 3'b110, 5'd0); // csrrsi x0,mstatus,8: MIE=1
        rom[3]  = 32'h00900113; // addi x2,x0,9
        if (TRAP_CASE == 0)
            rom[4] = 32'h00100073; // EBREAK at PC=16, cause 3
        else if (TRAP_CASE == 1)
            rom[4] = 32'h00000073; // ECALL at PC=16, cause 11
        else
            rom[4] = 32'hffffffff; // illegal instruction at PC=16, cause 2
        rom[5]  = 32'h00700193; // resume target PC=20: addi x3,x0,7
        rom[6]  = 32'h0000006f; // stop loop
        rom[16] = 32'h01400213; // handler: addi x4,x0,20
        rom[17] = csr_insn(12'h341, 5'd4, 3'b001, 5'd0); // csrrw x0,mepc,x4
        rom[18] = 32'h30200073; // mret

        repeat (5) @(posedge clk);
        resetb = 1'b1;

        wait (dut.rf[3] === 32'd7);
        #1;
        if (trap_valid !== 1'b1 ||
            trap_pc !== 32'd16 ||
            trap_cause !== ((TRAP_CASE == 0) ? 32'd3 : ((TRAP_CASE == 1) ? 32'd11 : 32'd2)) ||
            dut.csr_mcause !== ((TRAP_CASE == 0) ? 32'd3 : ((TRAP_CASE == 1) ? 32'd11 : 32'd2)) ||
            dut.csr_mepc !== 32'd20 ||
            dut.csr_mtvec !== 32'd64 ||
            dut.rf[2] !== 32'd9 ||
            dut.rf[4] !== 32'd20 ||
            dut.csr_mstatus[3] !== 1'b1 ||
            dut.csr_mstatus[7] !== 1'b1 ||
            dut.csr_mstatus[12:11] !== 2'b11) begin
            $display("FAIL: trap entry/MRET mismatch");
            $display("trap_pc=%h cause=%h mtvec=%h mepc=%h mcause=%h mstatus=%h x2=%h x3=%h x4=%h pc=%h",
                     trap_pc, trap_cause, dut.csr_mtvec, dut.csr_mepc,
                     dut.csr_mcause, dut.csr_mstatus, dut.rf[2], dut.rf[3],
                     dut.rf[4], dut.pc);
            $fatal(1);
        end
        $display("PASS: trap case %0d entry, CSR state, handler, and MRET return passed.", TRAP_CASE);
        $finish;
    end

    initial begin
        #5000;
        $display("FAIL: trap regression timeout pc=%h x3=%h", dut.pc, dut.rf[3]);
        $fatal(1);
    end
endmodule

`default_nettype wire
