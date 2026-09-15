import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_slave_monitor extends uvm_monitor;

    `uvm_component_utils(axi_slave_monitor)

    virtual axi_if vif;

    uvm_analysis_port #(axi_transaction) analysis_port;

    function new(string name="axi_slave_monitor",
                 uvm_component parent=null);
        super.new(name,parent);
    endfunction

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        analysis_port = new("analysis_port", this);

        if (!uvm_config_db #(virtual axi_if)::get(
                this, "", "vif", vif))

            `uvm_fatal("MONITOR", "Interface missing")

    endfunction


    task run_phase(uvm_phase phase);

        axi_transaction trans;

        forever begin

            @(posedge vif.clk);

            // -------------------------
            // WRITE TRANSACTION
            // -------------------------
            if (vif.AWVALID && vif.AWREADY)
            begin

                trans =
                    axi_transaction::type_id::create("trans");

                trans.write = 1;
                trans.addr  = vif.AWADDR;

                wait(vif.WVALID);

                trans.wdata = vif.WDATA;

                // Wait for write response
                wait(vif.BVALID);

                trans.resp = vif.BRESP;

                analysis_port.write(trans);

                `uvm_info("MONITOR",
                    $sformatf(
                        "WRITE addr=%h data=%h BRESP=%b",
                        trans.addr,
                        trans.wdata,
                        trans.resp),
                    UVM_MEDIUM)

            end


            // -------------------------
            // READ TRANSACTION
            // -------------------------
            if (vif.ARVALID && vif.ARREADY)
            begin

                trans =
                    axi_transaction::type_id::create("trans");

                trans.write = 0;
                trans.addr  = vif.ARADDR;

                // Wait for read response
                wait(vif.RVALID);

                trans.rdata = vif.RDATA;
                trans.resp  = vif.RRESP;

                analysis_port.write(trans);

                `uvm_info("MONITOR",
                    $sformatf(
                        "READ addr=%h data=%h RRESP=%b",
                        trans.addr,
                        trans.rdata,
                        trans.resp),
                    UVM_MEDIUM)

            end

        end

    endtask

endclass