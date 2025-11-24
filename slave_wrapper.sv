module slave_wrapper (
  input  logic        clk,
  input  logic        reset,
  input logic HSEL1,HSEL2,

  input  logic [31:0] haddr,
  input  logic [31:0] hwdata,
  input  logic [3:0]  hprot,
  input  logic        hwrite,
  input  logic [2:0]  hsize,
  input  logic        is_signed,
  output logic [31:0] instruction,  
  output logic [31:0] load_out,
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
  // Data Memory Instance
  //--------------------------------------
  Data_Memory data_memory (
    .clk(clk),
    .mem_write(wr_en_ram),
    .mem_read(rd_en_ram),
    .address_ram(address_ram),
    .write_data(wr_data_ram),
    .read_data(load_out),
    .HSEL2(HSEL2)
    
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
endmodule
