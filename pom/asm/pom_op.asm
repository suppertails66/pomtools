
;========================================
; basic stuff
;========================================

.psx

.fixloaddelay

;=======================
; include auto-generated index files
;=======================

;.include "out/include/roboselect_overlaygrp.inc"

;========================================
; old functions
;========================================
  
  ; a0 = entry to insert after
  ; a1 = new entry
  linkIntoDisplayList equ 0x8003FD50
  
  setRectRenderCmdTransparency equ 0x8003FE04
  
;  memcpy equ 0x80100820
;  memcmp equ 0x801008B4
;  memset equ 0x801009A0

;========================================
; old memory
;========================================
  
;  nameScreenNameEntryBuffer equ 0x8012C624

;========================================
; defines
;========================================
    
  opCreditsCharsPerString equ 40
  opCreditsSpaceWidth equ 6

  opCreditsMaxOnscreenChars equ 256
  bytesPerVarWidthRectRenderCmd equ 0x14

  ; this is a global pointer to some rendering space
  ; used by the opening credits 
  opCreditsGeneralRenderPosGp equ 0x042C

;============================================================================
; SLPS_008.17
;============================================================================
  
  ; this executable doesn't use much memory, so we just occupy
  ; a big chunk of it with our new code and data
  newCodeStartSection equ 0x80140000
  newCodeEndSection   equ 0x80160000
  
.open "out/asm/SLPS_008.17", 0x8000F800
; size field in exe header
;.org 0x8000F800+0x1C
;  .word 0x1EE000
.org 0x8000F800+0x1C
;  .word 0x150000
  .word newCodeEndSection-0x80010000

  ;============================================================================
  ; MODIFICATION:
  ; simplified generation of "press start button" on title screen
  ;============================================================================
  
  titlePressStart1Width equ 0x40+0x50
  titlePressStart1X equ 0x40-8
  
    .org 0x8001BEA4
    .area 0x8001BEF4-.,0xFF
/*      ori $a0, $zero, 0x0040
      lw $v1, 0x042C($gp)
      ori $v0, $zero, 0x0030
      sb $v0, 0x000C($v1)
      lw $v0, 0x042C($gp)
      ori $s1, $zero, 0x0040
      ; set width
      sh $a0, 0x0010($v1)
      sh $s3, 0x0012($v1)
      sb $s1, 0x000D($v0)
      lw $v0, 0x042C($gp)
      ori $t3, $zero, 0x0080
      sb $t3, 0x0004($v0)
      lw $v1, 0x042C($gp)
      ori $s2, $zero, 0x00B0
      ; set x-pos
      sh $a0, 0x0008($v0) */
      
      ; width
      ori $a0, $zero, titlePressStart1Width
      ; v1 = dst render cmd pointer
      lw $v1, 0x042C($gp)
      ; src x
      ori $v0, $zero, 0x0030
      sb $v0, 0x000C($v1)
;      lw $v0, 0x042C($gp)
      ; src y
      ori $s1, $zero, 0x0040
      ; set width
      sh $a0, 0x0010($v1)
      ; set height
      sh $s3, 0x0012($v1)
      ; set src y
      sb $s1, 0x000D($v1)
;      lw $v0, 0x042C($gp)
      ; color value modifier
      ori $t3, $zero, 0x0080
      sb $t3, 0x0004($v1)
;      lw $v1, 0x042C($gp)
      ; dst y
      ori $s2, $zero, 0x00B0
      ; set x-pos
      li $a0,titlePressStart1X
      sh $a0, 0x0008($v1)
      sh $s2, 0x000A($v1)
      sb $t3, 0x0005($v1)
;      lw $v0, 0x042C($gp)
;      nop 
      sb $t3, 0x0006($v1)
      
      j 0x8001BEF4
      nop
      
    .endarea
  
    ; skip drawing second part of text (no longer needed)
    ; FREE SPACE
    .org 0x8001BF3C
    .area 0x8001BFCC-.,0xFF
    
      j 0x8001BFCC
      nop
      
    .endarea

  ;============================================================================
  ; MODIFICATION + FREE SPACE:
  ; simplified generation of title menu
  ;============================================================================
    
    titleNewGameSrcX equ 160
    titleNewGameSrcY equ 48
;    titleNewGameW equ 80
    titleNewGameW equ 88
    titleNewGameH equ 16
;    titleNewGameDstX equ 0x60
    titleNewGameDstX equ 88
    titleNewGameDstY equ 0xA8
    
    titleContinueSrcX equ 160
    titleContinueSrcY equ 80
;    titleContinueW equ 64
    titleContinueW equ 72
    titleContinueH equ 16
;    titleContinueDstX equ 0x60
    titleContinueDstX equ 92
    titleContinueDstY equ 0xC0
    
    .org 0x8001BFE4
    .area 0x8001C28C-.,0xFF

      ;=============
      ; new game
      ;=============
      
      lw $a0, 0x042C($gp)
      jal 0x8003FF1C
      nop 
      lw $a0, 0x042C($gp)
      jal 0x8003FE2C
      addu $a1, $zero, $zero
      lw $v1, 0x042C($gp)
      ; w
      ori $v0, $zero, titleNewGameW
      sh $v0, 0x0010($v1)
      ; h
      ori $v0, $zero, titleNewGameH
      sh $v0, 0x0012($v1)
      ; srcX
      ori $v0, $zero, titleNewGameSrcX
      sb $v0, 0x000C($v1)
      lw $v1, 0x042C($gp)
      ; srcY
      ori $v0, $zero, titleNewGameSrcY
      sb $v0, 0x000D($v1)
      lw $v1, 0x042C($gp)
      ori $t3, $zero, 0x0080
      sb $t3, 0x0004($v1)
      lw $a0, 0x042C($gp)
      ; dstX
      ori $v0, $zero, titleNewGameDstX
      sh $v0, 0x0008($v1)
      ; dstY
      ori $v0, $zero, titleNewGameDstY
      sh $v0, 0x000A($v1)
      sb $t3, 0x0005($a0)
      lw $v0, 0x042C($gp)
      nop 
      sb $t3, 0x0006($v0)
      lw $a0, 0x042C($gp)
      jal setRectRenderCmdTransparency
      addu $a1, $zero, $zero
      lui $v0, 0x8005
      lw $v0, 0x48C0($v0)
      lw $v1, 0x042C($gp)
      andi $v0, $v0, 0x0001
      bne $v0, $zero, @@noFlash_newgame
      nop 
      ; if selected (flashing palette needed)
        lw $t3, 0x0060($sp)
        nop 
        sra $v0, $t3, 1
        andi $v0, $v0, 0x0006
        lui $at, 0x800A
        addu $at, $at, $v0
        lhu $v0, 0xB916($at)
        j @@flashCheckDone_newgame
        nop 
      @@noFlash_newgame:
        lui $v0, 0x800A
        lhu $v0, 0xB912($v0)
      @@flashCheckDone_newgame:
      lw $a0, 0x02C0($gp)
      lw $a1, 0x042C($gp)
      ; "‚Í‚¶‚ß"
      jal linkIntoDisplayList
      sh $v0, 0x000E($v1)
      lw $a0, 0x042C($gp)
      nop 
      addiu $a0, $a0, 0x0014
      sw $a0, 0x042C($gp)
      
      ;=============
      ; continue
      ;=============
      
      jal 0x8003FF1C
      nop 
      lw $a0, 0x042C($gp)
      jal 0x8003FE2C
      addu $a1, $zero, $zero
      lw $v1, 0x042C($gp)
      ; w
      ori $v0, $zero, titleContinueW
      sh $v0, 0x0010($v1)
      ; h
      ori $v0, $zero, titleContinueH
      sh $v0, 0x0012($v1)
      ; srcX
      ori $v0, $zero, titleContinueSrcX
      sb $v0, 0x000C($v1)
      lw $v1, 0x042C($gp)
      ; srcY
      ori $v0, $zero, titleContinueSrcY
      sb $v0, 0x000D($v1)
      lw $v1, 0x042C($gp)
      ori $t3, $zero, 0x0080
      sb $t3, 0x0004($v1)
      lw $a0, 0x042C($gp)
      ; dstX
      ori $v0, $zero, titleContinueDstX
      sh $v0, 0x0008($v1)
      ; dstY
      ori $v0, $zero, titleContinueDstY
      sh $v0, 0x000A($v1)
      sb $t3, 0x0005($a0)
      lw $v0, 0x042C($gp)
      nop 
      sb $t3, 0x0006($v0)
      lw $a0, 0x042C($gp)
      jal setRectRenderCmdTransparency
      addu $a1, $zero, $zero
      lui $v0, 0x8005
      lw $v0, 0x48C0($v0)
      lw $v1, 0x042C($gp)
      andi $v0, $v0, 0x0001
      beq $v0, $zero, @@noFlash_continue
      addu $s1, $zero, $zero
      ; if selected (flashing palette needed)
        lw $t3, 0x0060($sp)
        nop 
        sra $v0, $t3, 1
        andi $v0, $v0, 0x0006
        lui $at, 0x800A
        addu $at, $at, $v0
        lhu $v0, 0xB916($at)
        j @@flashCheckDone_continue
        nop 
      ; else
      @@noFlash_continue:
        ; *0x8009B912 = 0x7B45 = x 0x50, y 0x1ED = gpu 0xF6850
        lui $v0, 0x800A
        lhu $v0, 0xB912($v0)
      @@flashCheckDone_continue:
      lw $a0, 0x02C0($gp)
      lw $a1, 0x042C($gp)
      ori $s0, $zero, 0x00A8
      ; "‚Â‚Ã‚«"
      jal linkIntoDisplayList
      sh $v0, 0x000E($v1)
      
      lui $a0, 0x800A
      addiu $a0, $a0, 0xB916
      lw $t3, 0x0060($sp)
      lw $v1, 0x042C($gp)
      sra $v0, $t3, 1
      andi $v0, $v0, 0x0006
      addu $s2, $v0, $a0
      addiu $v1, $v1, 0x0014
      sw $v1, 0x042C($gp)
    
      j 0x8001C28C
      nop
      
    .endarea

  ;============================================================================
  ; MODIFICATION:
  ; 8-bit credits string encoding
  ;============================================================================
    
    ; fetch 1 byte at a time
    .org 0x8001F2CC
;      lh $v0, 0x0000($s1)
      ; note: unsigned -- we're scrapping a feature where
      ; negative values offset the x-position backwards
      lbu $v0, 0x0000($s1)
    
    ; another read done during character conversion
    .org 0x8001F330
;      lhu $v0, 0x0000($s1)
      lbu $v0, 0x0000($s1)
    
    ; counter check value
    .org 0x8001F40C
      slti $v0, $s3, opCreditsCharsPerString
    
    ; advance 1 byte in src per loop
    .org 0x8001F414
;      addiu $s1, $s1, 0x0002
      addiu $s1, $s1, 0x0001

  ;============================================================================
  ; MODIFICATION:
  ; special width for space character
  ;============================================================================
    
    .org 0x8001F2E0
      addiu $s0, $s0, opCreditsSpaceWidth

  ;============================================================================
  ; MODIFICATION:
  ; extra init at start of credits page rendering
  ;============================================================================
    
    .org 0x8001F284
      j doOpCreditsExtraInit
      nop

  ;============================================================================
  ; MODIFICATION:
  ; extra init at start of credits string rendering
  ;============================================================================
      
    .org 0x8001F29C
      j doOpCreditsExtraStringStartInit
      nop

  ;============================================================================
  ; MODIFICATION:
  ; variable-width lookup for op credits
  ;============================================================================
    
    .org 0x8001F3C8
      j doOpCreditsWidthLookup
      nop

  ;============================================================================
  ; MODIFICATION:
  ; extra cleanup at end of credits page rendering
  ;============================================================================
    
    .org 0x8001F438
      j doOpCreditsExtraCleanup
      nop

  ;============================================================================
  ; MODIFICATION:
  ; kerning adjustment for opening credits
  ;============================================================================
    
    .org 0x8001F2F8
      j doOpCreditsKerning
      nop

  ;============================================================================
  ; MODIFICATION: 
  ; new strings for op credits
  ;============================================================================
    
    .loadtable "table/pom_op_en.tbl"
    
    ;============
    ; page 1: 0-4
    ;============
    
    .org 0x8001048C+(0*2)
      ; x/y
      .db 0x20,0x20
    .org 0x80010158+(0*40)
    .area 40,0x00
      ; okay, so i wanted to put the japanese strings in here as comments,
      ; but it turns out armips does NOT like that and will silently
      ; throw away lines or something?
      ; do look in the notes file instead.
      ; this is an old version, so i sure hope they've fixed this since!
;      .stringn "Art Director"
      .stringn "Art Director"
    .endarea
    
    .org 0x8001048C+(1*2)
      ; x/y
      .db 0x20,0x32
    .org 0x80010158+(1*40)
    .area 40,0x00
      .stringn "Satoru Higashida"
    .endarea
    
    .org 0x8001048C+(2*2)
      ; x/y
      .db 0xCA-1,0xA4
    .org 0x80010158+(2*40)
    .area 40,0x00
      .stringn "Art"
    .endarea
    
    .org 0x8001048C+(3*2)
      ; x/y
      .db 0x60-1,0xB6
    .org 0x80010158+(3*40)
    .area 40,0x00
      .stringn "Masao Horiguchi"
    .endarea
    
    .org 0x8001048C+(4*2)
      ; x/y
      .db 0x60-1+1,0xC8
    .org 0x80010158+(4*40)
    .area 40,0x00
      .stringn "Masafumi Ogura"
    .endarea
    
    ;============
    ; page 2: 5-9
    ;============
    
    .org 0x8001048C+(5*2)
      ; x/y
;      .db 0x0C,0x30
      ; this credit has a different position from the other
      ; "upper-left" credits for some reason.
      ; there doesn't seem to be any significance to it and it looks odd
      ; now that i notice it, so i'm moving it to the normal position.
      .db 0x20,0x20
    .org 0x80010158+(5*40)
    .area 40,0x00
      .stringn "Art Director"
    .endarea
    
    .org 0x8001048C+(6*2)
      ; x/y
;      .db 0x0C,0x42
      .db 0x20,0x32
    .org 0x80010158+(6*40)
    .area 40,0x00
      .stringn "Yasuki Sekihara"
    .endarea
    
    .org 0x8001048C+(7*2)
      ; x/y
;      .db 0xA0,0xA4
      .db 0xCA-1,0xA4
    .org 0x80010158+(7*40)
    .area 40,0x00
      .stringn "Art"
    .endarea
    
    .org 0x8001048C+(8*2)
      ; x/y
;      .db 0xA0,0xB6
      .db 0x41,0xB6
    .org 0x80010158+(8*40)
    .area 40,0x00
      .stringn "Masamichi Sekikawa"
    .endarea
    
    .org 0x8001048C+(9*2)
      ; x/y
;      .db 0xA0,0xC8
      .db 0x67+1,0xC8
    .org 0x80010158+(9*40)
    .area 40,0x00
      .stringn "Tateki Ishikawa"
    .endarea
    
    ;============
    ; page 3: 10-13
    ;============
    
    
    .org 0x8001048C+(10*2)
      ; x/y
      .db 0x20,0x20
    .org 0x80010158+(10*40)
    .area 40,0x00
      .stringn "Music"
    .endarea
    
    .org 0x8001048C+(11*2)
      ; x/y
      .db 0x20,0x32
    .org 0x80010158+(11*40)
    .area 40,0x00
      ; note: i'm following the original capitalization from the opening here.
      ; the ending credits list this as "h.ToBetA" instead.
      ; (and this person's real name is "Hideki Tobeta" per the guidebook)
      .stringn "h. TobetA"
    .endarea
    
    .org 0x8001048C+(12*2)
      ; x/y
      .db 0x98+25,0xB6
    .org 0x80010158+(12*40)
    .area 40,0x00
      .stringn "Sound"
    .endarea
    
    .org 0x8001048C+(13*2)
      ; x/y
      .db 0x67+1,0xC7
    .org 0x80010158+(13*40)
    .area 40,0x00
      .stringn "Kanta Watanabe"
    .endarea
    
    ;============
    ; page 4: 14-15
    ;============
    
    .org 0x8001048C+(14*2)
      ; x/y
      .db 0x20,0x20
    .org 0x80010158+(14*40)
    .area 40,0x00
      .stringn "Direction & Scenario"
    .endarea
    
    .org 0x8001048C+(15*2)
      ; x/y
      .db 0x20,0x32
    .org 0x80010158+(15*40)
    .area 40,0x00
      .stringn "Yasuyuki Hayasaka"
    .endarea
    
    ;============
    ; page ???: 16-17
    ; not displayed.
    ; this is a credit for Masaya Kon'ya, who is listed in the ending
    ; credits under "produce".
    ; try setting 0x800104BB to 4 to see it on the same page as
    ; the previous two, though since it's centered, it was probably
    ; meant to be on a different one.
    ; i'm guessing it was meant to go on the same page as the fill in cafe
    ; copyright, which is positioned oddly low on the screen;
    ; these strings would fit perfectly above it.
    ;============
    
    .org 0x8001048C+(16*2)
      ; x/y
;      .db 0x60,0x58
      .db 0x5A,0x58
    .org 0x80010158+(16*40)
    .area 40,0x00
      .stringn "Producer"
    .endarea
    
    .org 0x8001048C+(17*2)
      ; x/y
;      .db 0x60,0x6A
      .db 0x45,0x6A
    .org 0x80010158+(17*40)
    .area 40,0x00
      .stringn "Masaya Kon'ya"
    .endarea
    
    ;============
    ; page 5: 18-19
    ;============
    
    .org 0x8001048C+(18*2)
      ; x/y
;      .db 0x60,0x8A
;      .db 0x18,0x6E
      .db 0x18,0x8A
    .org 0x80010158+(18*40)
    .area 40,0x00
      .stringn "Produced by & Copyright"
    .endarea
    
    .org 0x8001048C+(19*2)
      ; x/y
;      .db 0x60,0x9C
;      .db 0x30,0x80
      .db 0x30+1,0x9C
    .org 0x80010158+(19*40)
    .area 40,0x00
      .stringn "Fill in Cafe Co., Ltd."
    .endarea

  ;============================================================================
  ; NEW STUFF
  ;============================================================================
   
  .org newCodeStartSection
  .area newCodeEndSection-.,0xFF
  
    .align 4

    ;============================================================================
    ; extra init for opening credits rendering
    ;============================================================================
    
    doOpCreditsExtraInit:
      ; temporarily set opCreditsGeneralRenderPosGp to our own
      ; memory space.
      ; there's not enough room for all the characters otherwise.
      ; FIXME: front/back buffers
/*      lw $a0,opCreditsGeneralRenderPosGp($gp)
      la $a1,opCreditsCharRenderSpaceFront
      ; save old position
      sw $a0,opCreditsOldGeneralRenderPos
      sw $a1,opCreditsGeneralRenderPosGp($gp) */
      
      ; make up work
      lbu $v0, 0x0001($v0)
      nop
      j 0x8001F28C
      nop
    
/*    opCreditsOldGeneralRenderPos:
      .dw 0
    
    opCreditsCharRenderSpaceFront:
      .fill opCreditsMaxOnscreenChars*bytesPerVarWidthRectRenderCmd,0x00
    opCreditsCharRenderSpaceBack:
      .fill opCreditsMaxOnscreenChars*bytesPerVarWidthRectRenderCmd,0x00
    .align 4 */

    ;============================================================================
    ; extra cleanup for opening credits rendering
    ;============================================================================
    
    doOpCreditsExtraCleanup:
      ; restore old opCreditsGeneralRenderPosGp
/*      lw $v0,opCreditsOldGeneralRenderPos
      nop
      sw $v0,opCreditsGeneralRenderPosGp($gp) */
      
      ; make up work
      addu $a1, $zero, $zero
      j 0x8001F440
      lw $a0, 0x02A4($gp)

    ;============================================================================
    ; extra init for opening credits string rendering
    ;============================================================================
    
    doOpCreditsExtraStringStartInit:
      ; reset last char id
      sb $zero,lastPrintedCharID
      
      ; make up work
      lbu $v0, 0x0000($v0)
      j 0x8001F2A4
      addu $s3, $zero, $zero
      
      lastPrintedCharID:
        .db 0
      .align 4

    ;============================================================================
    ; kerning adjustment for opening credits
    ;============================================================================
    
    doOpCreditsKerning:
      ; s0 = x-position we want to update
      
      ; make up work
      jal 0x8003FF1C
      nop
      
      ; v1 = target char id
      lbu $v1, 0x0000($s1)
      ; v0 = last char id
      lbu $v0,lastPrintedCharID
      ; a0 = kerning matrix pointer
      la $a0,kerningMatrix
      ; v0 = last char id * chars per row (256)
      sll $v0,8
      ; add current char id
      addu $v0,$v1
      ; a0 = pointer to kerning matrix entry
      addu $a0,$v0
      
      ; v0 = kerning amount (signed)
      lb $v0,0($a0)
      nop
      ; add to x
      addu $s0,$v0
      
      j 0x8001F300
      nop
      
      ; note; this is a stupidly big (64kb) matrix identifying exactly
      ; how every possible combination of characters kerns together.
      ; it's extremely sparse and very wasteful, but we have the space,
      ; so why not?
      kerningMatrix:
        .incbin "out/font/op_kerning.bin"
      .align 4

    ;============================================================================
    ; update x-pos in opening credits based on printed character's width
    ;============================================================================
    
    doOpCreditsWidthLookup:
      ; s0 = x-position we want to update
      ; s1 = pointer to target char ID
      
      ; make up work
      jal setRectRenderCmdTransparency
      nop
      
      ; a0 = target char ID
      lbu $a0,0($s1)
      ; a1 = pointer to width entry
      la $a1,opFontWidthTable
      ; update last printed char id
      sb $a0,lastPrintedCharID
      addu $a1,$a0
      ; a0 = width
      lbu $a0,0($a1)
      nop
      
      ; add width to x
      addu $s0,$a0
      
      j 0x8001F3D0
      nop
    
  
    opFontWidthTable:
      .incbin "out/font/op_width.bin"
    .align 4

    ;============================================================================
    ; pad to end of sector
    ;============================================================================
    
    .align 0x800
      
  .endarea

  ;============================================================================
  ; modifications
  ;============================================================================
  
  ; transfer width/height of textures in dlog display queue (-1?)
;  .org 0x80015708
;    addiu $t7, $zero, 0x000F+1

  ;============================================================================
  ; calls to new code
  ;============================================================================

  
  ;=========================================
  ; assign a char to the current char gpu slot
  ; and increment the slot.
  ; 
  ; returns:
  ; s0 = target gpu x
  ; s1 = target gpu y
  ;=========================================

;  .org 0x800180C0
;    j assignNextCharGpuSlot
    ; !! next instruction will get executed as a slot here,
    ;    but it doesn't matter and we'll need it later, so it stays

  ;============================================================================
  ; NEW STUFF
  ;============================================================================
;.area 0x1000

;  .org 0x801FD000
  
  ;  .ascii "test"
  
  ;=========================================
  ; for dlog op, reset vwf
  ; before starting new message
  ;=========================================
  
;   extraDlogInit:
;     ; trash something on the stack so we can save ra
;     sw $ra,0($sp)
;   
;     ; queue off
;     la $v0,vwfQueueActive
;     ; reset positioning data
;     jal resetVwfForLine
; ;    nop
;     sb $zero,0($v0)
;     
;     ; make up work
;     lw $ra,0($sp)
;     nop
;     jr $ra
;     addiu $sp, $sp, 0x0008
  
.close

  
