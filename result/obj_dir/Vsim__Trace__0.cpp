// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals

#include "verilated_vcd_c.h"
#include "Vsim__Syms.h"


void Vsim___024root__trace_chg_0_sub_0(Vsim___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void Vsim___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root__trace_chg_0\n"); );
    // Body
    Vsim___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vsim___024root*>(voidSelf);
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    Vsim___024root__trace_chg_0_sub_0((&vlSymsp->TOP), bufp);
}

void Vsim___024root__trace_chg_0_sub_0(Vsim___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root__trace_chg_0_sub_0\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    if (VL_UNLIKELY(((vlSelfRef.__Vm_traceActivity[1U] 
                      | vlSelfRef.__Vm_traceActivity
                      [2U])))) {
        bufp->chgBit(oldp+0,(vlSelfRef.tb_riscv_core__DOT__resetb));
        bufp->chgBit(oldp+1,(vlSelfRef.tb_riscv_core__DOT__stall));
        bufp->chgBit(oldp+2,(vlSelfRef.tb_riscv_core__DOT__timer_irq));
        bufp->chgBit(oldp+3,(vlSelfRef.tb_riscv_core__DOT__sw_irq));
        bufp->chgBit(oldp+4,(vlSelfRef.tb_riscv_core__DOT__ext_irq));
        bufp->chgIData(oldp+5,(vlSelfRef.tb_riscv_core__DOT__imem_rdata),32);
        bufp->chgBit(oldp+6,(vlSelfRef.tb_riscv_core__DOT__imem_valid));
        bufp->chgBit(oldp+7,((1U & (~ (IData)(vlSelfRef.tb_riscv_core__DOT__stall)))));
        bufp->chgBit(oldp+8,(vlSelfRef.tb_riscv_core__DOT__dmem_rvalid));
    }
    if (VL_UNLIKELY((vlSelfRef.__Vm_traceActivity[3U]))) {
        bufp->chgIData(oldp+9,(vlSelfRef.tb_riscv_core__DOT__imem_addr),32);
        bufp->chgIData(oldp+10,(vlSelfRef.tb_riscv_core__DOT__dmem_raddr),32);
        bufp->chgIData(oldp+11,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__pc_fetch),32);
        bufp->chgIData(oldp+12,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__pc_id),32);
        bufp->chgIData(oldp+13,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_insn),32);
        bufp->chgCData(oldp+14,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_rs1),5);
        bufp->chgCData(oldp+15,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_rs2),5);
        bufp->chgCData(oldp+16,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_fn3),3);
        bufp->chgBit(oldp+17,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_store));
        bufp->chgBit(oldp+18,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_load));
        bufp->chgBit(oldp+19,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_alu_op));
        bufp->chgBit(oldp+20,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_mul_op));
        bufp->chgBit(oldp+21,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_lui));
        bufp->chgBit(oldp+22,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_auipc));
        bufp->chgBit(oldp+23,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_jal));
        bufp->chgBit(oldp+24,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_jalr));
        bufp->chgBit(oldp+25,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_branch));
        bufp->chgBit(oldp+26,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_sys));
        bufp->chgBit(oldp+27,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_sys_any));
        bufp->chgBit(oldp+28,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_illegal));
        bufp->chgBit(oldp+29,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__stall_q));
        bufp->chgBit(oldp+30,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__flush_q));
        bufp->chgBit(oldp+31,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__exception));
    }
    if (VL_UNLIKELY((vlSelfRef.__Vm_traceActivity[4U]))) {
        bufp->chgIData(oldp+32,(vlSelfRef.tb_riscv_core__DOT__dmem_rdata),32);
        bufp->chgIData(oldp+33,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[0]),32);
        bufp->chgIData(oldp+34,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[1]),32);
        bufp->chgIData(oldp+35,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[2]),32);
        bufp->chgIData(oldp+36,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[3]),32);
        bufp->chgIData(oldp+37,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[4]),32);
        bufp->chgIData(oldp+38,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[5]),32);
        bufp->chgIData(oldp+39,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[6]),32);
        bufp->chgIData(oldp+40,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[7]),32);
        bufp->chgIData(oldp+41,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[8]),32);
        bufp->chgIData(oldp+42,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[9]),32);
        bufp->chgIData(oldp+43,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[10]),32);
        bufp->chgIData(oldp+44,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[11]),32);
        bufp->chgIData(oldp+45,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[12]),32);
        bufp->chgIData(oldp+46,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[13]),32);
        bufp->chgIData(oldp+47,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[14]),32);
        bufp->chgIData(oldp+48,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[15]),32);
        bufp->chgIData(oldp+49,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[16]),32);
        bufp->chgIData(oldp+50,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[17]),32);
        bufp->chgIData(oldp+51,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[18]),32);
        bufp->chgIData(oldp+52,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[19]),32);
        bufp->chgIData(oldp+53,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[20]),32);
        bufp->chgIData(oldp+54,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[21]),32);
        bufp->chgIData(oldp+55,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[22]),32);
        bufp->chgIData(oldp+56,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[23]),32);
        bufp->chgIData(oldp+57,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[24]),32);
        bufp->chgIData(oldp+58,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[25]),32);
        bufp->chgIData(oldp+59,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[26]),32);
        bufp->chgIData(oldp+60,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[27]),32);
        bufp->chgIData(oldp+61,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[28]),32);
        bufp->chgIData(oldp+62,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[29]),32);
        bufp->chgIData(oldp+63,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[30]),32);
    }
    if (VL_UNLIKELY((vlSelfRef.__Vm_traceActivity[5U]))) {
        bufp->chgIData(oldp+64,(vlSelfRef.tb_riscv_core__DOT__dmem_wdata),32);
        bufp->chgIData(oldp+65,(vlSelfRef.tb_riscv_core__DOT__dmem_waddr),32);
        bufp->chgCData(oldp+66,(vlSelfRef.tb_riscv_core__DOT__dmem_wstrb),4);
        bufp->chgCData(oldp+67,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_rd),5);
    }
    bufp->chgBit(oldp+68,(vlSelfRef.tb_riscv_core__DOT__clk));
    bufp->chgIData(oldp+69,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_imm),32);
    bufp->chgIData(oldp+70,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_a),32);
    bufp->chgIData(oldp+71,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_b),32);
    bufp->chgIData(oldp+72,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_out),32);
}

void Vsim___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root__trace_cleanup\n"); );
    // Body
    Vsim___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vsim___024root*>(voidSelf);
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    vlSymsp->__Vm_activity = false;
    vlSymsp->TOP.__Vm_traceActivity[0U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[1U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[2U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[3U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[4U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[5U] = 0U;
}
