/*module slave_glue (
    input  logic [31:0] haddr,
    input  logic [31:0] hwdata,
    //input  logic [1:0]  htrans,
    input  logic [3:0]  hprot,
    input  logic        hwrite,
    //input  logic [2:0]  hsize,

    output logic        wr_en_ram,
    output logic        rd_en_ram,
    output logic        rd_en_rom,
    output logic [31:0] wr_data_ram,
    output logic [31:0] address_rom,
    output logic [31:0] address_ram,
    output logic        hready_inst,
    output logic        hresp_inst,
    output logic        hresp_data,
    output logic        hready_data
);

always_comb begin
    wr_en_ram    = 0;
    rd_en_ram    = 0;
    rd_en_rom    = 0;
    wr_data_ram  = 32'b0;
    address_ram  = 32'b0;
    address_rom  = 32'b0;
    hready_inst     = 1;
    hready_data     = 1;
    hresp_inst      = 0;
    hresp_data      = 0;

    if (haddr[31:24] == 8'hB0) begin  // RAM access
        address_ram = haddr;
        if (hwrite) begin
            wr_en_ram   = 1;
            wr_data_ram = hwdata;
        end else begin
            rd_en_ram = 1;
        end
        hresp_data  = 0;
        hready_data = 1;

    end else if (haddr[31:24] == 8'hA0) begin  // ROM access
        address_rom = haddr;
        if (hwrite) begin
            hresp_inst  = 1;  // write not allowed
            hready_inst = 1;

        end else if (hprot[0]) begin  // opcode fetch not allowed
            hresp_inst  = 1;
            hready_inst = 1;

        end else begin  // valid ROM read
            rd_en_rom = 1;
            hresp_inst   = 0;
            hready_inst  = 1;
        end
    end
end

endmodule*/

/*module slave_glue (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] haddr,
    input  logic [31:0] hwdata,
    input  logic [3:0]  hprot,
    input  logic        hwrite,

    output logic        wr_en_ram,
    output logic        rd_en_ram,
    output logic        rd_en_rom,
    output logic [31:0] wr_data_ram,
    output logic [31:0] address_rom,
    output logic [31:0] address_ram,
    output logic        hready_inst,
    output logic        hresp_inst,
    output logic        hresp_data,
    output logic        hready_data
);

    logic [1:0] count_rom;
    logic [1:0] count_ram;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all outputs to safe defaults
            wr_en_ram    <= 1'b0;
            rd_en_ram    <= 1'b0;
            rd_en_rom    <= 1'b0;
            wr_data_ram  <= 32'b0;
            address_ram  <= 32'b0;
            address_rom  <= 32'b0;
            hready_inst  <= 1'b1;
            hready_data  <= 1'b1;
            hresp_inst   <= 1'b0;
            hresp_data   <= 1'b0;
            count_rom    <= 2'b00;
            count_ram    <= 2'b00;
        end else begin
            // Default deassert each cycle
            wr_en_ram   <= 1'b0;
            rd_en_ram   <= 1'b0;
            rd_en_rom   <= 1'b0;

            // ROM access
            if (haddr[31:24] == 8'hA0) begin
                if (count_rom < 2'b01) begin
                    address_rom <= haddr;
                    rd_en_rom   <= 1'b1;
                    hresp_inst  <= 1'b0;
                    hready_inst <= 1'b0;
                    count_rom   <= count_rom + 1'b1;
                end else begin
                    count_rom <= 2'b00; // reset counter after 3 cycles
                    hresp_inst  <= 1'b0;
                    hready_inst <= 1'b1;
                end
            end 

            // RAM access
            else begin
                    if (hwrite) begin
                        if (count_ram < 2'b10) begin
                        address_ram <= haddr;
                        wr_en_ram   <= 1'b1;
                        wr_data_ram <= hwdata;
                        hresp_data  <= 1'b0;
                        hready_data <= 1'b0;
                        count_ram   <= count_ram + 1'b1;
                        end
                    end else begin
                        if (count_ram < 2'b10) begin
                        rd_en_ram   <= 1'b1;
                        hresp_data  <= 1'b0;
                        hready_data <= 1'b0;
                        count_ram   <= count_ram + 1'b1;
                        end
                    end
                    hresp_data  <= 1'b0;
                    hready_data <= 1'b1;
            end
        end
    end

endmodule*/
/*module slave_glue (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] haddr,
    input  logic [31:0] hwdata,
    input  logic [3:0]  hprot,
    input  logic        hwrite,

    output logic        wr_en_ram,
    output logic        rd_en_ram,
    output logic        rd_en_rom,
    output logic [31:0] wr_data_ram,
    output logic [31:0] address_rom,
    output logic [31:0] address_ram,
    output logic        hready_inst,
    output logic        hresp_inst,
    output logic        hresp_data,
    output logic        hready_data
);

    // Reset and default logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            wr_en_ram    <= 1'b0;
            rd_en_ram    <= 1'b0;
            rd_en_rom    <= 1'b0;
            wr_data_ram  <= 32'b0;
            address_ram  <= 32'b0;
            address_rom  <= 32'b0;
            hready_inst  <= 1'b1;
            hready_data  <= 1'b1;
            hresp_inst   <= 1'b0;
            hresp_data   <= 1'b0;
        end else begin
            // Default all outputs each cycle
            wr_en_ram    <= 1'b0;
            rd_en_ram    <= 1'b0;
            rd_en_rom    <= 1'b0;
            hready_inst  <= 1'b1;
            hready_data  <= 1'b1;
            hresp_inst   <= 1'b0;
            hresp_data   <= 1'b0;

            // ROM read
            if (haddr[31:24] == 8'hA0) begin
                hready_inst  <= 1'b0;
                address_rom <= haddr;
                rd_en_rom   <= 1'b1;
            end
            // RAM access
            else if (haddr[31:24] == 8'hB0) begin
                hready_data  <= 1'b0;
                address_ram <= {8'h00, haddr[23:0]};
                if (hwrite) begin
                    wr_en_ram   <= 1'b1;
                    wr_data_ram <= hwdata;
                end else begin
                    rd_en_ram   <= 1'b1;
                end
            end
        end
    end

endmodule*/



/*module slave_glue (
    input  logic        clk,
    input  logic        reset,

    // AHB-lite subset from master
    input  logic [31:0] haddr,
    input  logic [31:0] hwdata,
    input  logic [3:0]  hprot,
    input  logic        hwrite,

    // To memories
    output logic        wr_en_ram,
    output logic        rd_en_ram,
    output logic        rd_en_rom,
    output logic [31:0] wr_data_ram,
    output logic [31:0] address_rom,
    output logic [31:0] address_ram,

    // Simple response/ready
    output logic        hready_inst,
    output logic        hresp_inst,
    output logic        hresp_data,
    output logic        hready_data
);

    // -------------------------
    // Latches for current access
    // -------------------------
    logic        busy;                // 1 while we are holding signals for 3 cycles
    logic [1:0]  hold_cnt;            // counts 2→1→0 => 3 cycles total
    logic        lat_is_rom;          // 1 for ROM, 0 for RAM
    logic        lat_is_write;        // 1 write, 0 read (for RAM only)
    logic [31:0] lat_addr;
    logic [31:0] lat_wdata;

    // For simple "new request" detection without HTRANS:
    logic [31:0] prev_addr;
    logic        prev_hwrite;

    // Region decode
    wire is_rom_now = (haddr[31:24] == 8'hA0);
    // wire is_ram_now = !is_rom_now; // everything else treated as RAM

    // New request heuristic:
    // Start a fresh 3-cycle window when address or direction changes AND we're not busy.
    wire new_req = (!busy) && ((haddr != prev_addr) || (hwrite != prev_hwrite));

    // --------------------------------
    // Sequential process (fully-reg'd)
    // --------------------------------
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            busy         <= 1'b0;
            hold_cnt     <= 2'd0;

            lat_is_rom   <= 1'b0;
            lat_is_write <= 1'b0;
            lat_addr     <= 32'd0;
            lat_wdata    <= 32'd0;

            prev_addr    <= 32'd0;
            prev_hwrite  <= 1'b0;

            // Default-safe outputs
            wr_en_ram    <= 1'b0;
            rd_en_ram    <= 1'b0;
            rd_en_rom    <= 1'b0;
            wr_data_ram  <= 32'd0;
            address_ram  <= 32'd0;
            address_rom  <= 32'd0;

            hready_inst  <= 1'b1;
            hready_data  <= 1'b1;
            hresp_inst   <= 1'b0;
            hresp_data   <= 1'b0;

        end else begin
            // Track last seen raw inputs for simple edge/new detection
            prev_addr   <= haddr;
            prev_hwrite <= hwrite;

            // Defaults every cycle; then override while busy
            wr_en_ram   <= 1'b0;
            rd_en_ram   <= 1'b0;
            rd_en_rom   <= 1'b0;

            hresp_inst  <= 1'b0; // no error signaling in this simple glue
            hresp_data  <= 1'b0;

            // Start of a new request?
            if (new_req) begin
                busy         <= 1'b1;
                hold_cnt     <= 2'd2;          // we will output for counts = 2,1,0 => 3 cycles
                lat_is_rom   <= is_rom_now;
                lat_is_write <= hwrite;
                lat_addr     <= haddr;
                lat_wdata    <= hwdata;
            end

            // While busy, drive latched values and count down
            if (busy) begin
                if (lat_is_rom) begin
                    // ROM read: hold address and rd_en for 3 cycles
                    address_rom <= lat_addr;
                    rd_en_rom   <= 1'b1;
                    // Instruction ready low during hold, high when done
                    hready_inst <= 1'b0;
                    hready_data <= 1'b1; // data path unaffected
                end else begin
                    // RAM access: write or read, hold address, data (if write), and enables
                    address_ram <= lat_addr;
                    if (lat_is_write) begin
                        wr_en_ram   <= 1'b1;
                        wr_data_ram <= lat_wdata;
                    end else begin
                        rd_en_ram   <= 1'b1;
                    end
                    // Data ready low during hold, high when done
                    hready_data <= 1'b0;
                    hready_inst <= 1'b1; // instr path unaffected
                end

                // 3-cycle hold window
                if (hold_cnt != 2'd0) begin
                    hold_cnt <= hold_cnt - 2'd1;
                end else begin
                    // Finished 3 cycles
                    busy      <= 1'b0;
                    // Deassert enables next cycle via defaults; raise ready now
                    hready_inst <= 1'b1;
                    hready_data <= 1'b1;
                end

            end else begin
                // Not busy: keep readys high; outputs idle
                hready_inst <= 1'b1;
                hready_data <= 1'b1;
            end
        end
    end

endmodule*/
module slave_glue (
    input  logic        clk,
    input  logic        reset,
    input  logic [31:0] haddr,
    input  logic [31:0] hwdata,
    input  logic [3:0]  hprot,
    input  logic        hwrite,

    output logic        wr_en_ram,
    output logic        rd_en_ram,
    output logic        rd_en_rom,
    output logic [31:0] wr_data_ram,
    output logic [31:0] address_rom,
    output logic [31:0] address_ram,
    output logic        hready_inst,
    output logic        hresp_inst,
    output logic        hresp_data,
    output logic        hready_data
);

    // 2-bit counters count down: 2 -> 1 -> 0 (ready when 0)
    logic [1:0] inst_wait_cnt;
    logic [1:0] data_wait_cnt;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            wr_en_ram      <= 1'b0;
            rd_en_ram      <= 1'b0;
            rd_en_rom      <= 1'b0;
            wr_data_ram    <= 32'b0;
            address_ram    <= 32'b0;
            address_rom    <= 32'b0;
            hready_inst    <= 1'b1;
            hready_data    <= 1'b1;
            hresp_inst     <= 1'b0;
            hresp_data     <= 1'b0;

            inst_wait_cnt  <= 2'd0;
            data_wait_cnt  <= 2'd0;
        end else begin
            /*// --------------------
            // Default every cycle
            // --------------------
            wr_en_ram    <= 1'b0;
            rd_en_ram    <= 1'b0;
            rd_en_rom    <= 1'b0;
            hresp_inst   <= 1'b0;
            hresp_data   <= 1'b0;

            // Explicitly default ready signals each cycle (important!)
            hready_inst  <= 1'b1;
            hready_data  <= 1'b1;*/

            // ---------------------------
            // INSTRUCTION (ROM) ACCESS 
            // ---------------------------
            // Start of access: detect ROM region and start 2-cycle wait
            if (haddr[31:24] == 8'hA0 && inst_wait_cnt == 0) begin
                rd_en_rom      <= 1'b1;
                address_rom    <= haddr;
                hready_inst    <= 1'b0;     // go not-ready immediately
                inst_wait_cnt  <= 2'd2;     // will take two cycles to become ready
            end
            // If a wait is in progress, count down and keep ready low until finished
            else if (inst_wait_cnt > 0) begin
                inst_wait_cnt <= inst_wait_cnt - 1;

                // while waiting keep hready_inst low
                if (inst_wait_cnt > 1) begin
                    hready_inst <= 1'b0; // still 2 or more (should be 2)
                end
                 else begin
                    // inst_wait_cnt == 1 -> after decrement it becomes 0 -> now ready
                    hready_inst <= 1'b1;
                end
            end

            // ---------------------------
            // DATA (RAM) ACCESS
            // ---------------------------
            if (haddr[31:24] == 8'hB0 && data_wait_cnt == 0) begin
                address_ram    <= {8'h00, haddr[23:0]};
                hready_data    <= 1'b0;     // not ready immediately
                data_wait_cnt  <= 2'd2;     // wait 2 cycles

                if (hwrite) begin
                    wr_en_ram   <= 1'b1;
                    wr_data_ram <= hwdata;
                end else begin
                    rd_en_ram   <= 1'b1;
                end
            end
            else if (data_wait_cnt > 0) begin
                data_wait_cnt <= data_wait_cnt - 1;

                if (data_wait_cnt > 1) begin
                    hready_data <= 1'b0; // still waiting
                end
                else begin
                    // data_wait_cnt == 1 -> after decrement becomes 0 -> now ready
                    hready_data <= 1'b1;
                end
            end

        end
    end

endmodule


