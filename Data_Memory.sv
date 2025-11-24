
`timescale 1ns/1ps
module Data_Memory (
    input  logic        clk,
    input  logic        mem_write,
    input  logic        mem_read,
    input  logic [31:0] address_ram,
    input  logic        HSEL2,
    input  logic [31:0] write_data,   
    input  logic        reset,
    output logic [31:0] read_data     
);

    // 1 KB memory = 1024 bytes
    logic [7:0] mem_ram [0:1023];  
    
    initial begin
    // Word 0 @ address 0x00 -> 0x11223344
    mem_ram[0]  = 8'h44;  
    mem_ram[1]  = 8'h33;  
    mem_ram[2]  = 8'h22;  
    mem_ram[3]  = 8'h11;  

    // Word 1 @ address 0x04 -> 0x55667788
    mem_ram[4]  = 8'h88;  
    mem_ram[5]  = 8'h77;  
    mem_ram[6]  = 8'h66;  
    mem_ram[7]  = 8'h55;  

    // Word 2 @ address 0x08 -> 0xDEADBEEF
    mem_ram[8]  = 8'hef;  
    mem_ram[9]  = 8'hbe;  
    mem_ram[10] = 8'had;  
    mem_ram[11] = 8'hde;  

    // Word 3 @ address 0x0C -> 0xCAFEBABE
    mem_ram[12] = 8'he;  
    mem_ram[13] = 8'hba;  
    mem_ram[14] = 8'hfe;  
    mem_ram[15] = 8'hca;  

    // Word 4 @ address 0x10 -> 0x12345678
    mem_ram[16] = 8'h78;  
    mem_ram[17] = 8'h56;  
    mem_ram[18] = 8'h34;  
    mem_ram[19] = 8'h12;  

    // Word 5 @ address 0x14 -> 0xFACE_C0DE
    mem_ram[20] = 8'hde;  
    mem_ram[21] = 8'hc0;  
    mem_ram[22] = 8'hce;  
    mem_ram[23] = 8'hfa;  

    // Word 6 @ address 0x18 -> 0xAAAA_5555
    mem_ram[24] = 8'h55;  
    mem_ram[25] = 8'h55;  
    mem_ram[26] = 8'haa;  
    mem_ram[27] = 8'haa;  

    // Word 7 @ address 0x1C -> 0x8765_4321
    mem_ram[28] = 8'h21;  
    mem_ram[29] = 8'h43;  
    mem_ram[30] = 8'h65;  
    mem_ram[31] = 8'h87;  
end

// Zero the rest of memory
initial begin
    for (int i = 20; i < 1024; i++) begin
        mem_ram[i] = 8'h00;
    end
end

    // ----------- SYNCHRONOUS WRITE + ASYNCHRONOUS RESET ------------
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
        
            for (int i = 4; i < 1024; i++) begin
                mem_ram[i] <= 8'h00;
            end
        end else if (mem_write && HSEL2) begin
            // Store word in little-endian format
            mem_ram[address_ram]     <= write_data[7:0];    // byte 0
            mem_ram[address_ram + 1] <= write_data[15:8];   // byte 1
            mem_ram[address_ram + 2] <= write_data[23:16];  // byte 2
            mem_ram[address_ram + 3] <= write_data[31:24];  // byte 3
        end
    end

    // ----------- SYNCHRONOUS READ (latched) ------------
    always_ff @(posedge clk) begin
        if (mem_read && HSEL2) begin
            read_data <= { mem_ram[address_ram + 3],
                           mem_ram[address_ram + 2],
                           mem_ram[address_ram + 1],
                           mem_ram[address_ram] };
        end else begin
            read_data <= 32'd0;
        end
    end

endmodule


