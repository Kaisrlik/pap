main:
	addi  $2,$0, 5       # 0x5
	addi  $2,$0, 4       # 0x4
	addi  $2,$0, 3       # 0x3
	jal   fun
	nop

	addi  $16,$2, 0
	addi  $2, $0, 10          # 0xa
	sw    $2,16($sp)
	lw    $4,32($fp)
	lw    $5,36($fp)
	lw    $6,40($fp)
	addi  $7, $0, 5			# 0x5
	jal   simple
	nop

	addu  $2,$16,$2
	sw    $2,36($fp)
$L2:
	j	$L2
	nop

fun:
	beq   $2,$0,$L4
	nop

	addi  $2, $0, 1       # 0x1
	j     $L5
	nop

$L4:
	lw    $2,32($fp)
	nop
	addiu $2,$2,-1
	move  $4,$2
	jal   fun
	nop

	addi  $3, $2, 0
	lw    $2,32($fp)
	nop
	add   $2,$3,$2
$L5:
	j     $31
	nop

simple:
	addi  $sp,$sp,-24
	sw    $fp,20($sp)
	addi  $fp, $sp, 0
	sw    $4,24($fp)
	sw    $5,28($fp)
	sw    $6,32($fp)
	sw    $7,36($fp)
	lw    $3,24($fp)
	lw    $2,28($fp)
	nop
	add   $3,$3,$2
	lw    $2,32($fp)
	nop
	add   $2,$3,$2
	sw    $2, 8($fp)
	lw    $3, 36($fp)
	lw    $2, 40($fp)
	nop
	sub   $2, $3, $2
	sw    $2, 12($fp)
	lw    $3, 8($fp)
	lw    $2, 12($fp)
	nop
	add   $2, $3, $2
	sw    $2, 8($fp)
	lw    $2, 8($fp)
	nop
	and  $2, $2, 0x7
	sw   $2, 8($fp)
	lw   $2, 8($fp)
	addi $sp, $fp, 0
	lw   $fp, 20($sp)
	addi $sp, $sp, 24
	j    $31
	nop
