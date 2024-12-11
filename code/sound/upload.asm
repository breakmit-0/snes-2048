;routine to upload a block of data to the APU

; $00-$02 => 24bit adress of code in RAM/ROM
; $03-$04 => 16bit destination in ARAM
; $05-$06 => 16bit block size
; $07     => 1bit  of scratch RAM

APU_UPLOAD:
    phy
    ;wait until the spc is in boot ROM
.waitSPC_1
    lda $2140
    cmp #$AA
    bne .waitSPC_1

    lda $2141
    cmp #$BB
    bne .waitSPC_1


    lda !apu_target_lo
    sta $2142
    lda !apu_target_hi
    sta $2143

    ;non zero => sending data 
    lda #$01
    sta $2141
    lda #$CC
    sta $2140

.waitSPC_2
    lda $2140
    cmp #$CC
    bne .waitSPC_2


    ;start sending data
    rep #$10

    ;use y as an index because only 'lda [dp],y' exists
    ldy #$0000

.data_loop
    ;send byte
    lda [!apu_src],y
    sta $2141

    ;send ready signal
    tya
    sta $2140
    sta !apu_ack_mem 

    ;wait until byte is processed
.waitACK
    lda $2140
    cmp !apu_ack_mem
    bne .waitACK

    iny

    ;exit condition
    cpy !apu_size
    beq .loop_end

    bra .data_loop

.loop_end

    lda #$FF
    sta $2143
    lda #$C0
    sta $2142

    lda #$00
    sta $2141

    ;send end signal
    iny
    tya
    sta $2140
    ;dont bother waiting for ack
    sep #$10
    ply
rtl


;jump to a location in ARAM
;
; $03-$04 : 16bit adress to go to
;
APU_RUN:
    ;wait until the spc is in boot ROM
.waitSPC_1

    lda $2140
    cmp #$AA
    bne .waitSPC_1

    lda $2141
    cmp #$BB
    bne .waitSPC_1

    lda !apu_target_lo
    sta $2142
    lda !apu_target_hi
    sta $2143

    lda #$00
    sta $2141
    lda #$CC
    sta $2140

-   lda $2140
    cmp #$CC
    bne -
rtl



;A = reg #
;X = value
APU_send_reg:
    ;data
    sta $2140
    stx $2141
    lda #$03
    sta $2142

    ;signal
    lda $2143
    sta $2143
    sta $00

    ; wait for ack: wait until $2143
    ; is no longer what we wrote
.wait
    lda $2143
    cmp $00
    beq .wait 
rtl