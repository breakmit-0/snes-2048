
;cimpelemnts a randomizer,
; stolen from super mario world


ROUTINE.get_rand:
    phy
    
    ldy #$01
    jsl .tickRNG
    
    dey
    jsl .tickRNG
    
    ply
rtl


.tickRNG
    lda !RAND_seed_lo
    asl #2

    sec
    adc !RAND_seed_lo
    sta !RAND_seed_lo

    asl !RAND_seed_hi
    lda #$20
    bit !RAND_seed_hi

    bcc ..option1
    beq ..skip
    bne ..option2

..option1
    bne ..skip

..option2
    inc !RAND_seed_hi

..skip
    lda !RAND_seed_hi
    eor !RAND_seed_lo

    ;cant adress dp,y
    sta.w !RAND_out_lo,y
rtl