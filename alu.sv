/*module alu (
    input  logic        ex_en,
    input  logic [3:0]  alu_control,
    input  logic [31:0] rs1_data, rs2_data,
    output logic [31:0] alu_out,
    output logic        zero
);

    // Signed versions for comparisons
    logic signed [31:0] rss1_data, rss2_data;
    assign rss1_data = rs1_data;
    assign rss2_data = rs2_data;

    always_comb begin
        alu_out = 0;
        zero    = 0;

        if (ex_en) begin
            case (alu_control)
                4'b0000: alu_out = rss1_data + rss2_data;            // add/addi/load/store/jalr
                4'b0001: alu_out = rss1_data - rss2_data;            // sub
                4'b0010: alu_out = rss1_data ^ rss2_data;            // xor/xori
                4'b0011: alu_out = rss1_data | rss2_data;            // or/ori
                4'b0100: alu_out = rss1_data & rss2_data;            // and/andi
                4'b0101: alu_out = rss1_data << rs2_data[4:0];       // sll/slli
                4'b0110: alu_out = rss1_data >> rs2_data[4:0];       // srl/srli
                4'b0111: alu_out = rss1_data >>> rs2_data[4:0];      // sra/srai

                4'b1000: alu_out = (rss1_data < rss2_data) ? 32'd1 : 32'd0;  // slt/slti
                4'b1001: alu_out = (rs1_data < rs2_data)   ? 32'd1 : 32'd0;  // sltu/sltiu

                // Branches: drive zero as branch_taken flag
                4'b1010: zero = (rss1_data == rss2_data);   // beq
                4'b1011: zero = (rss1_data != rss2_data);   // bne
                4'b1100: zero = (rss1_data <  rss2_data);   // blt
                4'b1101: zero = (rss1_data >= rss2_data);   // bge
                4'b1110: zero = (rs1_data  <  rs2_data);    // bltu
                4'b1111: zero = (rs1_data  >= rs2_data);    // bgeu

                default: begin
                    alu_out = 0;
                    zero    = 0;
                end
            endcase
        end
    end

endmodule*/
module alu (
    input  logic        clk,
    input  logic        reset,
    input  logic        ex_en,
    input  logic [3:0]  alu_control,
    input  logic [31:0] rs1_data, rs2_data,
    output logic [31:0] alu_out,
    output logic        zero
);

    // Signed versions for comparisons
    logic signed [31:0] rss1_data, rss2_data;
    assign rss1_data = rs1_data;
    assign rss2_data = rs2_data;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            alu_out <= 32'b0;
            zero    <= 1'b0;
        end 
        else if (ex_en) begin
            case (alu_control)
                4'b0000: alu_out <= rss1_data + rss2_data;            // add/addi/load/store/jalr
                4'b0001: alu_out <= rss1_data - rss2_data;            // sub
                4'b0010: alu_out <= rss1_data ^ rss2_data;            // xor/xori
                4'b0011: alu_out <= rss1_data | rss2_data;            // or/ori
                4'b0100: alu_out <= rss1_data & rss2_data;            // and/andi
                4'b0101: alu_out <= rss1_data << rs2_data[4:0];       // sll/slli
                4'b0110: alu_out <= rss1_data >> rs2_data[4:0];       // srl/srli
                4'b0111: alu_out <= rss1_data >>> rs2_data[4:0];      // sra/srai

                4'b1000: alu_out <= (rss1_data < rss2_data) ? 32'd1 : 32'd0;  // slt/slti
                4'b1001: alu_out <= (rs1_data < rs2_data)   ? 32'd1 : 32'd0;  // sltu/sltiu

                // Branches: store result in zero flag
                4'b1010: zero <= (rss1_data == rss2_data);   // beq
                4'b1011: zero <= (rss1_data != rss2_data);   // bne
                4'b1100: zero <= (rss1_data <  rss2_data);   // blt
                4'b1101: zero <= (rss1_data >= rss2_data);   // bge
                4'b1110: zero <= (rs1_data  <  rs2_data);    // bltu
                4'b1111: zero <= (rs1_data  >= rs2_data);    // bgeu

                default: begin
                    //alu_out <= 32'b0;
                    //zero    <= 1'b0;
                end
            endcase
        end
        
    end

endmodule


