// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vsim.h for the primary calling header

#include "Vsim__pch.h"

VL_ATTR_COLD void Vsim___024root___eval_initial__TOP(Vsim___024root* vlSelf);
VlCoroutine Vsim___024root___eval_initial__TOP__Vtiming__0(Vsim___024root* vlSelf);
VlCoroutine Vsim___024root___eval_initial__TOP__Vtiming__1(Vsim___024root* vlSelf);

void Vsim___024root___eval_initial(Vsim___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___eval_initial\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vsim___024root___eval_initial__TOP(vlSelf);
    vlSelfRef.__Vm_traceActivity[1U] = 1U;
    Vsim___024root___eval_initial__TOP__Vtiming__0(vlSelf);
    Vsim___024root___eval_initial__TOP__Vtiming__1(vlSelf);
}

VlCoroutine Vsim___024root___eval_initial__TOP__Vtiming__0(Vsim___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___eval_initial__TOP__Vtiming__0\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSymsp->_vm_contextp__->dumpfile("dump.vcd"s);
    vlSymsp->_traceDumpOpen();
    vlSelfRef.tb_riscv_core__DOT__resetb = 0U;
    vlSelfRef.tb_riscv_core__DOT__stall = 0U;
    vlSelfRef.tb_riscv_core__DOT__timer_irq = 0U;
    vlSelfRef.tb_riscv_core__DOT__sw_irq = 0U;
    vlSelfRef.tb_riscv_core__DOT__ext_irq = 0U;
    vlSelfRef.tb_riscv_core__DOT__imem_rdata = 0x00000013U;
    vlSelfRef.tb_riscv_core__DOT__imem_valid = 1U;
    vlSelfRef.tb_riscv_core__DOT__dmem_rvalid = 0U;
    co_await vlSelfRef.__VdlySched.delay(0x0000000000004e20ULL, 
                                         nullptr, "testbench.sv", 
                                         85);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.tb_riscv_core__DOT__resetb = 1U;
    co_await vlSelfRef.__VdlySched.delay(0x0000000000002710ULL, 
                                         nullptr, "testbench.sv", 
                                         88);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.tb_riscv_core__DOT__imem_rdata = 0x123450b7U;
    co_await vlSelfRef.__VdlySched.delay(0x0000000000002710ULL, 
                                         nullptr, "testbench.sv", 
                                         89);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.tb_riscv_core__DOT__imem_rdata = 0x00508193U;
    co_await vlSelfRef.__VdlySched.delay(0x0000000000002710ULL, 
                                         nullptr, "testbench.sv", 
                                         90);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.tb_riscv_core__DOT__imem_rdata = 0x003082b3U;
    co_await vlSelfRef.__VdlySched.delay(0x0000000000002710ULL, 
                                         nullptr, "testbench.sv", 
                                         91);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.tb_riscv_core__DOT__imem_rdata = 0x003092b3U;
    co_await vlSelfRef.__VdlySched.delay(0x0000000000002710ULL, 
                                         nullptr, "testbench.sv", 
                                         94);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.tb_riscv_core__DOT__dmem_rvalid = 1U;
    co_await vlSelfRef.__VdlySched.delay(0x0000000000002710ULL, 
                                         nullptr, "testbench.sv", 
                                         95);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.tb_riscv_core__DOT__dmem_rvalid = 0U;
    co_await vlSelfRef.__VdlySched.delay(0x000000000000c350ULL, 
                                         nullptr, "testbench.sv", 
                                         98);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    VL_WRITEF_NX("Simulation finished\n",0);
    VL_FINISH_MT("testbench.sv", 100, "");
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    co_return;}

VlCoroutine Vsim___024root___eval_initial__TOP__Vtiming__1(Vsim___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___eval_initial__TOP__Vtiming__1\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    while (VL_LIKELY(!vlSymsp->_vm_contextp__->gotFinish())) {
        co_await vlSelfRef.__VdlySched.delay(0x0000000000001388ULL, 
                                             nullptr, 
                                             "testbench.sv", 
                                             52);
        vlSelfRef.tb_riscv_core__DOT__clk = (1U & (~ (IData)(vlSelfRef.tb_riscv_core__DOT__clk)));
    }
    co_return;}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vsim___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

void Vsim___024root___eval_triggers__act(Vsim___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___eval_triggers__act\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VactTriggered[0U] = (QData)((IData)(
                                                    ((vlSelfRef.__VdlySched.awaitingCurrentTime() 
                                                      << 2U) 
                                                     | ((((~ (IData)(vlSelfRef.tb_riscv_core__DOT__resetb)) 
                                                          & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_riscv_core__DOT__resetb__0)) 
                                                         << 1U) 
                                                        | ((IData)(vlSelfRef.tb_riscv_core__DOT__clk) 
                                                           & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_riscv_core__DOT__clk__0)))))));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_riscv_core__DOT__clk__0 
        = vlSelfRef.tb_riscv_core__DOT__clk;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_riscv_core__DOT__resetb__0 
        = vlSelfRef.tb_riscv_core__DOT__resetb;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vsim___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
    }
#endif
}

bool Vsim___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___trigger_anySet__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        if (in[n]) {
            return (1U);
        }
        n = ((IData)(1U) + n);
    } while ((1U > n));
    return (0U);
}

void Vsim___024root___act_sequent__TOP__0(Vsim___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___act_sequent__TOP__0\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ tb_riscv_core__DOT__uut__DOT____VdfgExtracted_h0c6d2982__0;
    tb_riscv_core__DOT__uut__DOT____VdfgExtracted_h0c6d2982__0 = 0;
    // Body
    vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_imm = 0U;
    if ((1U & (~ (IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__stall_q)))) {
        if (((0x37U == (0x0000007fU & vlSelfRef.tb_riscv_core__DOT__imem_rdata)) 
             || (0x17U == (0x0000007fU & vlSelfRef.tb_riscv_core__DOT__imem_rdata)))) {
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_imm 
                = (0xfffff000U & vlSelfRef.tb_riscv_core__DOT__imem_rdata);
        } else if ((0x6fU == (0x0000007fU & vlSelfRef.tb_riscv_core__DOT__imem_rdata))) {
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_imm 
                = (((- (IData)((vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                                >> 0x1fU))) << 0x00000014U) 
                   | ((((0x000001feU & (vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                                        >> 0x0000000bU)) 
                        | (1U & (vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                                 >> 0x14U))) << 0x0000000bU) 
                      | (0x000007feU & (vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                                        >> 0x00000014U))));
        } else if ((((0x67U == (0x0000007fU & vlSelfRef.tb_riscv_core__DOT__imem_rdata)) 
                     || (3U == (0x0000007fU & vlSelfRef.tb_riscv_core__DOT__imem_rdata))) 
                    || (0x13U == (0x0000007fU & vlSelfRef.tb_riscv_core__DOT__imem_rdata)))) {
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_imm 
                = (((- (IData)((vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                                >> 0x1fU))) << 0x0000000cU) 
                   | (vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                      >> 0x14U));
        } else if ((0x63U == (0x0000007fU & vlSelfRef.tb_riscv_core__DOT__imem_rdata))) {
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_imm 
                = (((- (IData)((vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                                >> 0x1fU))) << 0x0000000cU) 
                   | ((0x00000800U & (vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                                      << 4U)) | ((0x000007e0U 
                                                  & (vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                                                     >> 0x00000014U)) 
                                                 | (0x0000001eU 
                                                    & (vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                                                       >> 7U)))));
        } else if ((0x23U == (0x0000007fU & vlSelfRef.tb_riscv_core__DOT__imem_rdata))) {
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_imm 
                = (((- (IData)((vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                                >> 0x1fU))) << 0x0000000cU) 
                   | ((0x00000fe0U & (vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                                      >> 0x00000014U)) 
                      | (0x0000001fU & (vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                                        >> 7U))));
        }
    }
    vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_b = 
        ((IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_alu_op)
          ? ((5U == (IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_fn3))
              ? (0x0000001fU & (vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_insn 
                                >> 0x00000014U)) : vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_imm)
          : ((0U == (IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_rs2))
              ? 0U : ((0x1eU >= (0x0000001fU & ((IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_rs2) 
                                                - (IData)(1U))))
                       ? vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf
                      [(0x0000001fU & ((IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_rs2) 
                                       - (IData)(1U)))]
                       : 0U)));
    tb_riscv_core__DOT__uut__DOT____VdfgExtracted_h0c6d2982__0 
        = (vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_a 
           + vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_b);
    vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_out = 0U;
    if (vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_alu_op) {
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_out 
            = ((4U & (IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_fn3))
                ? ((2U & (IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_fn3))
                    ? ((1U & (IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_fn3))
                        ? (vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_a 
                           & vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_b)
                        : (vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_a 
                           | vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_b))
                    : ((1U & (IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_fn3))
                        ? (vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_a 
                           >> (0x0000001fU & vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_b))
                        : (vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_a 
                           ^ vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_b)))
                : ((2U & (IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_fn3))
                    ? tb_riscv_core__DOT__uut__DOT____VdfgExtracted_h0c6d2982__0
                    : ((1U & (IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_fn3))
                        ? (vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_a 
                           << (0x0000001fU & vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_b))
                        : tb_riscv_core__DOT__uut__DOT____VdfgExtracted_h0c6d2982__0)));
    } else if (vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_lui) {
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_out 
            = vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_imm;
    } else if (vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_auipc) {
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_out 
            = (vlSelfRef.tb_riscv_core__DOT__uut__DOT__pc_id 
               + vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_imm);
    } else if (((IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_jal) 
                | (IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_jalr))) {
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_out 
            = ((IData)(4U) + vlSelfRef.tb_riscv_core__DOT__uut__DOT__pc_id);
    }
}

void Vsim___024root___eval_act(Vsim___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___eval_act\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((4ULL & vlSelfRef.__VactTriggered[0U])) {
        Vsim___024root___act_sequent__TOP__0(vlSelf);
    }
}

void Vsim___024root___nba_sequent__TOP__0(Vsim___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___nba_sequent__TOP__0\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __Vdly__tb_riscv_core__DOT__uut__DOT__pc_fetch;
    __Vdly__tb_riscv_core__DOT__uut__DOT__pc_fetch = 0;
    // Body
    __Vdly__tb_riscv_core__DOT__uut__DOT__pc_fetch 
        = vlSelfRef.tb_riscv_core__DOT__uut__DOT__pc_fetch;
    if (vlSelfRef.tb_riscv_core__DOT__resetb) {
        if ((1U & (~ (IData)(vlSelfRef.tb_riscv_core__DOT__stall)))) {
            vlSelfRef.tb_riscv_core__DOT__imem_addr 
                = ((IData)(4U) + vlSelfRef.tb_riscv_core__DOT__imem_addr);
            vlSelfRef.tb_riscv_core__DOT__dmem_raddr 
                = ((IData)(4U) + vlSelfRef.tb_riscv_core__DOT__dmem_raddr);
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_illegal = 0U;
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__flush_q = 0U;
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_mul_op 
                = (IData)((0x02000033U == (0xfe00007fU 
                                           & vlSelfRef.tb_riscv_core__DOT__imem_rdata)));
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_load 
                = (3U == (0x0000007fU & vlSelfRef.tb_riscv_core__DOT__imem_rdata));
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_store 
                = (0x23U == (0x0000007fU & vlSelfRef.tb_riscv_core__DOT__imem_rdata));
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_branch 
                = (0x63U == (0x0000007fU & vlSelfRef.tb_riscv_core__DOT__imem_rdata));
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_sys 
                = (IData)((0x00000073U == (0x0000707fU 
                                           & vlSelfRef.tb_riscv_core__DOT__imem_rdata)));
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_sys_any 
                = (0x73U == (0x0000007fU & vlSelfRef.tb_riscv_core__DOT__imem_rdata));
            __Vdly__tb_riscv_core__DOT__uut__DOT__pc_fetch 
                = ((IData)(4U) + vlSelfRef.tb_riscv_core__DOT__uut__DOT__pc_fetch);
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__pc_id 
                = vlSelfRef.tb_riscv_core__DOT__uut__DOT__pc_fetch;
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_auipc 
                = (0x17U == (0x0000007fU & vlSelfRef.tb_riscv_core__DOT__imem_rdata));
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_lui 
                = (0x37U == (0x0000007fU & vlSelfRef.tb_riscv_core__DOT__imem_rdata));
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_jal 
                = (0x6fU == (0x0000007fU & vlSelfRef.tb_riscv_core__DOT__imem_rdata));
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_jalr 
                = (0x67U == (0x0000007fU & vlSelfRef.tb_riscv_core__DOT__imem_rdata));
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_rs1 
                = (0x0000001fU & (vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                                  >> 0x0fU));
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_rs2 
                = (0x0000001fU & (vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                                  >> 0x14U));
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_insn 
                = vlSelfRef.tb_riscv_core__DOT__imem_rdata;
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__stall_q = 0U;
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_fn3 
                = (7U & (vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                         >> 0x0cU));
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_alu_op 
                = ((0x13U == (0x0000007fU & vlSelfRef.tb_riscv_core__DOT__imem_rdata)) 
                   | (0x33U == (0x0000007fU & vlSelfRef.tb_riscv_core__DOT__imem_rdata)));
        }
    } else {
        vlSelfRef.tb_riscv_core__DOT__imem_addr = 0U;
        vlSelfRef.tb_riscv_core__DOT__dmem_raddr = 0U;
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_illegal = 0U;
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__flush_q = 1U;
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_mul_op = 0U;
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_load = 0U;
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_store = 0U;
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_branch = 0U;
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_sys = 0U;
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_sys_any = 0U;
        __Vdly__tb_riscv_core__DOT__uut__DOT__pc_fetch = 0U;
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__pc_id = 0U;
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_auipc = 0U;
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_lui = 0U;
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_jal = 0U;
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_jalr = 0U;
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_rs1 = 0U;
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_rs2 = 0U;
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_insn = 0x00000013U;
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__stall_q = 1U;
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_fn3 = 0U;
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_alu_op = 0U;
    }
    if ((1U & (~ (IData)(vlSelfRef.tb_riscv_core__DOT__resetb)))) {
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__exception = 0U;
    }
    vlSelfRef.tb_riscv_core__DOT__uut__DOT__pc_fetch 
        = __Vdly__tb_riscv_core__DOT__uut__DOT__pc_fetch;
}

void Vsim___024root___nba_sequent__TOP__1(Vsim___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___nba_sequent__TOP__1\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VdlyVal__tb_riscv_core__DOT__uut__DOT__rf__v0;
    __VdlyVal__tb_riscv_core__DOT__uut__DOT__rf__v0 = 0;
    CData/*4:0*/ __VdlyDim0__tb_riscv_core__DOT__uut__DOT__rf__v0;
    __VdlyDim0__tb_riscv_core__DOT__uut__DOT__rf__v0 = 0;
    CData/*0:0*/ __VdlySet__tb_riscv_core__DOT__uut__DOT__rf__v0;
    __VdlySet__tb_riscv_core__DOT__uut__DOT__rf__v0 = 0;
    // Body
    if (VL_UNLIKELY(((0U != (IData)(vlSelfRef.tb_riscv_core__DOT__dmem_wstrb))))) {
        VL_WRITEF_NX("Write: addr=%x data=%x strb=%b\n",0,
                     32,vlSelfRef.tb_riscv_core__DOT__dmem_waddr,
                     32,vlSelfRef.tb_riscv_core__DOT__dmem_wdata,
                     4,(IData)(vlSelfRef.tb_riscv_core__DOT__dmem_wstrb));
    }
    __VdlySet__tb_riscv_core__DOT__uut__DOT__rf__v0 = 0U;
    if ((1U & (~ (IData)(vlSelfRef.tb_riscv_core__DOT__stall)))) {
        if ((0U != (IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_rd))) {
            vlSelfRef.tb_riscv_core__DOT__uut__DOT____Vlvbound_h2373211c__0 
                = vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_out;
            if ((0x1eU >= (0x0000001fU & ((IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_rd) 
                                          - (IData)(1U))))) {
                __VdlyVal__tb_riscv_core__DOT__uut__DOT__rf__v0 
                    = vlSelfRef.tb_riscv_core__DOT__uut__DOT____Vlvbound_h2373211c__0;
                __VdlyDim0__tb_riscv_core__DOT__uut__DOT__rf__v0 
                    = (0x0000001fU & ((IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_rd) 
                                      - (IData)(1U)));
                __VdlySet__tb_riscv_core__DOT__uut__DOT__rf__v0 = 1U;
            }
        }
    }
    if (vlSelfRef.tb_riscv_core__DOT__dmem_rvalid) {
        vlSelfRef.tb_riscv_core__DOT__dmem_rdata = 0xdeadbeefU;
    }
    if (__VdlySet__tb_riscv_core__DOT__uut__DOT__rf__v0) {
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[__VdlyDim0__tb_riscv_core__DOT__uut__DOT__rf__v0] 
            = __VdlyVal__tb_riscv_core__DOT__uut__DOT__rf__v0;
    }
}

void Vsim___024root___nba_comb__TOP__0(Vsim___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___nba_comb__TOP__0\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_imm = 0U;
    if ((1U & (~ (IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__stall_q)))) {
        if (((0x37U == (0x0000007fU & vlSelfRef.tb_riscv_core__DOT__imem_rdata)) 
             || (0x17U == (0x0000007fU & vlSelfRef.tb_riscv_core__DOT__imem_rdata)))) {
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_imm 
                = (0xfffff000U & vlSelfRef.tb_riscv_core__DOT__imem_rdata);
        } else if ((0x6fU == (0x0000007fU & vlSelfRef.tb_riscv_core__DOT__imem_rdata))) {
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_imm 
                = (((- (IData)((vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                                >> 0x1fU))) << 0x00000014U) 
                   | ((((0x000001feU & (vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                                        >> 0x0000000bU)) 
                        | (1U & (vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                                 >> 0x14U))) << 0x0000000bU) 
                      | (0x000007feU & (vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                                        >> 0x00000014U))));
        } else if ((((0x67U == (0x0000007fU & vlSelfRef.tb_riscv_core__DOT__imem_rdata)) 
                     || (3U == (0x0000007fU & vlSelfRef.tb_riscv_core__DOT__imem_rdata))) 
                    || (0x13U == (0x0000007fU & vlSelfRef.tb_riscv_core__DOT__imem_rdata)))) {
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_imm 
                = (((- (IData)((vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                                >> 0x1fU))) << 0x0000000cU) 
                   | (vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                      >> 0x14U));
        } else if ((0x63U == (0x0000007fU & vlSelfRef.tb_riscv_core__DOT__imem_rdata))) {
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_imm 
                = (((- (IData)((vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                                >> 0x1fU))) << 0x0000000cU) 
                   | ((0x00000800U & (vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                                      << 4U)) | ((0x000007e0U 
                                                  & (vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                                                     >> 0x00000014U)) 
                                                 | (0x0000001eU 
                                                    & (vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                                                       >> 7U)))));
        } else if ((0x23U == (0x0000007fU & vlSelfRef.tb_riscv_core__DOT__imem_rdata))) {
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_imm 
                = (((- (IData)((vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                                >> 0x1fU))) << 0x0000000cU) 
                   | ((0x00000fe0U & (vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                                      >> 0x00000014U)) 
                      | (0x0000001fU & (vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                                        >> 7U))));
        }
    }
    vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_b = 
        ((IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_alu_op)
          ? ((5U == (IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_fn3))
              ? (0x0000001fU & (vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_insn 
                                >> 0x00000014U)) : vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_imm)
          : ((0U == (IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_rs2))
              ? 0U : ((0x1eU >= (0x0000001fU & ((IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_rs2) 
                                                - (IData)(1U))))
                       ? vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf
                      [(0x0000001fU & ((IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_rs2) 
                                       - (IData)(1U)))]
                       : 0U)));
}

void Vsim___024root___nba_sequent__TOP__2(Vsim___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___nba_sequent__TOP__2\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1U & (~ (IData)(vlSelfRef.tb_riscv_core__DOT__resetb)))) {
        vlSelfRef.tb_riscv_core__DOT__dmem_wstrb = 0U;
        vlSelfRef.tb_riscv_core__DOT__dmem_waddr = 0U;
        vlSelfRef.tb_riscv_core__DOT__dmem_wdata = 0U;
    }
    if (vlSelfRef.tb_riscv_core__DOT__resetb) {
        if ((1U & (~ (IData)(vlSelfRef.tb_riscv_core__DOT__stall)))) {
            vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_rd 
                = (0x0000001fU & (vlSelfRef.tb_riscv_core__DOT__imem_rdata 
                                  >> 7U));
        }
    } else {
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_rd = 0U;
    }
}

void Vsim___024root___nba_comb__TOP__1(Vsim___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___nba_comb__TOP__1\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_a = 
        ((0U == (IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_rs1))
          ? 0U : ((0x1eU >= (0x0000001fU & ((IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_rs1) 
                                            - (IData)(1U))))
                   ? vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf
                  [(0x0000001fU & ((IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_rs1) 
                                   - (IData)(1U)))]
                   : 0U));
}

void Vsim___024root___nba_comb__TOP__2(Vsim___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___nba_comb__TOP__2\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ tb_riscv_core__DOT__uut__DOT____VdfgExtracted_h0c6d2982__0;
    tb_riscv_core__DOT__uut__DOT____VdfgExtracted_h0c6d2982__0 = 0;
    // Body
    tb_riscv_core__DOT__uut__DOT____VdfgExtracted_h0c6d2982__0 
        = (vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_a 
           + vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_b);
    vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_out = 0U;
    if (vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_alu_op) {
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_out 
            = ((4U & (IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_fn3))
                ? ((2U & (IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_fn3))
                    ? ((1U & (IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_fn3))
                        ? (vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_a 
                           & vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_b)
                        : (vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_a 
                           | vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_b))
                    : ((1U & (IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_fn3))
                        ? (vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_a 
                           >> (0x0000001fU & vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_b))
                        : (vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_a 
                           ^ vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_b)))
                : ((2U & (IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_fn3))
                    ? tb_riscv_core__DOT__uut__DOT____VdfgExtracted_h0c6d2982__0
                    : ((1U & (IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_fn3))
                        ? (vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_a 
                           << (0x0000001fU & vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_b))
                        : tb_riscv_core__DOT__uut__DOT____VdfgExtracted_h0c6d2982__0)));
    } else if (vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_lui) {
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_out 
            = vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_imm;
    } else if (vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_auipc) {
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_out 
            = (vlSelfRef.tb_riscv_core__DOT__uut__DOT__pc_id 
               + vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_imm);
    } else if (((IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_jal) 
                | (IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_jalr))) {
        vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_out 
            = ((IData)(4U) + vlSelfRef.tb_riscv_core__DOT__uut__DOT__pc_id);
    }
}

void Vsim___024root___eval_nba(Vsim___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___eval_nba\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((3ULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vsim___024root___nba_sequent__TOP__0(vlSelf);
        vlSelfRef.__Vm_traceActivity[3U] = 1U;
    }
    if ((1ULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vsim___024root___nba_sequent__TOP__1(vlSelf);
        vlSelfRef.__Vm_traceActivity[4U] = 1U;
    }
    if ((7ULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vsim___024root___nba_comb__TOP__0(vlSelf);
    }
    if ((3ULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vsim___024root___nba_sequent__TOP__2(vlSelf);
        vlSelfRef.__Vm_traceActivity[5U] = 1U;
    }
    if ((3ULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vsim___024root___nba_comb__TOP__1(vlSelf);
    }
    if ((7ULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vsim___024root___nba_comb__TOP__2(vlSelf);
    }
}

void Vsim___024root___timing_resume(Vsim___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___timing_resume\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((4ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VdlySched.resume();
    }
}

void Vsim___024root___trigger_orInto__act(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___trigger_orInto__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = (out[n] | in[n]);
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

bool Vsim___024root___eval_phase__act(Vsim___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___eval_phase__act\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VactExecute;
    // Body
    Vsim___024root___eval_triggers__act(vlSelf);
    Vsim___024root___trigger_orInto__act(vlSelfRef.__VnbaTriggered, vlSelfRef.__VactTriggered);
    __VactExecute = Vsim___024root___trigger_anySet__act(vlSelfRef.__VactTriggered);
    if (__VactExecute) {
        Vsim___024root___timing_resume(vlSelf);
        Vsim___024root___eval_act(vlSelf);
    }
    return (__VactExecute);
}

void Vsim___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___trigger_clear__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = 0ULL;
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

bool Vsim___024root___eval_phase__nba(Vsim___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___eval_phase__nba\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = Vsim___024root___trigger_anySet__act(vlSelfRef.__VnbaTriggered);
    if (__VnbaExecute) {
        Vsim___024root___eval_nba(vlSelf);
        Vsim___024root___trigger_clear__act(vlSelfRef.__VnbaTriggered);
    }
    return (__VnbaExecute);
}

void Vsim___024root___eval(Vsim___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___eval\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VnbaIterCount;
    // Body
    __VnbaIterCount = 0U;
    do {
        if (VL_UNLIKELY(((0x00000064U < __VnbaIterCount)))) {
#ifdef VL_DEBUG
            Vsim___024root___dump_triggers__act(vlSelfRef.__VnbaTriggered, "nba"s);
#endif
            VL_FATAL_MT("testbench.sv", 6, "", "NBA region did not converge after 100 tries");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        vlSelfRef.__VactIterCount = 0U;
        do {
            if (VL_UNLIKELY(((0x00000064U < vlSelfRef.__VactIterCount)))) {
#ifdef VL_DEBUG
                Vsim___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
#endif
                VL_FATAL_MT("testbench.sv", 6, "", "Active region did not converge after 100 tries");
            }
            vlSelfRef.__VactIterCount = ((IData)(1U) 
                                         + vlSelfRef.__VactIterCount);
        } while (Vsim___024root___eval_phase__act(vlSelf));
    } while (Vsim___024root___eval_phase__nba(vlSelf));
}

#ifdef VL_DEBUG
void Vsim___024root___eval_debug_assertions(Vsim___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___eval_debug_assertions\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}
#endif  // VL_DEBUG
