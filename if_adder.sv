module if_adder(address,pc_signed_offset,imm_out,ex_en);
input logic [31:0]address,imm_out;
input logic ex_en;
output logic [31:0]pc_signed_offset;
always_comb
if(ex_en)begin
pc_signed_offset = address + imm_out;
end
endmodule
