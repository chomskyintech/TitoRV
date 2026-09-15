`default_nettype none

module tapeout_top (
    input  wire       clk,
    input  wire       resetb,
    output wire [7:0] debug_out,
    output wire       pass
);

wire [31:0] awaddr;
wire        awvalid;
wire        awready;
wire [31:0] wdata;
wire [3:0]  wstrb;
wire        wvalid;
wire        wready;
wire [1:0]  bresp;
wire        bvalid;
wire        bready;
wire [31:0] araddr;
wire        arvalid;
wire        arready;
wire [31:0] rdata;
wire [1:0]  rresp;
wire        rvalid;
wire        rready;
wire [31:0] debug_pc;
wire [31:0] debug_x4;
wire [31:0] debug_x5;

riscv_system_top system (
    .clk(clk),
    .resetb(resetb),
    .M_AXI_AWADDR(awaddr),
    .M_AXI_AWVALID(awvalid),
    .M_AXI_AWREADY(awready),
    .M_AXI_WDATA(wdata),
    .M_AXI_WSTRB(wstrb),
    .M_AXI_WVALID(wvalid),
    .M_AXI_WREADY(wready),
    .M_AXI_BRESP(bresp),
    .M_AXI_BVALID(bvalid),
    .M_AXI_BREADY(bready),
    .M_AXI_ARADDR(araddr),
    .M_AXI_ARVALID(arvalid),
    .M_AXI_ARREADY(arready),
    .M_AXI_RDATA(rdata),
    .M_AXI_RRESP(rresp),
    .M_AXI_RVALID(rvalid),
    .M_AXI_RREADY(rready),
    .debug_pc(debug_pc),
    .debug_x4(debug_x4),
    .debug_x5(debug_x5)
);

axi_lite_ram #(.ADDR_WIDTH(8)) data_ram (
    .clk(clk),
    .resetb(resetb),
    .S_AXI_AWADDR(awaddr),
    .S_AXI_AWVALID(awvalid),
    .S_AXI_AWREADY(awready),
    .S_AXI_WDATA(wdata),
    .S_AXI_WSTRB(wstrb),
    .S_AXI_WVALID(wvalid),
    .S_AXI_WREADY(wready),
    .S_AXI_BRESP(bresp),
    .S_AXI_BVALID(bvalid),
    .S_AXI_BREADY(bready),
    .S_AXI_ARADDR(araddr),
    .S_AXI_ARVALID(arvalid),
    .S_AXI_ARREADY(arready),
    .S_AXI_RDATA(rdata),
    .S_AXI_RRESP(rresp),
    .S_AXI_RVALID(rvalid),
    .S_AXI_RREADY(rready)
);

assign debug_out = debug_x4[7:0];
assign pass      = (debug_x4 == 32'd15) && (debug_x5 == 32'd10);

// Retain PC for waveform/debug visibility in simulation and synthesis reports.
wire _unused_pc = ^debug_pc;

endmodule

`default_nettype wire
