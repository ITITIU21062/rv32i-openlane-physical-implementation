module Instruction_Mem #(
parameter N = 32,
    parameter DEPTH = 77
)(
input logic  i_clk,
    input logic  i_arst_n, // Reset active low
  input logic  [N-1:0] i_addr, // Address
  output logic [N-1:0] o_inst  // Instruction
);
  //77 instructions, each 32 bits
  logic [N-1:0] Imemory [0:DEPTH - 1];
  
  localparam int ADDR_LSB = 2;
  localparam int INDEX_W  = $clog2(DEPTH);
  wire [INDEX_W-1:0] word_idx = i_addr[ADDR_LSB +: INDEX_W];
  
  int i;
  
  assign o_inst = Imemory[word_idx];
   
  always_ff @(posedge i_clk or negedge i_arst_n) begin
    if(!i_arst_n) begin 
       for(i = 0; i < DEPTH; i = i + 1) begin
         Imemory[i] = '0;
       end

    end else begin
      // ===== Clean RV32I Demo Program for Terminal PASS/FAIL =====
      // Registers used:
      // x10 = 5
      // x11 = 10
      // x12 = x10 + x11 = 15
      // x13 = x11 - x10 = 5
      // MEM[0] = x12 = 15
      // x14 = MEM[0] = 15
      // beq x12, x14, +8 should be taken
      // x15 = 99 should be skipped
      // x16 = 1 should be executed after branch
      //
      // NOPs are inserted to avoid RAW hazards in terminal demonstration.

      Imemory[0]  = 32'h00000013; // nop

      Imemory[1]  = 32'h00500513; // addi x10, x0, 5      | x10 = 5
      Imemory[2]  = 32'h00a00593; // addi x11, x0, 10     | x11 = 10

      Imemory[3]  = 32'h00000013; // nop
      Imemory[4]  = 32'h00000013; // nop

      Imemory[5]  = 32'h00b50633; // add  x12, x10, x11   | x12 = 15
      Imemory[6]  = 32'h40a586b3; // sub  x13, x11, x10   | x13 = 5

      Imemory[7]  = 32'h00000013; // nop
      Imemory[8]  = 32'h00000013; // nop

      Imemory[9]  = 32'h00c02023; // sw   x12, 0(x0)      | MEM[0] = 15

      Imemory[10] = 32'h00000013; // nop
      Imemory[11] = 32'h00000013; // nop

      Imemory[12] = 32'h00002703; // lw   x14, 0(x0)      | x14 = MEM[0] = 15

      Imemory[13] = 32'h00000013; // nop
      Imemory[14] = 32'h00000013; // nop

      Imemory[15] = 32'h00e60463; // beq  x12, x14, 8     | branch to Imemory[17] if equal
      Imemory[16] = 32'h06300793; // addi x15, x0, 99     | should be skipped
      Imemory[17] = 32'h00100813; // addi x16, x0, 1      | x16 = 1

      Imemory[18] = 32'h00000013; // nop
      Imemory[19] = 32'h00000013; // nop
      Imemory[20] = 32'h00000013; // nop

      // Fill remaining memory with NOPs
      for (i = 21; i < DEPTH; i = i + 1) begin
        Imemory[i] = 32'h00000013; // nop
      end
    end
  end

endmodule
