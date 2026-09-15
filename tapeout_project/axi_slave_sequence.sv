import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_slave_sequence extends uvm_sequence #(axi_transaction);

    `uvm_object_utils(axi_slave_sequence)

    function new(string name = "axi_slave_sequence");
        super.new(name);
    endfunction

    virtual task body();

        axi_transaction write_trans;
        axi_transaction read_trans;

      repeat (10) begin

            //================================================
            // WRITE
            //================================================

            write_trans =
                axi_transaction::type_id::create("write_trans");

            start_item(write_trans);

            if (!write_trans.randomize() with {
                write == 1;
            }) begin
                `uvm_fatal("SEQ",
                    "Write transaction randomization failed")
            end

            `uvm_info("RANDOM",
                $sformatf(
                    "WRITE: AW=%0d W=%0d B=%0d",
                    write_trans.aw_delay,
                    write_trans.w_delay,
                    write_trans.b_delay
                ),
                UVM_MEDIUM)

            finish_item(write_trans);


            //================================================
            // READ
            //================================================

            read_trans =
                axi_transaction::type_id::create("read_trans");

            start_item(read_trans);

            if (!read_trans.randomize() with {
                write == 0;
                addr == write_trans.addr;
            }) begin
                `uvm_fatal("SEQ",
                    "Read transaction randomization failed")
            end

            `uvm_info("RANDOM",
                $sformatf(
                    "READ: AR=%0d R=%0d",
                    read_trans.ar_delay,
                    read_trans.r_delay
                ),
                UVM_MEDIUM)

            finish_item(read_trans);

        end

    endtask

endclass