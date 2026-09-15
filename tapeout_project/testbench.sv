`include "axi_pkg.sv"
`include "axi_assertions.sv"

import uvm_pkg::*;
import axi_pkg::*;

`include "uvm_macros.svh"


module tb_top;


    logic clk;

    logic resetb;



    //----------------------------------
    // Clock generation
    //----------------------------------

    initial begin

        clk = 0;

        forever #5 clk = ~clk;

    end



    //----------------------------------
    // Reset generation
    //----------------------------------

    initial begin

        resetb = 0;

        #50;

        resetb = 1;

    end




    //----------------------------------
    // AXI interface
    //----------------------------------

  axi_if axi(clk);



    //----------------------------------
    // DUT
    //----------------------------------

    riscv_system_top dut (

      .clk       (clk),
      .resetb    (resetb),


        // Write address channel

        .M_AXI_AWADDR  (axi.AWADDR),
        .M_AXI_AWVALID (axi.AWVALID),
        .M_AXI_AWREADY (axi.AWREADY),



        // Write data channel

        .M_AXI_WDATA   (axi.WDATA),
        .M_AXI_WSTRB   (axi.WSTRB),
        .M_AXI_WVALID  (axi.WVALID),
        .M_AXI_WREADY  (axi.WREADY),



        // Write response

        .M_AXI_BRESP   (axi.BRESP),
        .M_AXI_BVALID  (axi.BVALID),
        .M_AXI_BREADY  (axi.BREADY),



        // Read address

        .M_AXI_ARADDR  (axi.ARADDR),
        .M_AXI_ARVALID (axi.ARVALID),
        .M_AXI_ARREADY (axi.ARREADY),



        // Read data

        .M_AXI_RDATA   (axi.RDATA),
        .M_AXI_RRESP   (axi.RRESP),
        .M_AXI_RVALID  (axi.RVALID),
        .M_AXI_RREADY  (axi.RREADY)

    );

axi_assertions assertions
(

.clk(clk),
.resetb(resetb),


.AWVALID(axi.AWVALID),
.AWREADY(axi.AWREADY),


.WVALID(axi.WVALID),
.WREADY(axi.WREADY),


.BVALID(axi.BVALID),
.BREADY(axi.BREADY),


.ARVALID(axi.ARVALID),
.ARREADY(axi.ARREADY),


.RVALID(axi.RVALID),
.RREADY(axi.RREADY)

);




    //----------------------------------
    // Give interface to UVM
    //----------------------------------

    initial begin


        uvm_config_db #(virtual axi_if)::set(

            null,

            "*",

            "vif",

            axi

        );



        run_test("axi_base_test");


    end

 //----------------------------------
// Simulation termination
//----------------------------------

initial begin

 

    #1000ns;

$display("======================================");
$display("TIMEOUT TEST");
$display("x1 = %h", dut.cpu.rf[1]);
$display("x2 = %h", dut.cpu.rf[2]);
$display("x3 = %h", dut.cpu.rf[3]);
$display("x4 = %h", dut.cpu.rf[4]);
$display("x5 = %h", dut.cpu.rf[5]);
$display("AXI STATE = %0d", dut.cpu.axi_state);
$display("PC = %h", dut.cpu.pc);
$display("======================================");

$finish;

end

always @(posedge clk) begin
    if (resetb) begin
        $display(
            "AXI DEBUG T=%0t STATE=%0d | ARVALID=%b ARREADY=%b ARADDR=%h | RVALID=%b RREADY=%b RDATA=%h",
            $time,
            dut.cpu.axi_state,
            axi.ARVALID,
            axi.ARREADY,
            axi.ARADDR,
            axi.RVALID,
            axi.RREADY,
            axi.RDATA
        );
    end
end
  
//----------------------------------
// Waveform dump for EPWave
//----------------------------------
initial begin
    $dumpfile("dump.vcd");

    // Dump AXI interface
    $dumpvars(0, axi);

    // Dump CPU internals
    $dumpvars(0, dut.cpu);
end
endmodule