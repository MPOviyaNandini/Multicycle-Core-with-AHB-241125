

module program_counter (
    input  logic        clk,
    input  logic        reset,
    input  logic        if_en,
      input  logic      ex_en,
    input  logic [31:0] pc_next,
    output logic [31:0] address
);
    // Sequential logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            address    <= 32'hA0000000;
        end
        else if (if_en&&!ex_en&&(pc_next<32'hA0000020)) begin//it was 18
          
                address    <= pc_next;   
                end  
        else if(pc_next>=32'hA0000020)
       address    <=  32'hA0000000; 
    end
endmodule




