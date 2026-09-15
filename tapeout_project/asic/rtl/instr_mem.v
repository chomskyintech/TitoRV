`default_nettype none

module instr_mem (
    input  wire [31:0] addr,
    output reg  [31:0] rdata
);

// Deterministic, synthesis-friendly boot program.
//   0x00: addi x1, x0, 5
//   0x04: addi x2, x0, 10
//   0x08: add  x3, x1, x2
//   0x0c: sw   x3, 0(x0)
//   0x10: sw   x2, 4(x0)
//   0x14: lw   x4, 0(x0)
//   0x18: lw   x5, 4(x0)
//   0x1c: jal  x0, 0       (stop in a tight loop)
always @* begin
    case (addr[6:2])
        5'd0: rdata = 32'h00500093;
        5'd1: rdata = 32'h00A00113;
        5'd2: rdata = 32'h002081B3;
        5'd3: rdata = 32'h00302023;
        5'd4: rdata = 32'h00202223;
        5'd5: rdata = 32'h00002203;
        5'd6: rdata = 32'h00402283;
        5'd7: rdata = 32'h0000006F;
        default: rdata = 32'h00000013;
    endcase
end

endmodule

`default_nettype wire
