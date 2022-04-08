;***************************************
;* Target 6-column Version             *
;*                                     *
;* Author                              *
;* Fer Weber                           *
;* Gebr. Wienerstr. 139                *
;* 5913 XS Venlo                       *
;* Holland                             *
;*                                     *
;* published in KimKenner 8            *
;* on 18.06.1979                       *
;*                                     *
;* "After Target-1 war running, I      *
;* thought how about using all         *
;* 6 digits of the KIM-1 display..."   *
;*                                     *
;* Instructions:                       *
;* Start at $0200                      *
;* Now choose Game A or B              *
;*                                     *
;* Game A wins if all stripes have     *
;* been shot away,                     *
;* Game B wins if all stripes are      *
;* lid.                                *
;*                                     *
;* If you shoot (Key 3) you shoot at   *
;* Digit 4                             *
;*      |1|2|3|4| |5|6|                *
;*             ^                       *
;***************************************
         
         .org    $0030
 

inkey:   jsr     $1f40
         jsr     $1f6a
         sta     $21
         cmp     #$15
         beq     torts
inkeyc:  jsr     $1f6a
         cmp     $21
         beq     inkeyc
         lda     $21
torts:   rts

istate:  ldx     #$0b
fstate:  sta     $15,x
         dex
         bne     fstate
         rts

mescon:  jsr     pause
         jsr     messho
loopc:   lda     $04
         beq     repeat
         ldx     $01
         jsr     digsta
         jmp     loopc

repeat:  dec     $05
         bne     mescon
         rts

pause:   ldx     #$80
aa:      ldy     #$ff
aaa:     dey
         bne     aaa
         dex
         bne     aa
         rts

toshow:  ldy     $02
         ldx     $01
         jsr     fill
segsta:  ldx     $01
         jsr     show
         rts

         .byte   $00
         .byte   $00
         .byte   $00

rstart:  lda     #$0f
         sta     $01
         lda     #$1a
         sta     $03
         lda     #$f9
         sta     $07
         lda     #$e1
         sta     $08
         lda     #$e7
         sta     $09
         lda     #$ed
         sta     $0a
         lda     #$f3
         sta     $0b
         lda     #$80
         jsr     istate
         lda     #$81
         sta     $1b
         lda     #$0a
         sta     $05
         rts

 
; Start of the program
         .org     $0200 

start:   jsr     rstart
         nop
         nop
         nop
playab:  lda     $08
         sta     $02
         jsr     meshoc
anykey:  jsr     inkey
         cmp     #$15
         bne     keyA
contin:  lda     $04
         beq     back
         ldx     $01
         jsr     digsta
         jmp     anykey

back:    jsr     segsta
         jmp     anykey

keyA:    cmp     #$0a
         bne     keyB
         sta     $0e
         jmp     oncont

keyB:    cmp     #$0b
         bne     contin
         sta     $0e
oncont:  lda     $03
         cmp     #$14
         bne     done
         lda     #$1a
done:    sta     $03
         sta     $02
         lda     #$01
         sta     $06
         jsr     toshow
key:     jsr     inkey
         cmp     #$15
         bne     gokey
         lda     $04
         beq     OnOff
         ldx     $01
         jsr     digsta
         jmp     key

OnOff:   lda     $06
         beq     oncont
         lda     $02
         sta     $03
         dec     $03
         lda     $07
         sta     $02
         lda     #$00
         sta     $06
         jsr     meshoc
         jmp     key

gokey:   cmp     #$13
         bne     key3
         jmp     start

key3:    cmp     #$03
         bne     Foul
         lda     $13
         bne     hit
miss:    lda     $0e
         sta     $0f
         cmp     #$0a
         bne     missC
         lda     #$0b
         sta     $0f
missC:   ldy     $03
         ldx     $01
         jsr     fill
         jmp     hitcon

Foul:    lda     $09
         sta     $02
         jsr     mescon
         lda     #$0a
         sta     $05
         lda     $0e
         cmp     #$0a
         bne     ilcont
         lda     #$c9
         jsr     istate
         jmp     oncont

ilcont:  lda     #$81
         jsr     istate
         lda     #$80
         sta     $17
         sta     $19
         sta     $1b
         sta     $1d
         sta     $1f
         jmp     oncont

hit:     lda     $0e
         sta     $0f
hitcon:  lda     $0f
         cmp     #$0a
         bne     B3segs
         lda     $13
         cmp     #$80
         beq     make1S
         cmp     #$81
         bne     A2segs
         ldy     #$80
         jsr     statch
         jmp     allBla

A2segs:  cmp     #$c1
         bne     A3segs
make1S:  ldy     #$81
         jsr     statch
         jmp     oncont

A3segs:  ldy     #$c1
         jsr     statch
         jmp     oncont

allBla:  ldx     #$15
loopA:   inx
         cpx     #$21
         beq     win
         lda     $00,x
         cmp     #$80
L0300:   beq     loopA
         jmp     oncont

B3segs:  lda     $13
         cmp     #$c9
         beq     lose
         cmp     #$c1
         bne     B1segs
         ldy     #$c9
         jsr     statch
         lda     $0e
         cmp     #$0a
         bne     All2S
         jmp     oncont

B1segs:  cmp     #$81
         bne     B0segs
         ldy     #$c1
         jsr     statch
         jmp     oncont

B0segs:  ldy     #$81
         jsr     statch
         jmp     oncont

All2S:   ldx     #$15
loopB:   inx
         cpx     #$21
         beq     win
         lda     $00,x
         cmp     #$c9
         beq     loopB
         jmp     oncont

win:     lda     $0a
         sta     $02
         jsr     mescon
         jmp     start

lose:    lda     $0b
         sta     $02
         jsr     mescon
         jmp     start

         .byte   $00
         .byte   $00

fill:    iny
         lda     $0000,y
         inx
         sta     $00,x
         cpx     #$15
         bne     fill
         rts

show:    lda     #$30
         sta     $04
         lda     $06
         bne     digsta
         lsr     $04
digsta:  lda     #$07
         sta     $00
digcon:  inc     $00
         inc     $00
         lda     $00
         cmp     #$15
         beq     loopCn
LiteUp:  lda     #$7f
         sta     $1741
         lda     $00
         sta     $1742
         inx
         lda     $00,x
         sta     $1740
         ldy     #$30
wait:    dey
         bne     wait
         lda     #$00
         sta     $1740
         jmp     digcon

loopCn:  lda     #$00
         sta     $1742
         dec     $04
         rts

messho:  lda     #$01
         sta     $06
meshoc:  ldy     $02
         ldx     $01
mesfil:  iny
         lda     L0300,y
         inx
         sta     $00,x
         cpx     #$15
         bne     mesfil
         jsr     segsta
         rts

statch:  ldx     $03
         inx
         inx
         inx
         inx
         nop
         sty     $00,x
         cpx     #$1e
         beq     todec
         cpx     #$1d
         beq     todec
         cpx     #$1c
         beq     todec
         cpx     #$1b
         beq     end
         inx
         inx
         inx
         inx
         inx
         inx
         sty     $00,x
return:  rts

todec:   dex
         dex
         dex
         dex
         dex
         dex
         sty     $00,x
end:     rts

         .byte   $f7
         .byte   $80
         .byte   $bf
         .byte   $d0
         .byte   $80
         .byte   $fc
         .byte   $f1
         .byte   $bf
         .byte   $be
         .byte   $b8
         .byte   $80
         .byte   $80
         .byte   $f6
         .byte   $be
         .byte   $d0
         .byte   $d0
         .byte   $f7
         .byte   $ee
         .byte   $fc
         .byte   $be
         .byte   $ed
         .byte   $f8
         .byte   $f9
         .byte   $de
         .byte   $00
         .byte   $00
         .byte   $00
         .byte   $00
         .byte   $00
         .byte   $00
