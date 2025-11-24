/*module reg_file(
    input logic [4:0] rs1_sel, rs2_sel,
    input logic reg_write, clk, reset,
    input logic [31:0] wb_data,
    input logic [4:0] rd_sel,      
    output logic [31:0] rs1_data, rs2_data
);

    logic [31:0] register [31:0];

    always_comb begin
        rs1_data = register[rs1_sel];
        rs2_data = register[rs2_sel];
    end

    always @(posedge clk or posedge reset) begin
       
        if (reset) begin
                register <= '{default: 0};
        end else begin
                if  ((rd_sel !=0)& reg_write)
                    register[rd_sel] <=  wb_data;
        end
        end
endmodule*/

/*module reg_file(
    input  logic        clk,
    input  logic        reset,
    input logic id_en,
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
        end else if(id_en) begin
            if (reg_write && (rd_sel != 5'd0)) begin
                register[rd_sel] <= wb_data; // write if not x0
            end
        end
    end

    // Combinational reads
    assign rs1_data = (rs1_sel == 5'd0) ? 32'b0 : register[rs1_sel];
    assign rs2_data = (rs2_sel == 5'd0) ? 32'b0 : register[rs2_sel];

endmodule

*/
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
            //register[5] <= 32'hEEEEFFFF; // preload x5
            //register[10] <= 32'h00000004; // preload x5
            // Preload register values

/*register[1]  <= 32'h00000005; // x1 = 5
register[2]  <= 32'h00000003; // x2 = 3
register[9]  <= 32'h00000009; // x6 = 9*/
//register[10]  <= 32'h00000008;
//register[12]  <= 32'h00000002; // x6 = 9*/


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
