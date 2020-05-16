`include "defines.v"

module top (
	    input  clk,
	    input  reset
	    );

   wire [`CPU6_XLEN-1:0] pc;
   wire [`CPU6_XLEN-1:0] instr;
   wire [`CPU6_XLEN-1:0] readdata;

   wire [`CPU6_XLEN-1:0] dataaddr;
   wire [`CPU6_XLEN-1:0] writedata;
   wire memwrite;
   
   // instantiate processor and memories
   cpu6_core core(clk, reset, pc, instr, memwrite,
		  dataaddr, writedata, readdata);


   // ram size 64k
   // 2-port ram, port a for instruction fetch, port b for memory read/write
   ram mem(pc[12:2], dataaddr[12:2], clk, 32'b0, writedata, 1'b0, memwrite, 
      instr, readdata);
   
   //pseudo_icache icache(pc[9:2], instr);
   //pseudo_dcache dcache(clk, memwrite, dataaddr[9:2],
   //			writedata, readdata);

endmodule // top
