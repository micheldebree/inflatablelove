.pc =$0801 "Basic Upstart Program"
:BasicUpstart($0810)

// SETUP {{{
.var music = LoadSid("song2c.sid")

.pc = $0810 "Main Program"

            ldx #0
            ldy #0
            stx $d020
            stx $d021
            lda #music.startSong-1
            jsr music.init	

            // disable CIA 1 and CIA 2 interrupts
            lda #$7f
            sta $dc0d
            sta $dd0d
            
            // set interrupt vector
            lda #<irq1
            sta $0314
            lda #>irq1
            sta $0315

            // set raster line for interrupt
            lda #$1b
            sta $d011
            lda #$80
            sta $d012

            // ACK CIA 1 & 2 interrupts
            lda $dc0d
            lda $dd0d

            // ACK VIC interrupt
            asl $d019

            // enable the raster interrupt
            lda #$01
            sta $d01a

// groepaz: jmp * in main loop creates pseudo stable interrupt behaviour. unless you know very well what that means and that you want it that way, *always* run a non trivial function in the main loop. else you will get nice surprises once you add code to main.
            jmp *
// }}}

// IRQ {{{
irq1:  	
            // ACK VIC interrupt
            asl $d019

            dec $d020
            jsr rastersync
            inc $d020
            nop
            nop
            inc $d020
            inc $d021
            jsr music.play 
            dec $d020
            dec $d021

            // return
            pla
            tay
            pla
            tax
            pla
            rti

// }}}


// RASTERSYNC {{{

// simple polling rastersync routine
// http://codebase64.org/doku.php?id=base:sprites_in_bottom_sideborder
// align to next page so branches do not cross a page boundary and fuck up the timing

.align $100

rastersync:
!loop:
            cpx $d012
            bne !loop-
            jsr !cycles+
            bit $ea
            nop
            cpx $d012
            beq !skip+
            nop
            nop
!skip:
            jsr !cycles+
            bit $ea
            nop
            cpx $d012
            beq !skip+
            bit $ea
!skip:
            jsr !cycles+
            nop
            nop
            nop
            cpx $d012
            bne !onecycle+
!onecycle:
            rts

!cycles:
            ldy #$06
!loop:
            dey
            bne !loop-
            inx
            nop
            nop
            rts

//}}}


// music data {{{

.pc=music.location "Music"
.fill music.size, music.getData(i)

// }}}
