`include "defines.v"

module cpu6_pipelinereg_idex (
   input  clk,
   input  reset,

   input  memwrite,
 
   input  memtoreg,
   input  [`CPU6_BRANCHTYPE_SIZE-1:0] branchtype,
   input  alusrc,
   input  regwrite,
   input  jump,
   input  [`CPU6_ALU_CONTROL_SIZE-1:0] alucontrol,
   input  [`CPU6_IMMTYPE_SIZE-1:0] immtype,
   input  [`CPU6_XLEN-1:0] instr,

   output memwriteE,
   
   output memtoregE,
   output [`CPU6_BRANCHTYPE_SIZE-1:0] branchtypeE,
   output alusrcE,
   output regwriteE,
   output jumpE,
   output [`CPU6_ALU_CONTROL_SIZE-1:0] alucontrolE,
   output [`CPU6_IMMTYPE_SIZE-1:0] immtypeE,
   output [`CPU6_XLEN-1:0] instrE
   );

   cpu6_dffr#(1) memwrite_r(memwrite, memwriteE, clk, reset);
   
   cpu6_dffr#(1) memtoreg_r(memtoreg, memtoregE, clk, reset);
   cpu6_dffr#(`CPU6_BRANCHTYPE_SIZE) branchtype_r(branchtype, branchtypeE, clk, reset);
   cpu6_dffr#(1) alusrc_r(alusrc, alusrcE, clk, reset);
   cpu6_dffr#(1) regwrite_r(regwrite, regwriteE, clk, reset);
   cpu6_dffr#(1) jump_r(jump, jumpE, clk, reset);
   cpu6_dffr#(`CPU6_ALU_CONTROL_SIZE) alucontrol_r(alucontrol, alucontrolE, clk, reset);
   cpu6_dffr#(`CPU6_IMMTYPE_SIZE) immtype_r(immtype, immtypeE, clk, reset);

   cpu6_dffr#(`CPU6_XLEN) instr_r(instr, instrE, clk, reset);
   
endmodule // cpu6_pipelinereg_idex
