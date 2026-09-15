import uvm_pkg::*;
`include "uvm_macros.svh"

module tb_top;

    logic clk;

    always #5 clk = ~clk;

    axi_if axi(clk);

    initial begin
        clk = 0;
    end

endmodule