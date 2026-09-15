`default_nettype none

module riscv_core (
    input  wire        clk,
    input  wire        resetb,

    output wire [31:0] instr_addr,
    input  wire [31:0] instr_rdata,

    output reg  [31:0] M_AXI_AWADDR,
    output reg         M_AXI_AWVALID,
    input  wire        M_AXI_AWREADY,

    output reg  [31:0] M_AXI_WDATA,
    output reg  [3:0]  M_AXI_WSTRB,
    output reg         M_AXI_WVALID,
    input  wire        M_AXI_WREADY,

    input  wire [1:0]  M_AXI_BRESP,
    input  wire        M_AXI_BVALID,
    output reg         M_AXI_BREADY,

    output reg  [31:0] M_AXI_ARADDR,
    output reg         M_AXI_ARVALID,
    input  wire        M_AXI_ARREADY,

    input  wire [31:0] M_AXI_RDATA,
    input  wire [1:0]  M_AXI_RRESP,
    input  wire        M_AXI_RVALID,
    output reg         M_AXI_RREADY,

    output wire [31:0] debug_pc,
    output wire [31:0] debug_x4,
    output wire [31:0] debug_x5
);

localparam [31:0] RESET_PC = 32'h0000_0000;
localparam [31:0] NOP      = 32'h0000_0013;

localparam [6:0] OP_LUI    = 7'b0110111;
localparam [6:0] OP_JAL    = 7'b1101111;
localparam [6:0] OP_BRANCH = 7'b1100011;
localparam [6:0] OP_LOAD   = 7'b0000011;
localparam [6:0] OP_STORE  = 7'b0100011;
localparam [6:0] OP_ARITHI = 7'b0010011;
localparam [6:0] OP_ARITHR = 7'b0110011;

localparam [2:0] AXI_IDLE  = 3'd0;
localparam [2:0] AXI_WADDR = 3'd1;
localparam [2:0] AXI_WRESP = 3'd2;
localparam [2:0] AXI_RADDR = 3'd3;
localparam [2:0] AXI_RDATA = 3'd4;

reg [31:0] rf [0:31];
reg [31:0] pc;
reg [31:0] if_pc;
reg [31:0] if_insn;
reg [31:0] ex_pc;
reg [31:0] ex_insn;
reg        ex_valid;

reg [2:0] axi_state;
reg       aw_done;
reg       w_done;
reg [4:0] axi_rd;

wire pipe_stall = (axi_state != AXI_IDLE);

wire [6:0] opcode = ex_insn[6:0];
wire [2:0] funct3 = ex_insn[14:12];
wire [6:0] funct7 = ex_insn[31:25];
wire [4:0] rs1    = ex_insn[19:15];
wire [4:0] rs2    = ex_insn[24:20];
wire [4:0] rd     = ex_insn[11:7];

wire [31:0] rs1_data = (rs1 == 5'd0) ? 32'd0 : rf[rs1];
wire [31:0] rs2_data = (rs2 == 5'd0) ? 32'd0 : rf[rs2];

wire [31:0] imm_i = {{20{ex_insn[31]}}, ex_insn[31:20]};
wire [31:0] imm_s = {{20{ex_insn[31]}}, ex_insn[31:25], ex_insn[11:7]};
wire [31:0] imm_b = {{19{ex_insn[31]}}, ex_insn[31], ex_insn[7],
                     ex_insn[30:25], ex_insn[11:8], 1'b0};
wire [31:0] imm_u = {ex_insn[31:12], 12'b0};
wire [31:0] imm_j = {{11{ex_insn[31]}}, ex_insn[31], ex_insn[19:12],
                     ex_insn[20], ex_insn[30:21], 1'b0};

reg [31:0] alu_out;
always @* begin
    alu_out = 32'd0;
    case (opcode)
        OP_ARITHI: begin
            case (funct3)
                3'b000: alu_out = rs1_data + imm_i;
                default: alu_out = rs1_data + imm_i;
            endcase
        end
        OP_ARITHR: begin
            case (funct3)
                3'b000: alu_out = (funct7 == 7'b0100000) ?
                                  (rs1_data - rs2_data) :
                                  (rs1_data + rs2_data);
                default: alu_out = rs1_data + rs2_data;
            endcase
        end
        OP_LOAD:  alu_out = rs1_data + imm_i;
        OP_STORE: alu_out = rs1_data + imm_s;
        OP_LUI:   alu_out = imm_u;
        default:  alu_out = 32'd0;
    endcase
end

assign instr_addr = pc;
assign debug_pc   = pc;
assign debug_x4   = rf[4];
assign debug_x5   = rf[5];

wire ex_is_load  = ex_valid && (opcode == OP_LOAD);
wire ex_is_store = ex_valid && (opcode == OP_STORE);
wire ex_is_mem   = ex_is_load || ex_is_store;

integer i;
always @(posedge clk or negedge resetb) begin
    if (!resetb) begin
        pc       <= RESET_PC;
        if_pc    <= 32'd0;
        if_insn  <= NOP;
        ex_pc    <= 32'd0;
        ex_insn  <= NOP;
        ex_valid <= 1'b0;

        axi_state <= AXI_IDLE;
        axi_rd    <= 5'd0;
        aw_done   <= 1'b0;
        w_done    <= 1'b0;

        M_AXI_AWADDR  <= 32'd0;
        M_AXI_AWVALID <= 1'b0;
        M_AXI_WDATA   <= 32'd0;
        M_AXI_WSTRB   <= 4'd0;
        M_AXI_WVALID  <= 1'b0;
        M_AXI_BREADY  <= 1'b0;
        M_AXI_ARADDR  <= 32'd0;
        M_AXI_ARVALID <= 1'b0;
        M_AXI_RREADY  <= 1'b0;

        for (i = 0; i < 32; i = i + 1)
            rf[i] <= 32'd0;
    end else begin
        // x0 is architecturally hard-wired to zero.
        rf[0] <= 32'd0;

        // -----------------------------------------------------
        // AXI-Lite master state machine
        // -----------------------------------------------------
        case (axi_state)
            AXI_IDLE: begin
                M_AXI_AWVALID <= 1'b0;
                M_AXI_WVALID  <= 1'b0;
                M_AXI_BREADY  <= 1'b0;
                M_AXI_ARVALID <= 1'b0;
                M_AXI_RREADY  <= 1'b0;
            end

            AXI_WADDR: begin
                if (M_AXI_AWVALID && M_AXI_AWREADY) begin
                    M_AXI_AWVALID <= 1'b0;
                    aw_done       <= 1'b1;
                end

                if (M_AXI_WVALID && M_AXI_WREADY) begin
                    M_AXI_WVALID <= 1'b0;
                    w_done       <= 1'b1;
                end

                if ((aw_done || (M_AXI_AWVALID && M_AXI_AWREADY)) &&
                    (w_done  || (M_AXI_WVALID  && M_AXI_WREADY))) begin
                    M_AXI_BREADY <= 1'b1;
                    axi_state    <= AXI_WRESP;
                end
            end

            AXI_WRESP: begin
                M_AXI_BREADY <= 1'b1;
                if (M_AXI_BVALID && M_AXI_BREADY) begin
                    M_AXI_BREADY <= 1'b0;
                    aw_done      <= 1'b0;
                    w_done       <= 1'b0;
                    axi_state    <= AXI_IDLE;
                end
            end

            AXI_RADDR: begin
                if (M_AXI_ARVALID && M_AXI_ARREADY) begin
                    M_AXI_ARVALID <= 1'b0;
                    M_AXI_RREADY  <= 1'b1;
                    axi_state     <= AXI_RDATA;
                end
            end

            AXI_RDATA: begin
                M_AXI_RREADY <= 1'b1;
                if (M_AXI_RVALID && M_AXI_RREADY) begin
                    if (axi_rd != 5'd0)
                        rf[axi_rd] <= M_AXI_RDATA;
                    M_AXI_RREADY <= 1'b0;
                    axi_state    <= AXI_IDLE;
                end
            end

            default: axi_state <= AXI_IDLE;
        endcase

        // -----------------------------------------------------
        // Pipeline and execution
        // -----------------------------------------------------
        if (!pipe_stall) begin
            // A memory instruction starts the AXI transaction without
            // advancing the pipeline. This prevents the instruction from
            // being issued twice and preserves the younger IF instruction.
            if (ex_is_mem) begin
                ex_valid <= 1'b0;

                if (ex_is_load) begin
                    M_AXI_ARADDR  <= alu_out;
                    M_AXI_ARVALID <= 1'b1;
                    axi_rd        <= rd;
                    axi_state     <= AXI_RADDR;
                end else begin
                    M_AXI_AWADDR  <= alu_out;
                    M_AXI_AWVALID <= 1'b1;
                    M_AXI_WDATA   <= rs2_data;
                    M_AXI_WSTRB   <= 4'b1111;
                    M_AXI_WVALID  <= 1'b1;
                    aw_done       <= 1'b0;
                    w_done        <= 1'b0;
                    axi_state     <= AXI_WADDR;
                end
            end else begin
                // Fetch and advance the two pipeline registers.
                if_pc    <= pc;
                if_insn  <= instr_rdata;
                ex_pc    <= if_pc;
                ex_insn  <= if_insn;
                ex_valid <= 1'b1;
                pc       <= pc + 32'd4;

                if (ex_valid) begin
                    case (opcode)
                        OP_LUI: begin
                            if (rd != 5'd0)
                                rf[rd] <= alu_out;
                        end

                        OP_ARITHI: begin
                            if (rd != 5'd0)
                                rf[rd] <= alu_out;
                        end

                        OP_ARITHR: begin
                            if (rd != 5'd0)
                                rf[rd] <= alu_out;
                        end

                        OP_JAL: begin
                            if (rd != 5'd0)
                                rf[rd] <= ex_pc + 32'd4;
                            pc       <= ex_pc + imm_j;
                            if_insn  <= NOP;
                            ex_valid <= 1'b0;
                        end

                        OP_BRANCH: begin
                            if ((funct3 == 3'b000) && (rs1_data == rs2_data)) begin
                                pc       <= ex_pc + imm_b;
                                if_insn  <= NOP;
                                ex_valid <= 1'b0;
                            end
                        end

                        default: begin
                            // Unsupported instructions are treated as NOPs.
                        end
                    endcase
                end
            end
        end
    end
end

// Responses are currently consumed but not trapped. Keep the inputs used
// explicitly so lint does not interpret them as accidental omissions.
wire _unused_ok = &{1'b0, M_AXI_BRESP, M_AXI_RRESP};

endmodule

`default_nettype wire
