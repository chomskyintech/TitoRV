// Directed RV32I instruction and AXI-Lite transaction tests for riscv_core.
`timescale 1ns/1ps
`default_nettype none

module tb_riscv_correctness;
    reg clk = 1'b0;
    reg resetb = 1'b0;
    always #5 clk = ~clk;

    wire [31:0] instr_addr;
    reg  [31:0] instr_rdata;

    wire [31:0] M_AXI_AWADDR;
    wire        M_AXI_AWVALID;
    reg         M_AXI_AWREADY = 1'b1;
    wire [31:0] M_AXI_WDATA;
    wire [3:0]  M_AXI_WSTRB;
    wire        M_AXI_WVALID;
    reg         M_AXI_WREADY = 1'b1;
    reg  [1:0]  M_AXI_BRESP = 2'b00;
    reg         M_AXI_BVALID = 1'b0;
    wire        M_AXI_BREADY;

    wire [31:0] M_AXI_ARADDR;
    wire        M_AXI_ARVALID;
    reg         M_AXI_ARREADY = 1'b1;
    reg  [31:0] M_AXI_RDATA = 32'd0;
    reg  [1:0]  M_AXI_RRESP = 2'b00;
    reg         M_AXI_RVALID = 1'b0;
    wire        M_AXI_RREADY;

    reg [31:0] rom  [0:255];
    reg [31:0] dmem [0:255];

    integer i;
    integer lane;
    reg finished = 1'b0;

    // Deterministic, independent backpressure on each address/data channel.
    integer cycle_count = 0;
    reg aw_seen = 1'b0;
    reg w_seen = 1'b0;
    reg [31:0] captured_awaddr = 32'd0;
    reg [31:0] captured_wdata = 32'd0;
    reg [3:0] captured_wstrb = 4'd0;
    reg b_delay_active = 1'b0;
    integer b_delay_count = 0;
    integer r_delay_count = 0;
    reg r_delay_active = 1'b0;
    reg [31:0] captured_araddr = 32'd0;
    integer aw_handshake_count = 0;
    integer w_handshake_count = 0;
    integer ar_handshake_count = 0;
    integer b_handshake_count = 0;
    integer r_handshake_count = 0;

    riscv_core dut (
        .clk(clk),
        .resetb(resetb),
        .instr_addr(instr_addr),
        .instr_rdata(instr_rdata),
        .M_AXI_AWADDR(M_AXI_AWADDR),
        .M_AXI_AWVALID(M_AXI_AWVALID),
        .M_AXI_AWREADY(M_AXI_AWREADY),
        .M_AXI_WDATA(M_AXI_WDATA),
        .M_AXI_WSTRB(M_AXI_WSTRB),
        .M_AXI_WVALID(M_AXI_WVALID),
        .M_AXI_WREADY(M_AXI_WREADY),
        .M_AXI_BRESP(M_AXI_BRESP),
        .M_AXI_BVALID(M_AXI_BVALID),
        .M_AXI_BREADY(M_AXI_BREADY),
        .M_AXI_ARADDR(M_AXI_ARADDR),
        .M_AXI_ARVALID(M_AXI_ARVALID),
        .M_AXI_ARREADY(M_AXI_ARREADY),
        .M_AXI_RDATA(M_AXI_RDATA),
        .M_AXI_RRESP(M_AXI_RRESP),
        .M_AXI_RVALID(M_AXI_RVALID),
        .M_AXI_RREADY(M_AXI_RREADY)
    );

    always @* instr_rdata = rom[instr_addr[9:2]];

    // Single-outstanding AXI-Lite memory model with independent channel
    // handshakes and delayed B/R responses. AW and W may arrive on different
    // cycles; the write commits only after both payloads have been captured.
    always @* begin
        M_AXI_AWREADY = resetb && ((cycle_count % 5) >= 2);
        M_AXI_WREADY  = resetb && ((cycle_count % 7) >= 4);
        M_AXI_ARREADY = resetb && ((cycle_count % 6) >= 3);
    end

    always @(posedge clk) begin
        if (!resetb) begin
            cycle_count       <= 0;
            aw_seen           <= 1'b0;
            w_seen            <= 1'b0;
            captured_awaddr   <= 32'd0;
            captured_wdata    <= 32'd0;
            captured_wstrb    <= 4'd0;
            b_delay_active    <= 1'b0;
            b_delay_count     <= 0;
            M_AXI_BVALID      <= 1'b0;
            M_AXI_BRESP       <= 2'b00;
            r_delay_active    <= 1'b0;
            r_delay_count     <= 0;
            captured_araddr   <= 32'd0;
            M_AXI_RVALID      <= 1'b0;
            M_AXI_RDATA       <= 32'd0;
            M_AXI_RRESP       <= 2'b00;
        end else begin
            cycle_count <= cycle_count + 1;

            if (M_AXI_AWVALID && M_AXI_AWREADY) aw_handshake_count <= aw_handshake_count + 1;
            if (M_AXI_WVALID && M_AXI_WREADY)   w_handshake_count  <= w_handshake_count + 1;
            if (M_AXI_ARVALID && M_AXI_ARREADY) ar_handshake_count <= ar_handshake_count + 1;
            if (M_AXI_BVALID && M_AXI_BREADY)   b_handshake_count  <= b_handshake_count + 1;
            if (M_AXI_RVALID && M_AXI_RREADY)   r_handshake_count  <= r_handshake_count + 1;

            if (M_AXI_AWVALID && M_AXI_AWREADY) begin
                aw_seen         <= 1'b1;
                captured_awaddr <= M_AXI_AWADDR;
            end
            if (M_AXI_WVALID && M_AXI_WREADY) begin
                w_seen        <= 1'b1;
                captured_wdata <= M_AXI_WDATA;
                captured_wstrb <= M_AXI_WSTRB;
            end

            if (!b_delay_active && !M_AXI_BVALID &&
                (aw_seen || (M_AXI_AWVALID && M_AXI_AWREADY)) &&
                (w_seen || (M_AXI_WVALID && M_AXI_WREADY))) begin
                for (lane = 0; lane < 4; lane = lane + 1) begin
                    if ((M_AXI_WVALID && M_AXI_WREADY) ? M_AXI_WSTRB[lane] : captured_wstrb[lane])
                        dmem[((M_AXI_AWVALID && M_AXI_AWREADY) ? M_AXI_AWADDR[9:2] : captured_awaddr[9:2])]
                            [lane*8 +: 8]
                            <= ((M_AXI_WVALID && M_AXI_WREADY) ? M_AXI_WDATA[lane*8 +: 8] : captured_wdata[lane*8 +: 8]);
                end
                b_delay_active <= 1'b1;
                b_delay_count  <= 2;
                aw_seen        <= 1'b0;
                w_seen         <= 1'b0;
            end

            if (b_delay_active && !M_AXI_BVALID) begin
                if (b_delay_count == 0) begin
                    M_AXI_BVALID <= 1'b1;
                    M_AXI_BRESP  <= 2'b00;
                    b_delay_active <= 1'b0;
                end else begin
                    b_delay_count <= b_delay_count - 1;
                end
            end
            if (M_AXI_BVALID && M_AXI_BREADY)
                M_AXI_BVALID <= 1'b0;

            if (M_AXI_ARVALID && M_AXI_ARREADY && !r_delay_active && !M_AXI_RVALID) begin
                captured_araddr <= M_AXI_ARADDR;
                r_delay_active  <= 1'b1;
                r_delay_count   <= 3;
            end
            if (r_delay_active && !M_AXI_RVALID) begin
                if (r_delay_count == 0) begin
                    M_AXI_RDATA    <= dmem[captured_araddr[9:2]];
                    M_AXI_RRESP    <= 2'b00;
                    M_AXI_RVALID   <= 1'b1;
                    r_delay_active <= 1'b0;
                end else begin
                    r_delay_count <= r_delay_count - 1;
                end
            end
            if (M_AXI_RVALID && M_AXI_RREADY)
                M_AXI_RVALID <= 1'b0;
        end
    end

    // Catch a replay of the first store instead of waiting for the watchdog.
    // Count distinct accepted AW and W channel handshakes for diagnostics.
    always @(posedge clk) begin
        if (resetb && !finished &&
            M_AXI_AWVALID && M_AXI_AWREADY &&
            M_AXI_WVALID && M_AXI_WREADY &&
            M_AXI_AWADDR == 32'd0 && dmem[0] == 32'd15) begin
            $display("FAIL: store at address 0 was reissued; inspect ex_valid/pipeline handling.");
            $fatal(1);
        end
    end

    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            rom[i]  = 32'h00000013; // NOP
            dmem[i] = 32'd0;
        end

        // Arithmetic, memory, taken/untaken BEQ, JAL, and a terminal loop.
        rom[0]  = 32'h00508093; // addi x1, x1, 5; catches duplicate first-instruction execution
        rom[1]  = 32'h00A00113; // addi x2, x0, 10
        rom[2]  = 32'h002081B3; // add  x3, x1, x2 => 15
        rom[3]  = 32'h40110233; // sub  x4, x2, x1 => 5
        rom[4]  = 32'h12345337; // lui  x6, 0x12345 => 0x12345000
        rom[5]  = 32'h00302023; // sw   x3, 0(x0)
        rom[6]  = 32'h00002283; // lw   x5, 0(x0) => 15
        rom[7]  = 32'h3FC00413; // addi x8, x0, 1020
        rom[8]  = 32'h05500493; // addi x9, x0, 85 (0x55)
        rom[9]  = 32'h00100513; // addi x10, x0, 1
        rom[10] = 32'h00100593; // addi x11, x0, 1
        rom[11] = 32'h00B50463; // beq x10, x11, +8 (taken; skip rom[12])
        rom[12] = 32'h06300613; // addi x12, x0, 99 (must be flushed)
        rom[13] = 32'h00700613; // addi x12, x0, 7
        rom[14] = 32'h00050463; // beq x10, x0, +8 (untaken)
        rom[15] = 32'h00800693; // addi x13, x0, 8
        rom[16] = 32'h0080076F; // jal x14, +8 (skip rom[17], link=PC+4)
        rom[17] = 32'h06300793; // addi x15, x0, 99 (must be flushed)
        rom[18] = 32'h00900813; // addi x16, x0, 9
        rom[19] = 32'h00504893; // xori x17, x0, 5
        rom[20] = 32'h0020F933; // and x18, x1, x2
        rom[21] = 32'h00000397; // auipc x7, 0
        rom[22] = 32'h0080e993; // ori x19, x1, 8
        rom[23] = 32'h00617a13; // andi x20, x2, 6
        rom[24] = 32'h0060aa93; // slti x21, x1, 6
        rom[25] = 32'h0060bb13; // sltiu x22, x1, 6
        rom[26] = 32'h00209b93; // slli x23, x1, 2
        rom[27] = 32'h00115c13; // srli x24, x2, 1
        rom[28] = 32'h40115c93; // srai x25, x2, 1
        rom[29] = 32'h0020cd33; // xor x26, x1, x2
        rom[30] = 32'h0020edb3; // or x27, x1, x2
        rom[31] = 32'h0020ae33; // slt x28, x1, x2
        rom[32] = 32'h0020beb3; // sltu x29, x1, x2
        rom[33] = 32'h00a09f33; // sll x30, x1, x10
        rom[34] = 32'h00a15fb3; // srl x31, x2, x10
        // Byte and halfword memory access tests at addresses 4..7.
        rom[35] = 32'h00900223; // sb   x9, 4(x0): byte 0x55
        rom[36] = 32'h00404603; // lbu  x12, 4(x0) => 85
        rom[37] = 32'h00400683; // lb   x13, 4(x0) => 85
        rom[38] = 32'hfff00793; // addi x15, x0, -1
        rom[39] = 32'h00f002a3; // sb   x15, 5(x0): byte 0xff
        rom[40] = 32'h00500803; // lb   x16, 5(x0) => -1
        rom[41] = 32'h00504883; // lbu  x17, 5(x0) => 255
        rom[42] = 32'h00201323; // sh   x2, 6(x0): halfword 10
        rom[43] = 32'h00601903; // lh   x18, 6(x0) => 10
        rom[44] = 32'h00605983; // lhu  x19, 6(x0) => 10
        // JALR must clear bit 0, write PC+4 to rd, and flush fall-through.
        rom[45] = 32'h00000b13; // addi x22, x0, 0 (clear sentinel)
        rom[46] = 32'h0c800513; // addi x10, x0, 200 (target byte address)
        rom[47] = 32'h00050a67; // jalr x20, 0(x10), target rom[48]
        rom[48] = 32'h06300b13; // addi x22, x0, 99 (must be flushed)
        rom[49] = 32'h00000013; // NOP at link address
        rom[50] = 32'h02a00a93; // target: addi x21, x0, 42
        // Exercise all six RV32I branch predicates with taken cases.
        // A failed predicate jumps to rom[100], preventing the signature.
        rom[51] = 32'h00108663; // beq  x1, x1, +12
        rom[52] = 32'h0c00006f; // failure path: jal to rom[100]
        rom[53] = 32'h00000013; // NOP
        rom[54] = 32'h00111663; // bne  x2, x1, +12
        rom[55] = 32'h0b40006f; // failure path: jal to rom[100]
        rom[56] = 32'h00000013; // NOP
        rom[57] = 32'h0020c663; // blt  x1, x2, +12
        rom[58] = 32'h0a80006f; // failure path: jal to rom[100]
        rom[59] = 32'h00000013; // NOP
        rom[60] = 32'h00115663; // bge  x2, x1, +12
        rom[61] = 32'h09c0006f; // failure path: jal to rom[100]
        rom[62] = 32'h00000013; // NOP
        rom[63] = 32'h0020e663; // bltu x1, x2, +12
        rom[64] = 32'h0900006f; // failure path: jal to rom[100]
        rom[65] = 32'h00000013; // NOP
        rom[66] = 32'h00117663; // bgeu x2, x1, +12
        rom[67] = 32'h0840006f; // failure path: jal to rom[100]
        rom[68] = 32'h00000013; // NOP
        // Signed arithmetic edge cases after the branch predicates.
        rom[69] = 32'h80000613; // addi x12, x0, -2048: minimum 12-bit immediate
        rom[70] = 32'hfff00693; // addi x13, x0, -1: sign extension
        rom[71] = 32'h0006a733; // slt  x14, x13, x0 => 1 (-1 < 0 signed)
        rom[72] = 32'h0006b7b3; // sltu x15, x13, x0 => 0 (0xffffffff < 0 unsigned is false)
        rom[73] = 32'h4016d813; // srai x16, x13, 1 => 0xffffffff
        rom[74] = 32'h0016d893; // srli x17, x13, 1 => 0x7fffffff
        rom[75] = 32'h00942023; // sw x9, 0(x8): completion signature
        rom[76] = 32'h0000006f; // terminal loop
        rom[100] = 32'h0000006f; // failure loop (watchdog must fire)

        repeat (5) @(posedge clk);
        resetb = 1'b1;
    end

    // Signature is written to byte address 1020 (word index 255).
    always @(posedge clk) begin
        if (resetb && !finished && dmem[255] == 32'h00000055 &&
            b_handshake_count == 5 && r_handshake_count == 7) begin
            finished = 1'b1;
            #1;
            $display("TitoRV directed correctness test results:");
            $display("x1=%08h x2=%08h x3=%08h x4=%08h", dut.rf[1], dut.rf[2], dut.rf[3], dut.rf[4]);
            $display("x5=%08h x6=%08h x8=%08h x9=%08h", dut.rf[5], dut.rf[6], dut.rf[8], dut.rf[9]);
            $display("mem[0]=%08h signature=%08h", dmem[0], dmem[255]);
            $display("byte/halfword word=%08h", dmem[1]);
            $display("AXI handshakes AW=%0d W=%0d B=%0d AR=%0d R=%0d", aw_handshake_count, w_handshake_count, b_handshake_count, ar_handshake_count, r_handshake_count);

            if (dut.rf[1] !== 32'd5 ||
                dut.rf[2] !== 32'd10 ||
                dut.rf[3] !== 32'd15 ||
                dut.rf[4] !== 32'd5 ||
                dut.rf[5] !== 32'd15 ||
                dut.rf[6] !== 32'h12345000 ||
                dut.rf[8] !== 32'd1020 ||
                dut.rf[9] !== 32'd85 ||
                dut.rf[10] !== 32'd200 ||
                dut.rf[11] !== 32'd1 ||
                dut.rf[12] !== 32'hfffff800 ||
                dut.rf[13] !== 32'hffffffff ||
                dut.rf[14] !== 32'd1 ||
                dut.rf[15] !== 32'd0 ||
                dut.rf[16] !== 32'hffffffff ||
                dut.rf[17] !== 32'h7fffffff ||
                dut.rf[18] !== 32'd10 ||
                dut.rf[7] !== 32'd84 ||
                dut.rf[19] !== 32'd10 ||
                dut.rf[20] !== 32'd192 ||
                dut.rf[21] !== 32'd42 ||
                dut.rf[22] !== 32'd0 ||
                dut.rf[23] !== 32'd20 ||
                dut.rf[24] !== 32'd5 ||
                dut.rf[25] !== 32'd5 ||
                dut.rf[26] !== 32'd15 ||
                dut.rf[27] !== 32'd15 ||
                dut.rf[28] !== 32'd1 ||
                dut.rf[29] !== 32'd1 ||
                dut.rf[30] !== 32'd10 ||
                dut.rf[31] !== 32'd5 ||
                dut.rf[0] !== 32'd0 ||
                aw_handshake_count !== 5 ||
                w_handshake_count !== 5 ||
                ar_handshake_count !== 7 ||
                b_handshake_count !== 5 ||
                r_handshake_count !== 7 ||
                dmem[0] !== 32'd15 ||
                dmem[1] !== 32'h000aff55 ||
                dmem[255] !== 32'd85) begin
                $display("FAIL: one or more architectural state checks mismatched.");
                $fatal(1);
            end else begin
                $display("PASS: arithmetic, control flow, byte/halfword load-store, AXI, and x0 checks passed.");
                $finish;
            end
        end
    end

    initial begin
        #10000;
        $display("FAIL: timeout before completion signature was written.");
        $display("PC=%08h AXI state=%0d", dut.pc, dut.axi_state);
        $fatal(1);
    end
endmodule

`default_nettype wire
