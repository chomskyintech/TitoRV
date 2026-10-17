`timescale 1ns/1ps
`default_nettype none

module tb_riscv_csr;
    reg clk = 1'b0;
    reg resetb = 1'b0;
    always #5 clk = ~clk;

    wire [31:0] instr_addr;
    reg [31:0] instr_rdata;
    wire trap_valid;
    wire [31:0] trap_pc;
    wire [31:0] trap_cause;
    wire [31:0] awaddr, wdata, araddr;
    wire [3:0] wstrb;
    wire awvalid, wvalid, bready, arvalid, rready;
    wire [1:0] unused_bresp, unused_rresp;
    wire [31:0] unused_wdata;
    wire [3:0] unused_wstrb;

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
        rom[0]  = 32'h02a00293; // addi x5,x0,42
        rom[1]  = csr_insn(12'h340, 5'd5, 3'b001, 5'd1); // csrrw x1,mscratch,x5
        rom[2]  = csr_insn(12'h340, 5'd0, 3'b010, 5'd6); // csrrs x6,mscratch,x0
        rom[3]  = 32'h01000393; // addi x7,x0,16
        rom[4]  = csr_insn(12'h340, 5'd7, 3'b010, 5'd2); // csrrs x2,mscratch,x7
        rom[5]  = csr_insn(12'h340, 5'd7, 3'b011, 5'd3); // csrrc x3,mscratch,x7
        rom[6]  = csr_insn(12'h305, 5'd8, 3'b101, 5'd4); // csrrwi x4,mtvec,8
        rom[7]  = csr_insn(12'h305, 5'd1, 3'b110, 5'd8); // csrrsi x8,mtvec,1
        rom[8]  = csr_insn(12'h305, 5'd1, 3'b111, 5'd9); // csrrci x9,mtvec,1
        rom[9]  = csr_insn(12'h341, 5'd5, 3'b001, 5'd10); // csrrw x10,mepc,x5
        rom[10] = csr_insn(12'h342, 5'd5, 3'b001, 5'd11); // csrrw x11,mcause,x5
        rom[11] = csr_insn(12'h341, 5'd0, 3'b010, 5'd12); // csrrs x12,mepc,x0: read aligned MEPC
        rom[12] = 32'h01300693; // addi x13,x0,19 (base=16, reserved MODE=3)
        rom[13] = csr_insn(12'h305, 5'd13, 3'b001, 5'd14); // mtvec WARL write
        rom[14] = 32'h00100073; // EBREAK terminates test via current diagnostic trap
        repeat (5) @(posedge clk);
        resetb = 1'b1;

        wait (trap_valid === 1'b1);
        #1;
        if (dut.rf[1] !== 32'd0 ||
            dut.rf[6] !== 32'd42 ||
            dut.rf[2] !== 32'd42 ||
            dut.rf[3] !== 32'd58 ||
            dut.csr_mscratch !== 32'd42 ||
            dut.rf[4] !== 32'd0 ||
            dut.rf[8] !== 32'd8 ||
            dut.rf[9] !== 32'd9 ||
            dut.csr_mtvec !== 32'd16 ||
            dut.rf[10] !== 32'd0 ||
            dut.csr_mepc !== 32'd56 ||
            dut.rf[11] !== 32'd0 ||
            dut.rf[12] !== 32'd40 ||
            dut.csr_mcause !== 32'd3 ||
            dut.trap_cause !== 32'd3 ||
            dut.trap_pc !== 32'd56) begin
            $display("FAIL: CSR access mismatch");
            $display("x1=%h x2=%h x3=%h x4=%h x6=%h x8=%h x9=%h", dut.rf[1],dut.rf[2],dut.rf[3],dut.rf[4],dut.rf[6],dut.rf[8],dut.rf[9]);
            $display("mscratch=%h mtvec=%h mepc=%h mcause=%h trap_pc=%h cause=%h", dut.csr_mscratch,dut.csr_mtvec,dut.csr_mepc,dut.csr_mcause,trap_pc,trap_cause);
            $fatal(1);
        end
        $display("PASS: machine CSR read/write/set/clear and immediate forms passed.");
        $finish;
    end

    initial begin
        #5000;
        $display("FAIL: CSR test timeout pc=%h", dut.pc);
        $fatal(1);
    end
endmodule

`default_nettype wire
