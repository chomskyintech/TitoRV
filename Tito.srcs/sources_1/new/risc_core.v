


`default_nettype none
`timescale 1ns/1ps

module riscv_core #(
    parameter integer RV32M = 1,
    parameter integer RV32E = 0
)(
    input  wire        clk,
    input  wire        resetb,
    input  wire        stall,

    // Interrupt sources
    input  wire        timer_irq,
    input  wire        sw_irq,
    input  wire        ext_irq,

    // Memory interface - instruction
    input  wire        imem_valid,
    input  wire [31:0] imem_rdata,
    output reg  [31:0] imem_addr,
    output wire        imem_ready,

    // Memory interface - data
    input  wire        dmem_rvalid,
    input  wire [31:0] dmem_rdata,
    output reg  [31:0] dmem_raddr,
    output reg  [31:0] dmem_wdata,
    output reg  [31:0] dmem_waddr,
    output reg  [3:0]  dmem_wstrb,
    output wire        dmem_rready,
    output wire        dmem_wready
);
assign imem_ready = !stall;
assign dmem_rready  = 1'b1;
assign dmem_wready  = 1'b1;
localparam NOP = 32'h00000013;  // ADDI x0, x0, 0
localparam RESETVEC = 32'h00000000;

always @(posedge clk or negedge resetb) begin
    if (!resetb) begin
        imem_addr   <= RESETVEC;
        dmem_raddr  <= 32'd0;
        dmem_waddr  <= 32'd0;
        dmem_wdata  <= 32'd0;
        dmem_wstrb  <= 4'd0;
    end else if (!stall) begin
        // For now, just increment PC for testing
        imem_addr <= imem_addr + 4;
        dmem_raddr <= dmem_raddr + 4;
        // write ports stay 0 for now
    end
end

// Instruction opcode constants 
localparam OP_LUI    = 7'b0110111;
localparam OP_AUIPC  = 7'b0010111;
localparam OP_JAL    = 7'b1101111;
localparam OP_JALR   = 7'b1100111;
localparam OP_BRANCH = 7'b1100011;
localparam OP_LOAD   = 7'b0000011;
localparam OP_STORE  = 7'b0100011;
localparam OP_ARITHI = 7'b0010011;
localparam OP_ARITHR = 7'b0110011;
localparam OP_SYSTEM = 7'b1110011;

// funct3 constants
localparam F3_ADD_SUB = 3'b000;
localparam F3_SLL     = 3'b001;
localparam F3_SLT     = 3'b010;
localparam F3_SLTU    = 3'b011;
localparam F3_XOR     = 3'b100;
localparam F3_OR      = 3'b110;
localparam F3_AND     = 3'b111;
localparam F3_SR      = 3'b101;  // SRLI/SRAI

// Pipeline registers 
reg [31:0] pc_fetch, pc_id, pc_ex, pc_wb;
reg [31:0] ex_insn, ex_imm;
reg [4:0]  ex_rs1, ex_rs2, ex_rd;
reg [2:0]  ex_fn3;
reg        ex_fn7_alt, ex_store, ex_load, ex_alu_op, ex_mul_op;
reg        ex_lui, ex_auipc, ex_jal, ex_jalr, ex_branch, ex_sys, ex_sys_any;
reg        ex_illegal;

reg stall_q, flush_q;
reg exception;

// Register file 
localparam RF_DEPTH = (RV32E==1) ? 16 : 32;
reg [31:0] rf [RF_DEPTH-1:1];

//  Memory handshake 
assign dmem_rready = ex_load;
assign dmem_wready = ex_store;

// Fetch logic 

always @(posedge clk or negedge resetb) begin
    if(!resetb) begin
        pc_fetch <= RESETVEC;
        pc_id <= RESETVEC;
    end else if(!stall) begin
        pc_fetch <= pc_fetch + 4;
        pc_id <= pc_fetch;
    end
end

// Immediate decode 
always @* begin
    ex_imm = 32'd0;
    if(!stall_q) begin
        case (imem_rdata[6:0])
            OP_LUI, OP_AUIPC: ex_imm = {imem_rdata[31:12],12'd0};
            OP_JAL:          ex_imm = {{12{imem_rdata[31]}}, imem_rdata[19:12], imem_rdata[20], imem_rdata[30:21],1'b0};
            OP_JALR, OP_LOAD, OP_ARITHI: ex_imm = {{20{imem_rdata[31]}}, imem_rdata[31:20]};
            OP_BRANCH:       ex_imm = {{20{imem_rdata[31]}}, imem_rdata[7], imem_rdata[30:25], imem_rdata[11:8],1'b0};
            OP_STORE:        ex_imm = {{20{imem_rdata[31]}}, imem_rdata[31:25], imem_rdata[11:7]};
        endcase
    end
end

// ID → EX pipeline 
always @(posedge clk or negedge resetb) begin
    if(!resetb) begin
        ex_insn <= NOP; ex_rs1 <= 0; ex_rs2 <= 0; ex_rd <= 0;
        ex_fn3 <= 0; ex_store <= 0; ex_load <= 0; ex_alu_op <= 0;
        ex_mul_op <= 0; ex_lui <= 0; ex_auipc <= 0; ex_jal <= 0; ex_jalr <= 0;
        ex_branch <= 0; ex_sys <= 0; ex_sys_any <= 0; ex_illegal <= 0;
        flush_q <= 1;
        stall_q <= 1;
        exception <= 0;
    end else if(!stall) begin
        ex_insn <= imem_rdata;
        ex_rs1 <= imem_rdata[19:15];
        ex_rs2 <= imem_rdata[24:20];
        ex_rd  <= imem_rdata[11:7];
        ex_fn3 <= imem_rdata[14:12];
        ex_store <= (imem_rdata[6:0]==OP_STORE);
        ex_load  <= (imem_rdata[6:0]==OP_LOAD);
        ex_alu_op <= (imem_rdata[6:0]==OP_ARITHI) || (imem_rdata[6:0]==OP_ARITHR);
        ex_mul_op <= (RV32M==1) && (imem_rdata[6:0]==OP_ARITHR) && (imem_rdata[31:25]==7'h01);
        ex_lui <= (imem_rdata[6:0]==OP_LUI);
        ex_auipc <= (imem_rdata[6:0]==OP_AUIPC);
        ex_jal <= (imem_rdata[6:0]==OP_JAL);
        ex_jalr <= (imem_rdata[6:0]==OP_JALR);
        ex_branch <= (imem_rdata[6:0]==OP_BRANCH);
        ex_sys <= (imem_rdata[6:0]==OP_SYSTEM) && (imem_rdata[14:12]==3'b000);
        ex_sys_any <= (imem_rdata[6:0]==OP_SYSTEM);
        ex_illegal <= 0; // Can implement illegal instruction detection if needed
        flush_q <= 0;
        stall_q <= 0;
    end
end

// ALU (EX stage) 
wire [31:0] alu_a = (ex_rs1==0) ? 0 : rf[ex_rs1];
wire [31:0] alu_b = ex_alu_op ? ((ex_fn3==F3_SR)? {{27{1'b0}}, ex_insn[24:20]} : ex_imm) : (ex_rs2==0 ? 0 : rf[ex_rs2]);
reg  [31:0] alu_out;

always @* begin
    alu_out = 32'd0;
    if(ex_alu_op) begin
        case(ex_fn3)
            F3_ADD_SUB: alu_out = alu_a + alu_b;
            F3_AND:     alu_out = alu_a & alu_b;
            F3_OR:      alu_out = alu_a | alu_b;
            F3_XOR:     alu_out = alu_a ^ alu_b;
            F3_SLL:     alu_out = alu_a << alu_b[4:0];
            F3_SR:      alu_out = alu_a >> alu_b[4:0]; // SRLI (arithmetic shift not handled here)
            default:    alu_out = alu_a + alu_b;
        endcase
    end else if(ex_lui) alu_out = ex_imm;
    else if(ex_auipc) alu_out = pc_id + ex_imm;
    else if(ex_jal || ex_jalr) alu_out = pc_id + 4;
end

// WB stage 
always @(posedge clk) begin
    if(!stall) begin
        if(ex_rd != 0) rf[ex_rd] <= alu_out;
    end
end

endmodule
