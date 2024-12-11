;SRAM = 30h-3Fh,B0h-BFh:6000h-7FFFh


;save file format:
;
; * 16 bytes for the table data
; * 3 bytes for the current score
; * 3 bytes for the best score
; * 1 byte checksum
; * 1 byte checksum complement




ROUTINE.save:
    lda #$00
    sta !save_checksum

    ldx #$00
.loop1
    lda table(0,0),x
    sta !save_table,x

    clc
    adc !save_checksum
    sta !save_checksum

    inx
    cpx #$10
    bne .loop1

    ldx #$00
.loop2
    lda !score,x
    sta !save_score,x
    clc
    adc !save_checksum
    sta !save_checksum

    lda !hiscore,x
    sta !save_best,x
    clc
    adc !save_checksum
    sta !save_checksum

    inx 
    cpx #$03
    bne .loop2

    ;save -checksum aka. 2's complement
    lda #$00
    sec
    sbc !save_checksum
    sta !save_complement
rtl
