/*module if_stage
(
    input logic clk, and_out, reset,
    //input logic [1:0] data,
    input logic [31:0] pc_signed_offset,
    input logic [6:0]opcode,
    output logic [31:0] address, pc_new
    
);
    wire [31:0] pc_next;
    wire pc_gen_out;
    adder add (.address(address), .b(4), .pc_new(pc_new));
    mux21 mu (.a(pc_new), .b(pc_signed_offset), .control(pc_gen_out), .y(pc_next));
    program_counter programc (.pc_next(pc_next), .address(address), .clk(clk), .reset(reset));
    pc_cntrl pc_cnt (.opcode(opcode),.and_out(and_out),.pc_gen_out(pc_gen_out));
endmodule*/

module if_stage (
    input  logic        clk,
    input  logic        reset,
    input  logic        and_out,
    input  logic        if_en,              // <-- enable from FSM
    input  logic        ex_en, 
    input  logic [31:0] pc_signed_offset,
    input  logic [6:0]  opcode,
    output logic [31:0] address,
    output logic [31:0] pc_new
);

    logic [31:0] pc_next;
    logic        pc_gen_out;

    // Adder for PC+4
    adder add (.if_en(if_en),
        .address(address),
        .b(32'd4),
        .pc_new(pc_new)
    );

    // Branch MUX
    mux21 mu (
        .a(pc_new),
        .b(pc_signed_offset),
        .control(pc_gen_out),
        .y(pc_next)
    );

    // Program Counter (only updates when if_en=1)
    program_counter programc (
        .clk(clk),
        .reset(reset),
        .if_en(if_en),       // <-- added enable
        .ex_en(ex_en),
        .pc_next(pc_next),
        .address(address)
    );

    // PC Control for branch/jump
    pc_cntrl pc_cnt (
        .opcode(opcode),
        .and_out(and_out),
        .pc_gen_out(pc_gen_out)
    );

endmodule
