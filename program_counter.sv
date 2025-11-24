/*module program_counter (
    input  logic        clk,
    input  logic        reset,
    input  logic        [1:0]data,            // 0 = instruction fetch, 1 = data access
    input  logic [31:0] pc_next,
    output logic [31:0] address
);

    logic [1:0] cycle_count_inst; // counts 0 → 2 (3 cycles total)
    logic [3:0] cycle_count_data; // counts 0 → 8 (9 cycles total)

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            address           <= 32'hA0000000;
            cycle_count_inst  <= 0;
            cycle_count_data  <= 0;
        end else begin
          if(pc_next<32'hA000001c)begin
            if (data==2'b01||data==2'b10) begin
                // DATA MODE: hold for 9 cycles
                if (cycle_count_data < 4) begin
                    cycle_count_data <= cycle_count_data + 1;
                end else begin
                    cycle_count_data <= 0;
                    address          <= pc_next; // update after 9th cycle
                end
                // Reset instruction counter when in data mode
                cycle_count_inst <= 0;
                
            end else if(data==2'b00) begin
                // INSTRUCTION MODE: hold for 3 cycles
                if (cycle_count_inst <1) begin
                    cycle_count_inst <= cycle_count_inst + 1;
                end else begin
                    cycle_count_inst <= 0;
                    address          <= pc_next; // update after 3rd cycle
                end
                // Reset data counter when in instruction mode
               cycle_count_data <= 0;
              
                //cycle_count_inst <= 0;
                 
            end
            else begin
            address<=32'b00000000;
              end
        end
    end
end
endmodule


*/

/*module program_counter (
    input  logic         clk,
    input  logic         reset,
    input  logic [31:0]  pc_next,
    output logic [31:0]  address
);

    logic [2:0] cycle_count; // counts 0 → 4 (5 cycles total)

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            address <= 32'hA0000000;
            cycle_count <= 0;
        end else begin
            if (cycle_count < 5) begin
                cycle_count <= cycle_count + 1;
            end else begin
                cycle_count <= 0;
                address <= pc_next; // update after the 5th cycle
            end
        end
    end
endmodule*/

/*module program_counter (
    input logic if_en,
    input logic clk,
    input logic reset,
    input logic [31:0] pc_next,
    output logic [31:0] address
);

    logic [2:0] hold_count;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            address    <= 32'hA0000000;
            hold_count <= 3'd0;
        end
        else if (if_en) begin
            if (address < 32'hA0000014) begin
                if (hold_count == 3'd4) begin
                    address    <= pc_next;
                    hold_count <= 3'd0;
                end
                else begin
                    hold_count <= hold_count + 3'd1;
                end
            end
            // else: address stays the same automatically
        end
    end
endmodule*/

/*module program_counter (
    input logic if_en,
    input logic clk,
    input logic reset,
    input logic [31:0] pc_next,
    output logic [31:0] address
);

    logic [2:0] hold_count;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            address    <= 32'hA0000000;
            hold_count <= 3'd0;
        end
        else if (if_en) begin
            if (hold_count == 3'd4) begin
                address    <= pc_next;  // update PC after 5 cycles
                hold_count <= 3'd0;
            end
            else begin
                hold_count <= hold_count + 3'd1;
            end
        end
    end
endmodule*/
//this was the working one
/*module program_counter (
    input  logic        clk,
    input  logic        reset,
    input  logic        if_en,
    input  logic [31:0] pc_next,
    output logic [31:0] address
);

    logic [2:0] hold_count;
    logic [31:0] next_address;

    // Sequential logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            address    <= 32'hA0000000;
            hold_count <= 3'd0;
        end
        else if (if_en) begin
            if (hold_count == 3'd5) begin
                address    <= pc_next;   // update PC after 5 cycles
                hold_count <= 3'd0;
            end
            else begin
                hold_count <= hold_count + 3'd1;
            end
        end
    end

endmodule*/
//BELOW CODE IS 27_10_25
/*module program_counter (
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
        else if (if_en&&!ex_en&&(pc_next<32'hA000001C)) begin
          
                address    <= pc_next;   // update PC after 5 cycles
                end
        
    end
endmodule*/

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
        //address    <= address ;
       address    <=  32'hA0000000; 
    end
endmodule



