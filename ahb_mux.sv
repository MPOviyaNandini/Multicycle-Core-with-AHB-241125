

module ahb_mux (
    input  logic        hready_inst, hready_data, hresp_inst, hresp_data,
    input  logic [31:0] hrdata_inst, hrdata_data,
    input  logic        muxsel,  // 0: RAM, 1: ROM
    output logic [31:0] hr_data,
    output logic        hready,
    output logic        hresp
);


    always_comb begin
  
        if (muxsel) begin
            // ROM selected
            hr_data = hrdata_inst;
            hready  = hready_inst;
            hresp   = hresp_inst;
        end else begin
            // RAM selected
            hr_data = hrdata_data;
            hready  = hready_data;
            hresp   = hresp_data;
        end
    end

endmodule
