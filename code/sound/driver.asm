;
; send the correct commands to the APU
;
;  A - TVPPPPPP
;   :=> T - 1 for tone, 0 for noise
;   :=> V - volume (high/low)
;   :=> P - 6bit pitch
;   0=> reset sounds

!sound_T = %10000000
!sound_V = %01000000
!sound_P = %00111111
function channel(n) = ($01<<n)

;shut channel 0
SOUND.silent:
    lda #$5C
    ldx #channel(0)
    jml APU_send_reg


;actual main
SOUND.driver:

    cmp #$00
    beq SOUND.silent

    eor #!sound_P
    pha

    ;keys OFF but no channel, does nothing?
    lda #$5C
    ldx #%00000000
    jsl APU_send_reg

    ;set the noise clock to 32kHz, and set some flags
    lda #$6C
    ldx #%00011111
    jsl APU_send_reg

    pla
    pha
    
    and #!sound_T
    beq SOUND.tone

SOUND.noise:

    ;enable noise
    lda #$3D
    ldx #channel(0)
    jsl APU_send_reg

    pla
    pha

    ;set the noise clock to the pitch
    and #!sound_P
    lsr : tax
    lda #$6C
    jsl APU_send_reg

    bra SOUND.done