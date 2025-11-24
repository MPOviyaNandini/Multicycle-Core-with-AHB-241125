module single_cycle_riscV (input logic clk,input logic reset, input logic [31:0]instruction,output logic [31:0]rs2_data,alu_out,
output logic [31:0]address,input logic [31:0] mem_out,output logic mem_read, mem_write,
output logic [2:0]fn3,output logic [1:0]data,
output logic if_en,output logic mem_en);
//output logic [6:0]opcode);
wire if_en,id_en,ex_en,wb_en,mem_en;
wire [31:0]rs1_data,imm_out,pc_signed_offset,return_addr,wb_data;
wire [6:0] opcode;
wire [6:0]imm11_5;
wire [2:0]aluop;
wire and_out_ex,branch,alu_src,fn7_5;
wire [1:0]memtoreg;
wire mux_inp;
if_stage if_st (.ex_en(ex_en),.if_en(if_en),.pc_new(return_addr),.clk(clk),.reset(reset),.and_out(and_out_ex),.pc_signed_offset(pc_signed_offset),.address(address),.opcode(opcode));
id_stage id_st (.id_en(id_en),.data(data),.mux_inp(mux_inp),.imm11_5(imm11_5),.opcode_out_d(opcode),.rs1_data(rs1_data),.rs2_data(rs2_data),.imm_out(imm_out),.instruction(instruction),.wb_data(wb_data),
                                          .fn3_out_d(fn3),.fn7_5(fn7_5),.branch(branch),.mem_read(mem_read),.memtoreg(memtoreg),
                                          .aluop(aluop),.mem_write(mem_write),.alu_src(alu_src),.clk(clk),.reset(reset));
execution ex_st (.clk(clk),.reset(reset),.ex_en(ex_en),.mux_inp(mux_inp),.aluop(aluop),.pc_ex_out(pc_signed_offset),.address(address),.alu_src(alu_src),.branch(branch),.alu_out(alu_out),.rs1_data(rs1_data),.imm_out(imm_out),.and_out_ex(and_out_ex),.rs2_data(rs2_data),.fn3(fn3),.fn7_5(fn7_5),.imm11_5(imm11_5));
wb_stage wb_st (.mem_out(mem_out),.alu_out(alu_out),.memtoreg(memtoreg),.wb_data(wb_data),.return_addr(return_addr),.opcode_out_d(opcode),.imm_out(imm_out),.pc_signed_offset(pc_signed_offset));
fsm f(.opcode(opcode),.clk(clk),.reset(reset),.if_en(if_en),.id_en(id_en),.ex_en(ex_en),.wb_en(wb_en),.mem_en(mem_en));

endmodule

