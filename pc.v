/*
* http://ifire.cz/tst/mips.php
*/

module pc(
   input [31:0] pc, jmpaddr,
   input clk, alu2_en, jumpen, rst,
   output reg[31:0] outputpc);

   initial outputpc = 0;

   always @ (posedge clk, jumpen)
   begin

   if(rst == 0)
   begin
      if (jumpen == 1)
         #1 outputpc = jmpaddr;
      else
         #1 outputpc = pc+2;
   end
   else
      outputpc = pc;
   if (jumpen == 1)
      #1 outputpc = jmpaddr;
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
   input clk, alu2_en,
   input [31:0] r1, r2,
   input [31:0] r21, r22,
   output reg [4:0] e, f,
   output reg [31:0] data1, data2);

   initial  $readmemh ("data",MEM);
   reg [31:0] MEM[4095:0];
   reg [31:0] daddr1;
   reg [31:0] daddr2;
   reg [31:0] temp;

   initial e = 5'b0;
   initial f = 5'b0;
   initial data1 = 32'b0;
   initial data2 = 32'b0;


   //TODO : compiler by nemel udelat, ze nacte za sebou na stejnou addr a testuji to regs
   always @ (posedge clk)
   begin
//      $display( "DataMEM:  %x, %x",a,b);
      #1 e = 5'b0;
      f = 5'b0;
      data1 = 32'b0;
      data2 = 32'b0;
      daddr1 = a[15:0]+r1;
      daddr2 = a[15:0]+r21;
      case(a[31:26])
         6'b100011: //lw $t = MEM[$s + offset];
         begin
            if(a[15] == 1)
               temp = 32'hFFFF0000;
            else
               temp = 32'h0;
            temp[15:0] = a[15:0];
            e = a[20:16];
            data1 = MEM[r1+temp];
      $display("lw: $t = MEM[$s + offset] addr=%x, %x = MEM[%x+%x]",e,data1,r1,temp);
         end
         6'b101011: //sw MEM[$s + offset] = $t;
            begin
               if(a[15] == 1)
                  temp = 32'hFFFF0000;
               else
                  temp = 32'h0;
               temp[15:0] = a[15:0];
               temp = temp+r1;
               MEM[temp] = r2;
               $display( "SW1:MEM[$s+offset]=$t:MEM[$%x+off]=$%x MEM[%x]=%x",a[25:21],a[20:16],temp,r2);
            end
         default:
            e = 32'b0;
     endcase
     if(alu2_en)
     begin
      case(b[31:26])
         6'b100011: //lw $t = MEM[$s + offset];
         begin
            if(b[15] == 1)
               temp = 32'hFFFF0000;
            else
               temp = 32'h0;
            temp[15:0] = b[15:0];
            f = b[20:16];
            temp = temp + r21;
      $display("lw2: $t = MEM[$s + offset] addr=%x, %x = MEM[%x+%x]",f,data2,r21,temp);
         end
         6'b101011: //sw MEM[$s + offset] = $t;
            begin
            if(b[15] == 1)
               temp = 32'hFFFF0000;
            else
               temp = 32'h0;
            temp[15:0] = b[15:0];
            MEM[r21+temp] = r22;
               $display( "SW2:MEM[$s+offset]=$t:MEM[$%x+off]=$%x MEM[%x+%x]=%x", b[25:21], b[20:16], r21, temp, r22);
            end
            default:
            f = 32'b0;
         endcase
      end
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
   always @ (w1, w1addr)
   begin
      #1 regs[w1addr] = w1;
      if(w1addr != 0)$display( "Write1: addr %x: val: %x", w1addr, w1);
      regs[0] = 32'b0;
   end
   always @ (w2, w2addr)
   begin
      #1 regs[w2addr] = w2;
      if(w2addr != 0)$display( "Write2: addr %x: val: %x", w2addr, w2);
      regs[0] = 32'b0;
   end
   always @ (w3, w3addr)
   begin
      #1 regs[w3addr] = w3;
      if(w3addr != 0)$display( "Write3: addr %x: val: %x", w3addr, w3);
      regs[0] = 32'b0;
   end
   always @ (w4, w4addr)
   begin
      #1 regs[w4addr] = w4;
      if(w4addr != 0)$display( "Write4: addr %x: val: %x", w4addr, w4);
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
   reg [31:0] buffer [500:0];
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

//if buffer is full this function doing smthg really wrong! TODO:call rst if buffer is full or do better check

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
         //jmp
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

         if(buffer[pbuffernext][31:26] == 6'b101011)
            en_alu2 = 0;
         if(buffer[pbuffernext][31:26] == 6'b100011)
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
   reg [31:0] temp;

   always @ (posedge clk)
   begin
//      $display( "Core %d: INS: %b", aluNum, a[31:26]);
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
                  $display( "ADD: $%x+$%x dest$%x -- d: %x=%x+%x", a[25:21], a[20:16], a[15:11], data, r1, r2);
                  d = a[15:11];
               end
               6'b100100: //and $d = $s & $t;
               begin
                  data = r1&r2;
                  $display( "AND: %x %x %x -- d: %x=%x&%x",  a[25:21], a[20:16], a[15:11], data, r1, r2);
                  d = a[15:11];
               end
               6'b100101: //or
               begin
                  data = r1|r2;
                  $display( "OR: %x %x %x -- d: %x=%x|%x",  a[25:21], a[20:16], a[15:11], data, r1, r2);
                  d = a[15:11];
               end
               6'b101010: //slt if $s < $t $d = 1; else $d = 0;
               begin
                  if (r1 < r2)
                     data = 1;
                  else
                     data = 0;
                  $display( "slt: %x %x %x -- d: %x=%x<%x",  a[25:21], a[20:16],  a[15:11], data, r1, r2);
                  d = a[15:11];
               end
               6'b100010: //sub
               begin
                  data = r1-r2;
                  $display( "sub: %x %x %x -- d: %x=%x-%x",  a[25:21], a[20:16],  a[15:11], data, r1, r2);
                  d = a[15:11];
               end
               6'b001000: //jr goto s; jen $1
               begin
                   pc = r1;
                  $display( "jr:$x pc: %x", a[25:21], pc);
                  jmp = 1;
               end
               6'b0:
                  $display("NOP");

               default:
                  $display( "ERROR: R instruction using unsupported function %b",a[5:0]);
            endcase
            end
         6'b001000: //addi Adds a register and a sign-extended immediate value and stores the result in a register  Operation: $t = $s + imm;
         begin
            if(a[15] == 1)
               temp = 32'hFFFF0000;
            else
               temp = 32'h0;
            temp[15:0] = a[15:0];
            data = r1 + temp;
            d = a[20:16];
        $display( "addi%d: $t=$s+imm : %x=%x+i %x=%x+%x",aluNum,a[20:16], a[25:21], data, r1, a[15:0]) ;
         end
         6'b000100: //beq if $s == $t go to PC+4+4*offset; else go to PC+4
         begin
            if(r1 == r2)
            begin
               if(a[15] == 1)
                  temp = 32'hFFFF0000;
               else
                  temp = 32'h0;
               temp[15:0] = a[15:0];
               pc = ipc+1+temp+1*aluNum;
               $display("ibeq: if(%x==%x) %x (%x + %x + 1 * %x)", a[25:21], a[20:16], pc, ipc, temp, aluNum);
              jmp = 1;
            end
            //TODO: ELSE neni => branchprediction !!! :D
         end
         6'b100011: //lw $t = MEM[$s + offset];
         begin
         d = 5'b0;
         data = 32'b0;
  //           $display("LW");
         end
         /*begin/
            d = r2;
            data = MEM[r1+a[15:0]]
         end*/
         6'b101011://sw MEM[$s + offset] = $t;
         begin
         d = 5'b0;
         data = 32'b0;
//             $display("SW");
         end
         /*begin
            MEM[r1+a[15:0]] = r2;
         end*/
         6'b000011: //jal $31 = PC + 8; PC = (PC & 0xf0000000) | (target << 2)
         begin
            d = 31;//TODO target is sign?
            data = ipc+2+1*aluNum;
            pc = ((ipc+1*aluNum) & 32'hF0000000) | (a[25:0] );// << 2); //TODO shift of
            $display("jal PC=%x=(%x & 0xf0000000)|(%x << 2>>2) $%x=%x", pc,ipc, a[25:0], d,data);
           jmp = 1;
         end
         default:
             $display( "ERROR: Unsupported opcode %b",a[31:26]);
      endcase
   end
   end
endmodule
