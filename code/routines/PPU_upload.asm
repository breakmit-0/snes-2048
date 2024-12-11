;all these routines 



;OAM is 0x0200 + 0x20 bytes long


;this routine uploads the OAM mirror
OAM_upload:
    ;save DB
    phb     

    ;set DB to $00 to access registers
    lda #$00   
    pha
    plb

    stz $2102   ;start at the begining of OAM
    stz $2103   ;and used standard priority

    lda #$00    ; transfer byte by byte
    sta $4300   ;

    lda #$04    ; use port $2104 aka. OAM
    sta $4301   ;

    ;src adress: OAM RAM mirror
    lda.b #lo(!OAM_start) : sta $4302
    lda.b #hi(!OAM_start) : sta $4303
    lda.b #$7E : sta $4304

    ; write 0x0220 bytes
    lda #$20 : sta $4305
    lda #$02 : sta $4306

    lda #$01
    sta $420B

    plb
rtl

;uploads the full CG-RAM from the ram mirror
CGRAM_upload:
    ;save DB
    phb     

    ;set DB to $00 to access registers
    lda #$00   
    pha
    plb
    
    lda #$02    ; forwards, double writes
    sta $4300   ;

    lda #$22    ; to CGRAM
    sta $4301   ;

    ;choose adress
    lda.b #lo(PAL_BASE)
    sta $4302
    lda.b #hi(PAL_BASE)
    sta $4303
    lda.b #bk(PAL_BASE)
    sta $4304

    ;upload  0x100 words
    lda #$00
    sta $4305
    lda #$02
    sta $4306

    stz $2121   ; at adress 00

    lda #$01    ; fire DMA
    sta $420B   ;

    plb
rtl


;VRAM size: 64Kb, aka. 1 bank



;expects a8i16, overwrites A, X and Y,
; Y -> adress to write (in WORDS, half the byte adress)
; X -> bytes to write
VRAM_upload:
    stx $4305 ; bytes to write

    sty $2116 ; destination adress

    lda.b #$01 ;#DMA_data(!DMA_cpu_io, !DMA_inc, !DMA_VRAM)
    sta $4300

    lda.b #$18 ;#!DMA_adress_VRAM
    sta $4301

    ;select data
    ; lda.b #lo(TMAP_MAIN)
    ; sta $4302
    ; lda.b #hi(TMAP_MAIN)
    ; sta $4303
    ; lda.b #bk(TMAP_MAIN)
    ; sta $4304

    ;fire DMA
    lda #$01
    sta $420B
rtl

;NOTE: the bsnes debugger shows VRAM adress in BYTES, not  WORDS and shows only the usable 64k

;reupload SP1-4 if required by the dirty flag
;uses X, Y, $00, returns a8i8
VRAM_upload.SPTILE:
    ;save DB
    phb     

    ;set DB to $00 to access registers
    lda #$00   
    pha
    plb

    rep #$10 ;i16
    
    ldy #$0000

    .loop
        lda !SPRAM_dirty,y  ; only reupload if needed
        beq .clean          ;

        ldx #$1801  ;> increment, 2 byte writes
        stx $4300   ;> to WRAM

        ;choose the ROM data
        lda !SP_PTR_lo,y
        sta $4302
        lda !SP_PTR_hi,y
        sta $4303
        lda !SP_PTR_bk,y
        sta $4304

        ;select the VRAM adress
        tya         ;> Y_hi=>B, Y_lo=>A
        asl #$03    ;> use as page number
        ora #$E0    ;> start at $C000, IN BYTES
        stz $2116   ;> low byte is 00
        sta $2117   ;> hi byte is page

        ldx #$1000  ;> write 4KB
        stx $4305   ;

        lda #$01    ;> fire DMA 
        sta $420B   ;

        lda #$00            ;> dont reupload until dirty again
        sta !SPRAM_dirty,y  ;

        iny
    .clean
        cpy #$0004
        bne .loop

    sep #$30 ;i8

    plb
rtl
