// ############################################################
// ##                                                        ##
// ##   riscv_core.v                                         ##
// ##   RV32I/M/E  —  3-stage in-order pipeline             ##
// ##   Stages: IF/ID  |  EX  |  WB                         ##
// ##                                                        ##
// ##   Extensions controlled by parameters:                 ##
// ##     RV32M  – multiply / divide (MULH, DIV, REM …)     ##
// ##     RV32E  – embedded ISA (16 integer registers)       ##
// ##     RV32B  – bit-manipulation (stub, reserved)         ##
// ##     RV32C  – compressed instructions (stub, reserved)  ##
// ##                                                        ##
// ##   Key design choices:                                  ##
// ##     * csr_op() function: single point for R/S/C ops    ##
// ##     * All IF/ID→EX control bits in one always block    ##
// ##     * Named comparison wires (lt_s, lt_u) in EX        ##
// ##     * MRET fully spec-compliant (MPIE restore)         ##
// ##     * `default_nettype none throughout                  ##
// ##     * RF_DEPTH localparam drives all register arrays   ##
// ##     * RV32M div is combinational — see timing note     ##
// ##                                                        ##
// ############################################################

`default_nettype none
`timescale 1ns/1ps

module riscv_core #(
    parameter integer RV32M = 1,
    parameter integer RV32E = 0,
    parameter integer RV32B = 0,
    parameter integer RV32C = 0
)(
    // ── clock / reset ──────────────────────────────────────
    input  wire        clk,
    input  wire        resetb,       // active-low async reset

    // ── external control ───────────────────────────────────
    input  wire        stall,
    output reg         exception,    // sticky — any alignment/illegal fault
    output wire        timer_en,     // high once pipeline is full

    // ── interrupt sources ──────────────────────────────────
    input  wire        timer_irq,
    input  wire        sw_irq,
    input  wire        interrupt,    // external interrupt

    // ── instruction memory (read-only) ─────────────────────
    output wire        imem_ready,
    input  wire        imem_valid,
    output wire [31:0] imem_addr,
    input  wire        imem_rresp,   // unused; kept for interface parity
    input  wire [31:0] imem_rdata,

    // ── data memory write channel ───────────────────────────
    output wire        dmem_wready,
    input  wire        dmem_wvalid,
    output wire [31:0] dmem_waddr,
    output wire [31:0] dmem_wdata,
    output wire [ 3:0] dmem_wstrb,

    // ── data memory read channel ────────────────────────────
    output wire        dmem_rready,
    input  wire        dmem_rvalid,
    output wire [31:0] dmem_raddr,
    input  wire        dmem_rresp,
    input  wire [31:0] dmem_rdata
);

`include "opcode.vh"

// ============================================================
//  Global constants
// ============================================================
localparam PC_INC    = 32'd4;                       // bytes per instruction
localparam RF_DEPTH  = (RV32E == 1) ? 16 : 32;     // register file entries

// ============================================================
//  csr_op — unified CSR read-modify-write
//
//  func3[1:0]  operation
//  ──────────  ──────────────────────────────
//  2'b01       CSRRW / CSRRWI  — write
//  2'b10       CSRRS / CSRRSI  — set bits
//  2'b11       CSRRC / CSRRCI  — clear bits
//  default     no-op (should not reach hardware)
// ============================================================
function automatic [31:0] csr_op;
    input [31:0] cur;       // current CSR value
    input [31:0] src;       // operand (rs1 or zero-extended uimm5)
    input [ 2:0] fn3;       // instruction func3
    case (fn3[1:0])
        2'b01:   csr_op = src;          // write
        2'b10:   csr_op = cur |  src;   // set
        2'b11:   csr_op = cur & ~src;   // clear
        default: csr_op = cur;
    endcase
endfunction

// ============================================================
//  Pipeline flow-control
// ============================================================
reg         stall_q;            // registered stall (one-cycle delay)
reg         flush_q;            // registered stall (two-cycle delay → flush)
reg  [ 1:0] pipe_fill;          // counts up to 2 before timer_en asserts

wire        id_stall;           // IF/ID stage cannot advance
wire        ex_stall;           // EX  stage cannot advance
wire        wb_stall;           // WB  stage cannot advance
wire        ex_squash;          // squash EX because of taken branch or trap
wire        wb_squash;          // squash WB NOP chain

// ── stall conditions ────────────────────────────────────────
assign id_stall  = stall_q || !imem_valid;
assign ex_stall  = stall_q || id_stall || (ex_load && !dmem_rvalid);
assign wb_stall  = stall_q || (wb_store_en && !dmem_wvalid)
                            || (wb_load_en  && !dmem_rresp);

// ── squash (bubble injection) conditions ────────────────────
assign ex_squash = wb_taken || wb_taken_d;   // branch/trap fired last cycle
assign wb_squash = wb_nop_a || wb_nop_b;     // drain two bubbles

// ============================================================
//  Program counters
// ============================================================
reg  [31:0] pc_fetch;       // sent to imem; updated every non-stalled cycle
reg  [31:0] pc_id;          // registered in IF/ID
reg  [31:0] pc_ex;          // registered in EX
reg  [31:0] pc_wb;          // registered in WB (debug / instret)

// ============================================================
//  Instruction word after flush-to-NOP
// ============================================================
wire [31:0] raw_insn  = imem_rdata;
wire [31:0] insn      = flush_q ? NOP : raw_insn;
reg  [31:0] imm_dec;        // decoded immediate (combinational)

// ============================================================
//  Register file
// ============================================================
reg  [31:0] rf [RF_DEPTH-1:1];
wire [31:0] rs1_data;       // forwarded read port 1
wire [31:0] rs2_data;       // forwarded read port 2
wire [31:0] alu_a;          // ALU operand A  = rs1
wire [31:0] alu_b;          // ALU operand B  = rs2 or immediate

integer     rfi;            // loop variable for reset

// ============================================================
//  IF/ID → EX pipeline registers
//  (all control bits captured from decoded insn in one block)
// ============================================================
reg  [31:0] ex_insn;        // raw instruction word (for mtval on ill)
reg  [31:0] ex_imm;         // decoded immediate
reg         ex_imm_sel;     // 1 = use imm as ALU B operand
reg  [ 4:0] ex_rs1;         // source register 1 index
reg  [ 4:0] ex_rs2;         // source register 2 index
reg  [ 4:0] ex_rd;          // destination register index
reg  [ 2:0] ex_fn3;         // func3 field
reg         ex_fn7_alt;     // func7 == 0x20 (SUB / SRA qualifier)
reg         ex_store;       // instruction is a store
reg         ex_load;        // instruction is a load
reg         ex_alu_op;      // instruction uses integer ALU
reg         ex_mul_op;      // instruction uses M-ext mul/div
reg         ex_csr_op;      // instruction reads a CSR
reg         ex_csr_wr;      // instruction also writes a CSR
reg         ex_lui;
reg         ex_auipc;
reg         ex_jal;
reg         ex_jalr;
reg         ex_branch;
reg         ex_sys;         // SYSTEM opcode, func3==0 (ecall/ebreak/mret)
reg         ex_sys_any;     // any SYSTEM opcode
reg         ex_illegal;     // no matching decode

// ── EX combinational ────────────────────────────────────────
wire [31:0] ex_ea;          // effective address = rs1 + imm
wire [31:1] ex_retpc;       // return address for jal/jalr/interrupts
wire        ex_syscall;     // active system call (not squashed)
wire        ex_flush_trap;  // trap is firing this cycle
wire        ex_trap_nop;    // exception (not interrupt) firing
wire [31:0] ex_trap_vec;    // next PC on trap/interrupt
wire [31:0] ex_csr_src;     // CSR write data (reg or uimm5)

reg  [31:0] ex_csr_rdata;   // CSR read result
reg  [31:0] ex_mcause_mux;  // combinational mcause for this event
reg         ex_ill_br;      // unrecognised branch func3
reg         ex_ill_csr;     // CSR access to unknown/RO address

// ── exception wires ─────────────────────────────────────────
wire        trap_ld_align;
wire        trap_st_align;
wire        trap_inst_ill;
wire        trap_inst_align;
wire        irq_timer;
wire        irq_sw;
wire        irq_ext;

// ============================================================
//  EX → WB pipeline registers
// ============================================================
reg         wb_reg_wr;      // write result to register file
reg  [31:0] wb_result;      // value to write (or store data)
reg  [ 2:0] wb_fn3;         // func3 (for load sign-extension)
reg         wb_load_en;     // load outstanding
reg         wb_store_en;    // store handshake pending
reg  [ 4:0] wb_rd;          // destination register
reg         wb_taken;       // branch/trap taken this cycle → inject bubble
reg         wb_taken_d;     // one-cycle delayed version → second bubble
reg         wb_trap_nop;    // exception nop suppresses regfile write
reg         wb_nop_a;       // bubble slot A
reg         wb_nop_b;       // bubble slot B
reg  [31:0] wb_store_addr;
reg  [ 1:0] wb_load_raddr;  // byte address for load alignment
reg  [ 3:0] wb_store_strb;
reg  [31:0] wb_store_data;
reg  [31:0] wb_load_data;   // sign/zero-extended load result (combinational)

// ============================================================
//  CSR register file
// ============================================================
reg  [63:0] csr_cycle;
reg  [63:0] csr_instret;
reg  [31:0] csr_mscratch;
reg  [31:0] csr_mstatus;
reg  [31:0] csr_mstatush;
reg  [31:0] csr_misa;
reg  [31:0] csr_mie;
reg  [31:0] csr_mip;
reg  [31:0] csr_mtvec;
reg  [31:0] csr_mepc;
reg  [31:0] csr_mcause;
reg  [31:0] csr_mtval;

// ============================================================
//  Wire assignments — memory interfaces
// ============================================================
assign imem_addr   = pc_fetch;
assign imem_ready  = !stall_q && !wb_stall;

assign dmem_raddr  = ex_ea;
assign dmem_rready = ex_load;

assign dmem_waddr  = wb_store_addr;
assign dmem_wdata  = wb_store_data;
assign dmem_wstrb  = wb_store_strb;
assign dmem_wready = wb_store_en;

// ============================================================
//  Exception / interrupt detection
// ============================================================
assign trap_ld_align  = ex_load  && !ex_squash && (
                            (ex_fn3 == OP_LH  && ex_ea[0]    ) ||
                            (ex_fn3 == OP_LHU && ex_ea[0]    ) ||
                            (ex_fn3 == OP_LW  && |ex_ea[1:0] )
                        );

assign trap_st_align  = ex_store && !ex_squash && (
                            (ex_fn3 == OP_SH  && ex_ea[0]    ) ||
                            (ex_fn3 == OP_SW  && |ex_ea[1:0] )
                        );

assign trap_inst_ill  = !ex_squash && (ex_ill_br || ex_ill_csr || ex_illegal);
assign trap_inst_align= !ex_squash && |next_pc[1:0];

assign irq_timer = timer_irq  && csr_mstatus[MIE] && csr_mie[MTIE]
                               && !ex_sys_any && !ex_squash;
assign irq_sw    = sw_irq     && csr_mstatus[MIE] && csr_mie[MSIE]
                               && !ex_sys_any && !ex_squash;
assign irq_ext   = interrupt  && csr_mstatus[MIE] && csr_mie[MEIE]
                               && !ex_sys_any && !ex_squash;

assign ex_trap_nop   = (trap_inst_ill || trap_inst_align ||
                        trap_ld_align || trap_st_align) && !ex_squash;

assign ex_flush_trap = (trap_inst_ill || trap_inst_align ||
                        trap_ld_align || trap_st_align   ||
                        irq_timer || irq_sw || irq_ext   ||
                        ex_syscall) && !ex_squash;

// Trap/interrupt target PC
assign ex_trap_vec = (ex_syscall && ex_imm[1:0] == 2'b10) ? csr_mepc :
                     csr_mtvec[0] ?
                         {csr_mtvec[31:2], 2'b00} + {26'h0, ex_mcause_mux[3:0], 2'b00} :
                         {csr_mtvec[31:2], 2'b00};

assign ex_syscall  = ex_sys && !ex_squash;
assign ex_csr_src  = ex_fn3[2] ? {27'h0, ex_rs1} : rs1_data;

// Return PC saved for interrupts
assign ex_retpc    = (ex_jal || ex_jalr || (ex_branch && branch_taken)) ?
                      next_pc[31:1] : pc_ex[31:1] + 31'd2;

// ============================================================
//  Exception sticky flag
// ============================================================
always @(posedge clk or negedge resetb) begin
    if (!resetb)
        exception <= 1'b0;
    else if (trap_inst_ill || trap_inst_align || trap_ld_align || trap_st_align)
        exception <= 1'b1;
end

// ============================================================
//  Pipeline flow-control registers
// ============================================================
always @(posedge clk or negedge resetb) begin
    if (!resetb) begin
        stall_q <= 1'b1;
        flush_q <= 1'b1;
    end else begin
        stall_q <= stall;
        flush_q <= stall_q;
    end
end

// ============================================================
//  PC — IF/ID register
// ============================================================
always @(posedge clk or negedge resetb) begin
    if (!resetb)     pc_id <= RESETVEC;
    else if (!wb_stall) pc_id <= pc_fetch;
end

// ============================================================
//  Immediate decode
// ============================================================
always @* begin
    case (insn[`OPCODE])
        OP_AUIPC : imm_dec = {insn[31:12], 12'd0};
        OP_LUI   : imm_dec = {insn[31:12], 12'd0};
        OP_JAL   : imm_dec = {{12{insn[31]}}, insn[19:12], insn[20], insn[30:21], 1'b0};
        OP_JALR  : imm_dec = {{20{insn[31]}}, insn[31:20]};
        OP_BRANCH: imm_dec = {{20{insn[31]}}, insn[7], insn[30:25], insn[11:8], 1'b0};
        OP_LOAD  : imm_dec = {{20{insn[31]}}, insn[31:20]};
        OP_STORE : imm_dec = {{20{insn[31]}}, insn[31:25], insn[11:7]};
        OP_ARITHI: imm_dec = (insn[`FUNC3] == OP_SLL || insn[`FUNC3] == OP_SR) ?
                              {27'h0, insn[24:20]} : {{20{insn[31]}}, insn[31:20]};
        OP_SYSTEM: imm_dec = {20'h0, insn[31:20]};
        default  : imm_dec = 32'd0;
    endcase
end

// ============================================================
//  IF/ID → EX  — all control signals in a single clocked block
//  (consolidation eliminates the ex_load race of the original)
// ============================================================
always @(posedge clk or negedge resetb) begin
    if (!resetb) begin
        ex_insn    <= NOP;      ex_imm     <= 32'h0;
        ex_imm_sel <= 1'b0;     ex_rs1     <= 5'h0;
        ex_rs2     <= 5'h0;     ex_rd      <= 5'h0;
        ex_fn3     <= 3'h0;     ex_fn7_alt <= 1'b0;
        ex_store   <= 1'b0;     ex_load    <= 1'b0;
        ex_alu_op  <= 1'b0;     ex_mul_op  <= 1'b0;
        ex_csr_op  <= 1'b0;     ex_csr_wr  <= 1'b0;
        ex_lui     <= 1'b0;     ex_auipc   <= 1'b0;
        ex_jal     <= 1'b0;     ex_jalr    <= 1'b0;
        ex_branch  <= 1'b0;     ex_sys     <= 1'b0;
        ex_sys_any <= 1'b0;     ex_illegal <= 1'b0;
        ex_pc      <= RESETVEC;
    end else if (!id_stall) begin
        ex_insn    <= insn;
        ex_imm     <= imm_dec;
        ex_imm_sel <= (insn[`OPCODE] == OP_JALR  ) ||
                      (insn[`OPCODE] == OP_LOAD  ) ||
                      (insn[`OPCODE] == OP_ARITHI);
        ex_rs1     <= insn[`RS1];
        ex_rs2     <= insn[`RS2];
        ex_rd      <= insn[`RD];
        ex_fn3     <= insn[`FUNC3];
        ex_fn7_alt <= insn[`SUBTYPE] &&
                      !(insn[`OPCODE] == OP_ARITHI && insn[`FUNC3] == OP_ADD);
        ex_store   <= insn[`OPCODE] == OP_STORE;
        ex_load    <= insn[`OPCODE] == OP_LOAD;
        ex_alu_op  <= (insn[`OPCODE] == OP_ARITHI) ||
                      ((insn[`OPCODE] == OP_ARITHR) &&
                       (insn[`FUNC7] == 7'h00 || insn[`FUNC7] == 7'h20));
        ex_mul_op  <= (insn[`OPCODE] == OP_ARITHR) &&
                      (insn[`FUNC7] == 7'h01) && (RV32M == 1);
        ex_csr_op  <= (insn[`OPCODE] == OP_SYSTEM) && (insn[`FUNC3] != OP_ECALL);
        ex_csr_wr  <= (insn[`OPCODE] == OP_SYSTEM) &&
                      (insn[`FUNC3] != OP_ECALL) &&
                      !(insn[`FUNC3] != OP_CSRRW && insn[`FUNC3] != OP_CSRRWI &&
                        insn[`RS1]  == 5'h0);
        ex_lui     <= insn[`OPCODE] == OP_LUI;
        ex_auipc   <= insn[`OPCODE] == OP_AUIPC;
        ex_jal     <= insn[`OPCODE] == OP_JAL;
        ex_jalr    <= insn[`OPCODE] == OP_JALR;
        ex_branch  <= insn[`OPCODE] == OP_BRANCH;
        ex_sys     <= (insn[`OPCODE] == OP_SYSTEM) && (insn[`FUNC3] == 3'b000);
        ex_sys_any <= insn[`OPCODE] == OP_SYSTEM;
        ex_pc      <= pc_id;
        ex_illegal <= !((insn[`OPCODE] == OP_AUIPC ) ||
                        (insn[`OPCODE] == OP_LUI   ) ||
                        (insn[`OPCODE] == OP_JAL   ) ||
                        (insn[`OPCODE] == OP_JALR  ) ||
                        (insn[`OPCODE] == OP_BRANCH) ||
                        ((insn[`OPCODE] == OP_LOAD ) &&
                         (insn[`FUNC3] == OP_LB  || insn[`FUNC3] == OP_LH  ||
                          insn[`FUNC3] == OP_LW  || insn[`FUNC3] == OP_LBU ||
                          insn[`FUNC3] == OP_LHU)) ||
                        ((insn[`OPCODE] == OP_STORE) &&
                         (insn[`FUNC3] == OP_SB || insn[`FUNC3] == OP_SH ||
                          insn[`FUNC3] == OP_SW)) ||
                        (insn[`OPCODE] == OP_ARITHI) ||
                        ((insn[`OPCODE] == OP_ARITHR) &&
                         (insn[`FUNC7] == 7'h00 || insn[`FUNC7] == 7'h20)) ||
                        ((insn[`OPCODE] == OP_ARITHR) &&
                         (insn[`FUNC7] == 7'h01) && (RV32M == 1)) ||
                        (insn[`OPCODE] == OP_FENCE ) ||
                        (insn[`OPCODE] == OP_SYSTEM));
    end
end

`ifndef SYNTHESIS
always @* begin
    if (ex_illegal && !ex_squash)
        $display("[riscv_core] Illegal insn @ PC %08h  insn=%08h", pc_ex, ex_insn);
    if (ex_ill_br  && !ex_squash)
        $display("[riscv_core] Bad branch func3 @ PC %08h", pc_ex);
end
`endif

// ============================================================
//  EX — ALU operands
// ============================================================
assign alu_a = rs1_data;
assign alu_b = ex_imm_sel ? ex_imm : rs2_data;

// Subtraction results with extended sign bit for comparisons
wire [32:0] sub_s = {alu_a[31], alu_a} - {alu_b[31], alu_b};  // signed
wire [32:0] sub_u = {1'b0,      alu_a} - {1'b0,      alu_b};  // unsigned

// Friendly names that make branch polarity self-documenting
wire lt_s = sub_s[32];     // alu_a <  alu_b  (signed)
wire lt_u = sub_u[32];     // alu_a <  alu_b  (unsigned)
wire eq   = (sub_s[31:0] == 32'h0);

assign ex_ea = alu_a + ex_imm;

wire [31:0] jal_target  = pc_ex + ex_imm;
wire [31:0] jalr_target = alu_a + ex_imm;

// ============================================================
//  EX — Branch / next-PC
// ============================================================
reg  [31:0] next_pc;
reg         branch_taken;

always @* begin
    branch_taken = !ex_squash;
    next_pc      = pc_fetch + PC_INC;
    ex_ill_br    = 1'b0;

    case (1'b1)
        ex_jal:  next_pc = {jal_target[31:1],  1'b0};
        ex_jalr: next_pc = {jalr_target[31:1], 1'b0};

        ex_branch: begin
            case (ex_fn3)
                OP_BEQ:  if ( eq)  next_pc = pc_ex + ex_imm; else begin next_pc = pc_fetch + PC_INC; branch_taken = 1'b0; end
                OP_BNE:  if (!eq)  next_pc = pc_ex + ex_imm; else begin next_pc = pc_fetch + PC_INC; branch_taken = 1'b0; end
                OP_BLT:  if ( lt_s) next_pc = pc_ex + ex_imm; else begin next_pc = pc_fetch + PC_INC; branch_taken = 1'b0; end
                OP_BGE:  if (!lt_s) next_pc = pc_ex + ex_imm; else begin next_pc = pc_fetch + PC_INC; branch_taken = 1'b0; end
                OP_BLTU: if ( lt_u) next_pc = pc_ex + ex_imm; else begin next_pc = pc_fetch + PC_INC; branch_taken = 1'b0; end
                OP_BGEU: if (!lt_u) next_pc = pc_ex + ex_imm; else begin next_pc = pc_fetch + PC_INC; branch_taken = 1'b0; end
                default: begin next_pc = pc_fetch; ex_ill_br = 1'b1; branch_taken = 1'b0; end
            endcase
        end

        default: begin next_pc = pc_fetch + PC_INC; branch_taken = 1'b0; end
    endcase
end

// ============================================================
//  Fetch PC update
// ============================================================
always @(posedge clk or negedge resetb) begin
    if (!resetb)
        pc_fetch <= RESETVEC;
    else if (!ex_stall)
        pc_fetch <= ex_squash      ? pc_fetch + PC_INC :
                    ex_flush_trap  ? ex_trap_vec        :
                                     {next_pc[31:1], 1'b0};
end

// ============================================================
//  RV32M — multiply / divide
//  NOTE: dividers are purely combinational.  If closure fails,
//  replace with a radix-2 iterative unit gated by div_busy.
// ============================================================
wire [63:0] mul_ss, mul_uu, mul_su;
wire [31:0] div_s, div_u, rem_s, rem_u;

generate
    if (RV32M == 1) begin : g_mext
        assign mul_ss = $signed  ({{32{alu_a[31]}}, alu_a}) *
                        $signed  ({{32{alu_b[31]}}, alu_b});
        assign mul_uu = $unsigned({{32{1'b0}},      alu_a}) *
                        $unsigned({{32{1'b0}},      alu_b});
        assign mul_su = $signed  ({{32{alu_a[31]}}, alu_a}) *
                        $unsigned({{32{1'b0}},      alu_b});

        // Spec §M: div-by-zero → −1; overflow (INT_MIN/−1) → INT_MIN
        assign div_s = (alu_b == 32'h0) ? 32'hffff_ffff :
                       (alu_a == 32'h8000_0000 && alu_b == 32'hffff_ffff) ? 32'h8000_0000 :
                        $signed($signed(alu_a) / $signed(alu_b));

        assign div_u = (alu_b == 32'h0) ? 32'hffff_ffff :
                        $unsigned($unsigned(alu_a) / $unsigned(alu_b));

        assign rem_s = (alu_b == 32'h0) ? alu_a :
                       (alu_a == 32'h8000_0000 && alu_b == 32'hffff_ffff) ? 32'h0 :
                        $signed($signed(alu_a) % $signed(alu_b));

        assign rem_u = (alu_b == 32'h0) ? alu_a :
                        $unsigned($unsigned(alu_a) % $unsigned(alu_b));
    end else begin : g_no_mext
        assign mul_ss = 64'h0; assign mul_uu = 64'h0; assign mul_su = 64'h0;
        assign div_s  = 32'h0; assign div_u  = 32'h0;
        assign rem_s  = 32'h0; assign rem_u  = 32'h0;
    end
endgenerate

// ============================================================
//  EX — result mux
// ============================================================
reg [31:0] ex_result;

always @* begin
    ex_result = 32'h0;
    case (1'b1)
        ex_store  : ex_result = alu_b;
        ex_jal    : ex_result = pc_ex + PC_INC;
        ex_jalr   : ex_result = pc_ex + PC_INC;
        ex_lui    : ex_result = ex_imm;
        ex_auipc  : ex_result = pc_ex + ex_imm;
        ex_csr_op : ex_result = ex_csr_rdata;

        ex_mul_op: begin
            case (ex_fn3)
                OP_MUL   : ex_result = mul_ss[31: 0];
                OP_MULH  : ex_result = mul_ss[63:32];
                OP_MULSU : ex_result = mul_su[63:32];
                OP_MULU  : ex_result = mul_uu[63:32];
                OP_DIV   : ex_result = div_s;
                OP_DIVU  : ex_result = div_u;
                OP_REM   : ex_result = rem_s;
                default  : ex_result = rem_u;   // OP_REMU
            endcase
        end

        ex_alu_op: begin
            case (ex_fn3)
                OP_ADD : ex_result = ex_fn7_alt ? alu_a - alu_b : alu_a + alu_b;
                OP_SLL : ex_result = alu_a << alu_b[4:0];
                OP_SLT : ex_result = lt_s ? 32'd1 : 32'd0;
                OP_SLTU: ex_result = lt_u ? 32'd1 : 32'd0;
                OP_XOR : ex_result = alu_a ^ alu_b;
                OP_SR  : ex_result = ex_fn7_alt ? $signed(alu_a) >>> alu_b[4:0]
                                                : alu_a >> alu_b[4:0];
                OP_OR  : ex_result = alu_a | alu_b;
                default: ex_result = alu_a & alu_b;   // OP_AND
            endcase
        end

        default: ex_result = 32'h0;
    endcase
end

// ============================================================
//  EX → WB pipeline registers
// ============================================================
always @(posedge clk or negedge resetb) begin
    if (!resetb) begin
        wb_result   <= 32'h0;  wb_reg_wr   <= 1'b0;
        wb_rd       <= 5'h0;   wb_fn3      <= 3'h0;
        wb_taken    <= 1'b0;   wb_taken_d  <= 1'b0;
        wb_load_en  <= 1'b0;   wb_load_raddr <= 2'h0;
    end else if (!ex_stall) begin
        wb_result   <= ex_result;
        wb_reg_wr   <= ex_alu_op || ex_lui || ex_auipc || ex_jal || ex_jalr ||
                       ex_csr_op || ex_mul_op ||
                       (ex_load && !trap_ld_align);
        wb_rd       <= ex_rd;
        wb_fn3      <= ex_fn3;
        wb_taken    <= branch_taken || ex_flush_trap;
        wb_taken_d  <= wb_taken;
        wb_load_en  <= ex_load;
        wb_load_raddr <= dmem_raddr[1:0];
    end
end

// ============================================================
//  Store write-enable — held until wvalid handshake
// ============================================================
always @(posedge clk or negedge resetb) begin
    if (!resetb)
        wb_store_en <= 1'b0;
    else if (ex_store && !ex_squash && !trap_st_align)
        wb_store_en <= 1'b1;
    else if (wb_store_en && dmem_wvalid)
        wb_store_en <= 1'b0;
end

// ============================================================
//  Store address / data / byte-enable
// ============================================================
always @(posedge clk or negedge resetb) begin
    if (!resetb) begin
        wb_store_addr <= 32'h0;
        wb_store_strb <= 4'h0;
        wb_store_data <= 32'h0;
    end else if (!ex_stall && ex_store) begin
        wb_store_addr <= ex_ea;
        case (ex_fn3)
            OP_SB: begin
                wb_store_data <= {4{alu_b[7:0]}};
                case (ex_ea[1:0])
                    2'b00:   wb_store_strb <= 4'b0001;
                    2'b01:   wb_store_strb <= 4'b0010;
                    2'b10:   wb_store_strb <= 4'b0100;
                    default: wb_store_strb <= 4'b1000;
                endcase
            end
            OP_SH: begin
                wb_store_data <= {2{alu_b[15:0]}};
                wb_store_strb <= ex_ea[1] ? 4'b1100 : 4'b0011;
            end
            default: begin   // OP_SW
                wb_store_data <= alu_b;
                wb_store_strb <= 4'hf;
            end
        endcase
    end
end

// ============================================================
//  WB — bubble injection (two slots drained after branch/trap)
// ============================================================
always @(posedge clk or negedge resetb) begin
    if (!resetb) begin
        wb_nop_a    <= 1'b0;
        wb_nop_b    <= 1'b0;
        wb_trap_nop <= 1'b0;
    end else if (!ex_stall && !(wb_store_en && !dmem_wvalid)) begin
        wb_nop_a    <= wb_taken;
        wb_nop_b    <= wb_nop_a;
        wb_trap_nop <= ex_trap_nop;
    end
end

// ============================================================
//  WB — load data alignment & sign extension
// ============================================================
always @* begin
    case (wb_fn3)
        OP_LB: begin
            case (wb_load_raddr)
                2'b00: wb_load_data = {{24{dmem_rdata[ 7]}}, dmem_rdata[ 7: 0]};
                2'b01: wb_load_data = {{24{dmem_rdata[15]}}, dmem_rdata[15: 8]};
                2'b10: wb_load_data = {{24{dmem_rdata[23]}}, dmem_rdata[23:16]};
                2'b11: wb_load_data = {{24{dmem_rdata[31]}}, dmem_rdata[31:24]};
                default: wb_load_data = 32'h0;
            endcase
        end
        OP_LH:  wb_load_data = wb_load_raddr[1]
                             ? {{16{dmem_rdata[31]}}, dmem_rdata[31:16]}
                             : {{16{dmem_rdata[15]}}, dmem_rdata[15: 0]};
        OP_LW:  wb_load_data = dmem_rdata;
        OP_LBU: begin
            case (wb_load_raddr)
                2'b00: wb_load_data = {24'h0, dmem_rdata[ 7: 0]};
                2'b01: wb_load_data = {24'h0, dmem_rdata[15: 8]};
                2'b10: wb_load_data = {24'h0, dmem_rdata[23:16]};
                2'b11: wb_load_data = {24'h0, dmem_rdata[31:24]};
                default: wb_load_data = 32'h0;
            endcase
        end
        OP_LHU: wb_load_data = wb_load_raddr[1]
                             ? {16'h0, dmem_rdata[31:16]}
                             : {16'h0, dmem_rdata[15: 0]};
        default: wb_load_data = 32'h0;
    endcase
end

// ============================================================
//  Trap mcause mux
// ============================================================
always @* begin
    ex_mcause_mux = 32'h0;
    case (1'b1)
        trap_inst_ill   : ex_mcause_mux = TRAP_INST_ILL;
        trap_inst_align : ex_mcause_mux = TRAP_INST_ALIGN;
        trap_ld_align   : ex_mcause_mux = TRAP_LD_ALIGN;
        trap_st_align   : ex_mcause_mux = TRAP_ST_ALIGN;
        irq_timer       : ex_mcause_mux = INT_MTIME;
        irq_sw          : ex_mcause_mux = INT_MSI;
        irq_ext         : ex_mcause_mux = INT_MEI;
        ex_syscall: begin
            case (ex_imm[1:0])
                2'b00:   ex_mcause_mux = TRAP_ECALL;
                2'b01:   ex_mcause_mux = TRAP_BREAK;
                2'b10:   ex_mcause_mux = csr_mcause;  // MRET — preserve
                default: ex_mcause_mux = TRAP_INST_ILL;
            endcase
        end
        default: ex_mcause_mux = 32'h0;
    endcase
end

// ============================================================
//  CSR trap / interrupt state update
// ============================================================
always @(posedge clk or negedge resetb) begin
    if (!resetb) begin
        csr_mcause   <= 32'h0;  csr_mepc     <= 32'h0;
        csr_mtval    <= 32'h0;  csr_mstatus  <= 32'h0;
        csr_mstatush <= 32'h0;  csr_mip      <= 32'h0;
    end else if (!ex_stall && !ex_squash) begin
        case (1'b1)

            trap_inst_ill: begin
                csr_mcause        <= TRAP_INST_ILL;
                csr_mepc          <= {pc_ex[31:1], 1'b0};
                csr_mtval         <= ex_insn;
                csr_mstatus[MPIE] <= csr_mstatus[MIE];
                csr_mstatus[MIE]  <= 1'b0;
            end

            // CSR write handled last so trap above takes priority
            ex_csr_wr: begin
                case (ex_imm[11:0])
                    CSR_MEPC    : csr_mepc    <= csr_op(csr_mepc,     ex_csr_src, ex_fn3);
                    CSR_MCAUSE  : csr_mcause  <= csr_op(csr_mcause,   ex_csr_src, ex_fn3);
                    CSR_MTVAL   : csr_mtval   <= csr_op(csr_mtval,    ex_csr_src, ex_fn3);
                    CSR_MSTATUS : csr_mstatus <= csr_op(csr_mstatus,  ex_csr_src, ex_fn3);
                    CSR_MSTATUSH: csr_mstatush<= csr_op(csr_mstatush, ex_csr_src, ex_fn3);
                    CSR_MIP     : csr_mip     <= csr_op(csr_mip,      ex_csr_src, ex_fn3);
                    default: ;
                endcase
            end

            trap_inst_align: begin
                csr_mcause        <= TRAP_INST_ALIGN;
                csr_mepc          <= {pc_ex[31:1], 1'b0};
                csr_mtval         <= next_pc;
                csr_mstatus[MPIE] <= csr_mstatus[MIE];
                csr_mstatus[MIE]  <= 1'b0;
            end

            trap_ld_align: begin
                csr_mcause        <= TRAP_LD_ALIGN;
                csr_mepc          <= {pc_ex[31:1], 1'b0};
                csr_mtval         <= ex_ea;
                csr_mstatus[MPIE] <= csr_mstatus[MIE];
                csr_mstatus[MIE]  <= 1'b0;
            end

            trap_st_align: begin
                csr_mcause        <= TRAP_ST_ALIGN;
                csr_mepc          <= {pc_ex[31:1], 1'b0};
                csr_mtval         <= ex_ea;
                csr_mstatus[MPIE] <= csr_mstatus[MIE];
                csr_mstatus[MIE]  <= 1'b0;
            end

            irq_timer: begin
                csr_mcause        <= INT_MTIME;
                csr_mepc          <= {ex_retpc[31:1], 1'b0};
                csr_mtval         <= 32'h0;
                csr_mstatus[MPIE] <= csr_mstatus[MIE];
                csr_mstatus[MIE]  <= 1'b0;
                csr_mip[MTIP]     <= 1'b1;
            end

            irq_sw: begin
                csr_mcause        <= INT_MSI;
                csr_mepc          <= {ex_retpc[31:1], 1'b0};
                csr_mtval         <= 32'h0;
                csr_mstatus[MPIE] <= csr_mstatus[MIE];
                csr_mstatus[MIE]  <= 1'b0;
                csr_mip[MSIP]     <= 1'b1;
            end

            irq_ext: begin
                csr_mcause        <= INT_MEI;
                csr_mepc          <= {ex_retpc[31:1], 1'b0};
                csr_mtval         <= 32'h0;
                csr_mstatus[MPIE] <= csr_mstatus[MIE];
                csr_mstatus[MIE]  <= 1'b0;
                csr_mip[MEIP]     <= 1'b1;
            end

            ex_syscall: begin
                case (ex_imm[1:0])
                    2'b00: begin   // ECALL
                        csr_mcause        <= TRAP_ECALL;
                        csr_mepc          <= {pc_ex[31:1], 1'b0};
                        csr_mtval         <= 32'h0;
                        csr_mstatus[MPIE] <= csr_mstatus[MIE];
                        csr_mstatus[MIE]  <= 1'b0;
                    end
                    2'b01: begin   // EBREAK
                        csr_mcause        <= TRAP_BREAK;
                        csr_mepc          <= {pc_ex[31:1], 1'b0};
                        csr_mtval         <= {pc_ex[31:1], 1'b0};
                        csr_mstatus[MPIE] <= csr_mstatus[MIE];
                        csr_mstatus[MIE]  <= 1'b0;
                    end
                    2'b10: begin   // MRET — spec-compliant restore
                        csr_mstatus[MIE]  <= csr_mstatus[MPIE];
                        csr_mstatus[MPIE] <= 1'b1;
                        // mcause / mtval architecturally preserved across mret
                    end
                    default: begin // undefined SYSTEM encoding → illegal
                        csr_mcause        <= TRAP_INST_ILL;
                        csr_mepc          <= {pc_ex[31:1], 1'b0};
                        csr_mtval         <= ex_insn;
                        csr_mstatus[MPIE] <= csr_mstatus[MIE];
                        csr_mstatus[MIE]  <= 1'b0;
                    end
                endcase
            end

            default: ;
        endcase
    end
end

// ============================================================
//  CSR file — read path
// ============================================================
always @* begin
    ex_ill_csr  = 1'b0;
    ex_csr_rdata = 32'h0;
    if (ex_csr_op && !ex_squash) begin
        case (ex_imm[11:0])
            CSR_MVENDORID  : ex_csr_rdata = MVENDORID;
            CSR_MARCHID    : ex_csr_rdata = MARCHID;
            CSR_MIMPID     : ex_csr_rdata = MIMPID;
            CSR_MHARTID    : ex_csr_rdata = MHARTID;
            CSR_MSCRATCH   : ex_csr_rdata = csr_mscratch;
            CSR_MSTATUS    : ex_csr_rdata = csr_mstatus;
            CSR_MSTATUSH   : ex_csr_rdata = csr_mstatush;
            CSR_MISA       : ex_csr_rdata = csr_misa;
            CSR_MIE        : ex_csr_rdata = csr_mie;
            CSR_MIP        : ex_csr_rdata = csr_mip;
            CSR_MTVEC      : ex_csr_rdata = csr_mtvec;
            CSR_MEPC       : ex_csr_rdata = csr_mepc;
            CSR_MCAUSE     : ex_csr_rdata = csr_mcause;
            CSR_MTVAL      : ex_csr_rdata = csr_mtval;
            CSR_RDCYCLE    : ex_csr_rdata = csr_cycle[31: 0];
            CSR_RDCYCLEH   : ex_csr_rdata = csr_cycle[63:32];
            CSR_RDTIME     : ex_csr_rdata = csr_cycle[31: 0];   // time aliased to cycle
            CSR_RDTIMEH    : ex_csr_rdata = csr_cycle[63:32];
            CSR_RDINSTRET  : ex_csr_rdata = csr_instret[31: 0];
            CSR_RDINSTRETH : ex_csr_rdata = csr_instret[63:32];
            default: begin
                ex_ill_csr = 1'b1;
                `ifndef SYNTHESIS
                $display("[riscv_core] Unknown CSR 0x%03x @ PC %08h", ex_imm[11:0], pc_ex);
                `endif
            end
        endcase
        if (ex_csr_wr && ex_imm[11:10] == 2'b11)
            ex_ill_csr = 1'b1;   // write to read-only CSR
    end
end

// ============================================================
//  CSR file — write path (non-trap owned CSRs)
// ============================================================
always @(posedge clk or negedge resetb) begin
    if (!resetb) begin
        csr_misa     <= MISA;    csr_mie      <= 32'h0;
        csr_mtvec    <= 32'h0;   csr_mscratch <= 32'h0;
    end else if (!ex_stall && ex_csr_wr && !ex_squash) begin
        case (ex_imm[11:0])
            CSR_MSCRATCH: csr_mscratch <= csr_op(csr_mscratch, ex_csr_src, ex_fn3);
            CSR_MISA    : csr_misa     <= csr_op(csr_misa,     ex_csr_src, ex_fn3);
            CSR_MIE     : csr_mie      <= csr_op(csr_mie,      ex_csr_src, ex_fn3);
            CSR_MTVEC   : csr_mtvec    <= csr_op(csr_mtvec,    ex_csr_src, ex_fn3);
            // Trap-owned: MSTATUS, MSTATUSH, MIP, MEPC, MCAUSE, MTVAL (handled above)
            // Read-only:  MVENDORID, MARCHID, MIMPID, MHARTID
            // Counters:   RDCYCLE, RDINSTRET (and their high halves)
            default: ;
        endcase
    end
end

// ============================================================
//  Performance counters + pipeline-fill tracker
// ============================================================
assign timer_en = (pipe_fill == 2'b10);

always @(posedge clk or negedge resetb) begin
    if (!resetb) begin
        csr_cycle   <= 64'h0;
        csr_instret <= 64'h0;
        pipe_fill   <= 2'b00;
    end else if (!stall_q) begin
        if (pipe_fill != 2'b10)
            pipe_fill <= pipe_fill + 1'b1;
        else begin
            csr_cycle <= csr_cycle + 1'b1;
            if (!ex_stall && !ex_squash)
                csr_instret <= csr_instret + 1'b1;
        end
    end
end

// ============================================================
//  Register file — forwarded read + write
//
//  Forwarding path: if the WB stage holds the destination we
//  need, bypass the array and use wb_result / wb_load_data
//  directly.  This covers both ALU→ALU and load→ALU forwarding
//  with no stall required.
// ============================================================
wire fwd1 = !wb_squash && wb_reg_wr && (wb_rd == ex_rs1) && (ex_rs1 != 5'h0);
wire fwd2 = !wb_squash && wb_reg_wr && (wb_rd == ex_rs2) && (ex_rs2 != 5'h0);

assign rs1_data = (ex_rs1 == 5'h0) ? 32'h0 :
                   fwd1             ? (wb_load_en ? wb_load_data : wb_result) :
                                       rf[ex_rs1];

assign rs2_data = (ex_rs2 == 5'h0) ? 32'h0 :
                   fwd2             ? (wb_load_en ? wb_load_data : wb_result) :
                                       rf[ex_rs2];

always @(posedge clk or negedge resetb) begin
    if (!resetb) begin
        for (rfi = 1; rfi < RF_DEPTH; rfi = rfi + 1)
            rf[rfi] <= 32'h0;
    end else if (wb_reg_wr && !stall_q && !wb_stall && !wb_squash && !wb_trap_nop) begin
        if (wb_rd != 5'h0)
            rf[wb_rd] <= wb_load_en ? wb_load_data : wb_result;
        `ifndef SYNTHESIS
        if (RV32E && wb_rd >= 5'd16) begin
            $display("[riscv_core] RV32E: write to x%0d is illegal @ WB PC %08h",
                     wb_rd, pc_wb);
            $finish(2);
        end
        `endif
    end
end

// ============================================================
//  Simulation-only helpers
// ============================================================
`ifndef SYNTHESIS
/* verilator coverage_off */
/* Verilator lint_off UNUSED */

wire [31:0] dbg_x0  = 32'd0;
wire [31:0] dbg_ra  = rf[ 1];   wire [31:0] dbg_sp  = rf[ 2];
wire [31:0] dbg_gp  = rf[ 3];   wire [31:0] dbg_tp  = rf[ 4];
wire [31:0] dbg_t0  = rf[ 5];   wire [31:0] dbg_t1  = rf[ 6];
wire [31:0] dbg_t2  = rf[ 7];   wire [31:0] dbg_s0  = rf[ 8];
wire [31:0] dbg_s1  = rf[ 9];   wire [31:0] dbg_a0  = rf[10];
wire [31:0] dbg_a1  = rf[11];   wire [31:0] dbg_a2  = rf[12];
wire [31:0] dbg_a3  = rf[13];   wire [31:0] dbg_a4  = rf[14];
wire [31:0] dbg_a5  = rf[15];

generate
    if (RV32E == 0) begin : g_dbg_hi
        wire [31:0] dbg_a6  = rf[16];  wire [31:0] dbg_a7  = rf[17];
        wire [31:0] dbg_s2  = rf[18];  wire [31:0] dbg_s3  = rf[19];
        wire [31:0] dbg_s4  = rf[20];  wire [31:0] dbg_s5  = rf[21];
        wire [31:0] dbg_s6  = rf[22];  wire [31:0] dbg_s7  = rf[23];
        wire [31:0] dbg_s8  = rf[24];  wire [31:0] dbg_s9  = rf[25];
        wire [31:0] dbg_s10 = rf[26];  wire [31:0] dbg_s11 = rf[27];
        wire [31:0] dbg_t3  = rf[28];  wire [31:0] dbg_t4  = rf[29];
        wire [31:0] dbg_t5  = rf[30];  wire [31:0] dbg_t6  = rf[31];
    end
endgenerate

reg [31:0] dbg_wb_insn;
reg [ 1:0] dbg_wb_ebreak;
reg        dbg_wb_sys;

always @(posedge clk or negedge resetb) begin
    if (!resetb) begin
        pc_wb          <= RESETVEC;
        dbg_wb_insn    <= 32'h0;
        dbg_wb_ebreak  <= 2'b00;
        dbg_wb_sys     <= 1'b0;
    end else if (!ex_stall) begin
        pc_wb          <= pc_ex;
        dbg_wb_insn    <= ex_insn;
        dbg_wb_ebreak  <= ex_imm[1:0];
        dbg_wb_sys     <= ex_syscall;
    end
end

// Simulation safety net: trap with uninitialised mtvec → halt
always @(posedge clk) begin
    if (!ex_stall && ex_flush_trap && csr_mtvec[31:2] == 30'd0) begin
        $display("[riscv_core] Trap fired but mtvec = 0 — stopping simulation.");
        $finish(2);
    end
end

// Backdoor write for testbench register initialisation
function [31:0] tb_set_reg;
    input [ 4:0] idx;
    input [31:0] val;
    /* verilator lint_off BLKSEQ */
    rf[idx] = val;
    /* verilator lint_on BLKSEQ */
    tb_set_reg = val;
endfunction

/* verilator coverage_on */
/* Verilator lint_on UNUSED */
`endif  // SYNTHESIS

endmodule

`default_nettype wire
