module ahb_dec (
    input  logic [31:0] haddr,
    output logic        HSEL1,
    output logic        HSEL2,
    output logic        muxsel 
);

always_comb begin
    HSEL1  = 1'b0;
    HSEL2  = 1'b0;
    muxsel = 1'b0;
    if(haddr[31:24]== 8'hA0)begin
            HSEL1  = 1'b1;
            muxsel = 1'b1;   
    end
    else if(haddr[31:24]== 8'hB0) begin
            HSEL2  = 1'b1;
            muxsel = 1'b0;    
    end
    
end
endmodule



