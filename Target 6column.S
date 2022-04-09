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
      
DIGITPT  =       $00
SEGMPT   =       $01
STATPT   =       $02
STATST   =       $03
LoopCo   =       $04
REPEST   =       $05
ONOFST   =       $06
OFFPTR   =       $07
MESPT1   =       $08
MESPT2   =       $09
MESPT3   =       $0a
MESPT4   =       $0b
PLAYST   =       $0e
TEMPPL   =       $0f
SEGST4   =       $13
SEGST6   =       $15
SAD      =       $1740
SBD      =       $1742
KEYIN    =       $1f40
GETKEY   =       $1f6a

         .org    $0030
        

inkey:   jsr     KEYIN
         jsr     GETKEY
         sta     $21
         cmp     #$15
         beq     torts
inkeyc:  jsr     GETKEY
         cmp     $21
         beq     inkeyc
         lda     $21
torts:   rts

istate:  ldx     #$0b
fstate:  sta     SEGST6,x
         dex
         bne     fstate
         rts

mescon:  jsr     pause
         jsr     messho
loopc:   lda     LoopCo
         beq     repeat
         ldx     SEGMPT
         jsr     digsta
         jmp     loopc

repeat:  dec     REPEST
         bne     mescon
         rts

pause:   ldx     #$80
aa:      ldy     #$ff
aaa:     dey
         bne     aaa
         dex
         bne     aa
         rts

toshow:  ldy     STATPT
         ldx     SEGMPT
         jsr     fill
segsta:  ldx     SEGMPT
         jsr     show
         rts

         .byte   $00
         .byte   $00
         .byte   $00

rstart:  lda     #$0f
         sta     SEGMPT
         lda     #$1a
         sta     STATST
         lda     #$f9
         sta     OFFPTR
         lda     #$e1
         sta     MESPT1
         lda     #$e7
         sta     MESPT2
         lda     #$ed
         sta     MESPT3
         lda     #$f3
         sta     MESPT4
         lda     #$80
         jsr     istate
         lda     #$81
         sta     $1b
         lda     #$0a
         sta     REPEST
         rts

;start
         .org 	 $0200 

start:   jsr     rstart
         nop
         nop
         nop
playab:  lda     MESPT1
         sta     STATPT
         jsr     meshoc
anykey:  jsr     inkey
         cmp     #$15
         bne     keyA
contin:  lda     LoopCo
         beq     back
         ldx     SEGMPT
         jsr     digsta
         jmp     anykey

back:    jsr     segsta
         jmp     anykey

keyA:    cmp     #$0a
         bne     keyB
         sta     PLAYST
         jmp     oncont

keyB:    cmp     #$0b
         bne     contin
         sta     PLAYST
oncont:  lda     STATST
         cmp     #$14
         bne     done
         lda     #$1a
done:    sta     STATST
         sta     STATPT
         lda     #$01
         sta     ONOFST
         jsr     toshow
key:     jsr     inkey
         cmp     #$15
         bne     gokey
         lda     LoopCo
         beq     OnOff
         ldx     SEGMPT
         jsr     digsta
         jmp     key

OnOff:   lda     ONOFST
         beq     oncont
         lda     STATPT
         sta     STATST
         dec     STATST
         lda     OFFPTR
         sta     STATPT
         lda     #$00
         sta     ONOFST
         jsr     meshoc
         jmp     key

gokey:   cmp     #$13
         bne     key3
         jmp     start

key3:    cmp     #$03
         bne     Foul
         lda     SEGST4
         bne     hit
miss:    lda     PLAYST
         sta     TEMPPL
         cmp     #$0a
         bne     missC
         lda     #$0b
         sta     TEMPPL
missC:   ldy     STATST
         ldx     SEGMPT
         jsr     fill
         jmp     hitcon

Foul:    lda     MESPT2
         sta     STATPT
         jsr     mescon
         lda     #$0a
         sta     REPEST
         lda     PLAYST
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

hit:     lda     PLAYST
         sta     TEMPPL
hitcon:  lda     TEMPPL
         cmp     #$0a
         bne     B3segs
         lda     SEGST4
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
         lda     DIGITPT,x
         cmp     #$80
L0300:   beq     loopA
         jmp     oncont

B3segs:  lda     SEGST4
         cmp     #$c9
         beq     lose
         cmp     #$c1
         bne     B1segs
         ldy     #$c9
         jsr     statch
         lda     PLAYST
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
         lda     DIGITPT,x
         cmp     #$c9
         beq     loopB
         jmp     oncont

win:     lda     MESPT3
         sta     STATPT
         jsr     mescon
         jmp     start

lose:    lda     MESPT4
         sta     STATPT
         jsr     mescon
         jmp     start

         .byte   $00
         .byte   $00

fill:    iny
         lda     DIGITPT,y
         inx
         sta     DIGITPT,x
         cpx     #$15
         bne     fill
         rts

show:    lda     #$30
         sta     LoopCo
         lda     ONOFST
         bne     digsta
         lsr     LoopCo
digsta:  lda     #$07
         sta     DIGITPT
digcon:  inc     DIGITPT
         inc     DIGITPT
         lda     DIGITPT
         cmp     #$15
         beq     loopCn
LiteUp:  lda     #$7f
         sta     SBD-1
         lda     DIGITPT
         sta     SBD
         inx
         lda     DIGITPT,x
         sta     SAD
         ldy     #$30
wait:    dey
         bne     wait
         lda     #$00
         sta     SAD
         jmp     digcon

loopCn:  lda     #$00
         sta     SBD
         dec     LoopCo
         rts

messho:  lda     #$01
         sta     ONOFST
meshoc:  ldy     STATPT
         ldx     SEGMPT
mesfil:  iny
         lda     L0300,y
         inx
         sta     DIGITPT,x
         cpx     #$15
         bne     mesfil
         jsr     segsta
         rts

statch:  ldx     STATST
         inx
         inx
         inx
         inx
         nop
         sty     DIGITPT,x
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
         sty     DIGITPT,x
return:  rts

todec:   dex
         dex
         dex
         dex
         dex
         dex
         sty     DIGITPT,x
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
