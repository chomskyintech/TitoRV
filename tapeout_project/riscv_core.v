`default_nettype none
`timescale 1ns/1ps

module riscv_core
(
    input  wire        clk,
    input  wire        resetb,

    // ============================================================
    // Instruction interface
    // ============================================================
    output reg  [31:0] instr_addr,
    input  wire [31:0] instr_rdata,

    // ============================================================
    // AXI-Lite Write Address
    // ============================================================
    output reg [31:0] M_AXI_AWADDR,
    output reg        M_AXI_AWVALID,
    input  wire        M_AXI_AWREADY,

    // ============================================================
    // AXI-Lite Write Data
    // ============================================================
    output reg [31:0] M_AXI_WDATA,
    output reg [3:0]  M_AXI_WSTRB,
    output reg        M_AXI_WVALID,
    input  wire        M_AXI_WREADY,

    // ============================================================
    // AXI-Lite Write Response
    // ============================================================
    input  wire [1:0] M_AXI_BRESP,
    input  wire        M_AXI_BVALID,
    output reg         M_AXI_BREADY,

    // ============================================================
    // AXI-Lite Read Address
    // ============================================================
    output reg [31:0] M_AXI_ARADDR,
    output reg        M_AXI_ARVALID,
    input  wire        M_AXI_ARREADY,

    // ============================================================
    // AXI-Lite Read Data
    // ============================================================
    input  wire [31:0] M_AXI_RDATA,
    input  wire [1:0]  M_AXI_RRESP,
    input  wire        M_AXI_RVALID,
    output reg         M_AXI_RREADY
);

localparam RESET_PC = 32'h0000_0000;

// ============================================================
// RISC-V Opcodes
// ============================================================

localparam OP_LUI    = 7'b0110111;
localparam OP_JAL    = 7'b1101111;
localparam OP_BRANCH = 7'b1100011;
localparam OP_LOAD   = 7'b0000011;
localparam OP_STORE  = 7'b0100011;
localparam OP_ARITHI = 7'b0010011;
localparam OP_ARITHR = 7'b0110011;

// ============================================================
// Register File
// ============================================================

reg [31:0] rf [31:0];

// ============================================================
// Program Counter
// ============================================================

reg [31:0] pc;

// ============================================================
// Pipeline Registers
// ============================================================

// IF -> ID
reg [31:0] if_pc;
reg [31:0] if_insn;

// ID -> EX
reg [31:0] ex_pc;
reg [31:0] ex_insn;

// Indicates whether ex_insn contains a valid instruction
reg        ex_valid;

// ============================================================
// AXI State Machine
// ============================================================

localparam AXI_IDLE  = 3'd0;
localparam AXI_WADDR = 3'd1;
localparam AXI_WDATA = 3'd2;
localparam AXI_WRESP = 3'd3;
localparam AXI_RADDR = 3'd4;
localparam AXI_RDATA = 3'd5;

reg [2:0] axi_state;
reg w_done;
reg aw_done;


// Register destination for an outstanding load
reg [4:0] axi_rd;

// ============================================================
// Pipeline stall
// ============================================================

wire pipe_stall = (axi_state != AXI_IDLE);

// ============================================================
// Decode
// ============================================================

wire [6:0] opcode = ex_insn[6:0];
wire [2:0] funct3 = ex_insn[14:12];
wire [6:0] funct7 = ex_insn[31:25];

wire [4:0] rs1 = ex_insn[19:15];
wire [4:0] rs2 = ex_insn[24:20];
wire [4:0] rd  = ex_insn[11:7];

// ============================================================
// Register Reads
// ============================================================

wire [31:0] rs1_data =
    (rs1 == 5'd0) ? 32'd0 : rf[rs1];

wire [31:0] rs2_data =
    (rs2 == 5'd0) ? 32'd0 : rf[rs2];

// ============================================================
// Immediate Generation
// ============================================================

wire [31:0] imm_i =
{
    {20{ex_insn[31]}},
    ex_insn[31:20]
};

wire [31:0] imm_s =
{
    {20{ex_insn[31]}},
    ex_insn[31:25],
    ex_insn[11:7]
};

wire [31:0] imm_b =
{
    {19{ex_insn[31]}},
    ex_insn[31],
    ex_insn[7],
    ex_insn[30:25],
    ex_insn[11:8],
    1'b0
};

wire [31:0] imm_u =
{
    ex_insn[31:12],
    12'b0
};

wire [31:0] imm_j =
{
    {11{ex_insn[31]}},
    ex_insn[31],
    ex_insn[19:12],
    ex_insn[20],
    ex_insn[30:21],
    1'b0
};

// ============================================================
// ALU
// ============================================================

reg [31:0] alu_out;

always @*
begin
    alu_out = 32'd0;

    case(opcode)

        // --------------------------------------------------------
        // ADDI
        // --------------------------------------------------------
        OP_ARITHI:
        begin
            case(funct3)

                3'b000:
                    alu_out = rs1_data + imm_i;

                default:
                    alu_out = rs1_data + imm_i;

            endcase
        end

        // --------------------------------------------------------
        // ADD / SUB
        // --------------------------------------------------------
        OP_ARITHR:
        begin
            case(funct3)

                3'b000:
                begin
                    if(funct7 == 7'b0100000)
                        alu_out = rs1_data - rs2_data;
                    else
                        alu_out = rs1_data + rs2_data;
                end

                default:
                    alu_out = rs1_data + rs2_data;

            endcase
        end

        // --------------------------------------------------------
        // Load address
        // --------------------------------------------------------
        OP_LOAD:
            alu_out = rs1_data + imm_i;

        // --------------------------------------------------------
        // Store address
        // --------------------------------------------------------
        OP_STORE:
            alu_out = rs1_data + imm_s;

        // --------------------------------------------------------
        // LUI
        // --------------------------------------------------------
        OP_LUI:
            alu_out = imm_u;

        default:
            alu_out = 32'd0;

    endcase
end

// ============================================================
// Main Sequential Logic
// ============================================================

integer i;

always @(posedge clk or negedge resetb)
begin

    // =========================================================
    // RESET
    // =========================================================

    if(!resetb)
    begin

        pc <= RESET_PC;

        instr_addr <= RESET_PC;

        if_pc   <= 32'd0;
        if_insn <= 32'h00000013;

        ex_pc    <= 32'd0;
        ex_insn  <= 32'h00000013;
        ex_valid <= 1'b0;

        axi_state <= AXI_IDLE;
        axi_rd    <= 5'd0;
        w_done    <= 1'b0;
        aw_done   <= 1'b0;
        
      
        // AXI write
        M_AXI_AWADDR  <= 32'd0;
        M_AXI_AWVALID <= 1'b0;

        M_AXI_WDATA   <= 32'd0;
        M_AXI_WSTRB   <= 4'd0;
        M_AXI_WVALID  <= 1'b0;

        M_AXI_BREADY  <= 1'b0;

        // AXI read
        M_AXI_ARADDR  <= 32'd0;
        M_AXI_ARVALID <= 1'b0;

        M_AXI_RREADY  <= 1'b0;

        // Register file
        for(i = 0; i < 32; i = i + 1)
            rf[i] <= 32'd0;

    end

    // =========================================================
    // NORMAL OPERATION
    // =========================================================

    else
    begin

        // =====================================================
        // AXI STATE MACHINE
        // =====================================================

        case(axi_state)

            // -------------------------------------------------
            // IDLE
            // -------------------------------------------------

            AXI_IDLE:
            begin
                M_AXI_BREADY  <= 1'b0;
                M_AXI_RREADY  <= 1'b0;

                M_AXI_AWVALID <= 1'b0;
                M_AXI_WVALID  <= 1'b0;
                M_AXI_ARVALID <= 1'b0;
            end

            // -------------------------------------------------
            // WRITE ADDRESS
            // -------------------------------------------------

           AXI_WADDR:
begin

    // ---------------------------------------------------------
    // AW channel handshake
    // ---------------------------------------------------------

    if(M_AXI_AWVALID && M_AXI_AWREADY)
    begin

        M_AXI_AWVALID <= 1'b0;
        aw_done       <= 1'b1;

        $display(
            "AXI AW HANDSHAKE: addr=%h",
            M_AXI_AWADDR
        );

    end


    // ---------------------------------------------------------
    // W channel handshake
    // ---------------------------------------------------------

    if(M_AXI_WVALID && M_AXI_WREADY)
    begin

        M_AXI_WVALID <= 1'b0;
        w_done       <= 1'b1;

        $display(
            "AXI W HANDSHAKE: data=%h",
            M_AXI_WDATA
        );

    end


    // ---------------------------------------------------------
    // Both channels completed
    // ---------------------------------------------------------

    if((aw_done || (M_AXI_AWVALID && M_AXI_AWREADY)) &&
       (w_done  || (M_AXI_WVALID  && M_AXI_WREADY)))
    begin

        axi_state <= AXI_WRESP;

        $display(
            "AXI WRITE ADDRESS + DATA COMPLETE"
        );

    end

end

            // -------------------------------------------------
            // WRITE RESPONSE
            // -------------------------------------------------

          AXI_WRESP:
begin
 

    M_AXI_BREADY <=  M_AXI_BVALID && !M_AXI_BREADY;

  if(M_AXI_BVALID && M_AXI_BREADY)
    begin
           $display(
            "AXI B HANDSHAKE: BRESP=%b",
            M_AXI_BRESP
        );

        
        M_AXI_BREADY <= 1'b0;
        axi_state    <= AXI_IDLE;
     

        aw_done <= 1'b0;
        w_done  <= 1'b0;
     
      
       $display(
            "STORE COMPLETE: addr=%h data=%h",
            M_AXI_AWADDR,
            M_AXI_WDATA
        );

    end

end

            // -------------------------------------------------
            // READ ADDRESS
            // -------------------------------------------------

            AXI_RADDR:
            begin
              if(M_AXI_ARVALID && M_AXI_ARREADY)
                begin
                    M_AXI_ARVALID <= 1'b0;
                    axi_state     <= AXI_RDATA;
                end
            end

            // -------------------------------------------------
            // READ DATA
            // -------------------------------------------------

           AXI_RDATA:
begin
    M_AXI_RREADY <= M_AXI_RVALID && !M_AXI_RREADY;

    if(M_AXI_RVALID && M_AXI_RREADY)
    begin
        if(axi_rd != 0)
            rf[axi_rd] <= M_AXI_RDATA;

        M_AXI_RREADY <= 1'b0;

        $display(
            "LOAD COMPLETE: addr=%h data=%h rd=x%0d",
            M_AXI_ARADDR,
            M_AXI_RDATA,
            axi_rd
        );

        axi_state <= AXI_IDLE;
    end
end

            default:
            begin
                axi_state <= AXI_IDLE;
            end

        endcase

        // =====================================================
        // PIPELINE
        // =====================================================
        //
        // Only advance/execute when no AXI transaction is
        // outstanding.
        //
        // IMPORTANT:
        // ex_valid is cleared when a LOAD/STORE is issued.
        // Therefore the memory instruction cannot execute again
        // after the AXI transaction finishes.
        //
        // =====================================================
if(!pipe_stall)
begin

    // ---------------------------------------------------------
    // FETCH
    // ---------------------------------------------------------

    if_pc   <= pc;
    if_insn <= instr_rdata;

    instr_addr <= pc;

    // ---------------------------------------------------------
    // ID -> EX
    // ---------------------------------------------------------

    ex_pc    <= if_pc;
    ex_insn  <= if_insn;
    ex_valid <= 1'b1;

    // ---------------------------------------------------------
    // Default PC increment
    // ---------------------------------------------------------

    pc <= pc + 32'd4;

    // ---------------------------------------------------------
    // EXECUTE
    // ---------------------------------------------------------

    if(ex_valid)
    begin
      $display(
    "PIPE: PC=%h IF_PC=%h IF_INSN=%h EX_PC=%h EX_INSN=%h AXI_STATE=%0d",
    pc,
    if_pc,
    if_insn,
    ex_pc,
    ex_insn,
    axi_state
);

        case(opcode)

            // =================================================
            // LUI
            // =================================================

            OP_LUI:
            begin
                if(rd != 0)
                    rf[rd] <= alu_out;
            end

            // =================================================
            // ADDI
            // =================================================

            OP_ARITHI:
            begin
                if(rd != 0)
                    rf[rd] <= alu_out;
                     $display("EXEC ADDI: rd=x%0d result=%h", rd, alu_out);
            end

            // =================================================
            // ADD / SUB
            // =================================================

            OP_ARITHR:
            begin
                if(rd != 0)
                    rf[rd] <= alu_out;
              $display("EXEC ARITH: rd=x%0d result=%h", rd, alu_out);
            end

            // =================================================
            // JAL
            // =================================================

            OP_JAL:
            begin
                if(rd != 0)
                    rf[rd] <= ex_pc + 32'd4;

                pc <= ex_pc + imm_j;
            end

            // =================================================
            // BEQ
            // =================================================

            OP_BRANCH:
            begin
                if(funct3 == 3'b000)
                begin
                    if(rs1_data == rs2_data)
                        pc <= ex_pc + imm_b;
                end
            end

            // =================================================
            // LOAD
            // =================================================

            OP_LOAD:
            begin

                M_AXI_ARADDR  <= alu_out;
                M_AXI_ARVALID <= 1'b1;

                axi_rd    <= rd;
                axi_state <= AXI_RADDR;

              
                $display(
                    "ISSUE LOAD: addr=%h rd=x%0d",
                    alu_out,
                    rd
                );

            end

            // =================================================
            // STORE
            // =================================================

            OP_STORE:
            begin

                M_AXI_AWADDR <= alu_out;

                M_AXI_WDATA  <= rs2_data;
                M_AXI_WSTRB  <= 4'b1111;

                M_AXI_AWVALID <= 1'b1;
                M_AXI_WVALID  <= 1'b1;

                aw_done <= 1'b0;
                w_done  <= 1'b0;

                axi_state <= AXI_WADDR;

              

                $display(
                    "ISSUE STORE: addr=%h data=%h",
                    alu_out,
                    rs2_data
                );

            end

            // =================================================
            // NOP / unsupported instruction
            // =================================================

            default:
            begin
            end

        endcase

    end

end

end

end

endmodule

`default_nettype wire