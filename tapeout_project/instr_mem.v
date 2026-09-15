`default_nettype none
`timescale 1ns/1ps

module instr_mem
(
    input  wire [31:0] addr,
    output reg  [31:0] rdata
);

    reg [31:0] rom [0:255];

    integer i;

    integer data1;
    integer data2;
    integer expected_sum;

    //=========================================================
    // Build ADDI instruction
    //
    // ADDI rd, rs1, imm
    // opcode = 0010011
    // funct3 = 000
    //=========================================================

    function [31:0] make_addi;

        input [4:0] rd;
        input [4:0] rs1;
        input integer imm;

        begin

            make_addi =
                {imm[11:0],
                 rs1,
                 3'b000,
                 rd,
                 7'b0010011};

        end

    endfunction


    //=========================================================
    // Initialize ROM
    //=========================================================

    initial
    begin

        // Fill ROM with NOPs

        for(i = 0; i < 256; i = i + 1)
            rom[i] = 32'h00000013;


        //=====================================================
        // Generate constrained-random operands
        //=====================================================

        data1 = $urandom_range(0, 2047);
        data2 = $urandom_range(0, 2047);

        expected_sum = data1 + data2;


        $display("");
        $display("======================================");
        $display("     RANDOM RISC-V TEST PROGRAM");
        $display("======================================");

        $display("Random data1       = %0d (%08h)",
                 data1, data1);

        $display("Random data2       = %0d (%08h)",
                 data2, data2);

        $display("Expected x3        = %0d (%08h)",
                 expected_sum, expected_sum);

        $display("Expected x4        = %0d (%08h)",
                 expected_sum, expected_sum);

        $display("Expected x5        = %0d (%08h)",
                 data2, data2);

        $display("======================================");
        $display("");


        //=====================================================
        // Randomized RISC-V program
        //=====================================================

        // addi x1,x0,data1
        rom[0] = make_addi(
                    5'd1,
                    5'd0,
                    data1
                 );


        // addi x2,x0,data2
        rom[1] = make_addi(
                    5'd2,
                    5'd0,
                    data2
                 );


        // add x3,x1,x2
        rom[2] = 32'h002081B3;


        // sw x3,0(x0)
        rom[3] = 32'h00302023;


        // sw x2,4(x0)
        rom[4] = 32'h00202223;


        // lw x4,0(x0)
        rom[5] = 32'h00002203;


        // lw x5,4(x0)
        rom[6] = 32'h00402283;


        // nop
        rom[7] = 32'h00000013;

    end


    //=========================================================
    // Combinational instruction read
    //=========================================================

    always @(*)
    begin

        rdata = rom[addr[9:2]];

    end

endmodule

`default_nettype wire