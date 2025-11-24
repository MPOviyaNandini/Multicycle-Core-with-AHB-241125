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

/*module ahb_dec (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] haddr,
    output logic        HSEL1,
    output logic        HSEL2,
    output logic        muxsel
);

    // raw decode result
    logic dec_HSEL1, dec_HSEL2, dec_muxsel;

    // hold registers
    logic hold_active;
    logic [0:0] hold_cnt;   // 1-bit counter → counts 0,1 = 2 cycles

    // --- Combinational Decode ---
    always_comb begin
        dec_HSEL1  = 1'b0;
        dec_HSEL2  = 1'b0;
        dec_muxsel = 1'b0;

        if (haddr[31:24] == 8'hA0) begin
            dec_HSEL1  = 1'b1;
            dec_muxsel = 1'b1;  // ROM side
        end else begin
            dec_HSEL2  = 1'b1;
            dec_muxsel = 1'b0;  // RAM side
        end
    end

    // --- Hold FSM ---
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            hold_active <= 1'b0;
            hold_cnt    <= 1'b0;
            muxsel      <= 1'b0;
            HSEL1       <= 1'b0;
            HSEL2       <= 1'b0;
        end else begin
            if (hold_active) begin
                if (hold_cnt == 1'b1) begin
                    hold_active <= 1'b0;   // finished 2 cycles
                    hold_cnt    <= 1'b0;
                end else begin
                    hold_cnt <= hold_cnt + 1'b1;
                end
            end else begin
                // Start hold whenever decoded muxsel changes
                if (muxsel != dec_muxsel) begin
                    muxsel      <= dec_muxsel;
                    HSEL1       <= dec_HSEL1;
                    HSEL2       <= dec_HSEL2;
                    hold_active <= 1'b1;
                    hold_cnt    <= 1'b0;
                end else begin
                    // Normal decode if stable
                    muxsel <= dec_muxsel;
                    HSEL1  <= dec_HSEL1;
                    HSEL2  <= dec_HSEL2;
                end
            end
        end
    end

endmodule*/

/*module ahb_dec (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] haddr,
    output logic        HSEL1,
    output logic        HSEL2,
    output logic        muxsel
);

    // raw decode result
    logic dec_HSEL1, dec_HSEL2, dec_muxsel;

    // hold registers
    logic hold_active;
    logic [2:0] hold_cnt;   // 3-bit counter → can count up to 7 (enough for 6 cycles)

    // --- Combinational Decode ---
    always_comb begin
        dec_HSEL1  = 1'b0;
        dec_HSEL2  = 1'b0;
        dec_muxsel = 1'b0;

        if (haddr[31:24] == 8'hA0) begin
            dec_HSEL1  = 1'b1;
            dec_muxsel = 1'b1;  // ROM side
        end else begin
            dec_HSEL2  = 1'b1;
            dec_muxsel = 1'b0;  // RAM side
        end
    end

    // --- Hold FSM (6 cycles) ---
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            hold_active <= 1'b0;
            hold_cnt    <= 3'd0;
            muxsel      <= 1'b0;
            HSEL1       <= 1'b0;
            HSEL2       <= 1'b0;
        end else begin
            if (hold_active) begin
                if (hold_cnt == 3'd5) begin   // held for 6 cycles (0..5)
                    hold_active <= 1'b0;      // release hold
                    hold_cnt    <= 3'd0;
                end else begin
                    hold_cnt <= hold_cnt + 1'b1;
                end
            end else begin
                // Start hold whenever decoded muxsel changes
                if (muxsel != dec_muxsel) begin
                    muxsel      <= dec_muxsel;
                    HSEL1       <= dec_HSEL1;
                    HSEL2       <= dec_HSEL2;
                    hold_active <= 1'b1;
                    hold_cnt    <= 3'd0;
                end else begin
                    // Normal decode if stable
                    muxsel <= dec_muxsel;
                    HSEL1  <= dec_HSEL1;
                    HSEL2  <= dec_HSEL2;
                end
            end
        end
    end

endmodule*/
/*module ahb_dec (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] haddr,
    output logic        HSEL1,
    output logic        HSEL2,
    output logic        muxsel
);

    // Raw combinational decode
    logic HSEL1_raw, HSEL2_raw, muxsel_raw;

    always_comb begin
        HSEL1_raw  = 1'b0;
        HSEL2_raw  = 1'b0;
        muxsel_raw = 1'b0;

        if (haddr[31:24] == 8'hA0) begin
            HSEL1_raw  = 1'b1;
            muxsel_raw = 1'b1;
        end else begin
            HSEL2_raw  = 1'b1;
            muxsel_raw = 1'b0;
        end
    end

    // Registers and 1-cycle hold counter
    logic        HSEL1_reg, HSEL2_reg, muxsel_reg;
    logic        muxsel_pending;
    logic [0:0]  hold_cnt;  // just 1-bit: "0=free, 1=hold active"

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            HSEL1_reg     <= 1'b0;
            HSEL2_reg     <= 1'b0;
            muxsel_reg    <= 1'b0;
            muxsel_pending<= 1'b0;
            hold_cnt      <= 1'b0;
        end else begin
            if (hold_cnt != 0) begin
                // still holding old value for 1 cycle
                hold_cnt       <= hold_cnt - 1;
                muxsel_reg     <= muxsel_reg;   // keep previous
                HSEL1_reg      <= HSEL1_reg;
                HSEL2_reg      <= HSEL2_reg;

                // apply pending muxsel when counter expires
                if (hold_cnt == 1) begin
                    muxsel_reg <= muxsel_pending;
                    HSEL1_reg  <= HSEL1_raw;
                    HSEL2_reg  <= HSEL2_raw;
                end
            end else begin
                // no hold active
                if (muxsel_raw != muxsel_reg) begin
                    // detect change: start 1-cycle hold
                    muxsel_pending <= muxsel_raw;
                    hold_cnt       <= 1;
                    // keep muxsel_reg as-is this cycle
                end else begin
                    // no change: just follow raw decode
                    muxsel_reg <= muxsel_raw;
                    HSEL1_reg  <= HSEL1_raw;
                    HSEL2_reg  <= HSEL2_raw;
                end
            end
        end
    end

    // Outputs
    assign HSEL1  = HSEL1_reg;
    assign HSEL2  = HSEL2_reg;
    assign muxsel = muxsel_reg;

endmodule*/

