import uvm_pkg::*;
`include "uvm_macros.svh"


class axi_slave_agent extends uvm_agent;


    `uvm_component_utils(axi_slave_agent)


    // UVM components
    axi_slave_driver     driver;
    axi_slave_sequencer  sequencer;
    axi_slave_monitor    monitor;



    function new(string name = "axi_slave_agent",
                 uvm_component parent = null);

        super.new(name, parent);

    endfunction



    virtual function void build_phase(uvm_phase phase);

        super.build_phase(phase);


        // Create sequencer
        sequencer = axi_slave_sequencer::type_id::create(
                        "sequencer",
                        this);


        // Create driver
        driver = axi_slave_driver::type_id::create(
                    "driver",
                    this);


        // Create monitor
        monitor = axi_slave_monitor::type_id::create(
                    "monitor",
                    this);


    endfunction



    virtual function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);


        // Connect sequencer to driver

        driver.seq_item_port.connect(
            sequencer.seq_item_export
        );


    endfunction



endclass