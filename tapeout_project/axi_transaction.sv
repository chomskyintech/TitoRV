import uvm_pkg::*;
`include "uvm_macros.svh"

class axi_transaction extends uvm_sequence_item;

    // AXI operation
    rand bit write;

    // Address/data fields
    rand bit [31:0] addr;
    rand bit [31:0] wdata;
    rand bit [3:0]  wstrb;

    // Read/response fields
    rand bit [31:0] rdata;
    rand bit [1:0]  resp;

    // Random AXI timing delays
    rand int unsigned aw_delay;
    rand int unsigned w_delay;
    rand int unsigned b_delay;
    rand int unsigned ar_delay;
    rand int unsigned r_delay;

    //================================================
    // Constraints
    //================================================

    constraint addr_c {
        addr[1:0] == 2'b00;
        addr <= 32'h00000FFC;
    }

    constraint resp_c {
        resp == 2'b00;
    }

    constraint wstrb_c {
        wstrb == 4'b1111;
    }

    // Random delay between 0 and 5 clock cycles
    constraint delay_c {
        aw_delay inside {[0:5]};
        w_delay  inside {[0:5]};
        b_delay  inside {[0:5]};
        ar_delay inside {[0:5]};
        r_delay  inside {[0:5]};
    }

    `uvm_object_utils_begin(axi_transaction)

        `uvm_field_int(write,UVM_ALL_ON)
        `uvm_field_int(addr,UVM_ALL_ON)
        `uvm_field_int(wdata,UVM_ALL_ON)
        `uvm_field_int(wstrb,UVM_ALL_ON)
        `uvm_field_int(rdata,UVM_ALL_ON)
        `uvm_field_int(resp,UVM_ALL_ON)

        `uvm_field_int(aw_delay,UVM_ALL_ON)
        `uvm_field_int(w_delay,UVM_ALL_ON)
        `uvm_field_int(b_delay,UVM_ALL_ON)
        `uvm_field_int(ar_delay,UVM_ALL_ON)
        `uvm_field_int(r_delay,UVM_ALL_ON)

    `uvm_object_utils_end

    function new(string name="axi_transaction");
        super.new(name);
    endfunction

    function void do_print(uvm_printer printer);

        super.do_print(printer);

        printer.print_field("write", write, 1);
        printer.print_field("addr", addr, 32, UVM_HEX);
        printer.print_field("wdata", wdata, 32, UVM_HEX);
        printer.print_field("rdata", rdata, 32, UVM_HEX);
        printer.print_field("resp", resp, 2, UVM_BIN);

        printer.print_field("aw_delay", aw_delay, 32, UVM_DEC);
        printer.print_field("w_delay",  w_delay,  32, UVM_DEC);
        printer.print_field("b_delay",  b_delay,  32, UVM_DEC);
        printer.print_field("ar_delay", ar_delay, 32, UVM_DEC);
        printer.print_field("r_delay",  r_delay,  32, UVM_DEC);

    endfunction

endclass