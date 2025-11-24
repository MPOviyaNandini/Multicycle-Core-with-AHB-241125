/*module execution (alu_out ,rs1_data,rs2_data,imm_out,and_out_ex,branch,alu_src,address,pc_ex_out,fn3,aluop,imm11_5,fn7_5,mux_inp);
input logic [31:0]rs1_data,rs2_data,imm_out,address;

input logic branch,alu_src,fn7_5;
input logic mux_inp;
input logic [2:0]fn3;
input logic [6:0]imm11_5;
input logic [2:0]aluop;
output logic and_out_ex;
output logic [31:0]pc_ex_out;
 output logic [31:0] alu_out ;
wire [31:0]mux_ex_out;
wire zero;
wire [3:0]alu_operation;
wire [31:0]pc_signed_offset;
mux21 mux_pc (.a(pc_signed_offset),.b(alu_out),.y(pc_ex_out),.control(mux_inp));
and_gate and_ex (.zero(zero),.branch(branch),.and_out(and_out_ex));
if_adder ex_add (.address(address),.pc_signed_offset(pc_signed_offset),.imm_out(imm_out));
alu alu1 (.alu_control(alu_operation),.rs1_data(rs1_data),.rs2_data(mux_ex_out),.alu_out(alu_out),.zero(zero));
mux21 mux_ex (.a(rs2_data),.b(imm_out),.control(alu_src),.y(mux_ex_out));
alu_control ac (.alu_op(aluop),.control_out(alu_operation),.fn3(fn3),.imm11_5(imm11_5),.fn7_5(fn7_5));
endmodule*/

module execution (clk,reset,ex_en,alu_out ,rs1_data,rs2_data,imm_out,and_out_ex,branch,alu_src,address,pc_ex_out,fn3,aluop,imm11_5,fn7_5,mux_inp);
input logic [31:0]rs1_data,rs2_data,imm_out,address;
input logic clk,reset;
input logic branch,alu_src,fn7_5;
input logic mux_inp,ex_en;
input logic [2:0]fn3;
input logic [6:0]imm11_5;
input logic [2:0]aluop;
output logic and_out_ex;
output logic [31:0]pc_ex_out;
 output logic [31:0] alu_out ;
wire [31:0]mux_ex_out;
wire zero;
wire [3:0]alu_operation;
wire [31:0]pc_signed_offset;
mux21 mux_pc (.a(pc_signed_offset),.b(alu_out),.y(pc_ex_out),.control(mux_inp));
and_gate and_ex (.zero(zero),.branch(branch),.and_out(and_out_ex));
if_adder ex_add (.ex_en(ex_en),.address(address),.pc_signed_offset(pc_signed_offset),.imm_out(imm_out));
alu alu1 (.clk(clk),.reset(reset),.ex_en(ex_en),.alu_control(alu_operation),.rs1_data(rs1_data),.rs2_data(mux_ex_out),.alu_out(alu_out),.zero(zero));
mux21 mux_ex (.a(rs2_data),.b(imm_out),.control(alu_src),.y(mux_ex_out));
alu_control ac (.ex_en(ex_en),.alu_op(aluop),.control_out(alu_operation),.fn3(fn3),.imm11_5(imm11_5),.fn7_5(fn7_5));
endmodule