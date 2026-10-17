`timescale 1ns/1ps
`default_nettype none

// ALU boundary regression: signed/unsigned comparisons, overflow wrapping,
// immediate sign extension, shift semantics, x0 hardwiring, and dependencies.
module tb_riscv_alu_edges;
    reg clk = 1'b0;
    reg resetb = 1'b0;
    always #5 clk = ~clk;

    wire [31:0] instr_addr;
    reg  [31:0] instr_rdata;
    wire trap_valid;
    wire [31:0] trap_pc, trap_cause;
    wire [31:0] awaddr, wdata, araddr;
    wire [3:0] wstrb;
    wire awvalid, wvalid, bready, arvalid, rready;
    reg awready = 1'b0, wready = 1'b0, bvalid = 1'b0;
    reg arready = 1'b0, rvalid = 1'b0;
    reg [31:0] rdata = 32'd0;
    reg [1:0] bresp = 2'b00, rresp = 2'b00;
    reg [31:0] rom [0:31];
    integer i;
    integer idx = 0;

    function [31:0] enc_i;
        input integer imm;
        input [4:0] rs1;
        input [2:0] funct3;
        input [4:0] rd;
        input [6:0] opcode;
        reg [11:0] imm12;
        begin
            imm12 = imm[11:0];
            enc_i = {imm12, rs1, funct3, rd, opcode};
        end
    endfunction

    function [31:0] enc_r;
        input [6:0] funct7;
        input [4:0] rs2;
        input [4:0] rs1;
        input [2:0] funct3;
        input [4:0] rd;
        begin
            enc_r = {funct7, rs2, rs1, funct3, rd, 7'b0110011};
        end
    endfunction

    task emit;
        input [31:0] instruction;
        begin
            rom[idx] = instruction;
            idx = idx + 1;
        end
    endtask

    riscv_core dut (
        .clk(clk), .resetb(resetb),
        .instr_addr(instr_addr), .instr_rdata(instr_rdata),
        .trap_valid(trap_valid), .trap_pc(trap_pc), .trap_cause(trap_cause),
        .M_AXI_AWADDR(awaddr), .M_AXI_AWVALID(awvalid), .M_AXI_AWREADY(awready),
        .M_AXI_WDATA(wdata), .M_AXI_WSTRB(wstrb), .M_AXI_WVALID(wvalid), .M_AXI_WREADY(wready),
        .M_AXI_BRESP(bresp), .M_AXI_BVALID(bvalid), .M_AXI_BREADY(bready),
        .M_AXI_ARADDR(araddr), .M_AXI_ARVALID(arvalid), .M_AXI_ARREADY(arready),
        .M_AXI_RDATA(rdata), .M_AXI_RRESP(rresp), .M_AXI_RVALID(rvalid), .M_AXI_RREADY(rready)
    );

    always @* instr_rdata = rom[instr_addr[6:2]];

    initial begin
        for (i = 0; i < 32; i = i + 1)
            rom[i] = 32'h00000013;

        emit(enc_i(-2048, 5'd0, 3'b000, 5'd1, 7'b0010011)); // x1 = -2048
        emit(enc_i( 2047, 5'd0, 3'b000, 5'd2, 7'b0010011)); // x2 = 2047
        emit(enc_r(7'b0000000, 5'd2, 5'd1, 3'b010, 5'd3)); // slt  x3,x1,x2 = 1
        emit(enc_r(7'b0000000, 5'd2, 5'd1, 3'b011, 5'd4)); // sltu x4,x1,x2 = 0
        emit(enc_i(-1, 5'd1, 3'b010, 5'd5, 7'b0010011)); // slti  x5,x1,-1 = 1
        emit(enc_i(-1, 5'd1, 3'b011, 5'd6, 7'b0010011)); // sltiu x6,x1,-1 = 1
        emit(enc_i(-1, 5'd0, 3'b000, 5'd7, 7'b0010011)); // x7 = 0xffffffff
        emit(enc_i(12'h41f, 5'd7, 3'b101, 5'd8, 7'b0010011)); // srai x8,x7,31 = -1
        emit(enc_i(12'h01f, 5'd7, 3'b101, 5'd9, 7'b0010011)); // srli x9,x7,31 = 1
        emit(enc_i(12'h01f, 5'd2, 3'b001, 5'd10, 7'b0010011)); // slli x10,x2,31 = 0x80000000
        emit(enc_i(2047, 5'd0, 3'b000, 5'd11, 7'b0010011)); // x11 = 2047
        emit(enc_i(1, 5'd11, 3'b000, 5'd12, 7'b0010011)); // dependency: x12 = 2048
        emit(enc_i(-2048, 5'd0, 3'b000, 5'd13, 7'b0010011)); // x13 = -2048
        emit(enc_i(-1, 5'd13, 3'b000, 5'd14, 7'b0010011)); // dependency: x14 = -2049
        emit(enc_r(7'b0000000, 5'd7, 5'd1, 3'b100, 5'd15)); // xor = 0x7ff
        emit(enc_r(7'b0000000, 5'd7, 5'd1, 3'b111, 5'd16)); // and = 0xfffff800
        emit(enc_r(7'b0000000, 5'd2, 5'd1, 3'b110, 5'd17)); // or = 0xffffffff
        emit(enc_r(7'b0000000, 5'd1, 5'd2, 3'b000, 5'd18)); // add overflow wraps to -1
        emit(enc_r(7'b0100000, 5'd1, 5'd2, 3'b000, 5'd19)); // sub = 4095
        emit(enc_i(123, 5'd0, 3'b000, 5'd0, 7'b0010011)); // attempted x0 write
        emit(enc_i(1, 5'd0, 3'b000, 5'd20, 7'b0010011)); // x0 must still read zero
        emit(enc_r(7'b0000000, 5'd2, 5'd20, 3'b001, 5'd21)); // sll by low 5 bits of x2
        emit(enc_r(7'b0000000, 5'd2, 5'd7, 3'b101, 5'd22)); // srl by 31 = 1
        emit(enc_r(7'b0100000, 5'd2, 5'd7, 3'b101, 5'd23)); // sra by 31 = -1
        emit(enc_r(7'b0000000, 5'd2, 5'd7, 3'b010, 5'd24)); // signed -1 < 2047
        emit(enc_r(7'b0000000, 5'd2, 5'd7, 3'b011, 5'd25)); // unsigned -1 < 2047 is false
        emit(enc_i(77, 5'd0, 3'b000, 5'd31, 7'b0010011)); // completion sentinel
        emit(32'h0000006f); // jal x0,0: stable terminal loop

        if (idx != 28) begin
            $display("FAIL: expected 28 instructions, assembled %0d", idx);
            $fatal(1);
        end

        repeat (5) @(posedge clk);
        resetb = 1'b1;
        wait (dut.rf[31] === 32'd77);
        repeat (5) @(posedge clk);
        #1;

        if (dut.rf[0]  !== 32'd0 ||
            dut.rf[1]  !== 32'hfffff800 ||
            dut.rf[2]  !== 32'd2047 ||
            dut.rf[3]  !== 32'd1 ||
            dut.rf[4]  !== 32'd0 ||
            dut.rf[5]  !== 32'd1 ||
            dut.rf[6]  !== 32'd1 ||
            dut.rf[7]  !== 32'hffffffff ||
            dut.rf[8]  !== 32'hffffffff ||
            dut.rf[9]  !== 32'd1 ||
            dut.rf[10] !== 32'h80000000 ||
            dut.rf[11] !== 32'd2047 ||
            dut.rf[12] !== 32'd2048 ||
            dut.rf[13] !== 32'hfffff800 ||
            dut.rf[14] !== 32'hfffff7ff ||
            dut.rf[15] !== 32'h000007ff ||
            dut.rf[16] !== 32'hfffff800 ||
            dut.rf[17] !== 32'hffffffff ||
            dut.rf[18] !== 32'hffffffff ||
            dut.rf[19] !== 32'd4095 ||
            dut.rf[20] !== 32'd1 ||
            dut.rf[21] !== 32'h80000000 ||
            dut.rf[22] !== 32'd1 ||
            dut.rf[23] !== 32'hffffffff ||
            dut.rf[24] !== 32'd1 ||
            dut.rf[25] !== 32'd0 ||
            dut.rf[31] !== 32'd77 ||
            trap_valid !== 1'b0) begin
            $display("FAIL: ALU boundary mismatch");
            $display("x1=%h x2=%h x3=%h x4=%h x5=%h x6=%h", dut.rf[1], dut.rf[2], dut.rf[3], dut.rf[4], dut.rf[5], dut.rf[6]);
            $display("x7=%h x8=%h x9=%h x10=%h x12=%h x14=%h", dut.rf[7], dut.rf[8], dut.rf[9], dut.rf[10], dut.rf[12], dut.rf[14]);
            $display("x15=%h x16=%h x17=%h x18=%h x19=%h x21=%h", dut.rf[15], dut.rf[16], dut.rf[17], dut.rf[18], dut.rf[19], dut.rf[21]);
            $display("trap_valid=%b pc=%h cause=%h", trap_valid, trap_pc, trap_cause);
            $fatal(1);
        end

        $display("PASS: ALU signedness, overflow, shifts, dependencies, and x0 boundary checks passed.");
        $finish;
    end

    initial begin
        #20000;
        $display("FAIL: ALU boundary regression timed out at PC=%08h", dut.pc);
        $fatal(1);
    end
endmodule

`default_nettype wire
