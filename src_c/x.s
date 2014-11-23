addi $4, $0, 5       #int a = 5;
addi $5, $0, 4       #int b = 4;
addi $6, $0, 3       #int c = 3;
addi $7, $0, 5       #param
addi $29, $0, 200    #$sp = 200
addi $8, $0, 10
sw $8 , 0($29)
addi $29, $29, 1    #sp++
jal siple
nop

addi $5, $0, 0
jal fun
nop

add $8, $3, $2

while:
   j while
nop

fun:
   add $5, $4, $5
   addi $4, $4, -1
   beq $4, $0, funend
   addi $11, $0, -4
   jr $11
   nop
funend:
   addi $3, $5, 1
   j $31
   nop

siple:
   addi $10, $0, 7
   add $9, $4, $5
   add $9, $9, $6
   add $9, $9, $7
   #lw from stack
   addi $29, $29, -1
   lw $8, 0($29)
   sub $9, $9, $8
   and $2, $9, $10
   j $31
   nop
