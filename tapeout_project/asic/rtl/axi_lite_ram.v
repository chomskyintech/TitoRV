`default_nettype none

module axi_lite_ram #(
    parameter ADDR_WIDTH = 8
) (
    input  wire        clk,
    input  wire        resetb,

    input  wire [31:0] S_AXI_AWADDR,
    input  wire        S_AXI_AWVALID,
    output wire        S_AXI_AWREADY,

    input  wire [31:0] S_AXI_WDATA,
    input  wire [3:0]  S_AXI_WSTRB,
    input  wire        S_AXI_WVALID,
    output wire        S_AXI_WREADY,

    output reg  [1:0]  S_AXI_BRESP,
    output reg         S_AXI_BVALID,
    input  wire        S_AXI_BREADY,

    input  wire [31:0] S_AXI_ARADDR,
    input  wire        S_AXI_ARVALID,
    output wire        S_AXI_ARREADY,

    output reg  [31:0] S_AXI_RDATA,
    output reg  [1:0]  S_AXI_RRESP,
    output reg         S_AXI_RVALID,
    input  wire        S_AXI_RREADY
);

localparam WORDS = (1 << ADDR_WIDTH) / 4;
localparam INDEX_BITS = ADDR_WIDTH - 2;

reg [31:0] mem [0:WORDS-1];
reg [31:0] awaddr_q;
reg [31:0] wdata_q;
reg [3:0]  wstrb_q;
reg        aw_pending;
reg        w_pending;

assign S_AXI_AWREADY = !aw_pending && !S_AXI_BVALID;
assign S_AXI_WREADY  = !w_pending  && !S_AXI_BVALID;
assign S_AXI_ARREADY = !S_AXI_RVALID;

wire [INDEX_BITS-1:0] write_index = awaddr_q[ADDR_WIDTH-1:2];
wire [INDEX_BITS-1:0] read_index  = S_AXI_ARADDR[ADDR_WIDTH-1:2];

always @(posedge clk or negedge resetb) begin
    if (!resetb) begin
        awaddr_q   <= 32'd0;
        wdata_q    <= 32'd0;
        wstrb_q    <= 4'd0;
        aw_pending <= 1'b0;
        w_pending  <= 1'b0;
        S_AXI_BRESP  <= 2'b00;
        S_AXI_BVALID <= 1'b0;
        S_AXI_RDATA  <= 32'd0;
        S_AXI_RRESP  <= 2'b00;
        S_AXI_RVALID <= 1'b0;
    end else begin
        if (S_AXI_AWVALID && S_AXI_AWREADY) begin
            awaddr_q   <= S_AXI_AWADDR;
            aw_pending <= 1'b1;
        end

        if (S_AXI_WVALID && S_AXI_WREADY) begin
            wdata_q   <= S_AXI_WDATA;
            wstrb_q   <= S_AXI_WSTRB;
            w_pending <= 1'b1;
        end

        if (aw_pending && w_pending && !S_AXI_BVALID) begin
            if (wstrb_q[0]) mem[write_index][7:0]   <= wdata_q[7:0];
            if (wstrb_q[1]) mem[write_index][15:8]  <= wdata_q[15:8];
            if (wstrb_q[2]) mem[write_index][23:16] <= wdata_q[23:16];
            if (wstrb_q[3]) mem[write_index][31:24] <= wdata_q[31:24];

            aw_pending   <= 1'b0;
            w_pending    <= 1'b0;
            S_AXI_BRESP  <= 2'b00;
            S_AXI_BVALID <= 1'b1;
        end

        if (S_AXI_BVALID && S_AXI_BREADY)
            S_AXI_BVALID <= 1'b0;

        if (S_AXI_ARVALID && S_AXI_ARREADY) begin
            S_AXI_RDATA  <= mem[read_index];
            S_AXI_RRESP  <= 2'b00;
            S_AXI_RVALID <= 1'b1;
        end else if (S_AXI_RVALID && S_AXI_RREADY) begin
            S_AXI_RVALID <= 1'b0;
        end
    end
end

endmodule

`default_nettype wire
