`timescale 1ns/1ps

module tb_rv32i_demo;

    localparam N = 32;

    logic i_clk;
    logic i_arst_n;

    logic [N-1:0] W_PC_out;
    logic [N-1:0] instruction;
    logic [N-1:0] W_RD1;
    logic [N-1:0] W_RD2;
    logic [N-1:0] W_m1;
    logic [N-1:0] W_m2;
    logic [N-1:0] W_ALUout;
    logic [N-1:0] W_WB_data;
    logic [4:0]   W_rd_addr;
    logic         W_reg_write;
    logic         W_mem_write;
    logic         W_mem_read;
    logic         W_branch_taken;
    logic [N-1:0] W_mem_addr;
    logic [N-1:0] W_mem_wdata;
    logic [N-1:0] W_mem_rdata;
    logic         W_jal;
    logic         W_jalr;
    logic         W_stall;
    logic         W_flush;
    logic [N-1:0] W_immediate;
    logic         W_ALUSrc;

    integer pass_count = 0;
    integer fail_count = 0;

    logic seen_x10 = 0;
    logic seen_x11 = 0;
    logic seen_x12 = 0;
    logic seen_x13 = 0;
    logic seen_x14 = 0;
    logic seen_x16 = 0;
    logic seen_mem_write = 0;
    logic seen_mem_read = 0;
    logic seen_branch = 0;
    logic wrong_x15_write = 0;

    initial begin
        i_clk = 1'b0;
        forever #10 i_clk = ~i_clk;
    end

    initial begin
        i_arst_n = 1'b0;
        #60;
        i_arst_n = 1'b1;
    end

    rv32i_top dut (
        .i_clk(i_clk),
        .i_arst_n(i_arst_n),

        .W_PC_out(W_PC_out),
        .instruction(instruction),
        .W_RD1(W_RD1),
        .W_RD2(W_RD2),
        .W_m1(W_m1),
        .W_m2(W_m2),
        .W_ALUout(W_ALUout),
        .W_WB_data(W_WB_data),
        .W_rd_addr(W_rd_addr),
        .W_reg_write(W_reg_write),
        .W_mem_write(W_mem_write),
        .W_mem_read(W_mem_read),
        .W_branch_taken(W_branch_taken),
        .W_mem_addr(W_mem_addr),
        .W_mem_wdata(W_mem_wdata),
        .W_mem_rdata(W_mem_rdata),
        .W_jal(W_jal),
        .W_jalr(W_jalr),
        .W_stall(W_stall),
        .W_flush(W_flush),
        .W_immediate(W_immediate),
        .W_ALUSrc(W_ALUSrc)
    );

    initial begin
        $dumpfile("sim/demo/rv32i_demo.vcd");
        $dumpvars(0, tb_rv32i_demo);
    end

    task automatic check_event;
        input string name;
        input logic condition;
        begin
            if (condition) begin
                pass_count = pass_count + 1;
                $display("PASS: %s", name);
            end else begin
                fail_count = fail_count + 1;
                $display("FAIL: %s", name);
            end
        end
    endtask

    always @(posedge i_clk) begin
        if (i_arst_n) begin

            // Print only useful register write-back events.
            if (W_reg_write && W_rd_addr != 5'd0) begin
                $display("WRITE-BACK: x%0d <= 0x%08h", W_rd_addr, W_WB_data);

                if (W_rd_addr == 5'd10 && !seen_x10) begin
                    seen_x10 = 1;
                    check_event("x10 = 5 after addi x10, x0, 5", W_WB_data == 32'h00000005);
                end

                if (W_rd_addr == 5'd11 && !seen_x11) begin
                    seen_x11 = 1;
                    check_event("x11 = 10 after addi x11, x0, 10", W_WB_data == 32'h0000000a);
                end

                if (W_rd_addr == 5'd12 && !seen_x12) begin
                    seen_x12 = 1;
                    check_event("x12 = 15 after add x12, x10, x11", W_WB_data == 32'h0000000f);
                end

                if (W_rd_addr == 5'd13 && !seen_x13) begin
                    seen_x13 = 1;
                    check_event("x13 = 5 after sub x13, x11, x10", W_WB_data == 32'h00000005);
                end

                if (W_rd_addr == 5'd14 && !seen_x14) begin
                    seen_x14 = 1;
                    check_event("x14 = 15 after lw x14, 0(x0)", W_WB_data == 32'h0000000f);
                end

                if (W_rd_addr == 5'd15) begin
                    wrong_x15_write = 1;
                    fail_count = fail_count + 1;
                    $display("FAIL: x15 was written, but it should be skipped by branch");
                end

                if (W_rd_addr == 5'd16 && !seen_x16) begin
                    seen_x16 = 1;
                    check_event("x16 = 1 after branch target instruction", W_WB_data == 32'h00000001);
                end
            end

            if (W_mem_write && !seen_mem_write) begin
                seen_mem_write = 1;
                $display("MEMORY WRITE: MEM[0x%08h] <= 0x%08h", W_mem_addr, W_mem_wdata);
                check_event("MEM[0] = 15 after sw x12, 0(x0)",
                            W_mem_addr == 32'h00000000 && W_mem_wdata == 32'h0000000f);
            end

            if (W_mem_read && !seen_mem_read) begin
                seen_mem_read = 1;
                $display("MEMORY READ : MEM[0x%08h] => 0x%08h", W_mem_addr, W_mem_rdata);
                check_event("load reads 15 from MEM[0]",
                            W_mem_addr == 32'h00000000 && W_mem_rdata == 32'h0000000f);
            end

            if (W_branch_taken && !seen_branch) begin
                seen_branch = 1;
                $display("BRANCH TAKEN at PC=0x%08h", W_PC_out);
                check_event("branch_taken = 1 for beq x12, x14", 1'b1);
            end

            if (W_stall) begin
                $display("PIPELINE STALL detected");
            end

            if (W_flush) begin
                $display("PIPELINE FLUSH detected");
            end
        end
    end

    initial begin
        #1200;

        $display("");
        $display("========== RV32I TERMINAL DEMO SUMMARY ==========");

        check_event("x10 write-back observed", seen_x10);
        check_event("x11 write-back observed", seen_x11);
        check_event("x12 write-back observed", seen_x12);
        check_event("x13 write-back observed", seen_x13);
        check_event("x14 write-back observed", seen_x14);
        check_event("memory write observed", seen_mem_write);
        check_event("memory read observed", seen_mem_read);
        check_event("branch taken observed", seen_branch);
        check_event("x15 skipped by branch", !wrong_x15_write);
        check_event("x16 write-back observed", seen_x16);

        $display("PASS count = %0d", pass_count);
        $display("FAIL count = %0d", fail_count);

        if (fail_count == 0) begin
            $display("FINAL RESULT: PASS - RV32I demo program executed as expected.");
        end else begin
            $display("FINAL RESULT: FAIL - Some expected results did not match.");
        end

        $display("=================================================");
        $finish;
    end

endmodule
