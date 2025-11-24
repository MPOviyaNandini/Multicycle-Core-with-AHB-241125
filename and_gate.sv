module and_gate(zero,branch,and_out);
input logic zero;
input logic branch;
output logic and_out;

always_comb
and_out = branch & zero;  
endmodule
