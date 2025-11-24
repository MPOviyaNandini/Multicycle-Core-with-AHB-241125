/*module slave_wrapper (
    input  logic        clk,
    input  logic        reset,

    input  logic        HSEL1,
    input  logic        HSEL2,

    input  logic [31:0] haddr,
    input  logic [31:0] hwdata,
    input  logic [3:0]  hprot,
    input  logic        hwrite,
    input  logic [2:0]  hsize,
    input  logic        is_signed,

    output logic [31:0] instruction,   // From Instruction_Memory
    output logic [31:0] load_out,      // From Data_Memory
    output logic        hready_inst,
    output logic        hready_data,
    output logic        hresp_inst,
    output logic        hresp_data
);

    // Internal signals
    logic        wr_en_ram;
    logic        rd_en_ram;
    logic        rd_en_rom;
    logic [31:0] wr_data_ram;
    logic [31:0] address_rom;
    logic [31:0] address_ram;
  
    // Delayed signals
    logic        wr_en_ram1;
    logic        rd_en_ram1;
    logic [31:0] wr_data_ram1;
    logic [31:0] address_ram1;
    logic [31:0] load_out1;
    logic        HSEL21;

    //--------------------------------------
    // Glue Logic
    //--------------------------------------
    slave_glue slave_glue_logic (
        .clk(clk),
        .reset(reset),
        .haddr(haddr),
        .hwdata(hwdata),
        .hprot(hprot),
        .hwrite(hwrite),
        .wr_en_ram(wr_en_ram),
        .rd_en_ram(rd_en_ram),
        .rd_en_rom(rd_en_rom),
        .wr_data_ram(wr_data_ram),
        .address_rom(address_rom),
        .address_ram(address_ram),
        .hready_inst(hready_inst),
        .hready_data(hready_data),
        .hresp_inst(hresp_inst),
        .hresp_data(hresp_data)
    );

    //--------------------------------------
    // Delay Elements (width-matched)
    //--------------------------------------
    delay #(1)  x1 (.clk(clk), .reset(reset), .x(wr_en_ram),  .d(wr_en_ram1));
    delay #(1)  x2 (.clk(clk), .reset(reset), .x(rd_en_ram),  .d(rd_en_ram1));
    delay #(32) x3 (.clk(clk), .reset(reset), .x(address_ram), .d(address_ram1));
    delay #(32) x4 (.clk(clk), .reset(reset), .x(wr_data_ram), .d(wr_data_ram1));
    delay #(32) x5 (.clk(clk), .reset(reset), .x(load_out),    .d(load_out1));
    delay #(1)  x6 (.clk(clk), .reset(reset), .x(HSEL2),      .d(HSEL21));

    //--------------------------------------
    // Data Memory Instance
    //--------------------------------------
    Data_Memory data_memory (
        .clk(clk),
        .mem_write(wr_en_ram1),
        .mem_read(rd_en_ram1),
        .address_ram(address_ram1),
        .write_data(wr_data_ram1),
        .read_data(load_out1),
        .HSEL2(HSEL21)
    );

    //--------------------------------------
    // Instruction Memory Instance
    //--------------------------------------
    Instruction_Memory instruction_memory (
        .clk(clk),
        .reset(reset),
        .HSEL1(HSEL1),
        .rd_en_rom(rd_en_rom),
        .address_rom(address_rom),
        .instruction(instruction)
    );

endmodule*/

module slave_wrapper (
  input  logic        clk,
  input  logic        reset,
 // input  logic        boot_wr_en,
 // input  logic [31:0] boot_wr_addr,
//  input  logic [7:0]  boot_wr_data,

  input logic HSEL1,HSEL2,

  input  logic [31:0] haddr,
  input  logic [31:0] hwdata,
  input  logic [3:0]  hprot,
  input  logic        hwrite,
  input  logic [2:0]  hsize,
  input  logic        is_signed,
  //input logic [1:0] htrans,

  output logic [31:0] instruction,   // From Instruction_Memory
  output logic [31:0] load_out,
//  output logic [31:0] store_data,
  output logic        hready_inst,
  output logic        hready_data,
  output logic        hresp_inst,
  output logic        hresp_data
);

  // Internal wires
  logic        wr_en_ram;
  logic        rd_en_ram;
  logic        rd_en_rom;
  logic [31:0] wr_data_ram;
  logic [31:0] address_rom;
  logic [31:0] address_ram;
  logic [31:0] read_data;
  logic [31:0] store_out; 
    logic [31:0]y;
  //--------------------------------------
  // Glue Logic
  //--------------------------------------
  slave_glue slave_glue_logic (
    .clk(clk),
    .reset(reset),
    .haddr(haddr),
    .hwdata(hwdata),
    .hprot(hprot),
    .hwrite(hwrite),
    //.hsize(hsize),
    //.htrans(htrans),
   // .is_signed(is_signed),
    .wr_en_ram(wr_en_ram),
    .rd_en_ram(rd_en_ram),
    .rd_en_rom(rd_en_rom),
    .wr_data_ram(wr_data_ram),
    .address_rom(address_rom),
    .address_ram(address_ram),
    .hready_inst(hready_inst),
    .hready_data(hready_data),
    .hresp_inst(hresp_inst),
    .hresp_data(hresp_data)
  );

  //--------------------------------------
  // Load Unit
  //--------------------------------------
  /*slave_load load_addressing (
    .clk(clk),
    .hsize(hsize),
    .is_signed(is_signed),
    .read_data(read_data),
    .load_out(load_out)
  );*/

  //--------------------------------------
  // Store Unit
  //--------------------------------------
  /*slave_store store_addressing (
    .clk(clk),
    .hsize(hsize),
    .read_data(read_data),
    .wr_data_ram(wr_data_ram),
    .store_out(store_out)
  );*/

  //--------------------------------------
  // Data Memory Instance
  //--------------------------------------
  Data_Memory data_memory (
    .clk(clk),
    .mem_write(wr_en_ram),
    .mem_read(rd_en_ram),
    .address_ram(address_ram),
    //.write_data(store_out),
    .write_data(wr_data_ram),
    //.read_data(read_data),
    .read_data(load_out),
    .HSEL2(HSEL2)
    
  );

  //--------------------------------------
  // Instruction Memory Instance
  //--------------------------------------
  Instruction_Memory instruction_memory (
    .clk(clk),
    .reset(reset),
    .HSEL1(HSEL1), // Always enabled for this wrapper
    .rd_en_rom(rd_en_rom),
   // .boot_wr_en(boot_wr_en),
   // .boot_wr_addr(boot_wr_addr),
  //  .boot_wr_data(boot_wr_data),
    .address_rom(address_rom),
    .instruction(instruction)
  );

  // Assign output load
 // assign load_out = load_temp;
//delay w (.clk(clk),.reset(reset),.x(wr_data_ram),.d(y));
endmodule