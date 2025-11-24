module ahb_interconnect (
  input  logic [31:0] haddr,           // From AHB master
  input  logic [31:0] hrdata_inst,     // From ROM
  input  logic [31:0] hrdata_data,     // From RAM
  input  logic        hready_inst,     // From ROM
  input  logic        hready_data,     // From RAM
  input  logic        hresp_inst,      // From ROM
  input  logic        hresp_data,      // From RAM

  input  logic [1:0]  htrans,
  input  logic        hwrite,
  input  logic [2:0]  hsize,
  input  logic [3:0]  hprot,
  input  logic [31:0] hwdata,
  input  logic        is_signed,

  output logic [31:0] hr_data,         // Final read data to AHB master
  output logic        hready,          // Final hready to AHB master
  output logic        hresp,           // Final hresp to AHB master
  output logic        HSEL1,           // ROM select
  output logic        HSEL2,           // RAM select
  output logic muxsel,
   
  //output logic [1:0]  Htrans,
  output logic        Hwrite,
  output logic [2:0]  Hsize,
  output logic [3:0]  Hprot,
  output logic [31:0] Hwdata,
  output logic        Is_signed,
  output logic [31:0] Haddr
);

  // Internal signal
  //logic muxsel;

  // === Address Decoder Instantiation ===
  ahb_dec dec_inst (
    .haddr (haddr),     // Updated to match ahb_dec port
    .HSEL1   (HSEL1),
    .HSEL2   (HSEL2),
    .muxsel  (muxsel)
  );

  // === AHB Multiplexer Instantiation ===
  ahb_mux mux_inst (
    .hready_inst (hready_inst),
    .hready_data (hready_data),
    .hresp_inst  (hresp_inst),
    .hresp_data  (hresp_data),
    .hrdata_inst (hrdata_inst),
    .hrdata_data (hrdata_data),
    .muxsel      (muxsel),
    .hr_data     (hr_data),
    .hready      (hready),
    .hresp       (hresp)
  );
   //hold hd (.clk(clk),.reset(reset),.muxsel(muxsel),.muxsel_held(muxsel_held));
  // === Forward control signals ===
  //assign Htrans     = htrans;
  assign Hwrite     = hwrite;
  assign Hsize      = hsize;
  assign Hprot      = hprot;
  assign Hwdata     = hwdata;
  assign Is_signed  = is_signed;
  assign Haddr      = haddr;

endmodule
