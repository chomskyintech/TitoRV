import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_coverage extends uvm_subscriber #(axi_transaction);

    `uvm_component_utils(axi_coverage)

    axi_transaction trans;

    covergroup axi_cg;

        //==================================================
        // 1. READ / WRITE
        //==================================================

        WRITE_READ: coverpoint trans.write {
            bins WRITE = {1};
            bins READ  = {0};
        }


        //==================================================
        // 2. ADDRESS
        //==================================================

        ADDRESS: coverpoint trans.addr {
            bins ADDR0 = {32'h00000000};
            bins ADDR4 = {32'h00000004};
            bins OTHER = default;
        }


        //==================================================
        // 3. RESPONSE
        //==================================================

        RESPONSE: coverpoint trans.resp {
            bins OKAY  = {2'b00};
            bins ERROR = default;
        }


        //==================================================
        // 4. DATA VALUE
        //==================================================

        DATA_VALUE: coverpoint trans.write ?
                    trans.wdata : trans.rdata {

            bins ZERO = {32'h00000000};

            bins SMALL = {[32'h00000001:32'h000000ff]};

            bins MEDIUM = {[32'h00000100:32'h0000ffff]};

            bins LARGE = {[32'h00010000:32'hffffffff]};
        }


        //==================================================
        // 5. OPERATION × ADDRESS
        //==================================================

        OP_ADDRESS: cross WRITE_READ, ADDRESS;


        //==================================================
        // 6. OPERATION × RESPONSE
        //==================================================

        OP_RESPONSE: cross WRITE_READ, RESPONSE;


        //==================================================
        // 7. ADDRESS × RESPONSE
        //==================================================

        ADDR_RESPONSE: cross ADDRESS, RESPONSE;

    endgroup


    //======================================================
    // Constructor
    //======================================================

    function new(string name="axi_coverage",
                 uvm_component parent=null);

        super.new(name,parent);

        axi_cg = new();

    endfunction


    //======================================================
    // Receive transaction from monitor
    //======================================================

    virtual function void write(axi_transaction t);

        trans = t;

        axi_cg.sample();

    endfunction


    //======================================================
    // Coverage report
    //======================================================

    function void report_phase(uvm_phase phase);

        super.report_phase(phase);

        `uvm_info(
            "COVERAGE",
            $sformatf(
                "AXI Functional Coverage = %0.2f%%",
                axi_cg.get_coverage()
            ),
            UVM_LOW
        )

    endfunction

endclass