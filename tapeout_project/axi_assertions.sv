module axi_assertions
(
    input logic clk,
    input logic resetb,

    input logic AWVALID,
    input logic AWREADY,

    input logic WVALID,
    input logic WREADY,

    input logic BVALID,
    input logic BREADY,

    input logic ARVALID,
    input logic ARREADY,

    input logic RVALID,
    input logic RREADY
);

  //========================================================
  // Assertion counters
  //========================================================

  int aw_pass = 0;
  int aw_fail = 0;

  int w_pass = 0;
  int w_fail = 0;

  int b_pass = 0;
  int b_fail = 0;

  int r_pass = 0;
  int r_fail = 0;


  //========================================================
  // AWVALID must remain HIGH until AWREADY
  //========================================================

  property aw_hold;
    @(posedge clk)
    disable iff(!resetb)
    AWVALID && !AWREADY
    |=> AWVALID;
  endproperty

  assert property(aw_hold)
  begin
    aw_pass++;
  end
  else begin
    aw_fail++;
    $error("ASSERT FAIL: AWVALID dropped before AWREADY");
  end


  //========================================================
  // WVALID must remain HIGH until WREADY
  //========================================================

  property w_hold;
    @(posedge clk)
    disable iff(!resetb)
    WVALID && !WREADY
    |=> WVALID;
  endproperty

  assert property(w_hold)
  begin
    w_pass++;
  end
  else begin
    w_fail++;
    $error("ASSERT FAIL: WVALID dropped before WREADY");
  end


  //========================================================
  // BVALID must remain HIGH while BREADY is LOW
  //========================================================

  property b_hold;
    @(posedge clk)
    disable iff(!resetb)
    BVALID && !BREADY
    |=> BVALID;
  endproperty

  assert property(b_hold)
  begin
    b_pass++;
  end
  else begin
    b_fail++;
    $error("ASSERT FAIL: BVALID dropped before BREADY");
  end


  //========================================================
  // RVALID must remain HIGH while RREADY is LOW
  //========================================================

  property r_hold;
    @(posedge clk)
    disable iff(!resetb)
    RVALID && !RREADY
    |=> RVALID;
  endproperty

  assert property(r_hold)
  begin
    r_pass++;
  end
  else begin
    r_fail++;
    $error("ASSERT FAIL: RVALID dropped before RREADY");
  end


  //========================================================
  // Final assertion report
  //========================================================

  final begin

    $display("");
    $display("==============================================");
    $display("        AXI ASSERTION RESULTS");
    $display("==============================================");

    $display("AWVALID HOLD : PASS=%0d FAIL=%0d",
             aw_pass, aw_fail);

    $display("WVALID HOLD  : PASS=%0d FAIL=%0d",
             w_pass, w_fail);

    $display("BVALID HOLD  : PASS=%0d FAIL=%0d",
             b_pass, b_fail);

    $display("RVALID HOLD  : PASS=%0d FAIL=%0d",
             r_pass, r_fail);

    $display("----------------------------------------------");

    if ((aw_fail == 0) &&
        (w_fail  == 0) &&
        (b_fail  == 0) &&
        (r_fail  == 0))
      $display("        ALL ASSERTIONS PASSED");
    else
      $display("        ASSERTION FAILURES DETECTED");

    $display("==============================================");

  end

endmodule