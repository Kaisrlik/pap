module test();
  wire [31:0] data1, data2, data5,data6, reg1, reg2, reg3, reg4, reg5, reg6, dataX, dataY;
  reg clk, clk2;

  wire enalu2, enalu2reg;
  wire [31:0] cpyData1, cpyData2, cpyData3, cpyData4,pc;
  wire [4:0] r1,r2,r3,s1,s2,s3, alu1r, alu2r;

//   registerBlock32 a(i1,i2,i3,clk,en,rs,d, data0, data1);
//
//
   wire en1, en2;
   wire [31:0] opc, xpc, mempc,ipc;


   imem RAM(mempc,clk, data1, data2);
   dec DEC(data1,data2, clk, r1,r2,r3, enalu2, s1,s2,s3, cpyData1,cpyData2);
   regs REGS(r1, r2, r3, s1, s2 , s3,clk,cpyData1,cpyData2, data5, data6, alu1r, alu2r, enalu2reg, reg1, reg2, reg3, reg4, reg5, reg6, cpyData3, cpyData4);
   alu a1(0, cpyData3, opc, reg1, reg2,reg3, clk, 1, 1, alu1r, ipc, data5, en1);
   alu a2(1, cpyData4, opc, reg4, reg5,reg6, clk, enalu2, enalu2reg,alu2r, xpc, data6, en2);
   dmem MEM(cpyData3, cpyData4, clk, reg1, reg2,reg3,reg4,reg5,reg6, alu1r, alu2r, data5, data6);
   pc PC(mempc, clk,en2, mempc);


   wire [31:0] apc;
   pc apc2(apc, clk,0, apc);
   imem amem2(apc,clk, dataX, dataY);
   initial begin
      $dumpfile("test");
      $dumpvars;
      clk = 0;
      clk2 = 0;
      #320 $finish;
   end

   always #10 clk = ~clk;
   always #10 clk2 = ~clk2;

//   always @(y) $display( "Zmenila se hodnota x. Time=%d, y=%b. Vstupy: a=%b, b=%b, c=%b. d=%b",$time, y,a,b,c,d);

endmodule
