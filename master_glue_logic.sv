/*module master_glue_logic (
    input  logic [31:0] hr_data,
    input  logic        hready,
    input  logic        hresp,
    input  logic [2:0]  fn3,
    input  logic        mem_write,
    input  logic        mem_read,
    input  logic [31:0] rs2_data,
    input  logic [31:0] alu_out,
    input  logic [31:0] address,
    //input logic HSEL1,
    //input logic HSEL2,
    input muxsel,


    output logic [1:0]  htrans,
    output logic [31:0] haddr,
    output logic [31:0] hwdata,
    output logic [3:0]  hprot,
    output logic        hwrite,
    output logic [2:0]  hsize,
    output logic        is_signed,
    
    output logic [31:0] instruction,mem_out 
);

always_comb begin
    // Default assignments
    htrans    = 2'b00;
    haddr     = address;
    hwdata    = 32'b0;
    hprot     = 4'b0000;
    hwrite    = 1'b0;
    hsize     = 3'b010;
    is_signed = 1'b0;
    

    if (hready && !hresp) begin
        htrans = 2'b10; // NONSEQ

       if (address[31:24] == 8'hB0) begin // RAM region
            haddr = alu_out;
            hprot = 4'b0001;
            case (fn3)
                3'b000: begin
                    hsize     = 3'b000;
                    is_signed = 1'b1;
                end
                3'b001: begin
                    hsize     = 3'b001;
                    is_signed = 1'b1;
                end
                3'b010: begin
                    hsize     = 3'b010;
                    is_signed = 1'b1;
                end
                3'b100: hsize = 3'b000; // LBU
                3'b101: hsize = 3'b001; // LHU
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


always_comb begin
    //instruction = 32'b0;  // Default assignment to avoid partial assign
    mem_out     = 32'b0;

    if (muxsel) instruction = hr_data;
else  mem_out = hr_data;

end


endmodule
*/

/*`timescale 1ns/1ps
module master_glue_logic(
    input  wire        clk,
    input  wire        reset,

    // Core side
    input  wire [31:0] hrdata,     // HRDATA from AHB slave
    input  wire [31:0] alu_out,    // data address
    input  wire [31:0] address,    // instruction address (PC)
    input  wire        mem_read,   // data read request
    input  wire        mem_write,  // data write request
    input  wire [31:0] rs2_data,   // store data
    input  wire [2:0]  fn3,        // size/signedness from funct3 (loads/stores)
    input  wire        muxsel,     // 1: route HRDATA to instruction, 0: to mem_out (used on read complete)

    // AHB slave side
    input  wire        hready,
    input  wire        hresp,      // 0=OKAY, 1=ERROR

    // AHB master outputs
    output logic       is_signed,  // for core's sign-extend unit (loads)
    output reg  [31:0] haddr,
    output reg  [1:0]  htrans,
    output reg  [2:0]  hsize,
    output reg         hwrite,
    output reg  [3:0]  hprot,
    output reg  [31:0] hwdata,

    // Core-side read results
    output logic [31:0] instruction,
    output logic [31:0] mem_out
);

    // -------- AHB encodings ----------
    localparam [1:0] HTRANS_IDLE   = 2'b00;
    localparam [1:0] HTRANS_BUSY   = 2'b01;
    localparam [1:0] HTRANS_NONSEQ = 2'b10;
    localparam [1:0] HTRANS_SEQ    = 2'b11; // (unused here; single-beat transfers)

    // -------- States ----------
    typedef enum logic [2:0] {
        S_IDLE       = 3'd0,  // no transfer pending
        S_IF_ADDR    = 3'd1,  // drive instr fetch address/control
        S_IF_WAIT    = 3'd2,  // wait for HREADY (instr)
        S_LD_ADDR    = 3'd3,  // drive data-read address/control
        S_LD_WAIT    = 3'd4,  // wait for HREADY (read)
        S_ST_ADDR    = 3'd5,  // drive data-write address/control
        S_ST_WAIT    = 3'd6,  // wait for HREADY (write)
        S_ERROR      = 3'd7
    } state_t;

    state_t state, next;

    // Latched (held) control for the active transfer
    reg [31:0] addr_r, wdata_r;
    reg [2:0]  hsize_r;
    reg [3:0]  hprot_r;
    reg        hwrite_r;
    reg        is_signed_r;   // holds load sign info for current transfer

    // ---------- State register & reset ----------
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state       <= S_IDLE;

            addr_r      <= 32'd0;
            wdata_r     <= 32'd0;
            hsize_r     <= 3'b010;   // word by default
            hprot_r     <= 4'b0011;  // impl-defined; safe default
            hwrite_r    <= 1'b0;
            is_signed_r <= 1'b0;

            // drive safe AHB outputs on reset
            haddr   <= 32'd0;
            htrans  <= HTRANS_IDLE;
            hsize   <= 3'b010;
            hwrite  <= 1'b0;
            hprot   <= 4'b0011;
            hwdata  <= 32'd0;

            instruction <= 32'd0;
            mem_out     <= 32'd0;
            is_signed   <= 1'b0;
        end else begin
            state <= next;

            // Drive AHB outputs from held regs each cycle
            haddr  <= addr_r;
            hsize  <= hsize_r;
            hwrite <= hwrite_r;
            hprot  <= hprot_r;
            hwdata <= wdata_r;

            // Output is_signed follows registered copy
            is_signed <= is_signed_r;

            // HTRANS depends on state/progress
            unique case (next)
                S_IDLE,
                S_ERROR:    htrans <= HTRANS_IDLE;

                // Address phase cycles
                S_IF_ADDR,
                S_LD_ADDR,
                S_ST_ADDR:  htrans <= HTRANS_NONSEQ;

                // Hold during wait states
                S_IF_WAIT,
                S_LD_WAIT,
                S_ST_WAIT:  htrans <= HTRANS_BUSY;

                default:    htrans <= HTRANS_IDLE;
            endcase

            // Capture HRDATA synchronously when read completes
            // (instruction fetch or data load completing)
            if ( (state == S_IF_WAIT || state == S_LD_WAIT) && hready && !hresp ) begin
                if (muxsel)
                    instruction <= hrdata;
                else
                    mem_out <= hrdata;
            end
        end
    end

    // ---------- Next-state & control generation ----------
    always_comb begin
        // Default: hold previous latched control
        next         = state;

        // Defaults (don't leave these unassigned in any path)
        // Note: the actual AHB outputs are driven from *_r in always_ff.
        // Here we only decide what to latch next cycle.
        addr_r_next: begin end // dummy label to remind: we're modifying addr_r etc. below

        unique case (state)
            // ------------------------------------------------
            S_IDLE: begin
                // Choose next transfer: prioritize data ops if requested,
                // otherwise perform an instruction fetch.
                if (mem_write) begin
                    next = S_ST_ADDR;
                end else if (mem_read) begin
                    next = S_LD_ADDR;
                end else begin
                    next = S_IF_ADDR;
                end
            end

            // -------- Instruction fetch (address/control) ----
            S_IF_ADDR: begin
                // Latch control for IF
                addr_r      = address;
                hsize_r     = 3'b010;    // word fetch
                hprot_r     = 4'b0011;   // impl-defined
                hwrite_r    = 1'b0;
                wdata_r     = 32'd0;
                is_signed_r = 1'b0;      // not used for IF

                // Go wait for data phase to complete
                next = S_IF_WAIT;
            end

            // Wait for IF completion
            S_IF_WAIT: begin
                if (hresp)        next = S_ERROR;
                else if (hready)  next = S_IDLE;
            end

            // -------- Data READ (address/control) ------------
            S_LD_ADDR: begin
                addr_r      = alu_out;
                hprot_r     = 4'b0001;   // data access
                hwrite_r    = 1'b0;
                wdata_r     = 32'd0;

                // Default size/sign
                hsize_r     = 3'b010;    // LW
                is_signed_r = 1'b0;

                // Decode loads by funct3
                unique case (fn3)
                    3'b000: begin hsize_r = 3'b000; is_signed_r = 1'b1; end // LB
                    3'b001: begin hsize_r = 3'b001; is_signed_r = 1'b1; end // LH
                    3'b010: begin hsize_r = 3'b010; is_signed_r = 1'b1; end // LW
                    3'b100: begin hsize_r = 3'b000; is_signed_r = 1'b0; end // LBU
                    3'b101: begin hsize_r = 3'b001; is_signed_r = 1'b0; end // LHU
                    default: begin hsize_r = 3'b010; is_signed_r = 1'b1; end // default LW (signed)
                endcase

                next = S_LD_WAIT;
            end

            // Wait for read completion
            S_LD_WAIT: begin
                if (hresp)        next = S_ERROR;
                else if (hready)  next = S_IDLE;
            end

            // -------- Data WRITE (address/control) -----------
            S_ST_ADDR: begin
                addr_r      = alu_out;
                hprot_r     = 4'b0001;
                hwrite_r    = 1'b1;
                wdata_r     = rs2_data;

                // Default size for stores (signedness N/A for stores)
                hsize_r     = 3'b010; // SW
                is_signed_r = 1'b0;

                // Decode stores by funct3
                unique case (fn3)
                    3'b000: hsize_r = 3'b000; // SB
                    3'b001: hsize_r = 3'b001; // SH
                    3'b010: hsize_r = 3'b010; // SW
                    default: hsize_r = 3'b010;
                endcase

                next = S_ST_WAIT;
            end

            // Wait for write completion
            S_ST_WAIT: begin
                if (hresp)        next = S_ERROR;
                else if (hready)  next = S_IDLE;
            end

            // -------- Error handling -------------------------
            S_ERROR: begin
                // Remain idle until error clears
                if (!hresp && hready) next = S_IDLE;
            end

            default: next = S_IDLE;
        endcase
    end

endmodule*/
/*`timescale 1ns/1ps
module master_glue_logic (
    input  logic        clk,
    input  logic        reset,

    // Core side
    input  logic [31:0] alu_out,     // Data address
    input  logic [31:0] address,     // Instruction address
    input  logic        mem_read,
    input  logic       mem_write,
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
    output logic [2:0]  hsize,
    output logic        hwrite,
    output logic [3:0]  hprot,
    output logic [31:0] hwdata,
    output logic        is_signed,

    // Core outputs
    output logic [31:0] instruction,
    output logic [31:0] mem_out
);

    // State encoding
    typedef enum logic [2:0] {
        INIT        = 3'b000,
        READ_INSTR  = 3'b001,
        READ_DATA   = 3'b010,
        WRITE_DATA  = 3'b011,
        WAIT_STATE  = 3'b100,
        ERROR_STATE = 3'b101
    } state_t;

    state_t state, nextstate;

    // Registers for AHB signals
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state   <= INIT;
            htrans  <= 2'b00;
            hwrite  <= 1'b0;
            haddr   <= 32'b0;
            hwdata  <= 32'b0;
            hsize   <= 3'b010;
            hprot   <= 4'b0011;
        end else begin
            state <= nextstate;
        end
    end

    // Next-state logic and outputs
    always_ff @(posedge clk) begin
        // Defaults
        nextstate = state;
        is_signed = 1'b0;

        case (state)
            INIT: begin
                htrans = 2'b00; // idle
                if (hready && !hresp)begin
                    nextstate = READ_INSTR; 
                    end     
                else
                    nextstate = WAIT_STATE;
                    //nextstate = READ_INSTR; 
            end

            READ_INSTR: begin
                if (hready && !hresp) begin
                    hwrite = 1'b0;
                    htrans = 2'b10; // NONSEQ
                    hprot  = 4'b0000;
                    haddr  = address;
                    hsize  = 3'b010;
                    if (mem_read)
                        nextstate = READ_DATA;
                    else if (mem_write)
                        nextstate = WRITE_DATA;
                    else
                        nextstate = INIT;
                        //nextstate =READ_INSTR;
                end else if (!hready && !hresp)
                    nextstate = WAIT_STATE;
                else if (hresp)
                    nextstate = ERROR_STATE;
            end

            READ_DATA: begin
                if (hready && !hresp) begin
                    hwrite = 1'b0;
                    htrans = 2'b10;
                    hprot  = 4'b0001;
                    haddr  = alu_out;

                    // Size / signedness based on funct3
                    case (fn3)
                        3'b000: begin hsize = 3'b000; is_signed = 1'b1; end // LB
                        3'b001: begin hsize = 3'b001; is_signed = 1'b1; end // LH
                        3'b010: begin hsize = 3'b010; is_signed = 1'b1; end // LW
                        3'b100: hsize = 3'b000; // LBU
                        3'b101: hsize = 3'b001; // LHU
                        default: hsize = 3'b010;
                    endcase

                    nextstate =READ_INSTR;
                end else if (!hready && !hresp)
                    nextstate = WAIT_STATE;
                else if (hresp)
                    nextstate = ERROR_STATE;
            end

            WRITE_DATA: begin
                if (hready && !hresp) begin
                    hwrite = 1'b1;
                    htrans = 2'b10;
                    hprot  = 4'b0001;
                    haddr  = alu_out;
                    hwdata = rs2_data;

                    case (fn3)
                        3'b000: begin hsize = 3'b000; is_signed = 1'b1; end // SB
                        3'b001: begin hsize = 3'b001; is_signed = 1'b1; end // SH
                        3'b010: begin hsize = 3'b010; is_signed = 1'b1; end // SW
                        default: hsize = 3'b010;
                    endcase

                    nextstate = READ_INSTR;
                end else if (!hready && !hresp)
                    nextstate = WAIT_STATE;
                else if (hresp)
                    nextstate = ERROR_STATE;
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
    always_comb begin
        instruction = 32'b0;
        mem_out     = 32'b0;

        if (muxsel)
            instruction = hr_data;
        else
            mem_out = hr_data;
    end

endmodule*/
/*`timescale 1ns/1ps
module master_glue_logic (
    input  logic        clk,
    input  logic        reset,

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

    // State encoding
    typedef enum logic [2:0] {
        INIT             = 3'b000,
        READ_INSTR       = 3'b001,
        READ_DATA        = 3'b010,
        READ_DATA_HOLD   = 3'b011,
        WRITE_DATA       = 3'b100,
        WRITE_DATA_HOLD  = 3'b101,
        WAIT_STATE       = 3'b110,
        ERROR_STATE      = 3'b111
    } state_t;

    state_t state, nextstate;

    // Latches for holding 2 cycles
    logic [31:0] hwdata_reg;
    logic [31:0] mem_out_reg;

    // Registers for AHB signals
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            state       <= INIT;
            htrans      <= 2'b00;
            hwrite      <= 1'b0;
            haddr       <= 32'b0;
            hwdata_reg  <= 32'b0;
            mem_out_reg <= 32'b0;
            hsize       <= 3'b010;
            hprot       <= 4'b0011;
        end else begin
            state <= nextstate;
        end
    end

    // Next-state logic and outputs
    always_ff @(posedge clk) begin
        // Defaults
        nextstate = state;
        is_signed = 1'b0;

        case (state)
            INIT: begin
                htrans    = 2'b00; // idle
                nextstate = READ_INSTR;
            end

            READ_INSTR: begin
                if (hready && !hresp) begin
                    hwrite = 1'b0;
                    htrans = 2'b10; // NONSEQ
                    hprot  = 4'b0000;
                    haddr  = address;
                    hsize  = 3'b010;

                    if (mem_read)
                        nextstate = READ_DATA;
                    else if (mem_write)
                        nextstate = WRITE_DATA;
                    else
                        nextstate = INIT;
                end else if (!hready && !hresp)
                    nextstate = WAIT_STATE;
                else if (hresp)
                    nextstate = ERROR_STATE;
            end

            READ_DATA: begin
                if (hready && !hresp) begin
                    hwrite = 1'b0;
                    htrans = 2'b10;
                    hprot  = 4'b0001;
                    haddr  = alu_out;

                    // Size / signedness based on funct3
                    case (fn3)
                        3'b000: begin hsize = 3'b000; is_signed = 1'b1; end // LB
                        3'b001: begin hsize = 3'b001; is_signed = 1'b1; end // LH
                        3'b010: begin hsize = 3'b010; is_signed = 1'b1; end // LW
                        3'b100: hsize = 3'b000; // LBU
                        3'b101: hsize = 3'b001; // LHU
                        default: hsize = 3'b010;
                    endcase

                    mem_out_reg <= hr_data;  // capture data
                    nextstate   = READ_DATA_HOLD;
                end else if (!hready && !hresp)
                    nextstate = WAIT_STATE;
                else if (hresp)
                    nextstate = ERROR_STATE;
            end

            READ_DATA_HOLD: begin
                // keep mem_out stable for 1 more cycle
                nextstate = READ_INSTR;
            end

            WRITE_DATA: begin
                if (hready && !hresp) begin
                    hwrite     = 1'b1;
                    htrans     = 2'b10;
                    hprot      = 4'b0001;
                    haddr      = alu_out;
                    hwdata_reg <= rs2_data;

                    case (fn3)
                        3'b000: begin hsize = 3'b000; is_signed = 1'b1; end // SB
                        3'b001: begin hsize = 3'b001; is_signed = 1'b1; end // SH
                        3'b010: begin hsize = 3'b010; is_signed = 1'b1; end // SW
                        default: hsize = 3'b010;
                    endcase

                    nextstate = WRITE_DATA_HOLD;
                end else if (!hready && !hresp)
                    nextstate = WAIT_STATE;
                else if (hresp)
                    nextstate = ERROR_STATE;
            end

            WRITE_DATA_HOLD: begin
                // keep hwdata stable for 1 more cycle
                nextstate = READ_INSTR;
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
    always_comb begin
        instruction = 32'b0;
        mem_out     = 32'b0;
        hwdata      = hwdata_reg;

        if (muxsel)
            instruction = hr_data;
        else
            mem_out = mem_out_reg;  // stays stable 2 cycles
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
    always_ff @(posedge clk) begin
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

                    mem_out <= hr_data;  // capture load result
                    nextstate = INIT;
                end
            end

            WRITE_DATA_WAIT1: nextstate <= WRITE_DATA_WAIT2;
            //WRITE_DATA_WAIT2: nextstate <= WRITE_DATA_WAIT3;
            
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

endmodule
