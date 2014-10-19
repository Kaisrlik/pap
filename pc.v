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
   input [31:0] pc,//pc2,
   input clk, alu2_en,
   output reg[31:0] e);

   always @ (posedge clk)
   begin
//      if(alu2_en == 1)
         e = addr+4+4*alu2_en;
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
      output alu2_en,
      output [31:0] a1, a2, a3, b1, b2, b3);


   reg [31:0] regs[31:0];

   always @ (posedge clk)
   begin

      if (we1 == 1)
         regs[w1addr] = w1;
      if (we2 == 1)
         regs[w2addr] = w2;
      regs[0] = 32'b0;
//   end
//   always @ (*)
//   begin
      a1 = regs[a];
      a2 = regs[b];
      a3 = regs[c];
      b1 = regs[d];
      b2 = regs[e];
      b3 = regs[f];
      if (c == d || c == e || c == 31)
         alu2_en = 0;
      else
         alu2_en = 1;
   end
endmodule

module dec(input [31:0] i1, i2,
      input clk,
      output [4:0] addrreg1, addrreg2, addrreg3,
      output en_alu2,
      output [4:0] addr2reg1, addr2reg2, addr2reg3,
      output [31:0] e, f);


   always @ (posedge clk)
      begin
         addrreg1 = i1[25:21];
         addrreg2 = i1[20:16];
         addrreg3 = i1[15:11];
         addr2reg1 = i2[25:21];
         addr2reg2 = i2[20:16];
         addr2reg3 = i2[15:11];
         e = i1;
         f = i2;
         //TODO: test i2 to jmps and branch?
         en_alu2 = 1;
         if(i1[31:26] == 6'b0 && i1[5:0] == 6'b001000)
            en_alu2 = 0;
         if(i1[31:26] == 6'b000011)
            en_alu2 = 0;
         if(i1[31:26] == 6'b000100)
            en_alu2 = 0;
         if(i1[31:26] == 6'b001000)
            en_alu2 = 0;
      end
endmodule


module alu(input aluNum;
         input [31:0] a, ipc,
         input [31:0] r1, r2, r3,
         input clk, en_reg, en_dec,
         output [4:0] d,
         output [31:0] pc,
         output [31:0] data);

   always @ (posedge clk)
   begin
      $display( "Core %d: INS: %b", aluNum, a[31:26]);
      d = 5'b0;
      case(a[31:26])
         6'b0:
            begin //mat + jump
            case(a[5:0])
               6'b100000: //add $3 = $1 + $2;
               begin
                  data = r1+r2;
                  d = r3;
               end
               6'b100100: //and $d = $s & $t;
               begin
                  data = r1&r2;
                  d = r3;
               end
               6'b100101: //or
               begin
                  data = r1|r2;
                  d = r3;
               end
               6'b101010: //slt if $s < $t $d = 1; else $d = 0;
               begin
                  if (r1 < r2)
                     data = 1;
                  else
                     data = 0;
                  d = r3;
               end
               6'b100010: //sub
               begin
                  data = r1-r2;
                  d = r3;
               end
               6'b001000: //jr goto s; jen $1
               begin
                   pc = r1;
               end
               default:
                  $display( "ERROR: R instruction using unsupported function %b",a[5:0]);
            endcase
            end
         6'b001000: //addi Adds a register and a sign-extended immediate value and stores the result in a register  Operation: $t = $s + imm;
         begin
            data = r1 + a[15:0];
            d = r2;
         end
         6'b000100: //beq if $s == $t go to PC+4+4*offset; else go to PC+4
         begin
            if(r1 == r2)
               pc = ipc+4+4*a[15:0];//TODO+4*offset
         end
         6'b100011: //lw $t = MEM[$s + offset];
         begin
            d = r2;
            data = MEM[r1+a[15:0]] //TODO+offset
         end
         6'b101011: //sw MEM[$s + offset] = $t;
         begin
            MEM[r1+a[15:0]] = r2; //TODO +offset
         end
         6'b000011: //jal $31 = PC + 8; PC = (PC & 0xf0000000) | (target << 2)
         begin
            d = 31;
            data = ipc+8+4*aluNum;
            pc = ((ipc+4*aluNum) & 26'hF0000000) | (a[25:0] << 2);
         end
         default:
             $display( "ERROR: Unsupported opcode %b",a[31:26]);
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
