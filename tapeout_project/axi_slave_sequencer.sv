import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_slave_sequencer extends uvm_sequencer #(axi_transaction);

    `uvm_component_utils(axi_slave_sequencer)

    function new(string name,
                 uvm_component parent);

        super.new(name,parent);

    endfunction

endclass