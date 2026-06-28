.data
    # Mensajes entrada
    msg_titulo:     .asciiz "Simulador de Fase de Grupos del Mundial\n"
    msg_ingreso:    .asciiz "Ingrese el nombre del pais: "
    
    msg_tabla_antes:    .asciiz "\n=============================================\n  TABLA DE POSICIONES (DESORDENADA)\n============================================="
    msg_tabla_despues:  .asciiz "\n=============================================\n  TABLA DE POSICIONES (ORDENADA)\n============================================="
    
    # Cabecera de la tabla y espaciadores de formato
    msg_header:         .asciiz "\nPos  Pais                 PTS  GF  GC  DG\n---------------------------------------------\n"
    sp_pos:             .asciiz "    "   # 4 espacios
    sp_pts:             .asciiz " "      # 1 espacio
    sp_gf:              .asciiz "    "   # 4 espacios
    sp_gc:              .asciiz "   "    # 3 espacios
    sp_dg:              .asciiz "   "    # 3 espacios
    
    .align 2
    
    # Arreglos paralelos
    nombres:        .space 80       # 4 equipos de 20 bytes cada uno
    puntos:         .word 0, 0, 0, 0
    goles_favor:    .word 0, 0, 0, 0
    goles_contra:   .word 0, 0, 0, 0
    dif_goles:      .word 0, 0, 0, 0
    
    # Mensajes varios
    msg_fase1:      .asciiz "\n--- Simulando Partidos ---\n"
    msg_fase2:      .asciiz "\n--- Tabla de Posiciones ---\n"
    msg_clasif:     .asciiz "\n--- Equipos Clasificados ---\n"
    nl:             .asciiz "\n"
    sep:            .asciiz " - "

.text
.globl main

main:
    # Imprimir titulo
    li $v0, 4
    la $a0, msg_titulo
    syscall

    # Llamar a funciones
    jal FaseIngreso
    jal FasePartidos
    
    li $v0, 4
    la $a0, msg_tabla_antes
    syscall
    jal MostrarTabla
    
    jal FaseBubbleSort
    
    li $v0, 4
    la $a0, msg_tabla_despues
    syscall
    jal MostrarTabla
    
    jal FaseClasificacion

    li $v0, 10
    syscall

FaseIngreso:
    li $t0, 0               
    la $t1, nombres         # Dirección base de nombres

loop_ingreso:
    beq $t0, 4, fin_ingreso # Si i == 4, salir

    li $v0, 4
    la $a0, msg_ingreso
    syscall

    # Leer string
    li $v0, 8
    move $a0, $t1           
    li $a1, 20
    syscall

    addi $t1, $t1, 20       # Avanzar al siguiente slot de 20 bytes
    addi $t0, $t0, 1
    j loop_ingreso

fin_ingreso:
    jr $ra


MostrarTabla:
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    li $v0, 4
    la $a0, msg_header
    syscall

    li $t0, 0
    
loop_tabla:
    beq $t0, 4, fin_tabla

    # Calcular offsets
    sll $t8, $t0, 2
    
    li $t7, 20
    mult $t0, $t7
    mflo $t1                # $t1 = i * 20
    la $t2, nombres
    add $t1, $t2, $t1       # $t1 = Dirección base del nombre del equipo actual

    # 1. Imprimir número de Posición (i + 1)
    addi $a0, $t0, 1
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, sp_pos
    syscall

    # 2. Imprimir Nombre con ancho fijo (20 caracteres) limpiando el '\n'
    move $t3, $t1           # $t3 = Puntero al carácter actual de la cadena
    li $t4, 0               # $t4 = Contador de caracteres impresos
    
print_char_loop:

    lb $t5, 0($t3)
    beq $t5, $zero, pad_spaces
    
    li $t7, 10
    beq $t5, $t7, pad_spaces
    
    # Imprimir el carácter válido
    li $v0, 11
    move $a0, $t5
    syscall
    
    addi $t3, $t3, 1
    addi $t4, $t4, 1
    j print_char_loop

pad_spaces:

    li $t7, 20
    bge $t4, $t7, fin_pad
    li $v0, 11
    li $a0, 32
    syscall
    addi $t4, $t4, 1
    j pad_spaces
    
fin_pad:

    # Espacio antes de la columna PTS para alineación exacta
    li $v0, 4
    la $a0, sp_pts
    syscall

    # 3. Imprimir PTS
    lw $a0, puntos($t8)
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, sp_gf
    syscall

    # 4. Imprimir GF
    lw $a0, goles_favor($t8)
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, sp_gc
    syscall

    # 5. Imprimir GC
    lw $a0, goles_contra($t8)
    li $v0, 1
    syscall
    
    li $v0, 4
    la $a0, sp_dg
    syscall

    # 6. Imprimir DG
    lw $a0, dif_goles($t8)
    li $v0, 1
    syscall

    li $v0, 4
    la $a0, nl
    syscall

    addi $t0, $t0, 1
    
    j loop_tabla

fin_tabla:
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra


FasePartidos:

    addi $sp, $sp, -4
    sw $ra, 0($sp)

    li $v0, 4
    la $a0, msg_fase1
    syscall

    # Jornada 1
    li $a2, 0          # 0 vs 1
    li $a3, 1
    jal Jugar_Partido

    li $a2, 2          # 2 vs 3
    li $a3, 3
    jal Jugar_Partido

    # Jornada 2
    li $a2, 0          # 0 vs 2
    li $a3, 2
    jal Jugar_Partido

    li $a2, 1          # 1 vs 3
    li $a3, 3
    jal Jugar_Partido

    # Jornada 3
    li $a2, 0          # 0 vs 3
    li $a3, 3
    jal Jugar_Partido

    li $a2, 1          # 1 vs 2
    li $a3, 2
    jal Jugar_Partido

    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

Jugar_Partido:
    # Calcular offsets para arreglos de enteros (Indice * 4)
    sll $t8, $a2, 2     # A
    sll $t9, $a3, 2     # B

    # Generar Goles Equipo A ($t0)
    li $v0, 42
    li $a0, 0
    li $a1, 6
    syscall
    move $t0, $a0

    # Generar Goles Equipo B ($t1)
    li $v0, 42
    li $a0, 0
    li $a1, 6
    syscall
    move $t1, $a0

    # Actualizar GF
    lw $t2, goles_favor($t8)
    add $t2, $t2, $t0
    sw $t2, goles_favor($t8)

    lw $t2, goles_favor($t9)
    add $t2, $t2, $t1
    sw $t2, goles_favor($t9)

    # Actualizar GC
    lw $t2, goles_contra($t8)
    add $t2, $t2, $t1
    sw $t2, goles_contra($t8)

    lw $t2, goles_contra($t9)
    add $t2, $t2, $t0
    sw $t2, goles_contra($t9)

    #Actualizar Diferencia de Goles
    lw $t2, goles_favor($t8)
    lw $t3, goles_contra($t8)
    sub $t4, $t2, $t3
    sw $t4, dif_goles($t8)

    lw $t2, goles_favor($t9)
    lw $t3, goles_contra($t9)
    sub $t4, $t2, $t3
    sw $t4, dif_goles($t9)

    # Lógica de Puntos FIFA
    # Si A > B -> A gana (3 pts)
    # Si B > A -> B gana (3 pts)
    # Si A == B -> Empate (1 pt cada uno)
    
    beq $t0, $t1, Empate
    bgt $t0, $t1, GanaA

    # Gana B
    lw $t2, puntos($t9)
    addi $t2, $t2, 3
    sw $t2, puntos($t9)
    jr $ra

GanaA:
    lw $t2, puntos($t8)
    addi $t2, $t2, 3
    sw $t2, puntos($t8)
    jr $ra

Empate:
    lw $t2, puntos($t8)
    addi $t2, $t2, 1
    sw $t2, puntos($t8)

    lw $t2, puntos($t9)
    addi $t2, $t2, 1
    sw $t2, puntos($t9)
    jr $ra


FaseBubbleSort:
    
    li $t0, 0

loopI:

    li $t1, 0               # j = 0
    li $t2, 3               # Límite n-1
    sub $t2, $t2, $t0       # 3 - i
    blez $t2, end_sort      # Si límite <= 0, salir

loopJ:

    sll $s0, $t1, 2         # $s0 = offset j
    addi $s1, $s0, 4        # $s1 = offset j+1

    # 1. Comparar puntos
    lw $t3, puntos($s0)
    lw $t4, puntos($s1)
    
    blt $t3, $t4, do_swap   # Si puntos(j) < puntos(j+1), intercambiar
    bgt $t3, $t4, no_swap

    # 2. Desempate
    lw $t3, dif_goles($s0)
    lw $t4, dif_goles($s1)
    
    blt $t3, $t4, do_swap
    bgt $t3, $t4, no_swap

    # 3. Desempate
    lw $t3, goles_favor($s0)
    lw $t4, goles_favor($s1)
    
    blt $t3, $t4, do_swap
    j no_swap               # Si todo es igual, no intercambiar

do_swap:

    lw $t8, puntos($s0)
    lw $t9, puntos($s1)
    sw $t9, puntos($s0)
    sw $t8, puntos($s1)


    lw $t8, goles_favor($s0)
    lw $t9, goles_favor($s1)
    sw $t9, goles_favor($s0)
    sw $t8, goles_favor($s1)

    lw $t8, goles_contra($s0)
    lw $t9, goles_contra($s1)
    sw $t9, goles_contra($s0)
    sw $t8, goles_contra($s1)

    lw $t8, dif_goles($s0)
    lw $t9, dif_goles($s1)
    sw $t9, dif_goles($s0)
    sw $t8, dif_goles($s1)

    # Intercambiar Strings
    # Offsets de string
    mul $s2, $t1, 20        # Dirección base string j
    addi $s3, $s2, 20       # Dirección base string j+1
    
    li $t7, 0               # Contador para mover 5 palabras (5 * 4 = 20 bytes)

swap_str_loop:

    lw $t8, nombres($s2)
    lw $t9, nombres($s3)
    sw $t9, nombres($s2)
    sw $t8, nombres($s3)

    addi $s2, $s2, 4
    addi $s3, $s3, 4
    addi $t7, $t7, 1
    blt $t7, 5, swap_str_loop

no_swap:

    addi $t1, $t1, 1
    blt $t1, $t2, loopJ

    addi $t0, $t0, 1
    j loopI

end_sort:

    jr $ra


FaseClasificacion:
    # Mostrar por pantalla los equipos que clasifican
    li $v0, 4
    la $a0, msg_clasif
    syscall

    # Imprimir el equipo clasificado 1
    la $a0, nombres
    li $v0, 4
    syscall

    # Imprimir el equipo clasificado 2
    la $a0, nombres
    addi $a0, $a0, 20
    li $v0, 4
    syscall

    jr $ra
