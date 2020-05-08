`include "defines.v"

module cpu6_datapath (
		      input  clk,
		      input  reset,
		      input  memtoreg,
		      input  [`CPU6_BRANCHTYPE_SIZE-1:0] branchtype,
		      input  alusrc,
		      input  regwrite,
		      input  jump,
		      input  [`CPU6_ALU_CONTROL_SIZE-1:0] alucontrol,
                      input  [`CPU6_IMMTYPE_SIZE-1:0] immtype,
		      output [`CPU6_XLEN-1:0] pc,
		      input  [`CPU6_XLEN-1:0] instr,
		      output [`CPU6_XLEN-1:0] dataaddr,
		      output [`CPU6_XLEN-1:0] writedata,
		      input  [`CPU6_XLEN-1:0] readdata
		      );

   wire [`CPU6_XLEN-1:0] aluout;

   assign dataaddr = aluout;
   
   wire [`CPU6_RFIDX_WIDTH-1:0] writereg = instr[`CPU6_RD_HIGH:`CPU6_RD_LOW];

   wire [`CPU6_XLEN-1:0] pcnext;
   wire [`CPU6_XLEN-1:0] pcnextbr;
   wire [`CPU6_XLEN-1:0] pcplus4;
   wire [`CPU6_XLEN-1:0] pcbranch;

   wire [`CPU6_XLEN-1:0] signimm; 
   wire [`CPU6_XLEN-1:0] signimmsh;
   
   wire [`CPU6_XLEN-1:0] rs1;
   wire [`CPU6_XLEN-1:0] rs2_imm;
   
   wire [`CPU6_XLEN-1:0] alu_mem;
   wire [`CPU6_XLEN-1:0] rd;

   wire branch;
   wire zero;


// IFID pipeline should not be here   
//   wire [`CPU6_XLEN-1:0] pcD;
//   wire [`CPU6_XLEN-1:0] instrD;
//   
//   cpu6_pipelinereg_d pipelinereg_d (clk, reset,
//      pc, instr,
//      pcD, instrD);
   

   // decode imm
   cpu6_immdec immdec(instr, immtype, signimm);

   // decode branch
   cpu6_branchdec branchdec(branchtype, zero, branch);
   
   // next PC logic
   cpu6_dffr#(`CPU6_XLEN) pcreg(pcnext, pc, clk, reset);
   
   cpu6_adder pcadd1(pc, 32'b100, pcplus4); // next pc if no branch, no jump
   cpu6_sl1 immsh(signimm, signimmsh);
   // risc-v counts begin at the current branch instruction
   cpu6_adder pcadd2(pc, signimmsh, pcbranch);
   // branch desides if to take next instruction or branch to pcbranch
   // pcnextbr means pc next br 
   cpu6_mux2#(`CPU6_XLEN) pcbrmux(pcplus4, pcbranch, branch, pcnextbr);
   // pcnext is the final pc
   // code review when implementing jump
   cpu6_mux2#(`CPU6_XLEN) pcmux(pcnextbr, aluout, jump, pcnext);

   // register file logic
   cpu6_regfile rf(instr[`CPU6_RS1_HIGH:`CPU6_RS1_LOW],
                   instr[`CPU6_RS2_HIGH:`CPU6_RS2_LOW],
                   rs1, writedata, // SW: rs2 contains data to write to memory
                   regwrite,
		   writereg, rd,
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
   cpu6_mux2#(`CPU6_XLEN) resmux(aluout, readdata, memtoreg, alu_mem);

   cpu6_mux2#(`CPU6_XLEN) jumpmux(alu_mem, pcplus4, jump, rd);

   //cpu6_signext se(instr[`CPU6_IMM_HIGH:`CPU6_IMM_LOW], signimm);

   // ALU logic
   cpu6_mux2#(`CPU6_XLEN) srcbmux(writedata, signimm, alusrc, rs2_imm);
   cpu6_alu alu(rs1, rs2_imm, alucontrol, aluout, zero);
		      
endmodule // cpu6_datapath
