`include "defines.v"

module cpu6_datapath (
		      input  clk,
		      input  reset,
		      input  memtoregE,
		      input  [`CPU6_BRANCHTYPE_SIZE-1:0] branchtypeE,
		      input  alusrcE,
		      input  regwriteE,
		      input  jumpE,
		      input  [`CPU6_ALU_CONTROL_SIZE-1:0] alucontrolE,
                      input  [`CPU6_IMMTYPE_SIZE-1:0] immtypeE,
		      input  [`CPU6_XLEN-1:0] pcE,
                      output [`CPU6_XLEN-1:0] pcnextE,
                      output pcsrcE,
		      input  [`CPU6_XLEN-1:0] instrE,
		      output [`CPU6_XLEN-1:0] dataaddrE,
		      output [`CPU6_XLEN-1:0] writedataE,
		      input  [`CPU6_XLEN-1:0] readdataE
		      );

   wire [`CPU6_XLEN-1:0] aluoutE;

   assign dataaddrE = aluoutE;
  
   // writeregE shoudl be writeregW, later 
   wire [`CPU6_RFIDX_WIDTH-1:0] writeregE = instrE[`CPU6_RD_HIGH:`CPU6_RD_LOW];

   wire [`CPU6_XLEN-1:0] pcnextbrE;
   wire [`CPU6_XLEN-1:0] pcplus4E;
   wire [`CPU6_XLEN-1:0] pcbranchE;

   wire [`CPU6_XLEN-1:0] signimmE; 
   wire [`CPU6_XLEN-1:0] signimmshE;
   
   wire [`CPU6_XLEN-1:0] rs1E;  // should be D, later
   wire [`CPU6_XLEN-1:0] rs2_immE; // should be D, later
   
   wire [`CPU6_XLEN-1:0] alu_memE;
   wire [`CPU6_XLEN-1:0] rdE; // rdEDW


   wire branchE;
   wire zeroE;

// IFID pipeline should not be here   
//   wire [`CPU6_XLEN-1:0] pcD;
//   wire [`CPU6_XLEN-1:0] instrD;
//   
//   cpu6_pipelinereg_d pipelinereg_d (clk, reset,
//      pc, instr,
//      pcD, instrD);
   

   // decode imm
   cpu6_immdec immdec(instrE, immtypeE, signimmE);

   // decode branch
   cpu6_branchdec branchdec(branchtypeE, zeroE, branchE);
   
   // next PC logic
   //cpu6_dffr#(`CPU6_XLEN) pcreg(stallF, pcnext, pc, clk, reset);
   
   cpu6_adder pcadd1(pcE, 32'b100, pcplus4E); // jump instruction need this to load it to rd
   cpu6_sl1 immsh(signimmE, signimmshE);
   // risc-v counts begin at the current branch instruction
   cpu6_adder pcadd2(pcE, signimmshE, pcbranchE);
   // branch desides if to take next instruction or branch to pcbranch
   // pcnextbr means pc next br 
   cpu6_mux2#(`CPU6_XLEN) pcbrmux(pcplus4E, pcbranchE, branchE, pcnextbrE);
   // pcnext is the final pc
   // code review when implementing jump
   cpu6_mux2#(`CPU6_XLEN) pcmux(pcnextbrE, aluoutE, jumpE, pcnextE);
   
   //assign pcsrcE = branchE | jumpE;
   assign pcsrcE = (branchtypeE != `CPU6_BRANCHTYPE_NOBRANCH) | jumpE;  

   // register file logic
   cpu6_regfile rf(instrE[`CPU6_RS1_HIGH:`CPU6_RS1_LOW],
                   instrE[`CPU6_RS2_HIGH:`CPU6_RS2_LOW],
                   rs1E, writedataE, // SW: rs2 contains data to write to memory
                   regwriteE,
		   writeregE, rdE,
		   clk, reset);

   // rd <-- mem/reg
   // when write to rs2?
   // only mips need to determine write-register, MIPS LW use rt(rs2) as the destination register
   // but other type instruction use rd
   
   //cpu6_mux2#(`CPU6_RFIDX_WIDTH) wrmux(instr[`CPU6_RS2_HIGH:`CPU6_RS2_LOW],
   //				       instr[`CPU6_RD_HIGH:`CPU6_RD_LOW],
   //				       regdst, writereg);
   
   // memtoreg 1 means it's a LW, data comes from memory,
   // otherwise the alu_mem comes from ALU
   // LW: load data from memory to rd.  add rd, rs1, rs2: ALU output to rd
   cpu6_mux2#(`CPU6_XLEN) resmux(aluoutE, readdataE, memtoregE, alu_memE);

   cpu6_mux2#(`CPU6_XLEN) jumpmux(alu_memE, pcplus4E, jumpE, rdE);

   //cpu6_signext se(instr[`CPU6_IMM_HIGH:`CPU6_IMM_LOW], signimm);

   // ALU logic
   cpu6_mux2#(`CPU6_XLEN) srcbmux(writedataE, signimmE, alusrcE, rs2_immE);
   cpu6_alu alu(rs1E, rs2_immE, alucontrolE, aluoutE, zeroE);
		      
endmodule // cpu6_datapath
