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
   output reg[31:0] outputpc);

   initial outputpc = 0;

//   #1
   always @ (posedge clk)
   begin
      //TODO : mozna dodelat ifelse na alu2en
//      if(alu2_en == 1)
         outputpc = pc+1+1*alu2_en;
   end
endmodule


//TODO :   readmemh doesnt work
module imem (input [31:0] pcaddr,
   input clk,
   output reg [31:0] e, f);

   reg [31:0] RAM[4095:0];

   initial  $readmemh ("ins2",RAM);
   always @ (*)
   begin
      e = RAM[pcaddr];
      f = RAM[pcaddr];
   end
endmodule

module dmem (input [31:0] a, b,
   input clk,
   input [31:0] r1, r2, r3,
   input [31:0] r21, r22, r23,
   output reg [4:0] e, f,
   output reg [31:0] data1, data2);

   reg [31:0] MEM[4095:0];


   //TODO : compiler by nemel udelat, ze nacte za sebou na stejnou addr a testuji to regs
   always @ (posedge clk)
   begin
      e = 5'bz;
      f = 5'bz;
      data1 = 32'bz;
      data2 = 32'bz;
      case(a)
         6'b100011: //lw $t = MEM[$s + offset];
         begin
            e = a[25:20];
            data1 = MEM[r1+a[15:0]];
         end
         6'b101011: //sw MEM[$s + offset] = $t;
            MEM[r1+a[15:0]] = r2;
         default:
            e = 32'bz;
     endcase
      case(b)
         6'b100011: //lw $t = MEM[$s + offset];
         begin
            f = b[25:20];
            data2 = MEM[r1+b[15:0]];
         end
         6'b101011: //sw MEM[$s + offset] = $t;
            MEM[r1+b[15:0]] = r2;
         default:
            f = 32'bz;
     endcase
  end
   //assign e <= {MEM[addr],MEM[addr-1], MEM[addr-2], MEM[addr-3]};
   //assign f <= {MEM[addr2],MEM[addr2-1], MEM[addr2-2], MEM[addr2-3]};
endmodule
module regs(
      input [4:0] a, b, c, d, e, f,
      input clk,
      input [31:0] ins1, ins2, w1, w2,
      input [4:0] w1addr, w2addr,
      output reg alu2_en,
      output reg [31:0] a1, a2, a3, b1, b2, b3, inso1, inso2);


   reg [31:0] regs[31:0];
   initial regs[9] = 32'b1;
   initial regs[8] = 32'b1;
      initial regs[10] = 32'b111;
      initial regs[11] = 32'b0;

   always @ (posedge clk)
   begin
      inso1 = ins1;
      inso2 = ins2;
//WriteEnable?
      regs[w1addr] = w1;
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
      if (c == d || c == e || c == f || c == 31)
         alu2_en = 0;
      else
         alu2_en = 1;
   end
endmodule

module dec(input [31:0] i1, i2,
      input clk,
      output reg [4:0] addrreg1, addrreg2, addrreg3,
      output reg en_alu2,
      output reg [4:0] addr2reg1, addr2reg2, addr2reg3,
      output reg [31:0] e, f);


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




module alu(input aluNum,
         input [31:0] a, ipc,
         input [31:0] r1, r2, r3,
         input clk, en_reg, en_dec,
         output reg [4:0] d,
         output reg [31:0] pc,
         output reg [31:0] data,
      output reg eno);

   initial eno = 0;
   initial pc = 0;

   always @ (posedge clk)
   begin
      $display( "Core %d: INS: %b", aluNum, a[31:26]);
      //d = 5'bz;
      d = 5'b0;
      //data = 32'bz;
      data = 32'b0;
      eno = en_reg & en_dec;
      pc = ipc;
      if(en_reg & en_dec)
      begin
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
               pc = ipc+4+4*a[15:0]+4*aluNum;
         end
         6'b100011: //lw $t = MEM[$s + offset];
         begin
         d = 5'bz;
         data = 32'bz;
         end
         /*begin
            d = r2;
            data = MEM[r1+a[15:0]]
         end*/
         6'b101011://sw MEM[$s + offset] = $t;
         begin
         d = 5'bz;
         data = 32'bz;
         end
         /*begin
            MEM[r1+a[15:0]] = r2;
         end*/
         6'b000011: //jal $31 = PC + 8; PC = (PC & 0xf0000000) | (target << 2)
         begin
            d = 31;
            data = ipc+8+4*aluNum;
            pc = ((ipc+4*aluNum) & 32'hF0000000) | (a[25:0] << 2);
         end
         default:
             $display( "ERROR: Unsupported opcode %b",a[31:26]);
      endcase
   end
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
