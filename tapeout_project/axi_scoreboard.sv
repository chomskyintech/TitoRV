import uvm_pkg::*;
`include "uvm_macros.svh"


class axi_scoreboard extends uvm_scoreboard;


`uvm_component_utils(axi_scoreboard)



uvm_analysis_imp #(axi_transaction,
axi_scoreboard)
analysis_export;



// Reference memory

bit [31:0] reference_memory [0:1023];



int total_transactions;
int write_transactions;
int read_transactions;

int pass_count;
int fail_count;



function new(
string name="axi_scoreboard",
uvm_component parent=null);

super.new(name,parent);

endfunction





function void build_phase(uvm_phase phase);


super.build_phase(phase);


analysis_export =
new("analysis_export",this);



endfunction





function void write(axi_transaction trans);


int addr_index;


addr_index = trans.addr[11:2];


total_transactions++;





//================================
// WRITE CHECK
//================================


if(trans.write)
begin


reference_memory[addr_index] =
trans.wdata;


write_transactions++;



`uvm_info
(
"SCOREBOARD_WRITE",

$sformatf(
"WRITE OK : Address=%h Data=%h",
trans.addr,
trans.wdata),

UVM_MEDIUM
)



end




//================================
// READ CHECK
//================================


else
begin


read_transactions++;




if(reference_memory[addr_index]
==
trans.rdata)

begin


pass_count++;



`uvm_info
(
"SCOREBOARD_PASS",

$sformatf(
"READ MATCH : Address=%h Expected=%h Received=%h",

trans.addr,

reference_memory[addr_index],

trans.rdata),

UVM_HIGH
)



end



else

begin


fail_count++;



`uvm_error
(
"SCOREBOARD_FAIL",

$sformatf(

"READ ERROR : Address=%h Expected=%h Received=%h",

trans.addr,

reference_memory[addr_index],

trans.rdata)

)



end



end


endfunction





function void report_phase(uvm_phase phase);



`uvm_info
(
"FINAL_REPORT",

"==============================",
UVM_NONE
)



`uvm_info
(
"FINAL_REPORT",

$sformatf(
"Total Transactions : %0d",
total_transactions),

UVM_NONE
)



`uvm_info
(
"FINAL_REPORT",

$sformatf(
"Writes : %0d",
write_transactions),

UVM_NONE
)



`uvm_info
(
"FINAL_REPORT",

$sformatf(
"Reads : %0d",
read_transactions),

UVM_NONE
)



`uvm_info
(
"FINAL_REPORT",

$sformatf(
"PASS : %0d",
pass_count),

UVM_NONE
)



`uvm_info
(
"FINAL_REPORT",

$sformatf(
"FAIL : %0d",
fail_count),

UVM_NONE
)




if(fail_count==0)

begin

`uvm_info
(
"TEST_RESULT",

"******** TEST PASSED ********",

UVM_NONE)

end


else

begin

`uvm_error
(
"TEST_RESULT",

"******** TEST FAILED ********")

end



endfunction


endclass