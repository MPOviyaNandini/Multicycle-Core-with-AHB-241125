module mux31 (input  logic [31:0] a, b, c,
    input  logic [1:0]  cntrl,
    output logic [31:0] out
);

always_comb begin
    out = 32'd0; // default

    
        case (cntrl)
            2'b00: out = a;
            2'b01: out = b;
            2'b10: out = c;
            default: out = 32'd0;
        endcase
   
end

endmodule
