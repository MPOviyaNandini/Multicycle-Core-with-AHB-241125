module AHB_top(

    input  logic        mem_write,
    input  logic        mem_read,
    input  logic        clk,
    input  logic        reset,
    input  logic [2:0]  fn3,
    input  logic [31:0] rs2_data,
    input  logic [31:0] alu_out,
    input  logic [31:0] address,
    output logic [31:0] data_out
);

    // Internal wires
    logic        hready_1, hready_2, hresp_1, hresp_2;
    logic        hready, hresp;
    logic [1:0]  htrans;
    logic [31:0] haddr, hwdata;
    logic [3:0]  hprot;
    logic        hwrite;
    logic [2:0]  hsize;
    logic        is_signed;
    logic        wr_en_ram, rd_en_ram, rd_en_rom;
    logic [31:0] wr_data_ram;
    logic [31:0] address_rom, address_ram;
    logic [31:0] rd_data;
    logic [31:0] instruction;
    logic        sel_0, sel_1, muxsel;
    logic [31:0] data_out_mux;

    // Master
    master_glue u_master (
        .hready(hready),
        .hresp(hresp),
        .fn3(fn3),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .rs2_data(rs2_data),
        .alu_out(alu_out),
        .address(address),
        .htrans(htrans),
        .hprot(hprot),
        .hwrite(hwrite),
        .hsize(hsize),
        .haddr(haddr),
        .hwdata(hwdata),
        .data_out_mux(data_out_mux),
    //    .is_signed(is_signed),
        .data_out(data_out)
    );

    // Decoder
    ahb_dec u_dec (
        .address(address),
        .sel_0(sel_0),
        .sel_1(sel_1),
        .muxsel(muxsel)
    );

    // Slave Glue
    slave_glue u_slave_glue (
        .haddr(haddr),
        .hwdata(hwdata),
        .htrans(htrans),
        .hprot(hprot),
        .hwrite(hwrite),
        .hsize(hsize),
      //  .is_signed(is_signed),
        .wr_en_ram(wr_en_ram),
        .rd_en_ram(rd_en_ram),
        .rd_en_rom(rd_en_rom),
        .wr_data_ram(wr_data_ram),
        .address_rom(address_rom),
        .address_ram(address_ram),
        .hready_1(hready_1),
        .hready_2(hready_2),
        .hresp_1(hresp_1),
        .hresp_2(hresp_2)
    );

    // AHB Mux
    ahb_mux u_mux (
        .hready_1(hready_1),
        .hready_2(hready_2),
        .hresp_1(hresp_1),
        .hresp_2(hresp_2),
        .rd_data1(instruction),
        .rd_data2(rd_data),
        .muxsel(muxsel),
        .data_out_mux(data_out_mux),
        .hready(hready),
        .hresp(hresp)
    );

endmodule
