import uvm_pkg::*;
`include "uvm_macros.svh"


class axi_base_test extends uvm_test;

    `uvm_component_utils(axi_base_test)


    axi_env env;
    axi_slave_sequence seq;


    function new(string name = "axi_base_test",
                 uvm_component parent = null);

        super.new(name,parent);

    endfunction



    virtual function void build_phase(uvm_phase phase);

        super.build_phase(phase);


        env = axi_env::type_id::create(
                "env",
                this);

    endfunction



  virtual task run_phase(uvm_phase phase);

    phase.raise_objection(this);

    `uvm_info("TEST",
              "Starting AXI test",
              UVM_LOW)

    seq = axi_slave_sequence::type_id::create("seq");

    fork
        seq.start(env.agent.sequencer);
    join_none

    #900ns;

    `uvm_info("TEST",
              "Ending AXI test",
              UVM_LOW)

    `uvm_info("COVERAGE",
              $sformatf("AXI Functional Coverage = %0.2f%%",
                        env.coverage.axi_cg.get_coverage()),
              UVM_LOW)

    phase.drop_objection(this);

endtask


endclass