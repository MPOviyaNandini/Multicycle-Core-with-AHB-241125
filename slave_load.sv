module slave_load (
  input  logic [2:0]  hsize,
  input logic clk,
  input  logic        is_signed,
  input  logic [31:0] read_data,
  output logic [31:0] load_out
);

  always@(posedge clk) begin
    if (is_signed) begin
      case (hsize)
        3'b000: load_out = {{24{read_data[7]}},  read_data[7:0]};
        3'b001: load_out = {{16{read_data[15]}}, read_data[15:0]};
        default: load_out = read_data;
      endcase
    end else begin
      case (hsize)
        3'b000: load_out = {24'b0, read_data[7:0]};
        3'b001: load_out = {16'b0, read_data[15:0]};
        default: load_out = read_data;
      endcase
    end
end
endmodule