`timescale 1ns/1ps
module tb_smoke;
  reg clk = 0;
  reg resetb = 0;
  wire [7:0] debug_out;
  wire pass;

  tapeout_top dut(
    .clk(clk),
    .resetb(resetb),
    .debug_out(debug_out),
    .pass(pass)
  );

  always #5 clk = ~clk;

  initial begin
    #40 resetb = 1;
    repeat (200) @(posedge clk);

    $display("debug_out=%0d pass=%0d pc=%h x4=%0d x5=%0d",
             debug_out, pass, dut.debug_pc, dut.debug_x4, dut.debug_x5);

    if (!pass)
      $fatal(1, "Smoke test failed");

    $finish;
  end
endmodule
