
module reg_file(
    input  logic        clk,
    input  logic        reset,
    input  logic        id_en,
    input  logic        reg_write,
    input  logic [4:0]  rs1_sel, rs2_sel, rd_sel,
    input  logic [31:0] wb_data,
    output logic [31:0] rs1_data, rs2_data
);

    // 32 registers, each 32 bits wide
    logic [31:0] register [31:0];

    // Synchronous write + reset
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            integer i;
            for (i = 0; i < 32; i++) begin
                register[i] <= 32'b0;    // clear all registers
            end

        end else if (id_en) begin
            if (reg_write && (rd_sel != 5'd0)) begin
                register[rd_sel] <= wb_data; // write if not x0
            end
        end
    end

    // Combinational reads with bypassing
    assign rs1_data = (rs1_sel == 5'd0) ? 32'b0 :
                      ((reg_write && (rd_sel == rs1_sel) && id_en) ? wb_data : register[rs1_sel]);

    assign rs2_data = (rs2_sel == 5'd0) ? 32'b0 :
                      ((reg_write && (rd_sel == rs2_sel) && id_en) ? wb_data : register[rs2_sel]);

endmodule
