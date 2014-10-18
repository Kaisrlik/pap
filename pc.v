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

module pc(
   input [31:0] pc,
   input clk,
   output reg[31:0] e);

   always @ (posedge clk)
   begin
         e = addr+4;
   end
endmodule

module imem (input [31:0] addr, addr2,
   input clk,
   output [31:0] e, f);

   reg [7:0] RAM[4095:0];

   initial  $readmemh ("memfile.dat",RAM);

   assign e <= {RAM[addr],RAM[addr-1], RAM[addr-2], RAM[addr-3]};
   assign f <= {RAM[addr+4],RAM[addr+3], RAM[addr+2], RAM[addr+1]};

endmodule


module regs(
      input [4:0] a, b, c, d, e, f,
      input clk,we1, we2,
      input [31:0] w1, w2,
      input [4:0] w1addr, w2addr,
      output [31:0] a1, a2, a3, b1, b2, b3);


   reg [31:0] regs[31:0];

   always @ (posedge clk)
   begin
      if (we1 == 1)
         regs[w1addr] = w1;
      if (we2 == 1)
         regs[w2addr] = w2;
      regs[0] = 32'b0;
      a1 = regs[a];
      a2 = regs[b];
      a3 = regs[c];
      b1 = regs[d];
      b2 = regs[e];
      b3 = regs[f];
   end
endmodule

module dec(input [31:0] i1, i2,
      input clk,
      output [4:0] addrreg1, addrreg2, addrreg3,
      output en_alu2,
      output [4:0] addr2reg1, addr2reg2, addr2reg3);


   reg ssen;
   reg is1reg;

   always @ (posedge clk)
      begin
         ssen = 0;
         case(i1[31:26])
            0: begin //jump ma taky 0
               addrreg1 = i1[25:21];
               addrreg2 = i1[20:16];
               addrreg3 = i1[15:11];
               if(i1[5:0] == 5'b01000)
                  is1reg = 0;
               else
                  is1reg = 1;
               end
            6'b001000: begin
               //addi
               addrreg1 = i1[25:21];
               addrreg2 = i1[20:16];
               addrreg3 = 5'bz;
               end

            6'b000011: begin
               //jump and link without regs
               //$31 = PC + 8;
               //PC = (PC & 0xf0000000) | (target << 2)
               addrreg1 = 5'bz;
               addrreg2 = 5'bz;
               addrreg3 = 5'bz;
               end
            6'b101011: begin
               //sw MEM[$s + offset] = $t;
               addrreg1 = i1[25:21];
               addrreg2 = i1[20:16];
               addrreg3 = 5'bz;
               end
            6'b100011: begin
               //lw $t = MEM[$s + offset];
               addrreg1 = i1[25:21];
               addrreg2 = i1[20:16];
               addrreg3 = 5'bz;
               end
            6'b000100: begin
               //beq if $s == $t go to PC+4+4*offset;
               //    else go to PC+4
               addrreg1 = i1[25:21];
               addrreg2 = i1[20:16];
               addrreg3 = 5'bz;
               end
            default:
            begin
               addrreg1 = 5'bz;
               addrreg2 = 5'bz;
               addrreg3 = 5'bz;
            end
         endcase
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




/*module registerBlock32(input [4:0] ra, rb, w,
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
endmodule*/
