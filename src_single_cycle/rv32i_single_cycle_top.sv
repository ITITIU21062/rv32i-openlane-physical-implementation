module rv32i_single_cycle_top (
    input  logic        i_clk,
    input  logic        i_arst_n,

    output logic [31:0] W_PC_out,
    output logic [31:0] instruction,
    output logic [31:0] W_ALUout,
    output logic [31:0] W_WB_data,
    output logic        W_reg_write,
    output logic        W_mem_write,
    output logic        W_branch_taken
);

    logic [31:0] pc;
    logic [31:0] pc_next;

    logic [31:0] instr_mem [0:255];
    logic [31:0] regfile [0:31];
    logic [31:0] data_mem [0:255];

    logic [6:0] opcode;
    logic [4:0] rd, rs1, rs2;
    logic [2:0] funct3;
    logic [6:0] funct7;

    logic [31:0] rs1_data, rs2_data;
    logic [31:0] imm_i, imm_s, imm_b;
    logic [31:0] alu_b;
    logic [31:0] alu_result;
    logic [31:0] mem_rdata;
    logic [31:0] wb_data;

    logic reg_write;
    logic mem_write;
    logic alu_src;
    logic mem_to_reg;
    logic branch;
    logic branch_taken;

    assign W_PC_out        = pc;
    assign instruction     = instr_mem[pc[9:2]];
    assign W_ALUout        = alu_result;
    assign W_WB_data       = wb_data;
    assign W_reg_write     = reg_write;
    assign W_mem_write     = mem_write;
    assign W_branch_taken  = branch_taken;

    assign opcode = instruction[6:0];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign funct7 = instruction[31:25];

    assign rs1_data = (rs1 == 5'd0) ? 32'd0 : regfile[rs1];
    assign rs2_data = (rs2 == 5'd0) ? 32'd0 : regfile[rs2];

    assign imm_i = {{20{instruction[31]}}, instruction[31:20]};
    assign imm_s = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
    assign imm_b = {{19{instruction[31]}}, instruction[31], instruction[7],
                    instruction[30:25], instruction[11:8], 1'b0};

    always_comb begin
        reg_write = 1'b0;
        mem_write = 1'b0;
        alu_src   = 1'b0;
        mem_to_reg = 1'b0;
        branch = 1'b0;

        case (opcode)
            7'b0110011: begin // R-type
                reg_write = 1'b1;
                alu_src = 1'b0;
            end

            7'b0010011: begin // I-type ALU
                reg_write = 1'b1;
                alu_src = 1'b1;
            end

            7'b0000011: begin // LW
                reg_write = 1'b1;
                mem_to_reg = 1'b1;
                alu_src = 1'b1;
            end

            7'b0100011: begin // SW
                mem_write = 1'b1;
                alu_src = 1'b1;
            end

            7'b1100011: begin // BEQ
                branch = 1'b1;
                alu_src = 1'b0;
            end

            default: begin
                reg_write = 1'b0;
            end
        endcase
    end

    assign alu_b = alu_src ? ((opcode == 7'b0100011) ? imm_s : imm_i) : rs2_data;

    always_comb begin
        alu_result = 32'd0;

        case (opcode)
            7'b0110011: begin
                case ({funct7, funct3})
                    {7'b0000000, 3'b000}: alu_result = rs1_data + rs2_data; // ADD
                    {7'b0100000, 3'b000}: alu_result = rs1_data - rs2_data; // SUB
                    {7'b0000000, 3'b111}: alu_result = rs1_data & rs2_data; // AND
                    {7'b0000000, 3'b110}: alu_result = rs1_data | rs2_data; // OR
                    {7'b0000000, 3'b100}: alu_result = rs1_data ^ rs2_data; // XOR
                    default: alu_result = 32'd0;
                endcase
            end

            7'b0010011,
            7'b0000011,
            7'b0100011: begin
                case (funct3)
                    3'b000: alu_result = rs1_data + alu_b; // ADDI / address
                    3'b111: alu_result = rs1_data & alu_b; // ANDI
                    3'b110: alu_result = rs1_data | alu_b; // ORI
                    default: alu_result = rs1_data + alu_b;
                endcase
            end

            7'b1100011: begin
                alu_result = rs1_data - rs2_data;
            end

            default: alu_result = 32'd0;
        endcase
    end

    assign branch_taken = branch && (funct3 == 3'b000) && (rs1_data == rs2_data); // BEQ only
    assign pc_next = branch_taken ? (pc + imm_b) : (pc + 32'd4);

    assign mem_rdata = data_mem[alu_result[9:2]];
    assign wb_data = mem_to_reg ? mem_rdata : alu_result;

    integer i;

    always_ff @(posedge i_clk or negedge i_arst_n) begin
        if (!i_arst_n) begin
            pc <= 32'd0;

            for (i = 0; i < 32; i = i + 1)
                regfile[i] = 32'd0;

            for (i = 0; i < 256; i = i + 1)
                data_mem[i] = 32'd0;

            // Simple demo program
            instr_mem[0] <= 32'h00500093; // addi x1, x0, 5
            instr_mem[1] <= 32'h00A00113; // addi x2, x0, 10
            instr_mem[2] <= 32'h002081B3; // add  x3, x1, x2
            instr_mem[3] <= 32'h00302023; // sw   x3, 0(x0)
            instr_mem[4] <= 32'h00002203; // lw   x4, 0(x0)
            instr_mem[5] <= 32'h00000013; // nop
            instr_mem[6] <= 32'h00000013; // nop
            instr_mem[7] <= 32'h00000013; // nop

            for (i = 8; i < 256; i = i + 1)
                instr_mem[i] = 32'h00000013;
        end else begin
            pc <= pc_next;

            if (mem_write)
                data_mem[alu_result[9:2]] <= rs2_data;

            if (reg_write && rd != 5'd0)
                regfile[rd] <= wb_data;
        end
    end

endmodule
