// Code your design here
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.06.2026 14:29:09
// Design Name: 
// Module Name: riscv_system_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
`include "riscv_core.v"
`include "instr_mem.v"


module riscv_system_top(

    input wire clk,
    input wire resetb,

    // AXI Write Address
    output wire [31:0] M_AXI_AWADDR,
    output wire        M_AXI_AWVALID,
    input  wire        M_AXI_AWREADY,

    // AXI Write Data
    output wire [31:0] M_AXI_WDATA,
    output wire [3:0]  M_AXI_WSTRB,
    output wire        M_AXI_WVALID,
    input  wire        M_AXI_WREADY,

    // AXI Write Response
    input  wire [1:0]  M_AXI_BRESP,
    input  wire        M_AXI_BVALID,
    output wire        M_AXI_BREADY,

    // AXI Read Address
    output wire [31:0] M_AXI_ARADDR,
    output wire        M_AXI_ARVALID,
    input  wire        M_AXI_ARREADY,

    // AXI Read Data
    input wire [31:0] M_AXI_RDATA,
    input wire [1:0]  M_AXI_RRESP,
    input wire        M_AXI_RVALID,
    output wire       M_AXI_RREADY

);
  
  
  //============================================================
// Instruction Memory Signals
//============================================================

wire [31:0] instr_addr;
wire [31:0] instr_rdata;

//============================================================
// RISC-V CPU
//============================================================

riscv_core cpu
(
    .clk(clk),
    .resetb(resetb),

    //---------------- Instruction ----------------

    .instr_addr(instr_addr),
    .instr_rdata(instr_rdata),

    //---------------- AXI Write Address ----------

    .M_AXI_AWADDR (M_AXI_AWADDR),
    .M_AXI_AWVALID(M_AXI_AWVALID),
    .M_AXI_AWREADY(M_AXI_AWREADY),

    //---------------- AXI Write Data -------------

    .M_AXI_WDATA (M_AXI_WDATA),
    .M_AXI_WSTRB (M_AXI_WSTRB),
    .M_AXI_WVALID(M_AXI_WVALID),
    .M_AXI_WREADY(M_AXI_WREADY),

    //---------------- AXI Write Response ---------

    .M_AXI_BRESP (M_AXI_BRESP),
    .M_AXI_BVALID(M_AXI_BVALID),
    .M_AXI_BREADY(M_AXI_BREADY),

    //---------------- AXI Read Address -----------

    .M_AXI_ARADDR (M_AXI_ARADDR),
    .M_AXI_ARVALID(M_AXI_ARVALID),
    .M_AXI_ARREADY(M_AXI_ARREADY),

    //---------------- AXI Read Data --------------

    .M_AXI_RDATA (M_AXI_RDATA),
    .M_AXI_RRESP (M_AXI_RRESP),
    .M_AXI_RVALID(M_AXI_RVALID),
    .M_AXI_RREADY(M_AXI_RREADY)
);

//============================================================
// Instruction Memory
//============================================================

instr_mem imem
(
    .addr (instr_addr),
    .rdata(instr_rdata)
);



endmodule

`default_nettype wire

