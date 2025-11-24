module imm_generator(imm_input,imm_output,opcode,imm_input_uj,fn3);
input logic [11:0]imm_input;
input logic [2:0]fn3;
input logic [6:0]opcode;
output logic [31:0]imm_output;
input logic [19:0]imm_input_uj;

always_comb
begin
imm_output = 0;
case(opcode)
7'b1100011: //B-Type
imm_output = {{20{imm_input[11]}},imm_input}<<1;
7'b1101111: //JAL-Type
imm_output = {{12{imm_input_uj[19]}},imm_input_uj}<<1;
7'b0110111: //U-Type lui
imm_output = {{imm_input_uj},12'b0};
7'b1100111: //JALR-Type
imm_output = {{20{imm_input[11]}}, imm_input};
7'b0010111: //U-Type auipc
imm_output = {{imm_input_uj},12'b0};


 7'b0010011:
 begin // I-Type (immediate ALU ops)
      if (fn3 == 3'b001) 
      begin // SLLI
         imm_output = {27'b0, imm_input[4:0]};
      end
      else if (fn3 == 3'b101) 
      begin
         if (imm_input[11:5] == 7'b0000000) // SRLI
             imm_output = {27'b0, imm_input[4:0]};
      else if (imm_input[11:5] == 7'b0100000) // SRAI
               imm_output = {27'b0, imm_input[4:0]};
      end
      else
      begin // Other immediate ALU ops (e.g., ADDI, ANDI, ORI, etc.)
         imm_output = {{20{imm_input[11]}}, imm_input};
      end
 end

default:
begin
imm_output = {{20{imm_input[11]}},imm_input};
end
endcase
end

endmodule
