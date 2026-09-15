import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_slave_config extends uvm_object;

    virtual axi_if vif;

    `uvm_object_utils(axi_slave_config)

    function new(string name="axi_slave_config");
        super.new(name);
    endfunction

endclass