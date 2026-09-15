import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_slave_driver extends uvm_driver #(axi_transaction);

    `uvm_component_utils(axi_slave_driver)

    virtual axi_if vif;

    bit [31:0] memory [0:1023];

    rand int aw_delay;
    rand int w_delay;
    rand int b_delay;
    rand int ar_delay;
    rand int r_delay;

    constraint delay_c {
        aw_delay inside {[0:3]};
        w_delay  inside {[0:3]};
        b_delay  inside {[0:3]};
        ar_delay inside {[0:3]};
        r_delay  inside {[0:3]};
    }

    function new(string name="axi_slave_driver",
                 uvm_component parent=null);
        super.new(name,parent);
    endfunction


    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        if(!uvm_config_db #(virtual axi_if)::get(
                this,"","vif",vif))
            `uvm_fatal("DRIVER",
                       "Virtual interface not found")

    endfunction


    task run_phase(uvm_phase phase);

        bit [31:0] write_addr;
        bit [31:0] read_addr;

        vif.AWREADY <= 1'b0;
        vif.WREADY  <= 1'b0;
        vif.BVALID  <= 1'b0;
        vif.BRESP   <= 2'b00;

        vif.ARREADY <= 1'b0;
        vif.RVALID  <= 1'b0;
        vif.RRESP   <= 2'b00;
        vif.RDATA   <= 32'h0;


        forever begin

            @(posedge vif.clk);


            // =====================================================
            // WRITE TRANSACTION
            // =====================================================

            if (vif.AWVALID) begin

                if (!randomize()) begin
                    `uvm_fatal(
                        "DRIVER",
                        "Slave timing randomization failed"
                    )
                end

                `uvm_info(
                    "RANDOM",
                    $sformatf(
                        "WRITE delays: AW=%0d W=%0d B=%0d",
                        aw_delay,
                        w_delay,
                        b_delay
                    ),
                    UVM_LOW
                )


                // -----------------------------
                // AWREADY
                // -----------------------------

                repeat (aw_delay)
                    @(posedge vif.clk);

                // Drive READY away from DUT posedge
                @(negedge vif.clk);
                vif.AWREADY <= 1'b1;


                // Handshake occurs on next posedge
                @(posedge vif.clk);

                if (vif.AWVALID && vif.AWREADY) begin

                    write_addr = vif.AWADDR;

                    `uvm_info(
                        "DRIVER",
                        $sformatf(
                            "WRITE ADDRESS HANDSHAKE = %08h",
                            write_addr
                        ),
                        UVM_MEDIUM
                    )

                end


                @(negedge vif.clk);
                vif.AWREADY <= 1'b0;


                // -----------------------------
                // WREADY
                // -----------------------------

                while (!vif.WVALID)
                    @(posedge vif.clk);

                repeat (w_delay)
                    @(posedge vif.clk);

                @(negedge vif.clk);
                vif.WREADY <= 1'b1;


                @(posedge vif.clk);

                if (vif.WVALID && vif.WREADY) begin

                    memory[write_addr[11:2]] = vif.WDATA;

                    `uvm_info(
                        "DRIVER",
                        $sformatf(
                            "WRITE DATA HANDSHAKE = %08h @ address %08h",
                            vif.WDATA,
                            write_addr
                        ),
                        UVM_MEDIUM
                    )

                end


                @(negedge vif.clk);
                vif.WREADY <= 1'b0;


                // -----------------------------
                // BVALID
                // -----------------------------

                repeat (b_delay)
                    @(posedge vif.clk);

                @(negedge vif.clk);

                vif.BRESP  <= 2'b00;
                vif.BVALID <= 1'b1;

                `uvm_info(
                    "DRIVER",
                    "BVALID asserted",
                    UVM_MEDIUM
                )


                // Wait for BREADY at rising edge
                do begin
                    @(posedge vif.clk);
                end
                while (!vif.BREADY);


                `uvm_info(
                    "DRIVER",
                    "WRITE RESPONSE HANDSHAKE",
                    UVM_MEDIUM
                )


                // Remove BVALID away from posedge
                @(negedge vif.clk);
                vif.BVALID <= 1'b0;

            end


            // =====================================================
            // READ TRANSACTION
            // =====================================================

            else if (vif.ARVALID) begin

                if (!randomize()) begin
                    `uvm_fatal(
                        "DRIVER",
                        "Slave timing randomization failed"
                    )
                end

                `uvm_info(
                    "RANDOM",
                    $sformatf(
                        "READ delays: AR=%0d R=%0d",
                        ar_delay,
                        r_delay
                    ),
                    UVM_LOW
                )


                // -----------------------------
                // ARREADY
                // -----------------------------

                repeat (ar_delay)
                    @(posedge vif.clk);

                @(negedge vif.clk);
                vif.ARREADY <= 1'b1;


                // Handshake on rising edge
                @(posedge vif.clk);

                if (vif.ARVALID && vif.ARREADY) begin

                    read_addr = vif.ARADDR;

                    `uvm_info(
                        "DRIVER",
                        $sformatf(
                            "READ ADDRESS HANDSHAKE = %08h",
                            read_addr
                        ),
                        UVM_MEDIUM
                    )

                end


                @(negedge vif.clk);
                vif.ARREADY <= 1'b0;


                // -----------------------------
                // RVALID / RDATA
                // -----------------------------

                repeat (r_delay)
                    @(posedge vif.clk);


                // Drive response on falling edge
                @(negedge vif.clk);

                vif.RDATA  <= memory[read_addr[11:2]];
                vif.RRESP  <= 2'b00;
                vif.RVALID <= 1'b1;


                `uvm_info(
                    "DRIVER",
                    $sformatf(
                        "READ DATA = %08h @ address %08h",
                        memory[read_addr[11:2]],
                        read_addr
                    ),
                    UVM_MEDIUM
                )


                // Wait for RREADY on rising edge
                do begin
                    @(posedge vif.clk);
                end
                while (!vif.RREADY);


                `uvm_info(
                    "DRIVER",
                    "READ RESPONSE HANDSHAKE",
                    UVM_MEDIUM
                )


                // Deassert RVALID away from posedge
                @(negedge vif.clk);
                vif.RVALID <= 1'b0;

            end

        end

    endtask

endclass