module test();
  reg [31:0] d;
  wire [31:0] data1, data0, data5;
  reg [4:0] i1, i2, i3;
  reg clk, es, en;

   registerBlock32 a(i1,i2,i3,clk,en,rs,d, data0, data1);

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

   always #20 clk = clk + 1;

//   always @(y) $display( "Zmenila se hodnota x. Time=%d, y=%b. Vstupy: a=%b, b=%b, c=%b. d=%b",$time, y,a,b,c,d);

endmodule
