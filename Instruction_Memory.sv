module Instruction_Memory (
    input  logic        clk,
    input  logic        reset,
    input  logic        HSEL1,
    input  logic        rd_en_rom,
    input  logic [31:0] address_rom,  // word address
    output logic [31:0] instruction
);

    logic [31:0] mem [0:255];  // 256 words = 1KB

    // Initialize ROM contents
    initial begin
        // Zero out all memory locations first
        for (int i = 0; i < 256; i++) begin
            mem[i] = 32'b0;
        end
        
        mem[1] = 32'h00208113; // ADDI x2, x1, 2->04   
        mem[2] = 32'h00308193; // ADDI x3, x1, 3->08
        mem[3] = 32'h0040A203; // LW x4, 4(x1)->0c
        mem[4] = 32'h0020B423; // SW x2, 8(x1)->10
        mem[5] = 32'h003102B3; // ADD x5, x2, x3->14

    end
    // Output instruction if enabled
    always_ff @(posedge clk) begin
        if (!reset && HSEL1 && rd_en_rom) begin
            instruction <= mem[address_rom[9:2]];
        end else begin
            instruction <= 32'b0;
        end
    end

endmodule
