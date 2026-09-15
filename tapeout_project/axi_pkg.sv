 `include "axi_if.sv" 

package axi_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

     `include "axi_transaction.sv"
     `include "axi_slave_sequencer.sv"
     `include "axi_slave_driver.sv"
     `include "axi_slave_monitor.sv"
     `include "axi_slave_agent.sv"
    //==================================================
    // Configuration
    //==================================================

    `include "axi_slave_config.sv"
    

    //==================================================
    // Transaction
    //==================================================

   


    //==================================================
    // Sequencer and Sequence
    //==================================================

    

    `include "axi_slave_sequence.sv"


    //==================================================
    // Driver and Monitor
    //==================================================

   

   


    //==================================================
    // Agent
    //==================================================

 


    //==================================================
    // Scoreboard
    //==================================================

    `include "axi_scoreboard.sv"


    //==================================================
    // Environment
    //==================================================
    `include "axi_coverage.sv"

    `include "axi_env.sv"


    //==================================================
    // Tests
    //==================================================

    `include "axi_base_test.sv"


endpackage