module test();
  reg [31:0] d;
  wire [31:0] data1, data2, data5,data6, reg1, reg2, reg3, reg4, reg5, reg6;
  reg [4:0] i1, i2, i3;
  reg clk, es, en, rs;

  wire enalu2, enalu2reg;
  wire [31:0] cpyData1, cpyData2, cpyData3, cpyData4,pc;
  wire [4:0] r1,r2,r3,s1,s2,s3, alu1r, alu2r;

//   registerBlock32 a(i1,i2,i3,clk,en,rs,d, data0, data1);
//
   imem RAM(0,clk, data1, data2);

   dec DEC(data1,data2, clk, r1,r2,r3, enalu2, s1,s2,s3, cpyData1,cpyData2);
   regs REGS(r1, r2, r3, s1, s2 , s3,clk,cpyData1,cpyData2, data5, data6, alu1r, alu2r, enalu2reg, reg1, reg2, reg3, reg4, reg5, reg6, cpyData3, cpyData4);
   alu a1(0, cpyData3, 0/*pc*/, reg1, reg2,reg3, clk, 1, 1, alu1r, pc, data5);
   alu a2(1, cpyData4, 0/*pc*/, reg4, reg5,reg6, clk, enalu2, enalu2reg,alu2r, pc, data6);


   initial begin
      $dumpfile("test");
      $dumpvars;
      d = 32'hFFFFFFFF;
      i1=0;
      i2=1;
      i3=3;
      clk = 0;
      en = 1;
      rs = 0;
      #320 $finish;
   end

   always #10 clk = ~clk;

//   always @(y) $display( "Zmenila se hodnota x. Time=%d, y=%b. Vstupy: a=%b, b=%b, c=%b. d=%b",$time, y,a,b,c,d);

endmodule
