module muxCv(input a, b, c, d, output reg e);
   always @(a, b, c, d)
      if(a)
         e = b & c;
      else
         e = (b ^ d) | c;
endmodule


module mux2(input [31:0] a, b, 
   input x,
   output reg [31:0] e);
   always @ (*)
      case (x)
         0: e = a;
         1: e = b;
         default: e = 32'bz;
      endcase
endmodule


module mux3(input [31:0] a, b, c,
   input [1:0] x, 
   output reg [31:0] e);
   always @ (*)
      case (x)
         0: e = a;
         1: e = b;
         2: e = c;
         default: e = 32'bz;
      endcase
endmodule

module sum32(input [31:0] a, b,
   output reg [31:0] e,
   output reg isZero, overflow);

   always @ (*)
      begin
         e = a+b;
         if (e < a && e < b)
            overflow = 1;
         else
            overflow = 0;
         if (e == 0)
            isZero = 1;
         else
            isZero = 0;
      end
endmodule



module multAx4(input [31:0] a,
   output reg [31:0] e,
   output reg isZero);

   always @ (*)
      begin
         e = a*4;
         if (e == 0)
            isZero = 1;
         else
            isZero = 0;
      end

endmodule

module comp2(input [31:0] a, b,
   output reg isEq);


   always @ (*)
      if( a == b)
         isEq = 1;
      else
         isEq = 0;
endmodule

module signExt16t32(input [15:0] a,
   output reg [31:0] e);
   always @ (*)
      if(a[15] == 1)
         e = {a[15], 16'hFF, a[14:0]};
      else
         e = {a[15], 16'b0, a[14:0]};
endmodule

module register32(input [31:0] a,
      input rs, clk, en,
      output reg [31:0] e);
   always @ (clk)
   begin
      if(clk == 1 && en == 1 && a != 32'bz)
         e = a;
      if(clk == 1 && rs == 1 && en == 1)
         e = 0;
   end
endmodule




module registerBlock32(input [4:0] ra, rb, w,
      input clk, en, rs,
      input [31:0] wd,
      output reg [31:0] e, f);

   wire [31:0] y[31:0];
   wire [31:0] in[31:0];
   wire x[31:0];
   register32 regs[31:0](in[31:0], rs, clk, en, y[31:0]);

   always @ (clk, en)
   begin
      x = 32'b0;
      if(clk == 1 && en == 1)
         if(w != 5'bz)
         begin
            in[w] = wd;
            x[w] = 1;
         end
      if(clk == 1 && en == 1)
         if(ra != 5'bz)
         begin
            e = regs[ra];
            x[w] = 1;
         end
      if(clk == 1 && en == 1)
         if(rb != 5'bz)
         begin
            f = regs[rb];
            x[w] = 1;
         end
   end
endmodule
