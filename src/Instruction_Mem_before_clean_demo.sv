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
      // ===== Simple RV32I Demo Program for Thesis Presentation =====
      // This program demonstrates arithmetic, write-back, memory access,
      // branch decision, and pipeline control behavior.

      Imemory[0]  = 32'h00500093; // addi x1, x0, 5       | x1 = 5
      Imemory[1]  = 32'h00a00113; // addi x2, x0, 10      | x2 = 10
      Imemory[2]  = 32'h002081b3; // add  x3, x1, x2      | x3 = 15
      Imemory[3]  = 32'h40110233; // sub  x4, x2, x1      | x4 = 5
      Imemory[4]  = 32'h00302023; // sw   x3, 0(x0)       | MEM[0] = x3
      Imemory[5]  = 32'h00002283; // lw   x5, 0(x0)       | x5 = MEM[0]
      Imemory[6]  = 32'h00518463; // beq  x3, x5, 8       | branch to Imemory[8] if x3 == x5
      Imemory[7]  = 32'h06300313; // addi x6, x0, 99      | should be skipped if branch is taken
      Imemory[8]  = 32'h00100393; // addi x7, x0, 1       | x7 = 1
      Imemory[9]  = 32'h00000013; // nop
      Imemory[10] = 32'h00000013; // nop
      Imemory[11] = 32'h00000013; // nop

      // Clear remaining instruction memory locations
      for (i = 12; i < DEPTH; i = i + 1) begin
        Imemory[i] = 32'h00000013; // nop
      end
    end
  end

endmodule
