main:
	addi  $2,$0, 5       # 0x5
	sw    $2,32($fp)
	addi  $2,$0, 4       # 0x4
	sw    $2,36($fp)
	addi  $2,$0, 3       # 0x3
	sw    $2,40($fp)
	lw    $4,32($fp)     #main args
	jal   fun

	addi  $16,$2, 0
	li    $2,10			# 0xa
	sw    $2,16($sp)
	lw    $4,32($fp)
	lw    $5,36($fp)
	lw    $6,40($fp)
	addi  $7, $0, 5			# 0x5
	jal   simple

	addu  $2,$16,$2
	sw    $2,36($fp)
$L2:
	j	$L2

fun:
	addi  $sp,$sp,-32
	sw    $31,28($sp)
	sw    $fp,24($sp)
	addi  $fp,$sp, 0
	sw    $4,32($fp)
	lw    $2,32($fp)
	bne   $2,$0,$L4

	addi  $2, $0, 1       # 0x1
	j     $L5

$L4:
	lw    $2,32($fp)
	addiu $2,$2,-1
	move  $4,$2
	jal   fun

	addi  $3, $2, 0
	lw    $2,32($fp)
	add   $2,$3,$2
$L5:
	move  $sp,$fp
	lw    $31,28($sp)
	lw    $fp,24($sp)
	addi  $sp,$sp,32
	j     $31

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
	add   $3,$3,$2
	lw    $2,32($fp)
	add   $2,$3,$2
	sw    $2, 8($fp)
	lw    $3, 36($fp)
	lw    $2, 40($fp)
	sub   $2, $3, $2
	sw    $2, 12($fp)
	lw    $3, 8($fp)
	lw    $2, 12($fp)
	add   $2, $3, $2
	sw    $2, 8($fp)
	lw    $2, 8($fp)
	and  $2, $2, 0x7
	sw   $2, 8($fp)
	lw   $2, 8($fp)
	addi $sp, $fp, 0
	lw   $fp, 20($sp)
	addi $sp, $sp, 24
	j    $31
