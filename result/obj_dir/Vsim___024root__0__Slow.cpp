// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vsim.h for the primary calling header

#include "Vsim__pch.h"

VL_ATTR_COLD void Vsim___024root___eval_static(Vsim___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___eval_static\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__Vtrigprevexpr___TOP__tb_riscv_core__DOT__clk__0 
        = vlSelfRef.tb_riscv_core__DOT__clk;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_riscv_core__DOT__resetb__0 
        = vlSelfRef.tb_riscv_core__DOT__resetb;
}

VL_ATTR_COLD void Vsim___024root___eval_initial__TOP(Vsim___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___eval_initial__TOP\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.tb_riscv_core__DOT__clk = 0U;
}

VL_ATTR_COLD void Vsim___024root___eval_final(Vsim___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___eval_final\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vsim___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vsim___024root___eval_phase__stl(Vsim___024root* vlSelf);

VL_ATTR_COLD void Vsim___024root___eval_settle(Vsim___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___eval_settle\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VstlIterCount;
    // Body
    __VstlIterCount = 0U;
    vlSelfRef.__VstlFirstIteration = 1U;
    do {
        if (VL_UNLIKELY(((0x00000064U < __VstlIterCount)))) {
#ifdef VL_DEBUG
            Vsim___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
#endif
            VL_FATAL_MT("testbench.sv", 6, "", "Settle region did not converge after 100 tries");
        }
        __VstlIterCount = ((IData)(1U) + __VstlIterCount);
    } while (Vsim___024root___eval_phase__stl(vlSelf));
}

VL_ATTR_COLD void Vsim___024root___eval_triggers__stl(Vsim___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___eval_triggers__stl\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VstlTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VstlTriggered
                                      [0U]) | (IData)((IData)(vlSelfRef.__VstlFirstIteration)));
    vlSelfRef.__VstlFirstIteration = 0U;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vsim___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
    }
#endif
}

VL_ATTR_COLD bool Vsim___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vsim___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(Vsim___024root___trigger_anySet__stl(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD bool Vsim___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___trigger_anySet__stl\n"); );
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

VL_ATTR_COLD void Vsim___024root___stl_sequent__TOP__0(Vsim___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___stl_sequent__TOP__0\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ tb_riscv_core__DOT__uut__DOT____VdfgExtracted_h0c6d2982__0;
    tb_riscv_core__DOT__uut__DOT____VdfgExtracted_h0c6d2982__0 = 0;
    // Body
    vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_a = 
        ((0U == (IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_rs1))
          ? 0U : ((0x1eU >= (0x0000001fU & ((IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_rs1) 
                                            - (IData)(1U))))
                   ? vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf
                  [(0x0000001fU & ((IData)(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_rs1) 
                                   - (IData)(1U)))]
                   : 0U));
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

VL_ATTR_COLD void Vsim___024root___eval_stl(Vsim___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___eval_stl\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VstlTriggered[0U])) {
        Vsim___024root___stl_sequent__TOP__0(vlSelf);
    }
}

VL_ATTR_COLD bool Vsim___024root___eval_phase__stl(Vsim___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___eval_phase__stl\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VstlExecute;
    // Body
    Vsim___024root___eval_triggers__stl(vlSelf);
    __VstlExecute = Vsim___024root___trigger_anySet__stl(vlSelfRef.__VstlTriggered);
    if (__VstlExecute) {
        Vsim___024root___eval_stl(vlSelf);
    }
    return (__VstlExecute);
}

bool Vsim___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vsim___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(Vsim___024root___trigger_anySet__act(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: @(posedge tb_riscv_core.clk)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 1U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 1 is active: @(negedge tb_riscv_core.resetb)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 2U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 2 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vsim___024root___ctor_var_reset(Vsim___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root___ctor_var_reset\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const uint64_t __VscopeHash = VL_MURMUR64_HASH(vlSelf->vlNamep);
    vlSelf->tb_riscv_core__DOT__clk = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 927428257173894171ull);
    vlSelf->tb_riscv_core__DOT__resetb = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 9872382227733294564ull);
    vlSelf->tb_riscv_core__DOT__stall = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 15233216899873681159ull);
    vlSelf->tb_riscv_core__DOT__timer_irq = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16720274030331819888ull);
    vlSelf->tb_riscv_core__DOT__sw_irq = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14222948815612502783ull);
    vlSelf->tb_riscv_core__DOT__ext_irq = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 3711702664969436677ull);
    vlSelf->tb_riscv_core__DOT__imem_rdata = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 5948099927657340820ull);
    vlSelf->tb_riscv_core__DOT__imem_valid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 42687311730286538ull);
    vlSelf->tb_riscv_core__DOT__imem_addr = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 8939003994407591288ull);
    vlSelf->tb_riscv_core__DOT__dmem_rdata = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 12873014232831324096ull);
    vlSelf->tb_riscv_core__DOT__dmem_rvalid = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6550455375834874437ull);
    vlSelf->tb_riscv_core__DOT__dmem_raddr = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 947997365560357875ull);
    vlSelf->tb_riscv_core__DOT__dmem_wdata = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 16851361676157930276ull);
    vlSelf->tb_riscv_core__DOT__dmem_waddr = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 13573228660460258820ull);
    vlSelf->tb_riscv_core__DOT__dmem_wstrb = VL_SCOPED_RAND_RESET_I(4, __VscopeHash, 9362652108990625517ull);
    vlSelf->tb_riscv_core__DOT__uut__DOT____Vlvbound_h2373211c__0 = 0;
    vlSelf->tb_riscv_core__DOT__uut__DOT__pc_fetch = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 9891163832023906796ull);
    vlSelf->tb_riscv_core__DOT__uut__DOT__pc_id = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 2408318238678372753ull);
    vlSelf->tb_riscv_core__DOT__uut__DOT__pc_ex = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 2440504188154995231ull);
    vlSelf->tb_riscv_core__DOT__uut__DOT__pc_wb = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 3695773570657398646ull);
    vlSelf->tb_riscv_core__DOT__uut__DOT__ex_insn = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 14866456802241731762ull);
    vlSelf->tb_riscv_core__DOT__uut__DOT__ex_imm = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 9799108989859698000ull);
    vlSelf->tb_riscv_core__DOT__uut__DOT__ex_rs1 = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 7751519704135912908ull);
    vlSelf->tb_riscv_core__DOT__uut__DOT__ex_rs2 = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 15266498213496403688ull);
    vlSelf->tb_riscv_core__DOT__uut__DOT__ex_rd = VL_SCOPED_RAND_RESET_I(5, __VscopeHash, 3557409120190925441ull);
    vlSelf->tb_riscv_core__DOT__uut__DOT__ex_fn3 = VL_SCOPED_RAND_RESET_I(3, __VscopeHash, 6788126103153931691ull);
    vlSelf->tb_riscv_core__DOT__uut__DOT__ex_fn7_alt = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 95836016479980035ull);
    vlSelf->tb_riscv_core__DOT__uut__DOT__ex_store = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 15569703165624114479ull);
    vlSelf->tb_riscv_core__DOT__uut__DOT__ex_load = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 6416928370757025861ull);
    vlSelf->tb_riscv_core__DOT__uut__DOT__ex_alu_op = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17077622385823922092ull);
    vlSelf->tb_riscv_core__DOT__uut__DOT__ex_mul_op = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 513071564821075809ull);
    vlSelf->tb_riscv_core__DOT__uut__DOT__ex_lui = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 853450294861015378ull);
    vlSelf->tb_riscv_core__DOT__uut__DOT__ex_auipc = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10926428366903367335ull);
    vlSelf->tb_riscv_core__DOT__uut__DOT__ex_jal = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2333468610819488763ull);
    vlSelf->tb_riscv_core__DOT__uut__DOT__ex_jalr = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 18122836793968793959ull);
    vlSelf->tb_riscv_core__DOT__uut__DOT__ex_branch = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1555749015816292895ull);
    vlSelf->tb_riscv_core__DOT__uut__DOT__ex_sys = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14664299526809298649ull);
    vlSelf->tb_riscv_core__DOT__uut__DOT__ex_sys_any = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14181971678984821642ull);
    vlSelf->tb_riscv_core__DOT__uut__DOT__ex_illegal = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 2555284487955295072ull);
    vlSelf->tb_riscv_core__DOT__uut__DOT__stall_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 16427569715459517610ull);
    vlSelf->tb_riscv_core__DOT__uut__DOT__flush_q = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 580435045764429390ull);
    vlSelf->tb_riscv_core__DOT__uut__DOT__exception = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 18239619432953820232ull);
    for (int __Vi0 = 0; __Vi0 < 31; ++__Vi0) {
        vlSelf->tb_riscv_core__DOT__uut__DOT__rf[__Vi0] = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 6948849166612007454ull);
    }
    vlSelf->tb_riscv_core__DOT__uut__DOT__alu_a = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 6336978928245396974ull);
    vlSelf->tb_riscv_core__DOT__uut__DOT__alu_b = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 14558938641855490477ull);
    vlSelf->tb_riscv_core__DOT__uut__DOT__alu_out = VL_SCOPED_RAND_RESET_I(32, __VscopeHash, 5325788398019990485ull);
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VstlTriggered[__Vi0] = 0;
    }
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VactTriggered[__Vi0] = 0;
    }
    vlSelf->__Vtrigprevexpr___TOP__tb_riscv_core__DOT__clk__0 = 0;
    vlSelf->__Vtrigprevexpr___TOP__tb_riscv_core__DOT__resetb__0 = 0;
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VnbaTriggered[__Vi0] = 0;
    }
    for (int __Vi0 = 0; __Vi0 < 6; ++__Vi0) {
        vlSelf->__Vm_traceActivity[__Vi0] = 0;
    }
}
