`timescale 1ns/1ps

module tb_single_cycle;

    logic clk;
    logic rst_n;

    logic [31:0] pc;
    logic [31:0] instr;
    logic [31:0] aluout;
    logic [31:0] wb_data;
    logic        reg_write;
    logic        mem_write;
    logic        branch_taken;

    rv32i_single_cycle_top dut (
        .i_clk(clk),
        .i_arst_n(rst_n),
        .W_PC_out(pc),
        .instruction(instr),
        .W_ALUout(aluout),
        .W_WB_data(wb_data),
        .W_reg_write(reg_write),
        .W_mem_write(mem_write),
        .W_branch_taken(branch_taken)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        rst_n = 0;

        #20;
        rst_n = 1;

        #200;

        $display("FINAL PC = %h", pc);
        $finish;
    end

    always @(posedge clk) begin
        if (rst_n) begin
            $display("PC=%h INSTR=%h ALU=%h WB=%h REGW=%b MEMW=%b BR=%b",
                pc, instr, aluout, wb_data, reg_write, mem_write, branch_taken);
        end
    end

endmodule
