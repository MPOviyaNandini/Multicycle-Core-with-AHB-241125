module adder
(   input logic if_en,
    input logic [31:0] address, b,
    output logic [31:0] pc_new
);

always_comb
if(if_en)begin
pc_new = address + b;
end
endmodule