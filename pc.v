module pc(
   input [31:0] pc, jmpaddr,
   input clk, alu2_en, jumpen, rst,
   output reg[31:0] outputpc);

   initial outputpc = 0;

   always @ (posedge clk)
   begin

      //TODO : mozna dodelat ifelse na alu2en
//      if(alu2_en == 1)
   if(rst == 0)
      if (jumpen == 1)
         #1 outputpc = jmpaddr;
      else
         #1 outputpc = pc+2;
   else
      outputpc = pc;
   end
endmodule


//TODO :   readmemh doesnt work
module imem (input [31:0] pcaddr,
   input clk,
   output reg [31:0] e, f, opcaddr);

   reg [31:0] RAM[4095:0];

   initial  $readmemh ("ins2",RAM);
   always @ (*)
   begin
//   if(rst == 0)
  // begin
      #1 e = RAM[pcaddr];
      f = RAM[pcaddr+1];
      opcaddr = pcaddr;
   end
   //else
     // opcaddr = 32'bz;
   //end
endmodule

module dmem (input [31:0] a, b,
   input clk,
   input [31:0] r1, r2, r3,
   input [31:0] r21, r22, r23,
   output reg [4:0] e, f,
   output reg [31:0] data1, data2);

   initial  $readmemh ("data",MEM);
   reg [31:0] MEM[4095:0];

   initial e = 5'b0;
   initial f = 5'b0;
   initial data1 = 32'b0;
   initial data2 = 32'b0;

   //TODO : compiler by nemel udelat, ze nacte za sebou na stejnou addr a testuji to regs
   always @ (posedge clk)
   begin
      $display( "DataMEM:  %x, %x",a,b);
      #1 e = 5'b0;
      f = 5'b0;
      data1 = 32'b0;
      data2 = 32'b0;
      case(a[31:26])
         6'b100011: //lw $t = MEM[$s + offset];
         begin
            e = a[20:16];
            data1 = MEM[r1+a[15:0]];
         end
         6'b101011: //sw MEM[$s + offset] = $t;
            MEM[r1+a[15:0]] = r2;
         default:
            e = 32'b0;
     endcase
      case(b[31:26])
         6'b100011: //lw $t = MEM[$s + offset];
         begin
            f = b[20:16];
            data2 = MEM[r1+b[15:0]];
         end
         6'b101011: //sw MEM[$s + offset] = $t;
            MEM[r1+b[15:0]] = r2;
         default:
            f = 32'b0;
     endcase
  end
   //assign e <= {MEM[addr],MEM[addr-1], MEM[addr-2], MEM[addr-3]};
   //assign f <= {MEM[addr2],MEM[addr2-1], MEM[addr2-2], MEM[addr2-3]};
endmodule
module regs(
      input clk,
      input [31:0] ins1, ins2, w1, w2, w3, w4,
      input [4:0] w1addr, w2addr, w3addr, w4addr,
      input alu2_dec,
      output reg alu2_en,
      output reg [31:0] a1, a2, a3, b1, b2, b3, inso1, inso2,
      input [31:0] ipc, output reg [31:0] opc);


   reg [31:0] regs[31:0];
   initial alu2_en = 0;
   initial regs[9] = 32'b1;
   initial regs[8] = 32'b1;
   initial regs[10] = 32'b111;
   initial regs[11] = 32'b0;


   //hazard
   always @ (w1, w2, w1addr, w2addr  )
   begin
      #1 regs[w1addr] = w1;
      $display( "Write 1: addr %d: val: %b", w1addr, w1);
      regs[w2addr] = w2;
      regs[w3addr] = w3;
      regs[w4addr] = w4;
      regs[0] = 32'b0;
   end

   always @ (posedge clk)
   begin
      opc = ipc;
      alu2_en = alu2_dec;
      inso1 = ins1;
      inso2 = ins2;
//WriteEnable?
//      regs[w1addr] = w1;
//      regs[w2addr] = w2;
//      regs[0] = 32'b0;
//   end
//   always @ (*)
//   begin
      a1 = regs[ins1[25:21]];
      a2 = regs[ins1[20:16]];
      a3 = regs[ins1[15:11]];
      b1 = regs[ins2[25:21]];
      b2 = regs[ins2[20:16]];
      b3 = regs[ins2[15:11]];
   end
endmodule

module dec(input [31:0] inst1, inst2,
      input clk,rst, waitpcin,
      output reg en_alu2, waitpc,
      output reg [31:0] e, f,
      input [31:0] ipc, output reg [31:0] opc);

   initial en_alu2 = 0;
   reg [31:0] buffer [31:0];
   reg [31:0] pcbuffer [31:0];
   reg [31:0] i1, i2;
   reg [31:0] pbufferlast;
   reg [31:0] sum;
   reg [31:0] pbuffernext;
   initial sum = 5'b0;
   initial pbuffernext = 0;
   initial pbufferlast = 0;
   initial waitpc = 0;

   always @ (rst)
   begin
      e = 32'b0;
      f = 32'b0;
      en_alu2 = 0;
      opc = 32'bz;
      sum = 0;
      pbufferlast = 0;
      pbuffernext = 0;
   end

   always @ (posedge clk)
      begin
         #1 i1 = inst1;
            i2 = inst2;
         opc = ipc;
         
         if(waitpcin == 0)
         begin
         buffer[pbufferlast] = i1;
         pbufferlast = pbufferlast+1;
         buffer[pbufferlast] = i2;
         pbufferlast = pbufferlast+1;
         sum = sum + 2;
         end
         waitpc = 0;
         if (sum >= 6)
           waitpc = 1;
        if (sum == 3)
           waitpc = 0;


         en_alu2 = 1;

         if(buffer[pbuffernext][31:26] == 6'b0 && buffer[pbuffernext][5:0] == 6'b001000)
            en_alu2 = 0;
         if(buffer[pbuffernext][31:26] == 6'b000011)
            en_alu2 = 0;
         if(buffer[pbuffernext][31:26] == 6'b000100)
            en_alu2 = 0;
         if(buffer[pbuffernext][31:26] == 6'b001000)
            en_alu2 = 0;
         //datahazard
         if ( buffer[pbuffernext][15:11]== buffer[pbuffernext-1][25:21] || buffer[pbuffernext][15:11] == buffer[pbuffernext-1][20:16] || buffer[pbuffernext][15:11] ==  buffer[pbuffernext-1][15:11] || buffer[pbuffernext][15:11] == 31)
            en_alu2 = 0;
         else
            en_alu2 = 1&en_alu2;


         e = buffer[pbuffernext];
         pbuffernext = pbuffernext + 1;
         sum = sum - 1;

         if(buffer[pbuffernext][31:26] == 6'b0 && buffer[pbuffernext][5:0] == 6'b001000)
            en_alu2 = 0;
         if(buffer[pbuffernext][31:26] == 6'b000011)
            en_alu2 = 0;
         if(buffer[pbuffernext][31:26] == 6'b000100)
            en_alu2 = 0;
         if(buffer[pbuffernext][31:26] == 6'b001000)
            en_alu2 = 0;

         if (en_alu2 == 1)
         begin
         f = buffer[pbuffernext];
         pbuffernext = pbuffernext + 1;
         sum = sum - 1;
         end
         else
            f = 32'b0;
      end
endmodule




module alu(input aluNum,
         input [31:0] a, ipc,
         input [31:0] r1, r2, r3,
         input clk, en,
         output reg [4:0] d,
         output reg [31:0] pc,
         output reg [31:0] data,
      output reg /*eno,*/ jmp);

   initial pc = 0;
   initial jmp = 1'b0;

   always @ (posedge clk)
   begin
      $display( "Core %d: INS: %b", aluNum, a[31:26]);
      #1 d = 5'b0;
      jmp = 1'b0;
      data = 32'b0;
      # 1 pc = ipc;
      if(en)
      begin
      case(a[31:26])
         6'b0:
            begin //mat + jump
            case(a[5:0])
               6'b100000: //add $3 = $1 + $2;
               begin
                  data = r1+r2;
                  d = a[15:11];
               end
               6'b100100: //and $d = $s & $t;
               begin
                  data = r1&r2;
                  d = a[15:11];
               end
               6'b100101: //or
               begin
                  data = r1|r2;
                  d = a[15:11];
               end
               6'b101010: //slt if $s < $t $d = 1; else $d = 0;
               begin
                  if (r1 < r2)
                     data = 1;
                  else
                     data = 0;
                  d = a[15:11];
               end
               6'b100010: //sub
               begin
                  data = r1-r2;
                  d = a[15:11];
               end
               6'b001000: //jr goto s; jen $1
               begin
                   pc = r1;
                   jmp = 1;
               end
               default:
                  $display( "ERROR: R instruction using unsupported function %b",a[5:0]);
            endcase
            end
         6'b001000: //addi Adds a register and a sign-extended immediate value and stores the result in a register  Operation: $t = $s + imm;
         begin
            data = r1 + a[15:0];
            d = a[20:16];
         end
         6'b000100: //beq if $s == $t go to PC+4+4*offset; else go to PC+4
         begin
            if(r1 == r2)
            begin
               pc = ipc+1+1*a[15:0]+1*aluNum;
               jmp = 1;
            end
         end
         6'b100011: //lw $t = MEM[$s + offset];
         begin
         d = 5'b0;
         data = 32'b0;
         end
         /*begin/
            d = r2;
            data = MEM[r1+a[15:0]]
         end*/
         6'b101011://sw MEM[$s + offset] = $t;
         begin
         d = 5'b0;
         data = 32'b0;
         end
         /*begin
            MEM[r1+a[15:0]] = r2;
         end*/
         6'b000011: //jal $31 = PC + 8; PC = (PC & 0xf0000000) | (target << 2)
         begin
            d = 31;
            data = ipc+8+4*aluNum;
            pc = ((ipc+4*aluNum) & 32'hF0000000) | (a[25:0] << 2);
            jmp = 1;
         end
         default:
             $display( "ERROR: Unsupported opcode %b",a[31:26]);
      endcase
   end
   end
endmodule
