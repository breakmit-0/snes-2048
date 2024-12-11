;OAM related routines and defines

;usage: start with 0 then OR big/x and AND the correct mod
!OAMX_big = %10101010
!OAMX_x = %01010101
!OAMX_mod0 = %00000011
!OAMX_mod1 = %00001100
!OAMX_mod2 = %00110000
!OAMX_mod3 = %11000000

;AND current mod from counter x4
!OAMX_mask = $0003



; increases the OAM counter and sets the OAM extra bits
; /!\ runs with PB != DB, needs db in [00-3F] or [80-BF]
;
; INPUT : 
;   !OAM_finish_input = extra bits to set, or-combo of (OAMX_big / OAMX_x)
;   
; OUTPUT :
;   !OAM_finish_input = GARBAGE
;   A > 8bit
;   X > 8bit
;   
!OAM_finish_input = $00
bank $80
OAM.finish:
    rep #$20
    phx
    phy

    ;get current mod in x
    lda !OAM_index
    lsr #2
    and #!OAMX_mask
    tax

    ;increase index
    lda !OAM_index
    clc : adc #$0004
    sta !OAM_index

    sep #$20

    ;AND the input with the right mask
    lda !OAM_finish_input
    and .modmask,x
    sta !OAM_finish_input

    ;...clean the current value
    ldy !OAMX_index
    lda !OAM_ex,y
    and .modmask_neg,x

    ;...and put in the right value
    ora !OAM_finish_input
    sta !OAM_ex,y

    ;if mod == 3, increase the OAMX index
    cpx #$03
    bne +
    inc !OAMX_index
    +

    ply
    plx
rtl

.modmask
db !OAMX_mod0, !OAMX_mod1, !OAMX_mod2, !OAMX_mod3
.modmask_neg
db ~!OAMX_mod0, ~!OAMX_mod1, ~!OAMX_mod2, ~!OAMX_mod3
