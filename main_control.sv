
module main_control (
    input  logic        clk,
    input  logic        reset,
    input  logic [6:0]  opcode,
    output logic        branch,
    output logic        mux_inp,
    output logic        memread,
    output logic [1:0]  memtoreg,
    output logic        memwrite,
    output logic        alusrc,
    output logic        reg_write,
    output logic [2:0]  aluop
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // Reset all outputs
            branch    <= 0;
            memread   <= 0;
            memtoreg  <= 2'b11;
            memwrite  <= 0;
            alusrc    <= 0;
            reg_write <= 0;
            aluop     <= 3'b000;
            mux_inp   <= 0;
        end else begin
            // Defaults each cycle
            branch    <= 0;
            memread   <= 0;
            memtoreg  <= 2'b11;
            memwrite  <= 0;
            alusrc    <= 0;
            reg_write <= 0;
            aluop     <= 3'b000;
            mux_inp   <= 0;

            case (opcode)
                7'b0110011: begin // R-type
                    memtoreg  <= 2'b00;
                    alusrc    <= 0;
                    reg_write <= 1;
                    aluop     <= 3'b000;
                end

                7'b0010011: begin // I-type
                    memtoreg  <= 2'b00;
                    alusrc    <= 1;
                    reg_write <= 1;
                    aluop     <= 3'b001;
                end

                7'b0000011: begin // Load
                    memread   <= 1;
                    memtoreg  <= 2'b01;
                    alusrc    <= 1;
                    reg_write <= 1;
                    aluop     <= 3'b010;
                end

                7'b0100011: begin // Store
                    memwrite  <= 1;
                    alusrc    <= 1;
                    aluop     <= 3'b011;
                end

                7'b1100011: begin // Branch
                    branch    <= 1;
                    aluop     <= 3'b100;
                end

                7'b1101111: begin // JAL
                    memtoreg  <= 2'b10;
                    alusrc    <= 1;
                    reg_write <= 1;
                    aluop     <= 3'b101;
                end

                7'b1100111: begin // JALR
                    memtoreg  <= 2'b10;
                    alusrc    <= 1;
                    reg_write <= 1;
                    aluop     <= 3'b001;
                    mux_inp   <= 1;
                end

                7'b0110111: begin // LUI
                    memtoreg  <= 2'b10;
                    alusrc    <= 1;
                    reg_write <= 1;
                    aluop     <= 3'b110;
                end

                7'b0010111: begin // AUIPC
                    memtoreg  <= 2'b10;
                    alusrc    <= 1;
                    reg_write <= 1;
                    aluop     <= 3'b000;
                end

                default: begin
                    // already set to safe defaults above
                end
            endcase
        end
    end

endmodule


