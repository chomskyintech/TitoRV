// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals

#include "verilated_vcd_c.h"
#include "Vsim__Syms.h"


VL_ATTR_COLD void Vsim___024root__trace_init_sub__TOP__0(Vsim___024root* vlSelf, VerilatedVcd* tracep) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root__trace_init_sub__TOP__0\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const int c = vlSymsp->__Vm_baseCode;
    tracep->pushPrefix("tb_riscv_core", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBit(c+69,0,"clk",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+1,0,"resetb",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+2,0,"stall",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+3,0,"timer_irq",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+4,0,"sw_irq",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+5,0,"ext_irq",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+6,0,"imem_rdata",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+7,0,"imem_valid",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+10,0,"imem_addr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+8,0,"imem_ready",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+33,0,"dmem_rdata",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+9,0,"dmem_rvalid",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+11,0,"dmem_raddr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+65,0,"dmem_wdata",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+66,0,"dmem_waddr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+67,0,"dmem_wstrb",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBit(c+74,0,"dmem_rready",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+74,0,"dmem_wready",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->pushPrefix("uut", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+75,0,"RV32M",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::INTEGER, false,-1, 31,0);
    tracep->declBus(c+76,0,"RV32E",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::INTEGER, false,-1, 31,0);
    tracep->declBit(c+69,0,"clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+1,0,"resetb",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+2,0,"stall",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+3,0,"timer_irq",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+4,0,"sw_irq",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+5,0,"ext_irq",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+7,0,"imem_valid",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+6,0,"imem_rdata",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+10,0,"imem_addr",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBit(c+8,0,"imem_ready",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+9,0,"dmem_rvalid",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+33,0,"dmem_rdata",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+11,0,"dmem_raddr",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+65,0,"dmem_wdata",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+66,0,"dmem_waddr",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+67,0,"dmem_wstrb",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 3,0);
    tracep->declBit(c+74,0,"dmem_rready",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+74,0,"dmem_wready",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+77,0,"NOP",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+78,0,"RESETVEC",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+79,0,"OP_LUI",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 6,0);
    tracep->declBus(c+80,0,"OP_AUIPC",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 6,0);
    tracep->declBus(c+81,0,"OP_JAL",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 6,0);
    tracep->declBus(c+82,0,"OP_JALR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 6,0);
    tracep->declBus(c+83,0,"OP_BRANCH",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 6,0);
    tracep->declBus(c+84,0,"OP_LOAD",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 6,0);
    tracep->declBus(c+85,0,"OP_STORE",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 6,0);
    tracep->declBus(c+86,0,"OP_ARITHI",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 6,0);
    tracep->declBus(c+87,0,"OP_ARITHR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 6,0);
    tracep->declBus(c+88,0,"OP_SYSTEM",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 6,0);
    tracep->declBus(c+89,0,"F3_ADD_SUB",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 2,0);
    tracep->declBus(c+90,0,"F3_SLL",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 2,0);
    tracep->declBus(c+91,0,"F3_SLT",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 2,0);
    tracep->declBus(c+92,0,"F3_SLTU",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 2,0);
    tracep->declBus(c+93,0,"F3_XOR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 2,0);
    tracep->declBus(c+94,0,"F3_OR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 2,0);
    tracep->declBus(c+95,0,"F3_AND",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 2,0);
    tracep->declBus(c+96,0,"F3_SR",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 2,0);
    tracep->declBus(c+12,0,"pc_fetch",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+13,0,"pc_id",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+97,0,"pc_ex",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+98,0,"pc_wb",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+14,0,"ex_insn",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+70,0,"ex_imm",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+15,0,"ex_rs1",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+16,0,"ex_rs2",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+68,0,"ex_rd",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 4,0);
    tracep->declBus(c+17,0,"ex_fn3",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 2,0);
    tracep->declBit(c+99,0,"ex_fn7_alt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+18,0,"ex_store",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+19,0,"ex_load",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+20,0,"ex_alu_op",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+21,0,"ex_mul_op",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+22,0,"ex_lui",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+23,0,"ex_auipc",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+24,0,"ex_jal",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+25,0,"ex_jalr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+26,0,"ex_branch",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+27,0,"ex_sys",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+28,0,"ex_sys_any",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+29,0,"ex_illegal",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+30,0,"stall_q",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+31,0,"flush_q",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+32,0,"exception",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+100,0,"RF_DEPTH",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->pushPrefix("rf", VerilatedTracePrefixType::ARRAY_UNPACKED);
    for (int i = 0; i < 31; ++i) {
        tracep->declBus(c+34+i*1,0,"",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, true,(i+1), 31,0);
    }
    tracep->popPrefix();
    tracep->declBus(c+71,0,"alu_a",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+72,0,"alu_b",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->declBus(c+73,0,"alu_out",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 31,0);
    tracep->popPrefix();
    tracep->popPrefix();
}

VL_ATTR_COLD void Vsim___024root__trace_init_top(Vsim___024root* vlSelf, VerilatedVcd* tracep) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root__trace_init_top\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vsim___024root__trace_init_sub__TOP__0(vlSelf, tracep);
}

VL_ATTR_COLD void Vsim___024root__trace_const_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
VL_ATTR_COLD void Vsim___024root__trace_full_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vsim___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vsim___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/);

VL_ATTR_COLD void Vsim___024root__trace_register(Vsim___024root* vlSelf, VerilatedVcd* tracep) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root__trace_register\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    tracep->addConstCb(&Vsim___024root__trace_const_0, 0, vlSelf);
    tracep->addFullCb(&Vsim___024root__trace_full_0, 0, vlSelf);
    tracep->addChgCb(&Vsim___024root__trace_chg_0, 0, vlSelf);
    tracep->addCleanupCb(&Vsim___024root__trace_cleanup, vlSelf);
}

VL_ATTR_COLD void Vsim___024root__trace_const_0_sub_0(Vsim___024root* vlSelf, VerilatedVcd::Buffer* bufp);

VL_ATTR_COLD void Vsim___024root__trace_const_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root__trace_const_0\n"); );
    // Body
    Vsim___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vsim___024root*>(voidSelf);
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    Vsim___024root__trace_const_0_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void Vsim___024root__trace_const_0_sub_0(Vsim___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root__trace_const_0_sub_0\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    bufp->fullBit(oldp+74,(1U));
    bufp->fullIData(oldp+75,(1U),32);
    bufp->fullIData(oldp+76,(0U),32);
    bufp->fullIData(oldp+77,(0x00000013U),32);
    bufp->fullIData(oldp+78,(0U),32);
    bufp->fullCData(oldp+79,(0x37U),7);
    bufp->fullCData(oldp+80,(0x17U),7);
    bufp->fullCData(oldp+81,(0x6fU),7);
    bufp->fullCData(oldp+82,(0x67U),7);
    bufp->fullCData(oldp+83,(0x63U),7);
    bufp->fullCData(oldp+84,(3U),7);
    bufp->fullCData(oldp+85,(0x23U),7);
    bufp->fullCData(oldp+86,(0x13U),7);
    bufp->fullCData(oldp+87,(0x33U),7);
    bufp->fullCData(oldp+88,(0x73U),7);
    bufp->fullCData(oldp+89,(0U),3);
    bufp->fullCData(oldp+90,(1U),3);
    bufp->fullCData(oldp+91,(2U),3);
    bufp->fullCData(oldp+92,(3U),3);
    bufp->fullCData(oldp+93,(4U),3);
    bufp->fullCData(oldp+94,(6U),3);
    bufp->fullCData(oldp+95,(7U),3);
    bufp->fullCData(oldp+96,(5U),3);
    bufp->fullIData(oldp+97,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__pc_ex),32);
    bufp->fullIData(oldp+98,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__pc_wb),32);
    bufp->fullBit(oldp+99,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_fn7_alt));
    bufp->fullIData(oldp+100,(0x00000020U),32);
}

VL_ATTR_COLD void Vsim___024root__trace_full_0_sub_0(Vsim___024root* vlSelf, VerilatedVcd::Buffer* bufp);

VL_ATTR_COLD void Vsim___024root__trace_full_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root__trace_full_0\n"); );
    // Body
    Vsim___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vsim___024root*>(voidSelf);
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    Vsim___024root__trace_full_0_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void Vsim___024root__trace_full_0_sub_0(Vsim___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vsim___024root__trace_full_0_sub_0\n"); );
    Vsim__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    bufp->fullBit(oldp+1,(vlSelfRef.tb_riscv_core__DOT__resetb));
    bufp->fullBit(oldp+2,(vlSelfRef.tb_riscv_core__DOT__stall));
    bufp->fullBit(oldp+3,(vlSelfRef.tb_riscv_core__DOT__timer_irq));
    bufp->fullBit(oldp+4,(vlSelfRef.tb_riscv_core__DOT__sw_irq));
    bufp->fullBit(oldp+5,(vlSelfRef.tb_riscv_core__DOT__ext_irq));
    bufp->fullIData(oldp+6,(vlSelfRef.tb_riscv_core__DOT__imem_rdata),32);
    bufp->fullBit(oldp+7,(vlSelfRef.tb_riscv_core__DOT__imem_valid));
    bufp->fullBit(oldp+8,((1U & (~ (IData)(vlSelfRef.tb_riscv_core__DOT__stall)))));
    bufp->fullBit(oldp+9,(vlSelfRef.tb_riscv_core__DOT__dmem_rvalid));
    bufp->fullIData(oldp+10,(vlSelfRef.tb_riscv_core__DOT__imem_addr),32);
    bufp->fullIData(oldp+11,(vlSelfRef.tb_riscv_core__DOT__dmem_raddr),32);
    bufp->fullIData(oldp+12,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__pc_fetch),32);
    bufp->fullIData(oldp+13,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__pc_id),32);
    bufp->fullIData(oldp+14,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_insn),32);
    bufp->fullCData(oldp+15,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_rs1),5);
    bufp->fullCData(oldp+16,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_rs2),5);
    bufp->fullCData(oldp+17,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_fn3),3);
    bufp->fullBit(oldp+18,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_store));
    bufp->fullBit(oldp+19,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_load));
    bufp->fullBit(oldp+20,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_alu_op));
    bufp->fullBit(oldp+21,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_mul_op));
    bufp->fullBit(oldp+22,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_lui));
    bufp->fullBit(oldp+23,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_auipc));
    bufp->fullBit(oldp+24,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_jal));
    bufp->fullBit(oldp+25,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_jalr));
    bufp->fullBit(oldp+26,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_branch));
    bufp->fullBit(oldp+27,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_sys));
    bufp->fullBit(oldp+28,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_sys_any));
    bufp->fullBit(oldp+29,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_illegal));
    bufp->fullBit(oldp+30,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__stall_q));
    bufp->fullBit(oldp+31,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__flush_q));
    bufp->fullBit(oldp+32,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__exception));
    bufp->fullIData(oldp+33,(vlSelfRef.tb_riscv_core__DOT__dmem_rdata),32);
    bufp->fullIData(oldp+34,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[0]),32);
    bufp->fullIData(oldp+35,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[1]),32);
    bufp->fullIData(oldp+36,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[2]),32);
    bufp->fullIData(oldp+37,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[3]),32);
    bufp->fullIData(oldp+38,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[4]),32);
    bufp->fullIData(oldp+39,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[5]),32);
    bufp->fullIData(oldp+40,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[6]),32);
    bufp->fullIData(oldp+41,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[7]),32);
    bufp->fullIData(oldp+42,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[8]),32);
    bufp->fullIData(oldp+43,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[9]),32);
    bufp->fullIData(oldp+44,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[10]),32);
    bufp->fullIData(oldp+45,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[11]),32);
    bufp->fullIData(oldp+46,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[12]),32);
    bufp->fullIData(oldp+47,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[13]),32);
    bufp->fullIData(oldp+48,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[14]),32);
    bufp->fullIData(oldp+49,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[15]),32);
    bufp->fullIData(oldp+50,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[16]),32);
    bufp->fullIData(oldp+51,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[17]),32);
    bufp->fullIData(oldp+52,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[18]),32);
    bufp->fullIData(oldp+53,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[19]),32);
    bufp->fullIData(oldp+54,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[20]),32);
    bufp->fullIData(oldp+55,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[21]),32);
    bufp->fullIData(oldp+56,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[22]),32);
    bufp->fullIData(oldp+57,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[23]),32);
    bufp->fullIData(oldp+58,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[24]),32);
    bufp->fullIData(oldp+59,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[25]),32);
    bufp->fullIData(oldp+60,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[26]),32);
    bufp->fullIData(oldp+61,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[27]),32);
    bufp->fullIData(oldp+62,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[28]),32);
    bufp->fullIData(oldp+63,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[29]),32);
    bufp->fullIData(oldp+64,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__rf[30]),32);
    bufp->fullIData(oldp+65,(vlSelfRef.tb_riscv_core__DOT__dmem_wdata),32);
    bufp->fullIData(oldp+66,(vlSelfRef.tb_riscv_core__DOT__dmem_waddr),32);
    bufp->fullCData(oldp+67,(vlSelfRef.tb_riscv_core__DOT__dmem_wstrb),4);
    bufp->fullCData(oldp+68,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_rd),5);
    bufp->fullBit(oldp+69,(vlSelfRef.tb_riscv_core__DOT__clk));
    bufp->fullIData(oldp+70,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__ex_imm),32);
    bufp->fullIData(oldp+71,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_a),32);
    bufp->fullIData(oldp+72,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_b),32);
    bufp->fullIData(oldp+73,(vlSelfRef.tb_riscv_core__DOT__uut__DOT__alu_out),32);
}
