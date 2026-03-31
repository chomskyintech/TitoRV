// Code your testbench here
// or browse Examples
`timescale 1ns/1ps
`default_nettype none

module tb_riscv_core();

    reg clk;
    reg resetb;
    reg stall;

    reg  timer_irq, sw_irq, ext_irq;

    reg  [31:0] imem_rdata;
    reg  imem_valid;
    wire [31:0] imem_addr;
    wire imem_ready;

    reg  [31:0] dmem_rdata;
    reg  dmem_rvalid;
    wire [31:0] dmem_raddr;
    wire [31:0] dmem_wdata;
    wire [31:0] dmem_waddr;
    wire [3:0]  dmem_wstrb;
    wire        dmem_rready;
    wire        dmem_wready;

    // Instantiate the core
    riscv_core uut (
        .clk(clk),
        .resetb(resetb),
        .stall(stall),
        .timer_irq(timer_irq),
        .sw_irq(sw_irq),
        .ext_irq(ext_irq),
        .imem_valid(imem_valid),
        .imem_rdata(imem_rdata),
        .imem_addr(imem_addr),
        .imem_ready(imem_ready),
        .dmem_rvalid(dmem_rvalid),
        .dmem_rdata(dmem_rdata),
        .dmem_raddr(dmem_raddr),
        .dmem_wdata(dmem_wdata),
        .dmem_waddr(dmem_waddr),
        .dmem_wstrb(dmem_wstrb),
        .dmem_rready(dmem_rready),
        .dmem_wready(dmem_wready)
    );

    // Clock
    initial clk = 0;
    always #5 clk = ~clk;

    // ---- Mock memory interface ----
    assign dmem_rready = 1;  // Data read always ready
    assign dmem_wready = 1;  // Data write always ready

    // Provide some dummy data for reads
    always @(posedge clk) begin
        if (dmem_rvalid) begin
            dmem_rdata <= 32'hDEADBEEF;  // Example dummy data
        end
    end

    // Monitor writes
    always @(posedge clk) begin
        if (dmem_wready && |dmem_wstrb) begin
            $display("Write: addr=%h data=%h strb=%b", dmem_waddr, dmem_wdata, dmem_wstrb);
        end
    end

    // ---- Test sequence ----
    initial begin
         $dumpfile("dump.vcd");   // VCD filename
    $dumpvars(0, tb_riscv_core); // Dump all signals in the testbench and instantiated modules
        // Initialize signals
        resetb = 0;
        stall = 0;
        timer_irq = 0; sw_irq = 0; ext_irq = 0;
        imem_rdata = 32'h00000013; // NOP
        imem_valid = 1;
        dmem_rvalid = 0;

        // Apply reset
        #20 resetb = 1;

        // Feed a few instructions
        #10 imem_rdata = 32'b00010010001101000101000010110111; // LUI x1,0x12345
        #10 imem_rdata = 32'b00000000010100001000000110010011; // ADDI x3,x1,5
        #10 imem_rdata = 32'b00000000001100001000001010110011; // ADD x4,x1,x3
        #10 imem_rdata = 32'b00000000001100001001001010110011; // OR x5,x1,x3

        // Dummy data memory read
        #10 dmem_rvalid = 1;
        #10 dmem_rvalid = 0;

        // Finish simulation
        #50;
        $display("Simulation finished");
        $finish;
    end

endmodule