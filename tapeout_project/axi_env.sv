import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_env extends uvm_env;

    `uvm_component_utils(axi_env)

    axi_slave_agent agent;
    axi_scoreboard  scoreboard;
    axi_coverage   coverage;

    function new(string name = "axi_env",
                 uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agent      = axi_slave_agent::type_id::create("agent", this);
        scoreboard = axi_scoreboard::type_id::create("scoreboard", this);
        coverage   = axi_coverage::type_id::create("coverage", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        agent.monitor.analysis_port.connect(
            scoreboard.analysis_export
        );

        agent.monitor.analysis_port.connect(
            coverage.analysis_export
        );

    endfunction

endclass