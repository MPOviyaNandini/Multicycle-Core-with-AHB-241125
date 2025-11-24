module slave_store (
  input  logic [2:0]  hsize,
  input logic clk,
  input  logic [31:0] read_data,
  input  logic [31:0] wr_data_ram,
  output logic [31:0] store_out
);

  always@(posedge clk) begin
    case (hsize)
      3'b000: store_out = {read_data[31:8],  wr_data_ram[7:0]};   // SB
      3'b001: store_out= {read_data[31:16], wr_data_ram[15:0]};  // SH
      3'b010: store_out = wr_data_ram;                            // SW
      default: store_out = wr_data_ram;
    endcase
  end

endmodule