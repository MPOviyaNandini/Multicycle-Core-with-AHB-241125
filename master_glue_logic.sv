
/*`timescale 1ns/1ps
module master_glue_logic (
    input  logic        clk,
    input  logic        reset,
    input  logic        mem_en,
    input  logic        if_en,
    // Core side
    input  logic [31:0] alu_out,     // Data address
    input  logic [31:0] address,     // Instruction address
    input  logic        mem_read,
    input  logic        mem_write,
    input  logic [31:0] rs2_data,
    input  logic [2:0]  fn3,

    // AHB Slave side
    input  logic [31:0] hr_data,
    input  logic        hready,
    input  logic        hresp,
    input  logic        muxsel,

    // AHB Master outputs
    output logic [31:0] haddr,
    output logic [1:0]  htrans,
    output logic [3:0]  hprot,
    output logic [2:0]  hsize,
    output logic        hwrite,
    output logic [31:0] hwdata,
    output logic        is_signed,

    // Core outputs
    output logic [31:0] instruction,
    output logic [31:0] mem_out
);

    // State encoding (added all missing WRITE_DATA_WAIT states)
    typedef enum logic [3:0] {
        INIT             = 4'b0000,
        READ_INSTR       = 4'b0001,
        READ_DATA_WAIT1  = 4'b0010,
        WRITE_DATA_WAIT1 = 4'b0011,
        WRITE_DATA_WAIT2 = 4'b0100,
        WAIT_STATE       = 4'b1101,
        ERROR_STATE      = 4'b1110,
        READ_DATA_WAIT2  = 4'b1111
    } state_t;

    state_t state, nextstate;

    // Registers for AHB signals
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state       <= INIT;
            htrans      <= 2'b00;
            hwrite      <= 1'b0;
            haddr       <= 32'b0;
            hwdata      <= 32'b0;
            hsize       <= 3'b010;
            hprot       <= 4'b0011;
            instruction <= 32'b0;
            mem_out     <= 32'b0;
        end else begin
            state <= nextstate;
        end
    end

    // Next-state logic and outputs
    always_comb begin
        // Defaults
        nextstate = state;
        is_signed = 1'b0;

        case (state)
            INIT: begin
                htrans = 2'b00; // idle
                if (hready && !hresp&&mem_en)
                    nextstate = READ_INSTR; 
                else
                    nextstate = WAIT_STATE;
            end

            READ_INSTR: begin
                if (hready && !hresp) begin
                    hwrite = 1'b0;
                    htrans = 2'b10; // NONSEQ
                    hprot  = 4'b0000;
                    haddr  = address;    // instruction fetch from PC
                    hsize  = 3'b010;
                    if (mem_read)
                        nextstate = READ_DATA_WAIT1;
                    else if (mem_write)
                        nextstate = WRITE_DATA_WAIT1;*/
                    /*else
                        nextstate = READ_INSTR;*/
                    /*else if (!hready && !hresp)
                        nextstate = WAIT_STATE;
                    else if (hresp)  
                    nextstate = ERROR_STATE;
                    else 
                    nextstate = INIT;
            end
            end
            READ_DATA_WAIT1: begin nextstate=READ_DATA_WAIT2; end
            READ_DATA_WAIT2:begin
                if (hready && !hresp ) begin
                    hwrite = 1'b0;
                    htrans = 2'b10;
                    hprot  = 4'b0001;
                    haddr  = {8'hB0, alu_out[23:0]}; // B0 + ALU address

                    // Size / signedness based on funct3
                    case (fn3)
                        3'b000: begin hsize = 3'b000; is_signed = 1'b1; end // LB
                        3'b001: begin hsize = 3'b001; is_signed = 1'b1; end // LH
                        3'b010: begin hsize = 3'b010; is_signed = 1'b1; end // LW
                        3'b100: hsize = 3'b000; // LBU
                        3'b101: hsize = 3'b001; // LHU
                        default: hsize = 3'b010;
                    endcase

                    nextstate = INIT;
                end
            end

            WRITE_DATA_WAIT1: nextstate = WRITE_DATA_WAIT2;
            
            
            WRITE_DATA_WAIT2: begin 
                if (hready && !hresp) begin
                    hwrite = 1'b1;
                    htrans = 2'b10;
                    hprot  = 4'b0001;
                    haddr  = {8'hB0, alu_out[23:0]}; // B0 + ALU address
                    hwdata = rs2_data;

                    case (fn3)
                        3'b000: hsize = 3'b000; // SB
                        3'b001: hsize = 3'b001; // SH
                        3'b010: hsize = 3'b010; // SW
                        default: hsize = 3'b010;
                    endcase

                    nextstate = READ_INSTR;
                end
            end

            WAIT_STATE: begin
                if (hresp)
                    nextstate = ERROR_STATE;
                else if (hready && !hresp)
                    nextstate = READ_INSTR;
                else
                    nextstate = WAIT_STATE;
            end

            ERROR_STATE: begin
                htrans = 2'b00; // idle
                if (hready && !hresp)
                    nextstate = READ_INSTR;
                else
                    nextstate = ERROR_STATE;
            end
        endcase
    end

    // Instruction vs Data MUX
    always_ff @(posedge clk) begin
        if (muxsel)
            instruction <= hr_data;  // instruction fetch
        else
            mem_out <= hr_data;      // load result
    end

endmodule*/

`timescale 1ns/1ps
module master_glue_logic (
    input  logic        clk,
    input  logic        reset,
    input  logic        mem_en,
    input  logic        if_en,
    // Core side
    input  logic [31:0] alu_out,     // Data address
    input  logic [31:0] address,     // Instruction address
    input  logic        mem_read,
    input  logic        mem_write,
    input  logic [31:0] rs2_data,
    input  logic [2:0]  fn3,

    // AHB Slave side
    input  logic [31:0] hr_data,
    input  logic        hready,
    input  logic        hresp,
    input  logic        muxsel,

    // AHB Master outputs
    output logic [31:0] haddr,
    output logic [1:0]  htrans,
    output logic [3:0]  hprot,
    output logic [2:0]  hsize,
    output logic        hwrite,
    output logic [31:0] hwdata,
    output logic        is_signed,

    // Core outputs
    output logic [31:0] instruction,
    output logic [31:0] mem_out
);

    // State encoding (added all missing WRITE_DATA_WAIT states)
    typedef enum logic [3:0] {
        INIT             = 4'b0000,
        READ_INSTR       = 4'b0001,
        READ_DATA_WAIT1  = 4'b0010,
        WRITE_DATA_WAIT1 = 4'b0011,
        WRITE_DATA_WAIT2 = 4'b0100,
        WAIT_STATE       = 4'b1101,
        ERROR_STATE      = 4'b1110,
        READ_DATA_WAIT2  = 4'b1111
    } state_t;

    state_t state, nextstate;

    // Registers for AHB signals
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state       <= INIT;
            htrans      <= 2'b00;
            hwrite      <= 1'b0;
            haddr       <= 32'b0;
            hwdata      <= 32'b0;
            hsize       <= 3'b010;
            hprot       <= 4'b0011;
            instruction <= 32'b0;
            mem_out     <= 32'b0;
        end else begin
            state <= nextstate;
        end
    end

    // Next-state logic and outputs
    always_comb begin
        // Defaults
        nextstate = state;
        is_signed = 1'b0;

        case (state)
            INIT: begin
                htrans = 2'b00; // idle
                if (hready && !hresp)begin
                    if(if_en)
                    nextstate = READ_INSTR; 
                    else if(/*mem_en&&*/mem_read)
                    nextstate = READ_DATA_WAIT1;
                    else if(/*mem_en&&*/mem_write)
                    nextstate = WRITE_DATA_WAIT1;
                    end
                else
                    nextstate = WAIT_STATE;
            end

            READ_INSTR: begin
                if (hready && !hresp) begin
                    hwrite = 1'b0;
                    htrans = 2'b10; // NONSEQ
                    hprot  = 4'b0000;
                    haddr  = address;    // instruction fetch from PC
                    hsize  = 3'b010;
                    if (mem_read)
                        nextstate = READ_DATA_WAIT1;
                    else if (mem_write)
                        nextstate = WRITE_DATA_WAIT1;
                    /*else
                        nextstate = READ_INSTR;*/
                    else if (!hready && !hresp)
                        nextstate = WAIT_STATE;
                    else if (hresp)  
                    nextstate = ERROR_STATE;
                    else 
                    nextstate = INIT;
            end
            end
            READ_DATA_WAIT1: begin nextstate=READ_DATA_WAIT2; end
            READ_DATA_WAIT2:begin
                if (hready && !hresp ) begin
                    hwrite = 1'b0;
                    htrans = 2'b10;
                    hprot  = 4'b0001;
                    haddr  = {8'hB0, alu_out[23:0]}; // B0 + ALU address

                    // Size / signedness based on funct3
                    case (fn3)
                        3'b000: begin hsize = 3'b000; is_signed = 1'b1; end // LB
                        3'b001: begin hsize = 3'b001; is_signed = 1'b1; end // LH
                        3'b010: begin hsize = 3'b010; is_signed = 1'b1; end // LW
                        3'b100: hsize = 3'b000; // LBU
                        3'b101: hsize = 3'b001; // LHU
                        default: hsize = 3'b010;
                    endcase

                    nextstate = INIT;
                end
            end

            WRITE_DATA_WAIT1: nextstate = WRITE_DATA_WAIT2; 
            WRITE_DATA_WAIT2: begin 
                if (hready && !hresp) begin
                    hwrite = 1'b1;
                    htrans = 2'b10;
                    hprot  = 4'b0001;
                    haddr  = {8'hB0, alu_out[23:0]}; // B0 + ALU address
                    hwdata = rs2_data;

                    case (fn3)
                        3'b000: hsize = 3'b000; // SB
                        3'b001: hsize = 3'b001; // SH
                        3'b010: hsize = 3'b010; // SW
                        default: hsize = 3'b010;
                    endcase

                    nextstate = READ_INSTR;
                end
            end

            WAIT_STATE: begin
                if (hresp)
                    nextstate = ERROR_STATE;
                else if (hready && !hresp)
                begin
                    if(mem_en&&mem_read)
                    nextstate = READ_DATA_WAIT1;
                    else if(mem_en && mem_write)
                    nextstate = WRITE_DATA_WAIT1;
                    else
                    nextstate = READ_INSTR;
                    
                end
            end

            ERROR_STATE: begin
                htrans = 2'b00; // idle
                if (hready && !hresp)
                    nextstate = READ_INSTR;
                else
                    nextstate = ERROR_STATE;
            end
        endcase
    end

    // Instruction vs Data MUX
    always_ff @(posedge clk) begin
        if (muxsel)
            instruction <= hr_data;  // instruction fetch
        else
            mem_out <= hr_data;      // load result
    end

endmodule
