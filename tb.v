module test();
  wire [31:0] data1, data2, data5,data6, reg1, reg2, reg3, reg4, reg5, reg6, dataX, dataY;
  reg clk;

  wire enalu2, enalu2reg;
  wire [31:0] cpyData1, cpyData2, cpyData3, cpyData4,pc, wmemdata1, wmemdata2;
  wire [4:0] r1,r2,r3,s1,s2,s3, alu1r, alu2r, wmem1, wmem2;

//   registerBlock32 a(i1,i2,i3,clk,en,rs,d, data0, data1);
//
//
   wire en1, en2, x1, rst;
   wire [31:0] opc, x, mempc,ipc, pcdec, pcreg,pcalu;
   wire reset;



   imem IMEM(mempc,clk, data1, data2, pcdec);
   dec DEC(data1,data2, clk,rst, reset, enalu2, reset, cpyData1,cpyData2, pcdec, pcreg);
   regs REGS(clk,cpyData1,cpyData2, data5, data6,wmemdata1, wmemdata2, alu1r, alu2r,wmem1,wmem2, enalu2, enalu2reg, reg1, reg2, reg3, reg4, reg5, reg6, cpyData3, cpyData4, pcreg, pcalu);
   alu a1(0, cpyData3, pcalu, reg1, reg2,reg3, clk,       1, alu1r, ipc, data5, rst);
   alu a2(1, cpyData4,     0, reg4, reg5,reg6, clk,enalu2reg, alu2r,   x, data6, x1);
   dmem MEM(cpyData3, cpyData4, clk, enalu2reg, reg1, reg2,reg4,reg5, wmem1, wmem2, wmemdata1, wmemdata2);
   pc PC(mempc,ipc, clk, 1,rst, reset,mempc);


//   wire [31:0] apc;
//   pc apc2(apc, clk,0, apc);
//   imem amem2(apc,clk, dataX, dataY);
   initial begin
      $dumpfile("test");
      $dumpvars;
      clk = 0;
//      clk2 = 0;
      #1720 $finish;
   end

   always #10 clk = ~clk;
//   always #40 clk2 = ~clk2;

//   always @(y) $display( "Zmenila se hodnota x. Time=%d, y=%b. Vstupy: a=%b, b=%b, c=%b. d=%b",$time, y,a,b,c,d);

endmodule
