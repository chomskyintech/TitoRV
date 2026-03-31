// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vsim.h for the primary calling header

#ifndef VERILATED_VSIM___024ROOT_H_
#define VERILATED_VSIM___024ROOT_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"


class Vsim__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vsim___024root final {
  public:

    // DESIGN SPECIFIC STATE
    CData/*0:0*/ tb_riscv_core__DOT__clk;
    CData/*0:0*/ tb_riscv_core__DOT__resetb;
    CData/*0:0*/ tb_riscv_core__DOT__stall;
    CData/*0:0*/ tb_riscv_core__DOT__timer_irq;
    CData/*0:0*/ tb_riscv_core__DOT__sw_irq;
    CData/*0:0*/ tb_riscv_core__DOT__ext_irq;
    CData/*0:0*/ tb_riscv_core__DOT__imem_valid;
    CData/*0:0*/ tb_riscv_core__DOT__dmem_rvalid;
    CData/*3:0*/ tb_riscv_core__DOT__dmem_wstrb;
    CData/*4:0*/ tb_riscv_core__DOT__uut__DOT__ex_rs1;
    CData/*4:0*/ tb_riscv_core__DOT__uut__DOT__ex_rs2;
    CData/*4:0*/ tb_riscv_core__DOT__uut__DOT__ex_rd;
    CData/*2:0*/ tb_riscv_core__DOT__uut__DOT__ex_fn3;
    CData/*0:0*/ tb_riscv_core__DOT__uut__DOT__ex_fn7_alt;
    CData/*0:0*/ tb_riscv_core__DOT__uut__DOT__ex_store;
    CData/*0:0*/ tb_riscv_core__DOT__uut__DOT__ex_load;
    CData/*0:0*/ tb_riscv_core__DOT__uut__DOT__ex_alu_op;
    CData/*0:0*/ tb_riscv_core__DOT__uut__DOT__ex_mul_op;
    CData/*0:0*/ tb_riscv_core__DOT__uut__DOT__ex_lui;
    CData/*0:0*/ tb_riscv_core__DOT__uut__DOT__ex_auipc;
    CData/*0:0*/ tb_riscv_core__DOT__uut__DOT__ex_jal;
    CData/*0:0*/ tb_riscv_core__DOT__uut__DOT__ex_jalr;
    CData/*0:0*/ tb_riscv_core__DOT__uut__DOT__ex_branch;
    CData/*0:0*/ tb_riscv_core__DOT__uut__DOT__ex_sys;
    CData/*0:0*/ tb_riscv_core__DOT__uut__DOT__ex_sys_any;
    CData/*0:0*/ tb_riscv_core__DOT__uut__DOT__ex_illegal;
    CData/*0:0*/ tb_riscv_core__DOT__uut__DOT__stall_q;
    CData/*0:0*/ tb_riscv_core__DOT__uut__DOT__flush_q;
    CData/*0:0*/ tb_riscv_core__DOT__uut__DOT__exception;
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __Vtrigprevexpr___TOP__tb_riscv_core__DOT__clk__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__tb_riscv_core__DOT__resetb__0;
    IData/*31:0*/ tb_riscv_core__DOT__imem_rdata;
    IData/*31:0*/ tb_riscv_core__DOT__imem_addr;
    IData/*31:0*/ tb_riscv_core__DOT__dmem_rdata;
    IData/*31:0*/ tb_riscv_core__DOT__dmem_raddr;
    IData/*31:0*/ tb_riscv_core__DOT__dmem_wdata;
    IData/*31:0*/ tb_riscv_core__DOT__dmem_waddr;
    IData/*31:0*/ tb_riscv_core__DOT__uut__DOT____Vlvbound_h2373211c__0;
    IData/*31:0*/ tb_riscv_core__DOT__uut__DOT__pc_fetch;
    IData/*31:0*/ tb_riscv_core__DOT__uut__DOT__pc_id;
    IData/*31:0*/ tb_riscv_core__DOT__uut__DOT__pc_ex;
    IData/*31:0*/ tb_riscv_core__DOT__uut__DOT__pc_wb;
    IData/*31:0*/ tb_riscv_core__DOT__uut__DOT__ex_insn;
    IData/*31:0*/ tb_riscv_core__DOT__uut__DOT__ex_imm;
    IData/*31:0*/ tb_riscv_core__DOT__uut__DOT__alu_a;
    IData/*31:0*/ tb_riscv_core__DOT__uut__DOT__alu_b;
    IData/*31:0*/ tb_riscv_core__DOT__uut__DOT__alu_out;
    IData/*31:0*/ __VactIterCount;
    VlUnpacked<IData/*31:0*/, 31> tb_riscv_core__DOT__uut__DOT__rf;
    VlUnpacked<QData/*63:0*/, 1> __VstlTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VactTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VnbaTriggered;
    VlUnpacked<CData/*0:0*/, 6> __Vm_traceActivity;
    VlDelayScheduler __VdlySched;

    // INTERNAL VARIABLES
    Vsim__Syms* vlSymsp;
    const char* vlNamep;

    // CONSTRUCTORS
    Vsim___024root(Vsim__Syms* symsp, const char* namep);
    ~Vsim___024root();
    VL_UNCOPYABLE(Vsim___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
