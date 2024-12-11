

!merged_t2 = $02
!merged_t3 = $03
macro do_move(tile0, tile1, tile2, tile3, line_dx)
    
    ;4 lines or columns, <line_dx> apart in memory,
    ;each made of 4 tiles

    ldx #$00

    ;has a merged tile registers
?loop:
    stz !merged_t2
    stz !merged_t3

?.tile2
    lda <tile2>,x
    beq ?.tile1

    cmp <tile3>,x
    bne ?..different

    ;...if tile not merged
    lda !merged_t3
    bne ?.tile1

    ;same tiles, increment
    stz <tile2>,x
    lda <tile3>,x
    inc A
    sta <tile3>,x

    ;and update scores
    sta $00
    jsl ROUTINE.update_score
    
    ;and disable further merging
    inc !merged_t3

    jmp ?.tile1

?..different

    ;different tiles, shift if possible
    lda <tile3>,x
    bne ?.tile1

    lda <tile2>,x
    sta <tile3>,x
    stz <tile2>,x

?.tile1
    
    lda <tile1>,x
    beq ?.tile0

    cmp <tile2>,x
    bne ?..different

    ;..if not merged
    lda !merged_t2
    bne ?.tile0

    ;increment and handle incremented tile
    stz <tile1>,x
    lda <tile2>,x
    inc A
    sta <tile2>,x

    ;and update score
    sta $00
    jsl ROUTINE.update_score

    ;incremented tile cannot merge, just move it while possible
    lda <tile3>,x
    bne ?..end_move_t2

    ; 2 -> 3
    lda <tile2>,x
    sta <tile3>,x
    stz <tile2>,x
    
    inc !merged_t3

    jmp ?.tile0

?..end_move_t2
    inc !merged_t2
    jmp ?.tile0

?..different

    ;shift if possible
    lda <tile2>,x
    bne ?.tile0 

    lda <tile1>,x
    sta <tile2>,x
    stz <tile1>,x

    jmp ?.tile2

?.tile0

    lda <tile0>,x
    beq ?.end

    cmp <tile1>,x
    bne ?..different

    ;increment and handle incremented tile
    stz <tile0>,x
    lda <tile1>,x
    inc A
    sta <tile1>,x

    ;and update score
    sta $00
    jsl ROUTINE.update_score

    ;just shift while possible
    lda <tile2>,x
    bne ?.end

    lda <tile1>,x
    sta <tile2>,x
    stz <tile1>,x

    lda <tile3>,x
    bne ?.end

    sta <tile3>,x
    stz <tile2>,x

    jmp ?.end

?..different

    ;shift if possible and handle next tile

    lda <tile1>,x
    bne ?.end

    lda <tile0>,x
    sta <tile1>,x
    stz <tile0>,x

    jmp ?.tile1

?.end

    inx #<line_dx>
    cpx #4*<line_dx>
    bne ?loop_return
    bra ?end

?loop_return:
    jmp ?loop

?end:
endmacro