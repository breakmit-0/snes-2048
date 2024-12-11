

;assemble after interrupts
org INT.END|!fastROM

BOOT:
    jsl BOOT.INIT_PPU

    rep #$30

    ldx.w #$1FFF  ; setup stack at RAM $1FFF
    txs           ;

    phk         ; use fast data bank
    plb         ;

    lda #$0000  ; set direct page to $7E:0000
    tcd         ;


    ;setup PPU registers (see ch.26 of snes dev manual)

    lda #$008F    ; F-blank, (also writes $00 to 2101)
    sta $2100     ;

    sep #$30

.clearWRAM
    ;setup DMA but dont call
    %prepDMA_ROM_RAM(.data_zero, $7E0000, !DMA_mode_static, $00, $0000)
    
    ;call twice for each RAM bank
    sta $420B
    sta $420B

jml MAIN

.data
..zero
    db $00


ENDSECTION_BOOT: