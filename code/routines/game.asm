


; set the OAM tile values correctly
;
;
;
bank $80
ROUTINE.updateOAM:
    ; no sprite for empty
    cpy #$00
    beq .end


.end
rtl


ROUTINE.setupOAM:

    lda #$28
    sta $00
    sta $01

    ldx #$00
.loop1

    lda $00
    sta mirrorOAM.posx,x
    lda $01
    sta mirrorOAM.posy,x
    lda #$00
    sta mirrorOAM.tile,x
    lda #%00110000
    sta mirrorOAM.prop,x

    ;change coordinates
    txa
    and #$0C
    cmp #$0C
    beq .incy
.incx
    lda $00
    clc : adc #$30
    sta $00
    bra .skip
.incy
    lda $01
    clc : adc #$30
    sta $01
    lda #$28
    sta $00
.skip
    inx #4
    cpx #$40
    bne .loop1

    lda #%10101010

    ldx #$00
.loop2

    sta !OAM_ex,x

    inx
    cpx #$04
    bne .loop2
rtl




ROUTINE.read_input:
    ;(A X L R) changed this frame
    lda !INPUT_lo
    eor !input1_held
    sta !input1_changed

    ;(B Y START SEL DPAD) changed this frame
    lda !INPUT_hi
    eor !input2_held
    sta !input2_changed

    lda !INPUT_lo
    sta !input1_held

    lda !INPUT_hi
    sta !input2_held
rtl


;update the 16 main sprites
ROUTINE.update_sprites:

    ; apply the code to every table index

    ; a compile loop rather than code loop
    ; because y cant index 24bit

    !index = 0
    while !index < 16

        ldx table(0, !index)

        ;update graphics
        lda .gfx_index,x
        sta mirrorOAM[!index].tile

        ;update palette
        lda mirrorOAM[!index].prop
        and #%11110001
        ora .pal_index,x
        sta mirrorOAM[!index].prop

        !index #= !index+1
    endif
rtl

.gfx_index
db $00, $04, $08, $0C, $40, $44, $48, $4C
db $80, $84, $88, $8C, $C0, $C4, $C8, $CC

.pal_index
db $00, $02, $04, $06, $08, $0A, $0C, $0E
db $00, $02, $04, $06, $08, $0A, $0C, $0E





ROUTINE.moved:

    ;detect if the game is won or lost
.detect_end
    inc !lost_flag
    stz !won_flag
    ldx #$00

..loop
    lda table(0,0),x
    
    cmp #$00
    bne +
    ;not lost
    stz !lost_flag
+   
    cmp #$0B
    bne +
    ;won
    lda !endgame
    bne +
    inc !won_flag
    lda #$02
    sta !game_mode
+
    inx
    cpx #$10
    bne ..loop

    lda !lost_flag
    beq .retry

    ;unset the lost flag if there is a legal move
    jsl ROUTINE.detect_lost

    lda !lost_flag
    beq .end

    jml ROUTINE.lose

.retry
    jsl ROUTINE.get_rand

    lda !RAND_out_lo
    and #$0F
    tax

    lda table(0,0),x
    bne .retry

.new_tile
    lda !RAND_out_hi
    and #$01
    inc A

    sta table(0,0),x 
.end
rtl


;nothing for now, always lose
ROUTINE.detect_lost:

    ;first, check vertical
    ldx #$00

.vloop
    lda table(0,0),x
    cmp table(1,0),x
    beq .not_lost

    inx
    cpx #$0C
    bne .vloop


    ;then, horizontal
    ldx #$00

.hloop
    lda table(0,1),x
    cmp table(0,0),x
    beq .not_lost

    cmp table(0,2),x
    beq .not_lost

    lda table(0,2),x
    cmp table(0,3),x
    beq .not_lost

    inx #4
    cpx #$10
    bne .hloop

rtl

.not_lost
    stz !lost_flag
rtl


;nothing for now, just reset, and set gm to lost
ROUTINE.lose:
    lda #$03
    sta !game_mode
rtl



incsrc "./move_macro.asm"

ROUTINE.move_right:
    %do_move(table(0,0), table(0,1), table(0,2), table(0,3), 4)
    jmp ROUTINE.moved

ROUTINE.move_left:
    %do_move(table(0,3), table(0,2), table(0,1), table(0,0), 4)
    jmp ROUTINE.moved


ROUTINE.move_up:
    %do_move(table(3,0), table(2,0), table(1,0), table(0,0), 1)
    jmp ROUTINE.moved

ROUTINE.move_down:
    %do_move(table(0,0), table(1,0), table(2,0), table(3,0), 1)
    jmp ROUTINE.moved




; exponent of the score to add is $00
ROUTINE.update_score:
    phx
    rep #$20 ;a16i8

    ;load score to add
    ldx #$00
    lda #$0001
.loop
    asl A

    inx 
    cpx $00
    bne .loop

    ;add current score
    clc
    adc !score
    sta !score

    sep #$20

    ;handle overflow
    bcc .inbound
    inc !score_ex
.inbound
    plx
rtl

 
; 24bit unsigned HexToDec,

macro create_hex2dec(in, out)
ROUTINE.hex2dec_<in>:
    phx
    rep #$20

    lda #$0000
    sta !<out>
    sta !<out>+2
    sta !<out>+4
    sta !<out>+6

    lda !<in>
    sta $00
    lda.w #(10000000&$00FFFF)
    sta $03
    
    sep #$20

    lda !<in>+2
    sta $02
    lda.b #bk(10000000)
    sta $05

    ldx #$00

.digit7
    jsr ROUTINE.24bit_substract

    bcc ..next

    lda $06 : sta $00
    lda $07 : sta $01
    lda $08 : sta $02
    inx

    bra .digit7

..next
    stz !<out>+7

    lda.b #lo(1000000)
    sta $03
    lda.b #hi(1000000)
    sta $04
    lda.b #bk(1000000)
    sta $05

    ldx #$00

.digit6
    jsr ROUTINE.24bit_substract

    bcc ..next
    
    lda $06 : sta $00
    lda $07 : sta $01
    lda $08 : sta $02
    inx

    bra .digit6

..next
    stx !<out>+6

    lda.b #lo(100000)
    sta $03
    lda.b #hi(100000)
    sta $04
    lda.b #bk(100000)
    sta $05

    ldx #$00

.digit5
    jsr ROUTINE.24bit_substract

    bcc ..next

    lda $06 : sta $00
    lda $07 : sta $01
    lda $08 : sta $02
    inx

    bra .digit5

..next
    stx !<out>+5

    ;>from here, 16bits are enough
    rep #$20

    lda.w #10000
    sta $02
    lda $00

    ldx #$00

.digit4
    sec 
    sbc $02
    bcc ..next 
    sta $00
    inx
    bra .digit4

..next
    stx !<out>+4

    lda.w #1000
    sta $02
    lda $00

    ldx #$00

.digit3
    sec
    sbc $02
    bcc ..next
    sta $00
    inx
    bra .digit3

..next
    stx !<out>+3

    lda.w #100
    sta $02
    lda $00

    ldx #$00

.digit2
    sec
    sbc $02
    bcc ..next
    sta $00
    inx
    bra .digit2

..next
    stx !<out>+2

    lda.w #10
    sta $02
    lda $00

    ldx #$00

.digit1
    sec
    sbc $02
    bcc ..next
    sta $00
    inx
    bra .digit1

..next
    stx !<out>+1

    sep #$20

    lda $00
    sta !<out>

    plx
rtl
endmacro
%create_hex2dec(score, score_dec)
%create_hex2dec(hiscore, hiscore_dec)


;SBC sets the carry if A >= M

; calculates $00:$01:$02 - $03:$04:$05 and
; and puts the result in $06:$07:$08, + carry = 345 > 012
ROUTINE.24bit_substract:
    rep #$20

    lda $00 
    sec
    sbc $03

    sta $06

    sep #$20

    lda $02
    ;[carry conserved]
    sbc $05

    sta $08

    ;return carry
rts
