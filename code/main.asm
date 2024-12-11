

org $C00000 ;put in the first hiROM fast bank
            ;note: C0:8000~C0:FFFF is a mirror of bank 00

MAIN:
.setup
    ;hide all sprites
    jsl OAM_RESET

    ;set default sprites

    lda #$28
    sta !OAM_x
    sta !OAM_y
    lda #$00
    sta !OAM_gfx
    lda #%00110000
    sta !OAM_prop
    
    lda #!OAMX_big
    sta !OAM_finish_input
    jsl OAM.finish

    ;scroll the BG down 1 pixel for some reason
    ;aligns with the holes
    lda #$FF
    sta $210E
    lda #$3
    sta $210E

    ;lda  #%00000010
    ;sta !OAM_ex

    ; reserve the 16 first OAM slots for the tiles
    jsl ROUTINE.setupOAM

    jsl OAM_upload

    lda #$27    ;> 8x8 + 32x32, no gap, last quarter
    sta $2101
    

    ;set sprite gfx
    %set_SP_PTR(0, GFX_SP0)
    %set_SP_PTR(1, GFX_SP1)
    %set_SP_PTR(2, GFX_SP2)
    %set_SP_PTR(3, GFX_SP3)

    ;upload all sprite V-RAM
    lda #$01
    sta !SPRAM_dirty
    sta !SPRAM_dirty+1
    sta !SPRAM_dirty+2
    sta !SPRAM_dirty+3
    jsl VRAM_upload.SPTILE
 

    ;upload palette
    jsl CGRAM_upload


    rep #$10 ;a8i16

    ;upload BG0 to $0000, 2KB
    %set_VRAM_PTR(GFX_BG0)
    ldy #$0000
    ldx #$0800
    jsl VRAM_upload

    ;upload BG3 to $2000, 2KB
    %set_VRAM_PTR(GFX_BG3)
    ldy #word_adress($2000)
    jsl VRAM_upload

    ;upload main tilemap to $0800, 2KB
    %set_VRAM_PTR(TMAP_MAIN)
    ldy #word_adress($0800)
    jsl VRAM_upload

    ;upload won tilemap to $1000, 2KB 
    %set_VRAM_PTR(TMAP_WON)
    ldy #word_adress($1000)
    jsl VRAM_upload
    
    ;upload lost tilemap to $1800, 2KB
    %set_VRAM_PTR(TMAP_LOST)
    ldy #word_adress($1800)
    jsl VRAM_upload

    %set_VRAM_PTR(TMAP_PAUSE)
    ldy #word_adress($2800)
    jsl VRAM_upload

    %set_VRAM_PTR(TMAP_BEGIN)
    ldy #word_adress($3000)
    jsl VRAM_upload

    lda.b #BGSC_data($0800, !BGSC_32x32)
    sta !BG1SC

    lda.b #BGSC_data($1800, !BGSC_32x32)
    sta !BG3SC


    lda.b #BG1NBA($0000)|BG2NBA($0000)
    stz !BG12NBA

    lda.b #BG3NBA($2000)|BG4NBA($0000)
    sta !BG34NBA


    sep #$10 ;a8i8

    ;enable sprites & BG1
    lda #%00010001
    sta $212C

    ;use BG mode 1 for 4bpp BG1, layer 3 high priority
    lda #$09
    sta $2105

    ;start displaying
    lda #$0F
    sta $2100

    JMP ..SKIP_APU_UPLOAD

    ;sound upload
    rep #$20
    lda #$0000
    sta !apu_src
    ldx #$FC
    stx !apu_src+2
    lda #$0100
    sta !apu_size
    lda #$0200
    sta !apu_target_lo
    sep #$20
    jsl APU_UPLOAD
    lda.b #$00
    sta $03
    lda.b #$02
    sta $04
    jsl APU_RUN

    ;wait until the driver has initialized the sync signal,
    ;and make sure the current signal is not $AA
    lda #$99
    sta $2143
-   lda $2143
    cmp #$AA
    bne - ; maybe should be BEQ instead

    ;echo = 0
    lda #$2C : ldx #$00
    jsl APU_send_reg
    lda #$3C : ldx #$00
    jsl APU_send_reg

    ;max volume
    lda #$0C : ldx #$7F
    jsl APU_send_reg
    lda #$1C : ldx #$7F
    jsl APU_send_reg

    ;sound directory at $0300
    lda #$5D : ldx #$03
    jsl APU_send_reg

    ;echo enable
    lda #$4D : ldx #%00000000
    jsl APU_send_reg

..SKIP_APU_UPLOAD


    ;enable NMI interrupts and auto joypad
    lda #$81
    sta $4200

    ; DONT DO ANYTHING HERE, WEIRD SHIT HAPPENS,
    ; EX: BRK REDIRECTED TO NMI ???

    ;and wait for a vblank
    wai


    ldx #$00
    lda #$00
..table_setup_loop
    sta table(0,0),x

    inx
    cpx #$10
    bne ..table_setup_loop


.find_save
    ; if the save checksum is correct, go into
    ; the save found menu instead of the game
 
    stz !game_mode

    stz $00
    ldx #$00
..loop
    lda !save_table,x
    clc
    adc $00
    sta $00

    inx
    cpx #$18
    bne ..loop

    lda $00
    cmp !save_checksum
    bne .mainloop


    lda #$06
    sta !game_mode
    inc !won_flag

.mainloop

    ;tick rng
    jsl ROUTINE.get_rand


    %pushlabel_long(..return)

    lda !game_mode
    jsl ROUTINE.ptr_long
        dl GM.play          ; $00
        dl GM.animated      ; $01
        dl GM.won           ; $02
        dl GM.lost          ; $03
        dl GM.back_to_game  ; $04
        dl GM.pause         ; $05
        dl GM.begin         ; $06

..return

    jsl ROUTINE.hex2dec_score
    jsl ROUTINE.hex2dec_hiscore

    jsl ROUTINE.update_sprites



    ; read input at the end of the frame asap
.waitinput
    lda $4212
    and #$01
    bne .waitinput

    jsl ROUTINE.read_input

    wai         ; and wait for the next V-blank

jml .mainloop


warnpc $C08000 ;dont spill over in the bank 00 mirror
ENDSECTION_MAIN:
