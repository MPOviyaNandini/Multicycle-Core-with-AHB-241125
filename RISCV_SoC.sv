/*module RISCV_SoC (
  input logic clk,
  input logic reset
);

  // === Internal Signals ===
  // --- Core to Interconnect ---
  logic [31:0] haddr;
  logic [1:0]  htrans;
  logic        hwrite;
  logic [2:0]  hsize;
  logic [3:0]  hprot;
  logic [31:0] hwdata;
  logic        is_signed;

  logic [31:0] hr_data;
  logic        hready, hresp;
  logic        HSEL1, HSEL2;
  logic muxsel;

  // --- Interconnect to Slave ---
  logic [31:0] Haddr;
  //logic [1:0]  Htrans;
  logic        Hwrite;
  logic [2:0]  Hsize;
  logic [3:0]  Hprot;
  logic [31:0] Hwdata;
  logic        Is_signed;

  // Memory interface
  logic [31:0] instruction;
  logic [31:0] hrdata_inst, hrdata_data;
  logic        hready_inst, hready_data;
  logic        hresp_inst, hresp_data;
  logic [31:0] read_data;
  logic sync_reset;

  // === Core Instance ===
  core_wrapper core_master (
    .clk(clk),
    .reset(sync_reset),
    .haddr(haddr),
    .htrans(htrans),
    .hwrite(hwrite),
    .hsize(hsize),
    .hprot(hprot),
    .hwdata(hwdata),
    .is_signed(is_signed),
    .hr_data(hr_data),
    .hready(hready),
    .hresp(hresp),
    .muxsel(muxsel)
  );

  // === AHB Interconnect ===
  ahb_interconnect ahb_ic (
    .haddr(haddr),
    .hrdata_inst(hrdata_inst),
    .hrdata_data(hrdata_data),
    .hready_inst(hready_inst),
    .hready_data(hready_data),
    .hresp_inst(hresp_inst),
    .hresp_data(hresp_data),
    .htrans(htrans),
    .hwrite(hwrite),
    .hsize(hsize),
    .hprot(hprot),
    .hwdata(hwdata),
    .is_signed(is_signed),
    .hr_data(hr_data),
    .hready(hready),
    .hresp(hresp),
    .HSEL1(HSEL1),
    .HSEL2(HSEL2),
    //.Htrans(Htrans),
    .Hwrite(Hwrite),
    .Hsize(Hsize),
    .Hprot(Hprot),
    .Hwdata(Hwdata),
    .Is_signed(Is_signed),
    .Haddr(Haddr),
    .muxsel(muxsel)
  );

  // === Slave Wrapper ===
  slave_wrapper slave_mem (
    .clk(clk),
    .reset(sync_reset),
    .HSEL1(HSEL1),
    .HSEL2(HSEL2),
    .haddr(Haddr),
    .hwdata(Hwdata),
    .hprot(Hprot),
    .hwrite(Hwrite),
    .hsize(Hsize),
    .is_signed(Is_signed),
    .instruction(instruction),
    .load_out(hrdata_data),
    .hready_inst(hready_inst),
    .hready_data(hready_data),
    .hresp_inst(hresp_inst),
    .hresp_data(hresp_data)
  );

  // === Reset Sync ===
  rst_sync rst (
    .clk(clk),
    .reset(reset),
    .sync_reset(sync_reset)
  );

  // === Instruction assignment ===
  assign hrdata_inst = instruction;
  assign hrdata_data=read_data;
endmodule*/

module RISCV_SoC (
  input logic clk,
  input logic reset,
  output logic hready
);

  // === Internal Signals ===
  // --- Core to Interconnect ---
  logic [31:0] haddr;
  logic [1:0]  htrans;
  logic        hwrite;
  logic [2:0]  hsize;
  logic [3:0]  hprot;
  logic [31:0] hwdata;
  logic        is_signed;

  logic [31:0] hr_data;
  logic        hready, hresp;
  logic        HSEL1, HSEL2;
  logic muxsel;

  // --- Interconnect to Slave ---
  logic [31:0] Haddr;
  //logic [1:0]  Htrans;
  logic        Hwrite;
  logic [2:0]  Hsize;
  logic [3:0]  Hprot;
  logic [31:0] Hwdata;
  logic        Is_signed;

  // Memory interface
  logic [31:0] instruction;
  logic [31:0] hrdata_inst, hrdata_data;
  logic        hready_inst, hready_data;
  logic        hresp_inst, hresp_data;
  logic [31:0] read_data;
  logic sync_reset;

  // === Core Instance ===
  core_wrapper core_master (
    .clk(clk),
    .reset(sync_reset),
    .haddr(haddr),
    .htrans(htrans),
    .hwrite(hwrite),
    .hsize(hsize),
    .hprot(hprot),
    .hwdata(hwdata),
    .is_signed(is_signed),
    .hr_data(hr_data),
    .hready(hready),
    .hresp(hresp),
    .muxsel(muxsel)
  );

  // === AHB Interconnect ===
  ahb_interconnect ahb_ic (
    .haddr(haddr),
    .hrdata_inst(hrdata_inst),
    .hrdata_data(hrdata_data),
    .hready_inst(hready_inst),
    .hready_data(hready_data),
    .hresp_inst(hresp_inst),
    .hresp_data(hresp_data),
    .htrans(htrans),
    .hwrite(hwrite),
    .hsize(hsize),
    .hprot(hprot),
    .hwdata(hwdata),
    .is_signed(is_signed),
    .hr_data(hr_data),
    .hready(hready),
    .hresp(hresp),
    .HSEL1(HSEL1),
    .HSEL2(HSEL2),
    .Hwrite(Hwrite),
    .Hsize(Hsize),
    .Hprot(Hprot),
    .Hwdata(Hwdata),
    .Is_signed(Is_signed),
    .Haddr(Haddr),
    .muxsel(muxsel)
  );

  // === Slave Wrapper ===
  slave_wrapper slave_mem (
    .clk(clk),
    .reset(sync_reset),
    .HSEL1(HSEL1),
    .HSEL2(HSEL2),
    .haddr(Haddr),
    .hwdata(Hwdata),
    .hprot(Hprot),
    .hwrite(Hwrite),
    .hsize(Hsize),
    .is_signed(Is_signed),
    .instruction(instruction),
    .load_out(hrdata_data),
    .hready_inst(hready_inst),
    .hready_data(hready_data),
    .hresp_inst(hresp_inst),
    .hresp_data(hresp_data)
  );

  // === Reset Sync ===
  rst_sync rst (
    .clk(clk),
    .reset(reset),
    .sync_reset(sync_reset)
  );

  // === Instruction assignment ===
  assign hrdata_inst = instruction;
  assign hrdata_data=read_data;
endmodule
