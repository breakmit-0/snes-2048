
###### W-RAM mapping


# $02FE ~ $051F
## OAM mirror
> $02FE: 2 bytes OAM index
> $0300: 512 bytes main OAM mirror
> $0500: 32 bytes extra OAM mirror

# $0520 ~ $05??
## pointers to static GFX
> $0520: 4x3 bytes for SP1-4, in little endian
> $052C: 1 byte dirty flag for SP-1-4 

# $7E0200 ~ $7E020F
> 16 bytes for the 16 current states






######  V-RAM mapping


# $0000 - $0FFF
## bg tile gfx
> $0000: 4096 bytes for BG0 gfx

# $1000 ~ $xxxx
## bg tilemap
> $1000: n bytes for BG0 tilemap

# $C000 ~ $FFFF
## sprite tile gfx
> $C000: 4096 bytes for SP1
> $D000: 4096 bytes for SP2
> $E000: 4096 bytes for SP3
> $F000: 4096 bytes for SP4