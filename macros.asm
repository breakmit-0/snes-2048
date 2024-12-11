function bk(adress) = (adress&$FF0000)>>16
function hi(adress) = (adress&$00FF00)>>8
function lo(adress) = (adress&$0000FF)

function table(row,col) = $0200+(4*row+col)


function BGSC_data(base, size) = ((((base&$FF80)>>9)|size)&$FF)
!BGSC_32x32 = $00
!BGSC_64x32 = $01
!BGSC_32x64 = $02
!BGSC_64x64 = $03

function BG1NBA(adress) = ((adress>>13)&$0F)
function BG2NBA(adress) = ((adress>>9)&$F0)
function BG3NBA(adress) = ((adress>>13)&$0F)
function BG4NBA(adress) = ((adress>>9)&$F0)

function word_adress(byte) = (byte>>1)

function DMA_data(dir, step, unit) = ((dir<<7)|(step<<3)|unit)
!DMA_cpu_io = $00
!DMA_io_cpu = $01

!DMA_inc = $00
!DMA_fixed = $01
!DMA_dec = $02

!DMA_WRAM = $00
!DMA_VRAM = $01
!DMA_OAM = $02
!DMA_CGRAM = $02

!DMA_adress_WRAM = $80
!DMA_adress_VRAM = $18
!DMA_adress_OAM = $04
!DMA_adress_CGRAM = $22


function VMAIN_data(byte, trans, incr) = ((byte<<7)|(trans<<2)|incr)
!VMAIN_2119 = $01
!VMAIN_2118 = $00

!VMAIN_none = $00
!VMAIN_8bit = $01
!VMAIN_9bit = $02
!VMAIN_10bit = $03

!VMAIN_inc_1 = $00
!VMAIN_inc_32 = $01
!VMAIN_inc_128 = $02


!DMA_mode_static = $08
!DMA_mode_increment = $00
!DMA_mode_decrement = $10
function DMA_channel(n) = n<<4



;compares 2 n byte numbers
;set carry if a >= b (unsigned), n flag if a >= b?? (signed)
macro compare_long(a, b, n)
    !compare_byte = <n>
    !compare_byte #= !compare_byte-1
    while !compare_byte > 0
        lda <a>+!compare_byte
        cmp <b>+!compare_byte
        beq +
        bra ?end
        +
        !compare_byte #= !compare_byte-1 
    endif

    lda <a>
    cmp <b>
?end
endmacro

macro prepDMA_ROM_RAM(ROM, RAM, incMode, channel, size)
    lda.b #<incMode>
    sta $4300|<channel>

    lda.b #$80
    sta $4301|<channel>

    lda.b #lo(<ROM>) : sta $4302|<channel>
    lda.b #hi(<ROM>) : sta $4303|<channel>
    lda.b #bk(<ROM>) : sta $4304|<channel>

    lda.b #lo(<RAM>) : sta $2181
    lda.b #hi(<RAM>) : sta $2182
    lda.b #bk(<RAM>)-$7E : sta $2183

    lda.b #lo(<size>) : sta $4305|<channel>
    lda.b #hi(<size>) : sta $4306|<channel>

    lda.b #$01<<(<channel>>>4)
endmacro


;include a file and create an appropriate label
macro incgfx(path, name)
    GFX_<name>:
    incbin <path>

    ;add this location to the GFX accumulators
    !GFX_RefAcc_lo += "lo(GFX_<name>),"
    !GFX_RefAcc_hi += "hi(GFX_<name>),"
    !GFX_RefAcc_bk += "bk(GFX_<name>),"
endmacro

macro inctmap(path, name)
    TMAP_<name>:
    incbin <path>
endmacro


;static writes a label into a SP_PTR
macro set_SP_PTR(ptrID, label)
    lda.b #lo(<label>)
    sta !SP_PTR_lo+<ptrID>
    lda.b #hi(<label>)
    sta !SP_PTR_hi+<ptrID>
    lda.b #bk(<label>)
    sta !SP_PTR_bk+<ptrID>
endmacro

;set the vram upload pointer to a label
macro set_VRAM_PTR(label)
    lda.b #lo(<label>)
    sta $4302
    lda.b #hi(<label>)
    sta $4303
    lda.b #bk(<label>)
    sta $4304
endmacro

macro pushpc_short()
    jsl ?+
    ?+
endmacro

macro pushpc_long()
    jsl ?+
    ?+
endmacro


;push the adress - 1 as rts/rtl return to 1 after the adress
macro pushlabel_short(label)
    lda.b #hi(<label>-1) : pha
    lda.b #lo(<label>-1) : pha
endmacro

macro pushlabel_long(label)
    lda.b #bk(<label>-1) : pha
    lda.b #hi(<label>-1) : pha
    lda.b #lo(<label>-1) : pha
endmacro