
module fsm (
    input  logic        clk,
    input  logic        reset,
    input  logic [6:0]  opcode,   // directly from datapath/decoder
    output logic        if_en,
    output logic        id_en,
    output logic        ex_en,
    output logic        mem_en,
    output logic        wb_en
);

    // Opcodes
    localparam [6:0] OP_RTYPE  = 7'b0110011;
    
    
    localparam [6:0] OP_ITYPE  = 7'b0010011;
    localparam [6:0] OP_LUI    = 7'b0110111;
    localparam [6:0] OP_AUIPC  = 7'b0010111;
    localparam [6:0] OP_JAL    = 7'b1101111;
    localparam [6:0] OP_LOAD   = 7'b0000011;
    localparam [6:0] OP_STORE  = 7'b0100011;

    // FSM states
    typedef enum logic [4:0] {
        S_IDLE, S_IF, W1, W2, W3, W4,W5,
        S_ID, S_EX, W6, W7, W8,S_EXW, S_IDW,W9,W10,W11,W12,S_MEM,
        S_WB,S_IDW1,S_IDW2,S_IDW3,S_EXW1
    } state_t;

    state_t state, next_state;

    // Instruction classification
    logic is_rtype, is_load, is_store, is_lui;

    assign is_rtype = (opcode == OP_RTYPE);
    assign is_load  = (opcode == OP_LOAD);
    assign is_store = (opcode == OP_STORE);
    assign is_lui   = (opcode == OP_LUI);

    // Sequential state register
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    // Writeback flag
    logic writeback;
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            writeback <= 0;
        else if (state == S_WB && !is_store)
            writeback <= 1;
        else if (state == S_IF)
            writeback <= 0;
    end

    // Next-state logic + outputs
    always_comb begin
        // Default outputs
        if_en  = 0;
        id_en  = 0;
        ex_en  = 0;
        mem_en = 0;
        wb_en  = 0;
        next_state = state;

        case (state)
            S_IDLE: next_state = S_IF;

            // ---------------- IF stage (4-cycle)
            S_IF:  begin if_en = 1; next_state = W1; end
            W1:    next_state = W2;
            W2:    next_state = W3;
            W3:    next_state = W4;
            W4:    next_state = S_ID;
           
            // ---------------- ID stage
            S_ID: begin
                //id_en = 1;
                if(writeback)begin
                    next_state = S_IF;
                    
                    end
                else
                    next_state = S_IDW;
            end
             S_IDW: begin
                id_en = 1;
                next_state =  S_IDW1;
                
            end
            S_IDW1: begin
                id_en = 1;
                next_state = S_IDW2;
               
            end
            S_IDW2: begin
                next_state = S_EX;
            end
            
            // ---------------- EX stage
            S_EX: begin
                ex_en = 1;
                if (is_rtype || is_lui)
                    next_state = S_WB;
                else if (is_load || is_store)
                    next_state = S_EXW;
                else
                    next_state = S_WB; 
            end
             S_EXW: begin
                
                next_state = S_EXW1;
                
            end
            S_EXW1: begin
                //ex_en = 1;
                next_state = S_MEM;
                
            end
            
            // ---------------- MEM stage (for load/store, 3 cycles)
            S_MEM: next_state = W6;
            W6: next_state = W7;
            W7: next_state = W8;
            W8: next_state = W9;
            W9: begin
                mem_en = 1;
                if (is_load)
                    next_state = S_WB;
                else if (is_store)
                    next_state = S_IF;
            end

            // ---------------- WB stage
            S_WB: begin
                wb_en = 1;
                if(!is_store)
                    next_state = S_ID;
                else
                    next_state = S_IF;        
            end
            default: next_state = S_ID;
        endcase
    end

endmodule
