
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


