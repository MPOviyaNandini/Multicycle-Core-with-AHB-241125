module master_glue (
    input  logic [31:0] data_out_mux,
    input  logic        hready,
    input  logic        hresp,
    input  logic [2:0]  fn3,
    input  logic        mem_write,
    input  logic        mem_read,
    input  logic [31:0] rs2_data,
    input  logic [31:0] alu_out,
    input  logic [31:0] address,
    output logic [1:0]  htrans,
    output logic [31:0] haddr,
    output logic [31:0] hwdata,
    output logic [3:0]  hprot,
    output logic        hwrite,
    output logic [2:0]  hsize,
    output logic [31:0] data_out
);

always_comb begin
    // Default assignments
    htrans   = 2'b00;
    haddr    = 32'b0;
    hwdata   = 32'b0;
    hprot    = 4'b0000;
    hwrite   = 1'b0;
    hsize    = 3'b010;
    data_out = data_out_mux;

    if (hready && !hresp) begin
        htrans = 2'b10; // NONSEQ

        if (address[31:24] == 8'hA0) begin // ROM
            if (!mem_read && !mem_write) begin
                haddr  = address;
                hwrite = 1'b0;
                hprot  = 4'b0000;
                case (fn3)
                    3'b000: hsize = 3'b000; // LB
                    3'b001: hsize = 3'b001; // LH
                    3'b010: hsize = 3'b010; // LW
                    3'b100: hsize = 3'b000; // LBU
                    3'b101: hsize = 3'b001; // LHU
                    default: hsize = 3'b010;
                endcase
            end
        end
        else if (address[31:24] == 8'hB0) begin // RAM
            haddr = alu_out;
            hprot = 4'b0001;
            case (fn3)
                3'b000: hsize = 3'b000;
                3'b001: hsize = 3'b001;
                3'b010: hsize = 3'b010;
                3'b100: hsize = 3'b000;
                3'b101: hsize = 3'b001;
                default: hsize = 3'b010;
            endcase

            if (mem_write) begin
                hwrite = 1'b1;
                hwdata = rs2_data;
            end
            else if (mem_read) begin
                hwrite = 1'b0;
            end
        end
    end
end

endmodule
