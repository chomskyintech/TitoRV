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

    // Illegal-instruction exception reporting (cause 2).
    output reg         trap_valid,
    output reg  [31:0] trap_pc,
    output reg  [31:0] trap_cause,

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
localparam OP_JALR   = 7'b1100111;
localparam OP_AUIPC  = 7'b0010111;
localparam OP_BRANCH = 7'b1100011;
localparam OP_LOAD   = 7'b0000011;
localparam OP_STORE  = 7'b0100011;
localparam OP_ARITHI = 7'b0010011;
localparam OP_ARITHR = 7'b0110011;
localparam OP_SYSTEM = 7'b1110011;

// ============================================================
// Register File
// ============================================================

reg [31:0] rf [31:0];

// ============================================================
// Program Counter
// ============================================================

reg [31:0] pc;

// Machine-mode CSR bank. Implements the machine CSRs used by the current
// machine-mode trap path; only MIE/MPIE/MPP are modelled in mstatus.
reg [31:0] csr_mstatus;
reg [31:0] csr_mtvec;
reg [31:0] csr_mscratch;
reg [31:0] csr_mepc;
reg [31:0] csr_mcause;

localparam [11:0] CSR_MSTATUS  = 12'h300;
localparam [11:0] CSR_MTVEC    = 12'h305;
localparam [11:0] CSR_MSCRATCH = 12'h340;
localparam [11:0] CSR_MEPC     = 12'h341;
localparam [11:0] CSR_MCAUSE   = 12'h342;

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
reg [2:0] axi_load_funct3;
reg [1:0] axi_load_addr_low;

reg [31:0] load_result;
always @* begin
    case (axi_load_funct3)
        3'b000: begin
            case (axi_load_addr_low)
                2'd0: load_result = {{24{M_AXI_RDATA[7]}}, M_AXI_RDATA[7:0]};
                2'd1: load_result = {{24{M_AXI_RDATA[15]}}, M_AXI_RDATA[15:8]};
                2'd2: load_result = {{24{M_AXI_RDATA[23]}}, M_AXI_RDATA[23:16]};
                default: load_result = {{24{M_AXI_RDATA[31]}}, M_AXI_RDATA[31:24]};
            endcase
        end
        3'b001: load_result = axi_load_addr_low[1] ? {{16{M_AXI_RDATA[31]}}, M_AXI_RDATA[31:16]} : {{16{M_AXI_RDATA[15]}}, M_AXI_RDATA[15:0]};
        3'b010: load_result = M_AXI_RDATA;
        3'b100: begin
            case (axi_load_addr_low)
                2'd0: load_result = {24'd0, M_AXI_RDATA[7:0]};
                2'd1: load_result = {24'd0, M_AXI_RDATA[15:8]};
                2'd2: load_result = {24'd0, M_AXI_RDATA[23:16]};
                default: load_result = {24'd0, M_AXI_RDATA[31:24]};
            endcase
        end
        3'b101: load_result = axi_load_addr_low[1] ? {16'd0, M_AXI_RDATA[31:16]} : {16'd0, M_AXI_RDATA[15:0]};
        default: load_result = M_AXI_RDATA;
    endcase
end

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
wire [11:0] csr_addr = ex_insn[31:20];
wire csr_op = (opcode == OP_SYSTEM) && (funct3 != 3'b000);
wire csr_addr_supported = (csr_addr == CSR_MSTATUS) ||
                          (csr_addr == CSR_MTVEC) ||
                          (csr_addr == CSR_MSCRATCH) ||
                          (csr_addr == CSR_MEPC) ||
                          (csr_addr == CSR_MCAUSE);
wire csr_instruction_valid = csr_op && csr_addr_supported &&
    ((funct3 == 3'b001) || (funct3 == 3'b010) || (funct3 == 3'b011) ||
     (funct3 == 3'b101) || (funct3 == 3'b110) || (funct3 == 3'b111));

reg [31:0] csr_read_data;
always @* begin
    case (csr_addr)
        CSR_MSTATUS:  csr_read_data = csr_mstatus;
        CSR_MTVEC:    csr_read_data = csr_mtvec;
        CSR_MSCRATCH: csr_read_data = csr_mscratch;
        CSR_MEPC:     csr_read_data = csr_mepc;
        CSR_MCAUSE:   csr_read_data = csr_mcause;
        default:      csr_read_data = 32'd0;
    endcase
end

wire [31:0] csr_source = (funct3[2]) ? {27'd0, rs1} : rs1_data;
reg [31:0] csr_write_data;
always @* begin
    case (funct3[1:0])
        2'b01: csr_write_data = csr_source;                 // CSRRW[I]
        2'b10: csr_write_data = csr_read_data | csr_source; // CSRRS[I]
        2'b11: csr_write_data = csr_read_data & ~csr_source;// CSRRC[I]
        default: csr_write_data = csr_read_data;
    endcase
end
wire csr_write_enable = (funct3[1:0] == 2'b01) ||
    (((funct3[1:0] == 2'b10) || (funct3[1:0] == 2'b11)) &&
     (rs1 != 5'd0));

// Accept only encodings implemented by this core. Unsupported funct fields
// must not alias ADDI/ADD/SUB or launch an unintended memory transaction.
wire valid_addi = (opcode == OP_ARITHI) &&
    ((funct3 == 3'b000) || (funct3 == 3'b010) || (funct3 == 3'b011) ||
     (funct3 == 3'b100) || (funct3 == 3'b110) || (funct3 == 3'b111) ||
     ((funct3 == 3'b001) && (funct7 == 7'b0000000)) ||
     ((funct3 == 3'b101) &&
      ((funct7 == 7'b0000000) || (funct7 == 7'b0100000))));
wire valid_arithr = (opcode == OP_ARITHR) &&
    (((funct7 == 7'b0000000)) ||
     ((funct7 == 7'b0100000) &&
      ((funct3 == 3'b000) || (funct3 == 3'b101))));
wire valid_load = (opcode == OP_LOAD) &&
    ((funct3 == 3'b000) || (funct3 == 3'b001) || (funct3 == 3'b010) ||
     (funct3 == 3'b100) || (funct3 == 3'b101));
wire valid_store = (opcode == OP_STORE) &&
    ((funct3 == 3'b000) || (funct3 == 3'b001) || (funct3 == 3'b010));
wire valid_branch = (opcode == OP_BRANCH) &&
    ((funct3 == 3'b000) || (funct3 == 3'b001) || (funct3 == 3'b100) ||
     (funct3 == 3'b101) || (funct3 == 3'b110) || (funct3 == 3'b111));
wire valid_jalr = (opcode == OP_JALR) && (funct3 == 3'b000);

// Detect malformed encodings in implemented instruction classes. FENCE and
// SYSTEM are legal RV32I opcode classes but are not implemented by this core;
// they are intentionally not mislabeled as illegal by this decoder.
wire system_exception = (opcode == OP_SYSTEM) &&
    ((ex_insn == 32'h00000073) || (ex_insn == 32'h00100073));
wire system_mret = (opcode == OP_SYSTEM) && (ex_insn == 32'h30200073);
wire illegal_instruction =
    ((opcode == OP_ARITHI) && !valid_addi) ||
    ((opcode == OP_ARITHR) && !valid_arithr) ||
    ((opcode == OP_LOAD) && !valid_load) ||
    ((opcode == OP_STORE) && !valid_store) ||
    ((opcode == OP_BRANCH) && !valid_branch) ||
    ((opcode == OP_JALR) && !valid_jalr) ||
    !((opcode == OP_LUI) || (opcode == OP_JAL) || (opcode == OP_JALR) ||
      (opcode == OP_AUIPC) || (opcode == OP_BRANCH) || (opcode == OP_LOAD) ||
      (opcode == OP_STORE) || (opcode == OP_ARITHI) || (opcode == OP_ARITHR) ||
      (opcode == 7'b0001111) || (opcode == OP_SYSTEM)) ||
    ((opcode == OP_SYSTEM) && !system_exception && !system_mret && !csr_instruction_valid);

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
            case (funct3)
                3'b000: if (valid_addi) alu_out = rs1_data + imm_i;
                3'b010: if (valid_addi) alu_out = ($signed(rs1_data) < $signed(imm_i)) ? 32'd1 : 32'd0;
                3'b011: if (valid_addi) alu_out = (rs1_data < imm_i) ? 32'd1 : 32'd0;
                3'b100: if (valid_addi) alu_out = rs1_data ^ imm_i;
                3'b110: if (valid_addi) alu_out = rs1_data | imm_i;
                3'b111: if (valid_addi) alu_out = rs1_data & imm_i;
                3'b001: if (valid_addi) alu_out = rs1_data << ex_insn[24:20];
                3'b101: if (valid_addi) begin
                    if (funct7 == 7'b0100000)
                        alu_out = $signed(rs1_data) >>> ex_insn[24:20];
                    else
                        alu_out = rs1_data >> ex_insn[24:20];
                end
                default: alu_out = 32'd0;
            endcase
        end

        // --------------------------------------------------------
        // ADD / SUB
        // --------------------------------------------------------
        OP_ARITHR:
        begin
            if (valid_arithr) begin
                case (funct3)
                    3'b000: alu_out = (funct7 == 7'b0100000) ? rs1_data - rs2_data : rs1_data + rs2_data;
                    3'b001: alu_out = rs1_data << rs2_data[4:0];
                    3'b010: alu_out = ($signed(rs1_data) < $signed(rs2_data)) ? 32'd1 : 32'd0;
                    3'b011: alu_out = (rs1_data < rs2_data) ? 32'd1 : 32'd0;
                    3'b100: alu_out = rs1_data ^ rs2_data;
                    3'b101: alu_out = (funct7 == 7'b0100000) ? $signed(rs1_data) >>> rs2_data[4:0] : rs1_data >> rs2_data[4:0];
                    3'b110: alu_out = rs1_data | rs2_data;
                    3'b111: alu_out = rs1_data & rs2_data;
                    default: alu_out = 32'd0;
                endcase
            end
        end

        // --------------------------------------------------------
        // Load address
        // --------------------------------------------------------
        OP_LOAD:
            if(valid_load) alu_out = rs1_data + imm_i;

        // --------------------------------------------------------
        // Store address
        // --------------------------------------------------------
        OP_STORE:
            if(valid_store) alu_out = rs1_data + imm_s;

        // --------------------------------------------------------
        // LUI
        // --------------------------------------------------------
        OP_LUI:
            alu_out = imm_u;

        OP_AUIPC:
            alu_out = ex_pc + imm_u;

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
        trap_valid <= 1'b0;
        trap_pc <= 32'd0;
        trap_cause <= 32'd0;
        csr_mstatus <= 32'h0000_1800;
        csr_mtvec <= 32'd0;
        csr_mscratch <= 32'd0;
        csr_mepc <= 32'd0;
        csr_mcause <= 32'd0;

        axi_state <= AXI_IDLE;
        axi_rd    <= 5'd0;
        axi_load_funct3 <= 3'b010;
        axi_load_addr_low <= 2'b00;
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
            rf[axi_rd] <= load_result;

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

    // The ROM output corresponds to the address held before this edge.
    // Advance the address in lockstep with the PC so sampled instruction data
    // and if_pc refer to the same word (avoids replaying the first instruction).
    instr_addr <= pc + 32'd4;

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

    if(ex_valid && (illegal_instruction || system_exception))
    begin
        // Synchronous machine-mode trap entry. trap_* remains a sticky
        // diagnostic output; execution itself continues at mtvec.
        trap_valid <= 1'b1;
        trap_pc <= ex_pc;
        if (ex_insn == 32'h00000073)
            trap_cause <= 32'd11; // ECALL from machine mode
        else if (ex_insn == 32'h00100073)
            trap_cause <= 32'd3;  // breakpoint
        else
            trap_cause <= 32'd2;  // illegal instruction

        csr_mepc <= {ex_pc[31:2], 2'b00};
        if (ex_insn == 32'h00000073)
            csr_mcause <= 32'd11;
        else if (ex_insn == 32'h00100073)
            csr_mcause <= 32'd3;
        else
            csr_mcause <= 32'd2;

        // mstatus.MPIE <- mstatus.MIE; MIE <- 0; MPP <- M.
        csr_mstatus <= (csr_mstatus & ~32'h0000_1888) |
                       ((csr_mstatus & 32'h0000_0008) << 4) |
                       32'h0000_1800;

        // Synchronous exceptions always use the direct base, even when
        // mtvec.MODE is set to vectored mode.
        pc <= {csr_mtvec[31:2], 2'b00};
        instr_addr <= {csr_mtvec[31:2], 2'b00};
        if_pc <= {csr_mtvec[31:2], 2'b00};
        if_insn <= 32'h00000013;
        ex_pc <= {csr_mtvec[31:2], 2'b00};
        ex_insn <= 32'h00000013;
        ex_valid <= 1'b0;
        $display("TRAP ENTRY: pc=%h insn=%h cause=%0d mtvec=%h",
                 ex_pc, ex_insn,
                 (ex_insn == 32'h00000073) ? 32'd11 :
                 ((ex_insn == 32'h00100073) ? 32'd3 : 32'd2),
                 {csr_mtvec[31:2], 2'b00});
    end
    else if(ex_valid && system_mret)
    begin
        // MRET restores the interrupt-enable stack and resumes at mepc.
        csr_mstatus <= (csr_mstatus & ~32'h0000_1888) |
                       ((csr_mstatus & 32'h0000_0080) >> 4) |
                       32'h0000_0080;
        pc <= {csr_mepc[31:2], 2'b00};
        instr_addr <= {csr_mepc[31:2], 2'b00};
        if_pc <= {csr_mepc[31:2], 2'b00};
        if_insn <= 32'h00000013;
        ex_pc <= {csr_mepc[31:2], 2'b00};
        ex_insn <= 32'h00000013;
        ex_valid <= 1'b0;
        $display("MRET: returning to %h", {csr_mepc[31:2], 2'b00});
    end
    else if(ex_valid)
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

            OP_LUI, OP_AUIPC:
            begin
                if(rd != 0)
                    rf[rd] <= alu_out;
            end

            // =================================================
            // ADDI
            // =================================================

            OP_ARITHI:
            begin
                if(valid_addi && rd != 0) begin
                    rf[rd] <= alu_out;
                    $display("EXEC ADDI: rd=x%0d result=%h", rd, alu_out);
                end
            end

            // =================================================
            // ADD / SUB
            // =================================================

            OP_ARITHR:
            begin
                if(valid_arithr && rd != 0) begin
                    rf[rd] <= alu_out;
                    $display("EXEC ARITH: rd=x%0d result=%h", rd, alu_out);
                end
            end

            // =================================================
            // JAL
            // =================================================

            OP_JAL, OP_JALR:
            begin
                if(rd != 0 && (opcode == OP_JAL || (opcode == OP_JALR && funct3 == 3'b000)))
                    rf[rd] <= ex_pc + 32'd4;

                // Redirect fetch and flush both younger pipeline slots.
                if (opcode == OP_JALR && funct3 == 3'b000) begin
                    pc         <= (rs1_data + imm_i) & 32'hffff_fffe;
                    instr_addr <= (rs1_data + imm_i) & 32'hffff_fffe;
                    if_pc      <= (rs1_data + imm_i) & 32'hffff_fffe;
                    ex_pc      <= (rs1_data + imm_i) & 32'hffff_fffe;
                end else if (opcode == OP_JAL) begin
                    pc         <= ex_pc + imm_j;
                    instr_addr <= ex_pc + imm_j;
                    if_pc      <= ex_pc + imm_j;
                    ex_pc      <= ex_pc + imm_j;
                end
                if_insn   <= 32'h00000013;
                ex_insn   <= 32'h00000013;
                ex_valid  <= 1'b1;
            end

            // =================================================
            // BEQ
            // =================================================

            OP_BRANCH:
            begin
                if ((funct3 == 3'b000 && rs1_data == rs2_data) ||
                    (funct3 == 3'b001 && rs1_data != rs2_data) ||
                    (funct3 == 3'b100 && $signed(rs1_data) < $signed(rs2_data)) ||
                    (funct3 == 3'b101 && $signed(rs1_data) >= $signed(rs2_data)) ||
                    (funct3 == 3'b110 && rs1_data < rs2_data) ||
                    (funct3 == 3'b111 && rs1_data >= rs2_data))
                begin
                    if (1'b1) begin
                        // A taken branch invalidates the sequential-path
                        // instructions already in IF and ID/EX.
                        pc         <= ex_pc + imm_b;
                        instr_addr <= ex_pc + imm_b;
                        if_pc      <= ex_pc + imm_b;
                        if_insn    <= 32'h00000013;
                        ex_pc      <= ex_pc + imm_b;
                        ex_insn    <= 32'h00000013;
                        ex_valid   <= 1'b1;
                    end
                end
            end

            // =================================================
            // Machine-mode CSR access (CSRRW/CSRRS/CSRRC and immediate forms)
            // =================================================
            OP_SYSTEM:
            begin
                if (csr_instruction_valid) begin
                    if (rd != 5'd0)
                        rf[rd] <= csr_read_data;

                    if (csr_write_enable) begin
                        case (csr_addr)
                            CSR_MSTATUS: begin
                                // M-only implementation: MPP is WARL-hardwired
                                // to machine mode; MIE and MPIE remain writable.
                                csr_mstatus <= (csr_write_data & 32'h0000_0088) | 32'h0000_1800;
                            end
                            CSR_MTVEC: begin
                                // mtvec.BASE is four-byte aligned. MODE 0
                                // (direct) and MODE 1 (vectored) are the
                                // defined encodings; reserved modes read back
                                // as direct mode (a permitted WARL choice).
                                csr_mtvec <= {csr_write_data[31:2],
                                              1'b0,
                                              (csr_write_data[1:0] == 2'b01)};
                            end
                            CSR_MSCRATCH:
                                csr_mscratch <= csr_write_data;
                            CSR_MEPC:
                                csr_mepc <= {csr_write_data[31:2], 2'b00};
                            CSR_MCAUSE:
                                csr_mcause <= csr_write_data;
                            default: begin end
                        endcase
                    end
                end
            end

            // =================================================
            // LOAD
            // =================================================

            OP_LOAD:
            begin
                if(valid_load) begin
                M_AXI_ARADDR  <= {alu_out[31:2], 2'b00};
                M_AXI_ARVALID <= 1'b1;

                axi_rd    <= rd;
                axi_load_funct3 <= funct3;
                axi_load_addr_low <= alu_out[1:0];
                axi_state <= AXI_RADDR;

              
                $display(
                    "ISSUE LOAD: addr=%h rd=x%0d",
                    alu_out,
                    rd
                );
                end
            end

            // =================================================
            // STORE
            // =================================================

            OP_STORE:
            begin
                if(valid_store) begin
                M_AXI_AWADDR <= {alu_out[31:2], 2'b00};
                M_AXI_WDATA  <= rs2_data << (alu_out[1:0] * 8);
                case (funct3)
                    3'b000: M_AXI_WSTRB <= 4'b0001 << alu_out[1:0];
                    3'b001: M_AXI_WSTRB <= alu_out[1] ? 4'b1100 : 4'b0011;
                    default: M_AXI_WSTRB <= 4'b1111;
                endcase

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