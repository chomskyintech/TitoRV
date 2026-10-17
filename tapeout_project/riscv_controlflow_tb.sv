`timescale 1ns/1ps
`default_nettype none

// Verify taken control-flow instructions squash younger instructions, including
// an illegal instruction that must not raise a trap on the discarded path.
module tb_riscv_controlflow #(parameter integer FLOW_CASE = 0);
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
    reg [31:0] rom [0:31];
    integer i;

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
        if (FLOW_CASE == 0) begin
            rom[0] = 32'h00000463; // beq x0,x0,+8
            rom[1] = 32'hffffffff; // must be squashed
            rom[2] = 32'h00700193; // target: addi x3,x0,7
        end else if (FLOW_CASE == 1) begin
            rom[0] = 32'h0080006f; // jal x0,+8
            rom[1] = 32'hffffffff; // must be squashed
            rom[2] = 32'h00700193; // target: addi x3,x0,7
        end else begin
            rom[0] = 32'h01000093; // addi x1,x0,16
            rom[1] = 32'h00008067; // jalr x0,x1,0
            rom[2] = 32'hffffffff; // must be squashed
            rom[3] = 32'hffffffff; // must be squashed
            rom[4] = 32'h00900213; // target: addi x4,x0,9
        end

        repeat (5) @(posedge clk);
        resetb = 1'b1;

        if (FLOW_CASE == 2)
            wait (dut.rf[4] === 32'd9);
        else
            wait (dut.rf[3] === 32'd7);
        repeat (4) @(posedge clk);
        #1;
        if (trap_valid !== 1'b0) begin
            $display("FAIL: control-flow case %0d trapped on a squashed instruction: pc=%h cause=%h",
                     FLOW_CASE, trap_pc, trap_cause);
            $fatal(1);
        end
        if ((FLOW_CASE == 2 && dut.rf[4] !== 32'd9) ||
            (FLOW_CASE != 2 && dut.rf[3] !== 32'd7)) begin
            $display("FAIL: control-flow case %0d did not reach target", FLOW_CASE);
            $fatal(1);
        end
        $display("PASS: control-flow case %0d squashed wrong-path illegal instructions.", FLOW_CASE);
        $finish;
    end

    initial begin
        #5000;
        $display("FAIL: control-flow case %0d timeout pc=%h", FLOW_CASE, dut.pc);
        $fatal(1);
    end
endmodule

`default_nettype wire
