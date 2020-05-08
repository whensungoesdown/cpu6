`include "defines.v"

module cpu6_core (
		  input  clk,
		  input  reset,
   
		  output [`CPU6_XLEN-1:0] pc,
		  input  [`CPU6_XLEN-1:0] instr,
                  // write back to memory
		  output memwriteE,
		  output [`CPU6_XLEN-1:0] dataaddr,
		  output [`CPU6_XLEN-1:0] writedata,
                  // fetch data
		  input  [`CPU6_XLEN-1:0] readdata
);

   wire memwrite;
   wire memtoreg;
   wire alusrc;
   wire regdst;
   wire regwrite;
   wire jump;
   wire [`CPU6_BRANCHTYPE_SIZE-1:0] branchtype;
   wire zero;

   wire [`CPU6_ALU_CONTROL_SIZE-1:0] alucontrol;
   wire [`CPU6_IMMTYPE_SIZE-1:0] immtype;
   
   wire memtoregE;
   wire [`CPU6_BRANCHTYPE_SIZE-1:0] branchtypeE;
   wire alusrcE;
   wire regwriteE;
   wire jumpE;
   wire [`CPU6_ALU_CONTROL_SIZE-1:0] alucontrolE;
   wire [`CPU6_IMMTYPE_SIZE-1:0] immtypeE;
   wire [`CPU6_XLEN-1:0] instrE;
   
   cpu6_controller c(instr[`CPU6_OPCODE_HIGH:`CPU6_OPCODE_LOW],
		     instr[`CPU6_FUNCT3_HIGH:`CPU6_FUNCT3_LOW],
		     instr[`CPU6_FUNCT7_HIGH:`CPU6_FUNCT7_LOW],
		     memtoreg, memwrite, branchtype,
		     alusrc, regwrite, jump,
		     alucontrol, immtype);

   cpu6_pipelinereg_idex pipelinereg_idex(clk, reset,
      memwrite,
      memtoreg, branchtype, alusrc, regwrite,jump, alucontrol, immtype,
      instr,
      memwriteE,
      memtoregE, branchtypeE, alusrcE, regwriteE, jumpE, alucontrolE, immtypeE,
      instrE);
   
   cpu6_datapath dp(clk, reset, memtoregE, branchtypeE,
		    alusrcE, regwriteE, jumpE,
		    alucontrolE, immtypeE, pc, instrE,
		    dataaddr, writedata, readdata);
endmodule   
