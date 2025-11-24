

module decoder (
    input  logic        clk,
    input  logic        reset,
    input  logic        id_en,
    input  logic [31:0] instruction,
    output logic [4:0]  rs1, rs2, rd,
    output logic [6:0]  opcode, imm11_5,
    output logic [2:0]  fn3,
    output logic [11:0] imm,
    output logic [19:0] imm_uj,
    output logic        fn7_5,
    output logic [1:0]  data
);

    // Registers to hold outputs
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            rd      <= 5'b0;
            fn3     <= 3'b0;
            rs1     <= 5'b0;
            rs2     <= 5'b0;
            imm     <= 12'b0;
            imm_uj  <= 20'b0;
            imm11_5 <= 7'b0;
            fn7_5   <= 1'b0;
            data    <= 2'b00;
            opcode  <= 7'b0;
        end else if (id_en && instruction != 32'b0) begin
            opcode <= instruction[6:0];
            case (instruction[6:0])
                7'b0110011: begin // R-Type
                    rd     <= instruction[11:7];
                    fn3    <= instruction[14:12];
                    rs1    <= instruction[19:15];
                    rs2    <= instruction[24:20];
                    fn7_5  <= instruction[30];
                    data   <= 2'b00;
                end

                7'b0010011: begin // I-Type
                    rd      <= instruction[11:7];
                    fn3     <= instruction[14:12];
                    rs1     <= instruction[19:15];
                    imm     <= instruction[31:20];
                    imm11_5 <= instruction[31:25];
                    data    <= 2'b00;
                end

                7'b0000011: begin // Load
                    rd   <= instruction[11:7];
                    fn3  <= instruction[14:12];
                    rs1  <= instruction[19:15];
                    imm  <= instruction[31:20];
                    data <= 2'b10;
                end

                7'b0100011: begin // Store
                    fn3 <= instruction[14:12];
                    rs1 <= instruction[19:15];
                    rs2 <= instruction[24:20];
                    imm <= {instruction[31:25], instruction[11:7]};
                    data <= 2'b01;
                end

                7'b1100011: begin // B-Type
                    fn3 <= instruction[14:12];
                    rs1 <= instruction[19:15];
                    rs2 <= instruction[24:20];
                    imm <= {instruction[31], instruction[7], instruction[30:25], instruction[11:8]};
                    data <= 2'b00;
                end

                7'b1101111: begin // J-Type jal
                    rd     <= instruction[11:7];
                    imm_uj <= {instruction[31], instruction[19:12], instruction[20], instruction[30:21]};
                    data   <= 2'b00;
                end

                7'b0110111: begin // U-Type lui
                    rd     <= instruction[11:7];
                    imm_uj <= instruction[31:12];
                    data   <= 2'b00;
                end

                7'b1100111: begin // JALR
                    rd   <= instruction[11:7];
                    rs1  <= instruction[19:15];
                    fn3  <= instruction[14:12]; // must be 000
                    imm  <= instruction[31:20];
                    data <= 2'b00;
                end

                7'b0010111: begin // AUIPC
                    rd     <= instruction[11:7];
                    imm_uj <= instruction[31:12];
                    data   <= 2'b00;
                end

                default: begin
                    // Do nothing, hold previous values
                end
            endcase
        end
        // else (id_en == 0) → hold last values
        
         end
endmodule


 
