module rv32i_3stage_top (
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

    // ============================================================
    // Stage 1: IF - Program Counter + Instruction Fetch
    // ============================================================

    logic [31:0] pc;
    logic [31:0] pc_next;

    logic [31:0] instr_mem [0:255];

    logic [31:0] if_instr;
    assign if_instr = instr_mem[pc[9:2]];

    // ============================================================
    // IF/ID Pipeline Register
    // ============================================================

    logic [31:0] if_id_pc;
    logic [31:0] if_id_instr;

    // ============================================================
    // Stage 2: ID - Decode + Register Read + Control
    // ============================================================

    logic [6:0] id_opcode;
    logic [4:0] id_rd, id_rs1, id_rs2;
    logic [2:0] id_funct3;
    logic [6:0] id_funct7;

    logic [31:0] regfile [0:31];

    logic [31:0] id_rs1_data;
    logic [31:0] id_rs2_data;

    logic [31:0] id_imm_i;
    logic [31:0] id_imm_s;
    logic [31:0] id_imm_b;

    logic id_reg_write;
    logic id_mem_write;
    logic id_alu_src;
    logic id_mem_to_reg;
    logic id_branch;

    assign id_opcode = if_id_instr[6:0];
    assign id_rd     = if_id_instr[11:7];
    assign id_funct3 = if_id_instr[14:12];
    assign id_rs1    = if_id_instr[19:15];
    assign id_rs2    = if_id_instr[24:20];
    assign id_funct7 = if_id_instr[31:25];

    assign id_rs1_data = (id_rs1 == 5'd0) ? 32'd0 : regfile[id_rs1];
    assign id_rs2_data = (id_rs2 == 5'd0) ? 32'd0 : regfile[id_rs2];

    assign id_imm_i = {{20{if_id_instr[31]}}, if_id_instr[31:20]};
    assign id_imm_s = {{20{if_id_instr[31]}}, if_id_instr[31:25], if_id_instr[11:7]};
    assign id_imm_b = {{19{if_id_instr[31]}}, if_id_instr[31], if_id_instr[7],
                       if_id_instr[30:25], if_id_instr[11:8], 1'b0};

    always_comb begin
        id_reg_write  = 1'b0;
        id_mem_write  = 1'b0;
        id_alu_src    = 1'b0;
        id_mem_to_reg = 1'b0;
        id_branch     = 1'b0;

        case (id_opcode)
            7'b0110011: begin // R-type
                id_reg_write = 1'b1;
                id_alu_src   = 1'b0;
            end

            7'b0010011: begin // I-type ALU
                id_reg_write = 1'b1;
                id_alu_src   = 1'b1;
            end

            7'b0000011: begin // LW
                id_reg_write  = 1'b1;
                id_alu_src    = 1'b1;
                id_mem_to_reg = 1'b1;
            end

            7'b0100011: begin // SW
                id_mem_write = 1'b1;
                id_alu_src   = 1'b1;
            end

            7'b1100011: begin // BEQ
                id_branch  = 1'b1;
                id_alu_src = 1'b0;
            end

            default: begin
                id_reg_write  = 1'b0;
                id_mem_write  = 1'b0;
                id_alu_src    = 1'b0;
                id_mem_to_reg = 1'b0;
                id_branch     = 1'b0;
            end
        endcase
    end

    // ============================================================
    // ID/EX Pipeline Register
    // ============================================================

    logic [31:0] ex_pc;
    logic [31:0] ex_instr;

    logic [6:0]  ex_opcode;
    logic [4:0]  ex_rd;
    logic [2:0]  ex_funct3;
    logic [6:0]  ex_funct7;

    logic [31:0] ex_rs1_data;
    logic [31:0] ex_rs2_data;
    logic [31:0] ex_imm_i;
    logic [31:0] ex_imm_s;
    logic [31:0] ex_imm_b;

    logic ex_reg_write;
    logic ex_mem_write;
    logic ex_alu_src;
    logic ex_mem_to_reg;
    logic ex_branch;

    // ============================================================
    // Stage 3: EX/MEM/WB - ALU + Memory + Write Back
    // ============================================================

    logic [31:0] data_mem [0:255];

    logic [31:0] ex_alu_b;
    logic [31:0] ex_alu_result;
    logic [31:0] ex_mem_rdata;
    logic [31:0] ex_wb_data;
    logic        ex_branch_taken;

    assign ex_alu_b = ex_alu_src ? ((ex_opcode == 7'b0100011) ? ex_imm_s : ex_imm_i) : ex_rs2_data;

    always_comb begin
        ex_alu_result = 32'd0;

        case (ex_opcode)
            7'b0110011: begin
                case ({ex_funct7, ex_funct3})
                    {7'b0000000, 3'b000}: ex_alu_result = ex_rs1_data + ex_rs2_data; // ADD
                    {7'b0100000, 3'b000}: ex_alu_result = ex_rs1_data - ex_rs2_data; // SUB
                    {7'b0000000, 3'b111}: ex_alu_result = ex_rs1_data & ex_rs2_data; // AND
                    {7'b0000000, 3'b110}: ex_alu_result = ex_rs1_data | ex_rs2_data; // OR
                    {7'b0000000, 3'b100}: ex_alu_result = ex_rs1_data ^ ex_rs2_data; // XOR
                    default: ex_alu_result = 32'd0;
                endcase
            end

            7'b0010011,
            7'b0000011,
            7'b0100011: begin
                case (ex_funct3)
                    3'b000: ex_alu_result = ex_rs1_data + ex_alu_b; // ADDI / address
                    3'b111: ex_alu_result = ex_rs1_data & ex_alu_b; // ANDI
                    3'b110: ex_alu_result = ex_rs1_data | ex_alu_b; // ORI
                    default: ex_alu_result = ex_rs1_data + ex_alu_b;
                endcase
            end

            7'b1100011: begin
                ex_alu_result = ex_rs1_data - ex_rs2_data;
            end

            default: begin
                ex_alu_result = 32'd0;
            end
        endcase
    end

    assign ex_branch_taken = ex_branch && (ex_funct3 == 3'b000) && (ex_rs1_data == ex_rs2_data);
    assign ex_mem_rdata    = data_mem[ex_alu_result[9:2]];
    assign ex_wb_data      = ex_mem_to_reg ? ex_mem_rdata : ex_alu_result;

    assign pc_next = ex_branch_taken ? (ex_pc + ex_imm_b) : (pc + 32'd4);

    // ============================================================
    // Output debug signals
    // ============================================================

    assign W_PC_out       = pc;
    assign instruction    = if_instr;
    assign W_ALUout       = ex_alu_result;
    assign W_WB_data      = ex_wb_data;
    assign W_reg_write    = ex_reg_write;
    assign W_mem_write    = ex_mem_write;
    assign W_branch_taken = ex_branch_taken;

    // ============================================================
    // Sequential Logic
    // ============================================================

    integer i;

    always_ff @(posedge i_clk or negedge i_arst_n) begin
        if (!i_arst_n) begin
            pc <= 32'd0;

            if_id_pc    <= 32'd0;
            if_id_instr <= 32'h00000013;

            ex_pc         <= 32'd0;
            ex_instr      <= 32'h00000013;
            ex_opcode     <= 7'b0010011;
            ex_rd         <= 5'd0;
            ex_funct3     <= 3'b000;
            ex_funct7     <= 7'd0;
            ex_rs1_data   <= 32'd0;
            ex_rs2_data   <= 32'd0;
            ex_imm_i      <= 32'd0;
            ex_imm_s      <= 32'd0;
            ex_imm_b      <= 32'd0;
            ex_reg_write  <= 1'b0;
            ex_mem_write  <= 1'b0;
            ex_alu_src    <= 1'b0;
            ex_mem_to_reg <= 1'b0;
            ex_branch     <= 1'b0;

            for (i = 0; i < 32; i = i + 1)
                regfile[i] = 32'd0;

            for (i = 0; i < 256; i = i + 1)
                data_mem[i] = 32'd0;

            instr_mem[0] <= 32'h00500093; // addi x1, x0, 5
            instr_mem[1] <= 32'h00A00113; // addi x2, x0, 10

            // Two NOPs are inserted because this simple 3-stage model
            // does not include forwarding or hazard detection.
            instr_mem[2] <= 32'h00000013; // nop
            instr_mem[3] <= 32'h00000013; // nop

            instr_mem[4] <= 32'h002081B3; // add x3, x1, x2

            instr_mem[5] <= 32'h00000013; // nop
            instr_mem[6] <= 32'h00000013; // nop

            instr_mem[7] <= 32'h00302023; // sw x3, 0(x0)

            instr_mem[8] <= 32'h00000013; // nop
            instr_mem[9] <= 32'h00000013; // nop

            instr_mem[10] <= 32'h00002203; // lw x4, 0(x0)

            instr_mem[11] <= 32'h00000013; // nop
            instr_mem[12] <= 32'h00000013; // nop
            instr_mem[13] <= 32'h00000013; // nop
            instr_mem[14] <= 32'h00000013; // nop

            for (i = 15; i < 256; i = i + 1)
                instr_mem[i] = 32'h00000013;
        end else begin
            pc <= pc_next;

            // IF/ID register
            if_id_pc    <= pc;
            if_id_instr <= if_instr;

            // ID/EX register
            ex_pc         <= if_id_pc;
            ex_instr      <= if_id_instr;
            ex_opcode     <= id_opcode;
            ex_rd         <= id_rd;
            ex_funct3     <= id_funct3;
            ex_funct7     <= id_funct7;
            ex_rs1_data   <= id_rs1_data;
            ex_rs2_data   <= id_rs2_data;
            ex_imm_i      <= id_imm_i;
            ex_imm_s      <= id_imm_s;
            ex_imm_b      <= id_imm_b;
            ex_reg_write  <= id_reg_write;
            ex_mem_write  <= id_mem_write;
            ex_alu_src    <= id_alu_src;
            ex_mem_to_reg <= id_mem_to_reg;
            ex_branch     <= id_branch;

            // Memory write
            if (ex_mem_write)
                data_mem[ex_alu_result[9:2]] <= ex_rs2_data;

            // Register write-back
            if (ex_reg_write && ex_rd != 5'd0)
                regfile[ex_rd] <= ex_wb_data;
        end
    end

endmodule
