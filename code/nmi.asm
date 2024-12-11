

org ENDSECTION_BOOT;put after the boot code in what remains of bank 00

NMI:
.start
    bit $4210 ;acknowledge NMI

    ;disable display
    lda #$80
    sta $2100
    
    jsl OAM_upload

    %pushlabel_short(..return)
    lda !game_mode
    jsl ROUTINE.ptr_short
        dw .game
        dw .game
        dw .won
        dw .lost
        dw .back_to_game
        dw .pause
        dw .begin
    ..return

    ;and reenable
    lda #$0F
    sta $2100

rti


.begin
    lda !won_flag
    beq ..frame

    lda.b #BGSC_data($3000, !BGSC_32x32)
    sta !BG3SC

    lda #%00010101
    sta $212C
    lda #$09
    sta $2105

    stz !option_select
    stz !won_flag

..frame

    ; lda !option_select
    ; beq +
    ; brk
    ; +

    lda.b #VMAIN_data(!VMAIN_2118, !VMAIN_none, !VMAIN_inc_1)
    sta $2115


    ;upload the correct continue tilemap
    lda.b #lo(word_adress($3314))
    sta $2116
    lda.b #hi(word_adress($3314))
    sta $2117

    ldy #$00
    ldx #$00
    lda !option_select
    beq ...loop1 

    ldx.b #(..tmap_reset-..tmap_continue)/2

...loop1
    lda.l ..tmap_continue,x
    sta $2118

    iny
    inx
    cpy.b #(..tmap_reset-..tmap_continue)/2
    bne ...loop1


    ;the reset tilemap
    lda.b #lo(word_adress($3454))
    sta $2116
    lda.b #hi(word_adress($3454))
    sta $2117

    ldy #$00
    ldx #$00
    lda !option_select
    cmp #$01
    beq ...loop2

    ldx.b #(..tmap_scores-..tmap_reset)/2

...loop2
    lda.l ..tmap_reset,x
    sta $2118

    inx
    iny
    cpy.b #(..tmap_scores-..tmap_reset)/2
    bne ...loop2


    ;and the reset scores
    lda.b #lo(word_adress($3594))
    sta $2116
    lda.b #hi(word_adress($3594))
    sta $2117

    ldy #$00
    ldx #$00
    lda !option_select
    cmp #$02
    beq ...loop3

    ldx.b #(..tmap_end-..tmap_scores)/2

...loop3
    lda.l ..tmap_scores,x
    sta $2118

    inx
    iny
    cpy.b #(..tmap_end-..tmap_scores)/2
    bne ...loop3
rts
..tmap
...continue
db $33,$26,$27,$28,$29,$2A,$2B,$2C,$2D
db $71,$0C,$18,$17,$1D,$12,$17,$1E,$0E
...reset
db $33,$2E,$2F,$30,$31,$32
db $71,$1B,$0E,$1C,$0E,$1D
...scores
db $33,$2E,$2F,$30,$31,$32,$71,$30,$26,$27,$2E,$2F,$30
db $71,$1B,$0E,$1C,$0E,$1D,$71,$1C,$0C,$18,$1B,$0E,$1C
...end



.pause
    lda !won_flag
    beq ..frame

    ;load won tilemap
    lda.b #BGSC_data($2800, !BGSC_32x32)
    sta !BG3SC

    ;activate layer 3 high priority
    lda #%00010101
    sta $212C
    lda #$09
    sta $2105

    ;reset continue/reset
    stz !option_select
    
    stz !won_flag

..frame

    ;[update continue/reset selection]
    lda.b #VMAIN_data(!VMAIN_2118, !VMAIN_none, !VMAIN_inc_1)
    sta $2115

    lda.b #lo(word_adress($2D0A))
    sta $2116
    lda.b #hi(word_adress($2D0A))
    sta $2117

    ldy #$00
    ldx #$00
    lda !option_select
    beq ...loop
    ldx.b #(..tilemap_reset-..tilemap)
...loop
    lda.l ..tilemap,x
    sta $2118

    inx
    iny
    cpy.b #(..tilemap_reset-..tilemap)
    bne ...loop
rts
..tilemap
db $71,$33,$26,$27,$28,$29,$2A,$2B,$2C,$2D
db $71,$71,$71
db $71,$1B,$0E,$1C,$0E,$1D
...reset
db $71,$71,$0C,$18,$17,$1D,$12,$17,$1E,$0E
db $71,$71,$71
db $33,$2E,$2F,$30,$31,$32


.back_to_game
    lda #$01
    sta $2105
rts

.game
    ;update score graphics

    lda.b #VMAIN_data(!VMAIN_2118, !VMAIN_none, !VMAIN_inc_1)
    sta $2115

    lda.b #lo(word_adress($0832))
    sta $2116
    lda.b #hi(word_adress($0832))
    sta $2117

    ldx #$05
..loop1
    lda !score_dec,x
    ora #$10
    sta $2118

    dex
    cpx #$FF
    bne ..loop1

    ;and upload the best score
    lda.b #lo(word_adress($0872))
    sta $2116
    lda.b #hi(word_adress($0872))
    sta $2117

    ldx #$05
..loop2
    lda !hiscore_dec,x
    ora #$10
    sta $2118

    dex
    cpx #$FF
    bne ..loop2 
rts

.won 
    lda !won_flag
    beq ..frame

..init
    ;load won tilemap
    lda.b #BGSC_data($1000, !BGSC_32x32)
    sta !BG3SC

    ;activate layer 3 high priority
    lda #%00010101
    sta $212C
    lda #$09
    sta $2105

    ;reset continue/reset
    stz !option_select

    ;[write score to tilemap]
    jsr .write_score_end
    
    stz !won_flag
..frame
    
    ;[update continue/reset selection]
    lda.b #VMAIN_data(!VMAIN_2118, !VMAIN_none, !VMAIN_inc_1)
    sta $2115

    lda.b #lo(word_adress($150A))
    sta $2116
    lda.b #hi(word_adress($150A))
    sta $2117

    ldy #$00
    ldx #$00
    lda !option_select
    beq ...loop
    ldx.b #(..tilemap_reset-..tilemap)
...loop
    lda.l ..tilemap,x
    sta $2118

    inx
    iny
    cpy.b #(..tilemap_reset-..tilemap)
    bne ...loop
rts

..tilemap
db $71,$33,$26,$27,$28,$29,$2A,$2B,$2C,$2D
db $71,$71,$71
db $71,$1B,$0E,$1C,$0E,$1D
...reset
db $71,$71,$0C,$18,$17,$1D,$12,$17,$1E,$0E
db $71,$71,$71
db $33,$2E,$2F,$30,$31,$32

.lost
    lda !lost_flag
    beq ..frame

..init
    ;load lost tilemap
    lda.b #BGSC_data($1800, !BGSC_32x32)
    sta !BG3SC

    ;activate layer 3
    lda #%00010101
    sta $212C
    lda #$09
    sta $2105

    ;copy score to tilemap
    lda.b #VMAIN_data(!VMAIN_2118, !VMAIN_none, !VMAIN_inc_1)
    sta $2115

    lda.b #lo(word_adress($1C60))
    sta $2116
    lda.b #hi(word_adress($1C60))
    sta $2117

    ldx #$05
...loop
    lda !score_dec,x
    sta $2118

    dex 
    cpx #$FF
    bne ...loop


    stz !lost_flag

..frame
    ;[update reset/??? selection]
rts


.write_score_end

    lda.b #VMAIN_data(!VMAIN_2118, !VMAIN_none, !VMAIN_inc_1)
    sta $2115

    lda.b #lo(word_adress($1C60))
    sta $2116
    lda.b #hi(word_adress($1C60))
    sta $2117

    ldx #$05
..loop
    lda !score_dec,x
    sta $2118

    dex 
    cpx #$FF
    bne ..loop

rts

ENDSECTION_NMI: