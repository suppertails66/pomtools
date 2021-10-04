
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
  linkIntoDisplayList equ 0x8001B768
  
  setRectRenderCmdTransparency equ 0x8001B81C
  
  addBigDisplayString equ 0x80016E64
  addSmallDisplayString equ 0x80016F5C
  addBigScrollString equ 0x8001705C
  addSmallScrollString equ 0x8001716C
  
;  memcpy equ 0x80100820
;  memcmp equ 0x801008B4
;  memset equ 0x801009A0

;========================================
; old memory
;========================================
  
;  nameScreenNameEntryBuffer equ 0x8012C624
  
  currentDisplayStructPtr_gp equ 0x200
  
  currentDisplayStructListOffset equ 0x70
  currentDisplayStructListStdTarget equ 0x26C

;========================================
; defines
;========================================

  ; reserved area for strings auto-placed by script generator
  creditsOverwriteFreeAreaStart equ 0x80100000
  creditsOverwriteFreeAreaEnd equ 0x80101000
  
  creditsScreenW equ 320
  creditsScreenH equ 240
  subtitlesUpperBaseY equ 20
  subtitlesLowerBaseY equ creditsScreenH-subtitlesUpperBaseY
  
  colorGradientPixelW equ 4
  
  ; these are loaded in with SPRITE.TIM
  fontTranslationClut equ 0x7FC8
  fontKaraokeFgClut equ 0x7FC9
  fontKaraokeBgClut equ 0x7FCA
  fontGradientClutBase equ 0x7FCB

;========================================
; structs
;========================================
  
  ;==================================
  ; sub render state structs
  ;==================================
  
  ;======
  ; subTargetPoint
  ;======
  
  subTargetPoint_size       equ 12
    ; 4
    subTargetPoint_time             equ 0
    ; 4
    subTargetPoint_pixelX           equ 4
    ; 4
    subTargetPoint_bytePos          equ 8
  
  ;======
  ; subRenderBuf
  ;======
  
  maxSubTargetPoints equ 16
  subRenderBuf_pointDataSize equ (maxSubTargetPoints * subTargetPoint_size)
  
  subRenderBuf_size          equ 20+subRenderBuf_pointDataSize
    ; 4
    subRenderBuf_srcStrPtr          equ 0
    ; 4
    subRenderBuf_srcStrW            equ 4
    ; 4
    subRenderBuf_baseClut           equ 8
    ; 4
    subRenderBuf_numPoints          equ 12
    ; 4
    subRenderBuf_currentPointIndex  equ 16
    ; (maxSubTargetPoints * subTargetPoint_size)
    subRenderBuf_pointData          equ 20

  .macro makeSubRenderBuf,label
    .align 4
    label:
      ; srcStrPtr
      .dw 0
      ; srcStrW
      .dw 0
      ; baseClut
      .dh 0
      ; numPoints
      .dh 0
      ; currentPointIndex
      .db 0
      ; pointData
      .fill subRenderBuf_pointDataSize,0
    .align 4
  .endmacro

;============================================================================
; SLPS_008.17
;============================================================================
  
  ; this executable doesn't use much memory, so we just occupy
  ; a big chunk of it with our new code and data
  newCodeSectionSize equ 0x20000
  newCodeStartSection equ creditsOverwriteFreeAreaEnd
  newCodeEndSection   equ creditsOverwriteFreeAreaEnd+newCodeSectionSize
  
.open "out/asm/POM_END.EXE", 0x8000F800
; size field in exe header
;.org 0x8000F800+0x1C
;  .word 0x1EE000
.org 0x8000F800+0x1C
  .word newCodeEndSection-0x80010000

  ;============================================================================
  ; MODIFICATION:
  ; replace targeted strings by pointers as needed
  ;============================================================================
    
    .org 0x80016E64
      j fix_addBigDisplayString
      nop
    
    .org 0x80016F5C
      j fix_addSmallDisplayString
      nop
    
    .org 0x8001705C
      j fix_addBigScrollString
      nop
    
    .org 0x8001716C
      j fix_addSmallScrollString
      nop
      
  
/*  ; r
  .org 0x80019060
    li $v0,0x40
  ; g
  .org 0x80019070
    li $v0,0x80
  ; b
  .org 0x80019080
    li $v0,0x80
  
  .org 0x800190BC
    li $a1,0*/

  ;============================================================================
  ; MODIFICATION:
  ; swap our render buffers at same time as originals
  ;============================================================================
  
    .org 0x80017FD8
      j doNewRenderBufferSwap
      ori $a1, $zero, 0x0080

  ;============================================================================
  ; MODIFICATION:
  ; start subtitle timer after cd audio starts
  ;============================================================================
    
    .org 0x80012144
      j startSubtitleTimer
      nop

  ;============================================================================
  ; MODIFICATION:
  ; do subtitle update and render in renderScene
  ;============================================================================
    
;    .org 0x800190F4
;      j doSubtitleUpdateAndRender
;      nop
    
    ; turns out this function renders most elements front-to-back
    ; in the final display list entry,
    ; so we need to do the subtitle rendering before anything else
    ; rather than after
    .org 0x800187B4
      j doSubtitleUpdateAndRender
      sw $s0, 0x0050($sp)

  ;============================================================================
  ; MODIFICATION:
  ; tick subtitle counter in vblank handler(?)
  ;============================================================================
      
/*    .org 0x800231A8
      j tickSubtitleCounter
      nop */

  ;============================================================================
  ; MODIFICATION:
  ; use new line content table for rolling credits
  ;============================================================================
  
    .org 0x8001482C
      lui $at, ((creditsLineTable & 0xFFFF0000) >> 16)
      addu $at, $at, $v0
      lw $v0, (creditsLineTable & 0xFFFF)($at)
    
    ; use new line count
    org 0x80014820
      sltiu $v0, $v1, ((creditsLineTableEnd - creditsLineTable) / 4)

  ;============================================================================
  ; MODIFICATION:
  ; use creditsExtraYOffset
  ;============================================================================
  
/*    .org 0x8001705C
      j doExtraCreditsYOffsetBig
      nop
  
    .org 0x8001716C
      j doExtraCreditsYOffsetSmall
      nop */
  
  ;============================================================================
  ; NEW STUFF
  ;============================================================================
   
  .org newCodeStartSection
  .area newCodeEndSection-.,0xFF
  
    .align 4

    ;============================================================================
    ; staff roll modifications
    ;============================================================================
    
      creditsEmptyLine equ 0x8001520C
      creditsTerminateSeq equ 0x80015208
      creditsSwitchEnd equ 0x8001520C
      
      ; new value that offsets the y-position of all calls to
      ; addBigScrollString and addSmallScrollString by a given amount
      ; to facilitate changes to the layout of the credits
      creditsExtraYOffset:
        .dw 0
      
/*      decrementCreditsExtraYOffset:
        la $v0,creditsExtraYOffset
        lw $v1,0($v0)
        nop
        subiu $v1,32
        jr $ra
        sw $v1,0($v0) */
      
      decrementCreditsExtraYOffset_switchEnd:
        la $v0,creditsExtraYOffset
        lw $v1,0($v0)
        nop
        subiu $v1,16
        j creditsSwitchEnd
        sw $v1,0($v0)
      
      incrementCreditsExtraYOffset_switchEnd:
        la $v0,creditsExtraYOffset
        lw $v1,0($v0)
        nop
        addiu $v1,16
        j creditsSwitchEnd
        sw $v1,0($v0)
      
      doExtraCreditsYOffsetBig:
        lw $v0,creditsExtraYOffset
        nop
        addu $a1,$v0
        
        addiu $sp, $sp, 0xFFC8
        j 0x80017064
        sw $s0, 0x0020($sp)
      
      doExtraCreditsYOffsetSmall:
        lw $v0,creditsExtraYOffset
        nop
        addu $a1,$v0
        
        addiu $sp, $sp, 0xFFC8
        j 0x80017174
        sw $s0, 0x0020($sp)

/*      creditsLineTable:
        ; 0
        ; "STAFF"
        .dw 0x80014844
        .dw creditsEmptyLine
        .dw 0x80014858
        .dw 0x80014874
        .dw creditsEmptyLine
        .dw 0x80014890
        .dw 0x800148AC
        .dw creditsEmptyLine
        .dw 0x800148B8
        .dw 0x800148D4
        ; 10
        .dw creditsEmptyLine
        .dw 0x800148E0
        .dw 0x800148FC
        .dw 0x80014908
        .dw creditsEmptyLine
        .dw 0x80014914
        .dw 0x80014930
        .dw creditsEmptyLine
        .dw 0x8001494C
        .dw 0x80014968
        ; 20
        .dw 0x80014974
        .dw creditsEmptyLine
        .dw 0x80014980
        .dw 0x8001499C
        .dw creditsEmptyLine
        .dw 0x800149A8
        .dw 0x800149C4
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        ; "SCENARIO"
        .dw 0x800149D0
        ; 30
        .dw creditsEmptyLine
        .dw 0x800149E4
        .dw 0x80014A00
        .dw creditsEmptyLine
        .dw 0x80014A20
        .dw 0x80014A3C
        .dw creditsEmptyLine
        .dw 0x80014A48
        .dw 0x80014A64
        .dw creditsEmptyLine
        ; 40
        .dw creditsEmptyLine
        ; "VISUALS"
        .dw 0x80014A70
        .dw creditsEmptyLine
        .dw 0x80014A84
        .dw 0x80014AA0
        .dw creditsEmptyLine
        .dw 0x80014AAC
        .dw 0x80014AC8
        .dw creditsEmptyLine
        .dw 0x80014AD4
        ; 50
        .dw 0x80014AF0
        .dw creditsEmptyLine
        .dw 0x80014AFC
        .dw 0x80014B18
        .dw 0x80014B38
        .dw creditsEmptyLine
        .dw 0x80014B44
        .dw 0x80014B60
        .dw creditsEmptyLine
        .dw 0x80014B80
        ; 60
        .dw 0x80014B9C
        .dw 0x80014BA8
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        ; "AUDIO"
        .dw 0x80014BC8
        .dw creditsEmptyLine
        .dw 0x80014BDC
        .dw 0x80014BF8
        .dw creditsEmptyLine
        .dw 0x80014C18
        ; 70
        .dw 0x80014C34
        .dw creditsEmptyLine
        .dw 0x80014C40
        .dw 0x80014C5C
        .dw creditsEmptyLine
        ; "ending song"
;        .dw 0x80014C78
;        .dw 0x80014CA8
        .dw creditsNewEndSong1
        .dw creditsNewEndSong2
        .dw creditsEmptyLine
        .dw 0x80014CD8
        .dw 0x80014CF4
        ; 80
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        ; "SYSTEM"
        .dw 0x80014D00
        .dw creditsEmptyLine
        .dw 0x80014D14
        .dw 0x80014D30
        .dw creditsEmptyLine
        .dw 0x80014D3C
        .dw 0x80014D58
        .dw creditsEmptyLine
        ; 90
        .dw 0x80014D78
        .dw 0x80014D94
        .dw creditsEmptyLine
        .dw 0x80014DB4
        .dw 0x80014DD0
        .dw creditsEmptyLine
        .dw 0x80014DF0
        .dw 0x80014E0C
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        ; 100
        ; "TEST PLAYERS"
        .dw 0x80014E2C
        .dw 0x80014E40
        .dw 0x80014E5C
        .dw 0x80014E78
        .dw creditsEmptyLine
        .dw 0x80014E94
        .dw 0x80014EB0
        .dw 0x80014ECC
        .dw 0x80014EE8
        .dw 0x80014F04
        ; 110
        .dw 0x80014F20
        .dw 0x80014F3C
        .dw 0x80014F58
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        ; "PUBLICITY"
        .dw 0x80014F74
        .dw creditsEmptyLine
        .dw 0x80014F88
        .dw 0x80014FA4
        .dw 0x80014FC0
        ; 120
        .dw creditsEmptyLine
        .dw 0x80014FDC
        .dw 0x80014FF8
        .dw 0x80015014
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        ; "SUPERVISOR"
        .dw 0x80015030
        .dw creditsEmptyLine
        .dw 0x80015044
        .dw creditsEmptyLine
        ; 130
        .dw creditsEmptyLine
        ; "SPECIAL THANKS"
        .dw 0x80015060
        .dw creditsEmptyLine
        .dw 0x80015074
        .dw 0x80015090
        .dw 0x800150AC
        .dw 0x800150C8
        .dw 0x800150D4
        .dw 0x800150F0
        .dw 0x80015110
        ; 140
        .dw 0x8001512C
        .dw 0x80015148
        .dw creditsEmptyLine
        .dw 0x80015164
        .dw 0x80015180
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        ; "PRODUCER"
        .dw 0x8001519C
        .dw creditsEmptyLine
        ; 150
        ; Y = 0xA50
        .dw 0x800151D0
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        ; 160
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        ; "copyright fill in cafe"
        ; Y = 0xB10
        .dw 0x800151EC
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        ; 170
        .dw creditsTerminateSeq
      creditsLineTableEnd: */

      creditsLineTable:
        ; 0
        ; "STAFF"
        .dw 0x80014844
        .dw creditsEmptyLine
        .dw 0x80014858
        .dw 0x80014874
        .dw creditsEmptyLine
        .dw 0x80014890
        .dw 0x800148AC
        .dw creditsEmptyLine
        .dw 0x800148B8
        .dw 0x800148D4
        ; 10
        .dw creditsEmptyLine
        .dw 0x800148E0
        .dw 0x800148FC
        .dw 0x80014908
        .dw creditsEmptyLine
        .dw 0x80014914
        .dw 0x80014930
        .dw creditsEmptyLine
        .dw 0x8001494C
        .dw 0x80014968
        ; 20
        .dw 0x80014974
        .dw creditsEmptyLine
        .dw 0x80014980
        .dw 0x8001499C
        .dw creditsEmptyLine
        .dw 0x800149A8
        .dw 0x800149C4
        .dw decrementCreditsExtraYOffset_switchEnd
        ; "SCENARIO"
        .dw 0x800149D0
        ; 30
        .dw creditsEmptyLine
        .dw 0x800149E4
        .dw 0x80014A00
        .dw creditsEmptyLine
        .dw 0x80014A20
        .dw 0x80014A3C
        .dw creditsEmptyLine
        .dw 0x80014A48
        .dw 0x80014A64
        .dw decrementCreditsExtraYOffset_switchEnd
        ; 40
        ; "VISUALS"
        .dw 0x80014A70
        .dw creditsEmptyLine
        .dw 0x80014A84
        .dw 0x80014AA0
        .dw creditsEmptyLine
        .dw 0x80014AAC
        .dw 0x80014AC8
        .dw creditsEmptyLine
        .dw 0x80014AD4
        ; 50
        .dw 0x80014AF0
        .dw creditsEmptyLine
        .dw 0x80014AFC
        .dw 0x80014B18
        .dw 0x80014B38
        .dw creditsEmptyLine
        .dw 0x80014B44
        .dw 0x80014B60
        .dw creditsEmptyLine
        .dw 0x80014B80
        ; 60
        .dw 0x80014B9C
        .dw 0x80014BA8
        .dw decrementCreditsExtraYOffset_switchEnd
        ; "AUDIO"
        .dw 0x80014BC8
        .dw creditsEmptyLine
        .dw 0x80014BDC
        .dw 0x80014BF8
        .dw creditsEmptyLine
        .dw 0x80014C18
        ; 70
        .dw 0x80014C34
        .dw creditsEmptyLine
        .dw 0x80014C40
        .dw 0x80014C5C
        .dw creditsEmptyLine
        ; "ending song"
;        .dw 0x80014C78
;        .dw 0x80014CA8
        .dw creditsNewEndSong1
        .dw creditsNewEndSong2
        .dw creditsEmptyLine
        .dw 0x80014CD8
        .dw 0x80014CF4
        ; 80
        .dw decrementCreditsExtraYOffset_switchEnd
        ; "SYSTEM"
        .dw 0x80014D00
        .dw creditsEmptyLine
        .dw 0x80014D14
        .dw 0x80014D30
        .dw creditsEmptyLine
        .dw 0x80014D3C
        .dw 0x80014D58
        .dw creditsEmptyLine
        ; 90
        .dw 0x80014D78
        .dw 0x80014D94
        .dw creditsEmptyLine
        .dw 0x80014DB4
        .dw 0x80014DD0
        .dw creditsEmptyLine
        .dw 0x80014DF0
        .dw 0x80014E0C
        .dw decrementCreditsExtraYOffset_switchEnd
        ; 100
        ; "TEST PLAYERS"
        .dw 0x80014E2C
        .dw 0x80014E40
        .dw 0x80014E5C
        .dw 0x80014E78
        .dw creditsEmptyLine
        .dw 0x80014E94
        .dw 0x80014EB0
        .dw 0x80014ECC
        .dw 0x80014EE8
        .dw 0x80014F04
        ; 110
        .dw 0x80014F20
        .dw 0x80014F3C
        .dw 0x80014F58
        .dw decrementCreditsExtraYOffset_switchEnd
        ; "PUBLICITY"
        .dw 0x80014F74
        .dw creditsEmptyLine
        .dw 0x80014F88
        .dw 0x80014FA4
        .dw 0x80014FC0
        ; 120
        .dw creditsEmptyLine
        .dw 0x80014FDC
        .dw 0x80014FF8
        .dw 0x80015014
        .dw decrementCreditsExtraYOffset_switchEnd
        ; "SUPERVISOR"
        .dw 0x80015030
        .dw creditsEmptyLine
        .dw 0x80015044
        .dw decrementCreditsExtraYOffset_switchEnd
        ; 130
        ; "SPECIAL THANKS"
        .dw 0x80015060
        .dw creditsEmptyLine
        .dw 0x80015074
        .dw 0x80015090
        .dw 0x800150AC
        .dw 0x800150C8
        .dw 0x800150D4
        .dw 0x800150F0
        .dw 0x80015110
        ; 140
        .dw 0x8001512C
        .dw 0x80015148
        .dw creditsEmptyLine
        .dw 0x80015164
        .dw 0x80015180
        .dw creditsEmptyLine
        .dw decrementCreditsExtraYOffset_switchEnd
        ; "PRODUCER"
        .dw 0x8001519C
        .dw creditsEmptyLine
        ; 150
        ; Y = 0xA50
        ; we've offset by 9 lines = 0x120 pixels,
        ; so effectively 0x930
        .dw 0x800151D0
        ; EXTRA START
        ; 0x950
        .dw incrementCreditsExtraYOffset_switchEnd
        .dw incrementCreditsExtraYOffset_switchEnd
        .dw creditsTranslationLine1
        .dw incrementCreditsExtraYOffset_switchEnd
        .dw creditsTranslationLine2
        .dw creditsTranslationLine3
        .dw creditsTranslationLine4
        .dw creditsTranslationLine5
        .dw incrementCreditsExtraYOffset_switchEnd
        ; EXTRA END
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        ; 160
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        ; "copyright fill in cafe"
        ; Y = 0xB10
        .dw 0x800151EC
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        .dw creditsEmptyLine
        ; 170
        .dw creditsTerminateSeq
      creditsLineTableEnd:
    
      creditsNewEndSong1:
        ori $a0, $zero, 0x0010
        lui $a2, 0x8001
        addiu $a2, $a2, 0x074C
        jal addSmallScrollString
        ori $a1, $zero, 0x05A0
/*        ori $a0, $zero, 0x0072
        ; to avoid having to add non-ascii support to the small font
        ; just to print 「ペリエ」, the title of the ending theme,
        ; someone got creative and put the characters in the big font
        ; instead.
        ; they're superimposed on the previous line in the spot where they
        ; need to appear.
        lui $a2, 0x8003
        addiu $a2, $a2, 0xAED8
        jal addBigScrollString
        ori $a1, $zero, 0x059E */
        j creditsSwitchEnd
        nop 
        
      creditsNewEndSong2:
        ; "lyrics & vocals"
        ori $a0, $zero, 0x0010
        lui $a2, 0x8001
        addiu $a2, $a2, 0x0764
        jal addSmallScrollString
        ori $a1, $zero, 0x05B0
        ; "kaori saitoh"
        ; move to the right to account for change from
        ; "lyric & vocal" to "lyrics & vocals"
        ori $a0, $zero, 0x0082+24
        lui $a2, 0x8001
        addiu $a2, $a2, 0x0774
        jal addBigScrollString
        ori $a1, $zero, 0x05AE
        j creditsSwitchEnd
        nop 
      
      creditsNewContentNominalY equ 0xA60
        
      creditsTranslationLine1:
        li $a0,0x10
        li $a1,creditsNewContentNominalY+0x00
        la $a2,creditsNewString0
        jal addSmallScrollString
        nop
        li $a0,0x10
        li $a1,creditsNewContentNominalY+0x08
        la $a2,creditsNewString1
        jal addSmallScrollString
        nop
        j incrementCreditsExtraYOffset_switchEnd
        nop
        
      creditsTranslationLine2:
        li $a0,0x10
        li $a1,creditsNewContentNominalY+0x00
        la $a2,creditsNewString2
        jal addSmallScrollString
        nop
        li $a0,0x10
        li $a1,creditsNewContentNominalY+0x08
        la $a2,creditsNewString3
        jal addSmallScrollString
        nop
        j incrementCreditsExtraYOffset_switchEnd
        nop
        
      creditsTranslationLine3:
        li $a0,0x10
        li $a1,creditsNewContentNominalY+0x00
        la $a2,creditsNewString4
        jal addSmallScrollString
        nop
        li $a0,0x10
        li $a1,creditsNewContentNominalY+0x08
        la $a2,creditsNewString5
        jal addSmallScrollString
        nop
        j incrementCreditsExtraYOffset_switchEnd
        nop
        
      creditsTranslationLine4:
        li $a0,0x10
        li $a1,creditsNewContentNominalY+0x00
        la $a2,creditsNewString6
        jal addSmallScrollString
        nop
        li $a0,0x10
        li $a1,creditsNewContentNominalY+0x08
        la $a2,creditsNewString7
        jal addSmallScrollString
        nop
        j incrementCreditsExtraYOffset_switchEnd
        nop
        
      creditsTranslationLine5:
        li $a0,0x10
        li $a1,creditsNewContentNominalY+0x00
        la $a2,creditsNewString8
        jal addSmallScrollString
        nop
        li $a0,0x10
        li $a1,creditsNewContentNominalY+0x08
        la $a2,creditsNewString9
        jal addSmallScrollString
        nop
        j incrementCreditsExtraYOffset_switchEnd
        nop
      
      ; lol, these all need to be word-aligned...
      ; because i specifically modified the print routines
      ; to read the first word and check if it's a pointer
      ; so i could redirect the existing strings.
      ; of course i forgot about this and couldn't figure out
      ; why the game was freezing every time it reached the new text.
      .align 4
      creditsNewString0:
        .incbin "out/script/endnew/endnew_0x0.bin"
      .align 4
      creditsNewString1:
        .incbin "out/script/endnew/endnew_0x1.bin"
      .align 4
      creditsNewString2:
        .incbin "out/script/endnew/endnew_0x2.bin"
      .align 4
      creditsNewString3:
        .incbin "out/script/endnew/endnew_0x3.bin"
      .align 4
      creditsNewString4:
        .incbin "out/script/endnew/endnew_0x4.bin"
      .align 4
      creditsNewString5:
        .incbin "out/script/endnew/endnew_0x5.bin"
      .align 4
      creditsNewString6:
        .incbin "out/script/endnew/endnew_0x6.bin"
      .align 4
      creditsNewString7:
        .incbin "out/script/endnew/endnew_0x7.bin"
      .align 4
      creditsNewString8:
        .incbin "out/script/endnew/endnew_0x8.bin"
      .align 4
      creditsNewString9:
        .incbin "out/script/endnew/endnew_0x9.bin"
      .align 4
      creditsNewStringA:
        .incbin "out/script/endnew/endnew_0xA.bin"
      .align 4
      creditsNewStringB:
        .incbin "out/script/endnew/endnew_0xB.bin"
      .align 4
    
    ;============================================================================
    ; hacks to replace targeted strings by pointers as needed
    ;============================================================================
    
      ; macro to check if a given register contains a pointer to
      ; a string pointer. if so, it replaces it with the pointed-to
      ; string pointer.
      ; this is fine since we're dealing with ascii strings and the 0x80+
      ; range for the top byte of the pointers in question is not valid content.
      .macro replaceIfTargetingStrPtr,srcReg
        lw $v0,0(srcReg)
        nop
        srl $v1,$v0,31
        beq $v1,$zero,@@noRep
        nop
          move srcReg,$v0
        @@noRep:
      .endmacro
    
      fix_addBigDisplayString:
        replaceIfTargetingStrPtr a2
        
        ; make up work
        addiu $sp, $sp, 0xFFC8
        j 0x80016E6C
        sw $s0, 0x0020($sp)
    
      fix_addSmallDisplayString:
        replaceIfTargetingStrPtr a2
        
        ; make up work
        addiu $sp, $sp, 0xFFC8
        j 0x80016F64
        sw $s0, 0x0020($sp)
    
      fix_addBigScrollString:
        replaceIfTargetingStrPtr a2
        
        lw $v0,creditsExtraYOffset
        nop
        addu $a1,$v0
        
        ; make up work
        addiu $sp, $sp, 0xFFC8
        j 0x80017064
        sw $s0, 0x0020($sp)
    
      fix_addSmallScrollString:
        replaceIfTargetingStrPtr a2
        
        lw $v0,creditsExtraYOffset
        nop
        addu $a1,$v0
        
        ; make up work
        addiu $sp, $sp, 0xFFC8
        j 0x80017174
        sw $s0, 0x0020($sp)

    ;============================================================================
    ; new rendering stuff
    ;============================================================================

      ;==================================
      ; new render buffers for subtitles
      ;==================================
      
      newRenderBufSize equ 0x4000
      
      newRenderBufA:
        .fill newRenderBufSize,0x00
      newRenderBufB:
        .fill newRenderBufSize,0x00
      
      .align 4
      
      ; pointer to current "back" buffer used for drawing
      currentRenderBufPtr:
        .dw newRenderBufA
      ; pointer to current put position in back buffer
      currentRenderBufPutPtr:
        .dw newRenderBufA
      ; bit 0 = current buffer party: 0 = targeting A, 1 = targeting B
      currentRenderBufParity:
        .dw 0
      
      newRenderBufPtrTbl:
        .dw newRenderBufA
        .dw newRenderBufB
      
      ; counter for timing subtitles
      ; incremented once per render frame (so don't lag the game)
      subtitleTimer:
        .dw 0
      ; subtitleTimer is only incremented if this is nonzero
      subtitleTimerOn:
        .dw 0

      ;==================================
      ; HACK: swap new render buffers
      ; between A and B at same time
      ; as regular ones
      ;==================================
      
      doNewRenderBufferSwap:
        ; make up work
        jal 0x8001C640
        nop
        
        ; a1 = *currentRenderBufParity
        la $a0,currentRenderBufParity
        lw $a1,0($a0)
        nop
        ; flip parity bit
        xori $a1,1
        ; save updated buffer parity value
        sw $a1,0($a0)
        ; use to look up new target buffer
        la $a0,newRenderBufPtrTbl
        sll $a1,2
        addu $a0,$a1
        ; a2 = new pointer
        lw $a2,0($a0)
        nop
        ; save new pointer
        sw $a2,currentRenderBufPtr
        sw $a2,currentRenderBufPutPtr
        
        ; increment subtitle timer if active
        lw $a2,subtitleTimerOn
        la $a0,subtitleTimer
        beq $a2,$zero,@@noTimerInc
        nop
          lw $a1,0($a0)
          nop
          addiu $a1,1
          sw $a1,0($a0)
        @@noTimerInc:
        
        j 0x80017FE0
        nop

      ;==================================
      ; HACK: update subtitle timer
      ; from vblank handler
      ; (i hope, maybe)
      ;==================================
      
/*      tickSubtitleCounter:
        ; increment subtitle timer if active
        lw $a2,subtitleTimerOn
        la $a0,subtitleTimer
        beq $a2,$zero,@@noTimerInc
        nop
          lw $a1,0($a0)
          nop
          addiu $a1,1
          sw $a1,0($a0)
        @@noTimerInc:
        
        ; make up work
        lui $a0, 0x8003
        j 0x800231B0
        lw $a0, 0xA558($a0) */

      ;==================================
      ; HACK: turn on subtitle timer
      ; once CD audio starts playing
      ;==================================
      
      initialSubtitleTimerValue equ 60
      
      startSubtitleTimer:
        ; make up work
        jal 0x80011A6C
        addu $a1, $zero, $zero
        
        ; turn on subtitle timer
        li $a0,1
        sw $a0,subtitleTimerOn
        
        ; there's a delay between the audio starting to play
        ; and this call actually occurring; account for that (hopefully)
        li $a0,initialSubtitleTimerValue
        sw $a0,subtitleTimer
        
        j 0x8001214C
        nop

      ;==================================
      ; do main subtitle update + rendering
      ;==================================
      
/*      doSubtitleUpdateAndRender:
        ; do nothing if subtitles not on
        lw $v0,subtitleTimerOn
        nop
        beq $v0,$zero,@@done
        nop
        
        ; run the interpreter until it encounters something
        ; that causes it to stop processing
        jal runSubtitleInterpreter
        nop
        
        ; render whatever we're currently supposed to display
        jal renderSubtitles
        nop
        
        @@done:
        ; make up work
        lw $ra, 0x0074($sp)
        j 0x800190FC
        lw $fp, 0x0070($sp) */
      
      doSubtitleUpdateAndRender:
        ; make up work
        jal 0x8001AAC8
        nop
        
        ; do nothing if subtitles not on
        lw $v0,subtitleTimerOn
        nop
        beq $v0,$zero,@@done
        nop
        
        ; run the interpreter until it encounters something
        ; that causes it to stop processing
        jal runSubtitleInterpreter
        nop
        
        ; render whatever we're currently supposed to display
        jal renderSubtitles
        nop
        
        @@done:
        j 0x800187BC
        nop

    ;============================================================================
    ; font
    ;============================================================================
      
      font_charH equ 16
      
      ; difference in codepoints between italic/standard charsets
      font_charSetOffset equ 0x60
      
      ; number of characters not used at top of font texpage
      ; (due to already being in use for other things)
      ; basically, add this to raw character id before doing conversion
      ; to get true codepoint
      font_texCharGap equ 0x30
      
      ; indices of characters with special properties
      font_spaceIndex equ 0x0000005F
      ; 'f'
;      font_fIndex1 equ 0x2A
;      font_fIndex2 equ font_fIndex1+font_charSetOffset
      ; 's'
;      font_sIndex1 equ 0x37
;      font_sIndex2 equ font_sIndex1+font_charSetOffset
      ; not real characters; used for point ops
      font_leftAngleBracketIndex equ 0x000000FD
      font_rightAngleBracketIndex equ 0x000000FE
      font_blackslashIndex equ 0x000000FF
      
      fontWidthTable:
        .incbin "out/font/end_width.bin"
      
      fontKerningMatrix:
        .incbin "out/font/end_kerning.bin"

      ;==================================
      ; a0 = current char
      ; a1 = previous char
      ; 
      ; returns kerning offset to correctly
      ; position current char relative to
      ; previous
      ;==================================
      
      getCharKerning:
        la $a2,fontKerningMatrix
        ; a1 = last char id * chars per row (256)
        sll $a1,8
        ; add current char id
        addu $a1,$a0
        ; a2 = pointer to kerning matrix entry
        addu $a2,$a1
        
        ; get kerning amount
        lb $v0,0($a2)
        
        jr $ra
        nop
      
    ;============================================================================
    ; subtitle interpreter
    ;============================================================================

      ;==================================
      ; opcodes
      ;==================================
      
      subOp_terminator  equ 0x00
      subOp_waitUntil   equ 0x01
      subOp_startSub    equ 0x02
      subOp_endSub      equ 0x03
      subOp_offsetTimer equ 0x04

      ;==================================
      ; op macros
      ;==================================
      
      ; every event happens this many frames later than the time specified.
      ; this is mostly to help account for the fact that the gradient on
      ; the karaoke is generated backwards from the "current" point
      ; to make some things more convenient, whereas it would ideally
      ; be "centered" on the target position.
      globalTimeOffset equ 4
      
      .macro genTime,time
      .align 4
        .dw time+globalTimeOffset
      .align 4
      .endmacro
      
      .macro genTimeMinSec,timeMin,timeSec
        genTime int(((float(timeMin) * 60.0 * 60.0) + (float(timeSec) * 60.0)))
      .endmacro
      
      .macro genTimePairMinSec,timeMin1,timeSec1,timeMin2,timeSec2
        genTimeMinSec timeMin1,timeSec1
        genTimeMinSec timeMin2,timeSec2
      .endmacro
      
      
      
      .macro sub_waitUntil,time
      .align 4
        .dw subOp_waitUntil
          genTime time
      .align 4
      .endmacro
      
      .macro sub_waitUntilMinSec,timeMin,timeSec
        ; convert to frame value and use normal macro
        sub_waitUntil int(((float(timeMin) * 60.0 * 60.0) + (float(timeSec) * 60.0)))
      .endmacro
      
      
      
      .macro sub_startSub_A,str
      .align 4
        .dw subOp_startSub
          .loadtable "font/end/table.tbl"
          .string str
      .align 4
      .endmacro
      
      .macro sub_startSub_B,str
      .align 4
          .loadtable "font/end/table_std.tbl"
          .string str
      .align 4
      .endmacro
      
      
      
      .macro sub_endSub
      .align 4
        .dw subOp_endSub
      .align 4
      .endmacro
      
      
      
      .macro sub_offsetTimer,time
      .align 4
        .dw subOp_offsetTimer
        .dw time
      .align 4
      .endmacro

      ;==================================
      ; op handlers
      ;
      ; a0 = value of currentSubtitlePtr
      ; 
      ; handlers must:
      ; - update currentSubtitlePtr in memory
      ;   if needed
      ; - return 0 if the interpreter
      ;   should continue running or
      ;   nonzero if not
      ;==================================
      
      subOp_waitUntil_handler:
        ; a1 = target counter value
        lw $a1,4($a0)
        ; a2 = current counter value
        lw $a2,subtitleTimer
        li $v0,1
        
        ; if target value not reached, do nothing and return nonzero
        ; to break interpreter loop
        blt $a2,$a1,@@done
        nop
          
          ; target value reached or exceeded:
          ; advance srcptr
          addiu $a0,8
          sw $a0,currentSubtitlePtr
          ; return 0 = continue interpreter loop
          li $v0,0
        
        @@done:
        jr $ra
        nop
      
      subOp_startSub_handler:
        subiu $sp,4
        sw $ra,0($sp)
;        sw $s0,4($sp)
        
          ; read subtitle A
          la $a1,subRenderBufA
          jal readSubData
          addiu $a0,4
          
          ; read subtitle B
          la $a1,subRenderBufB
          jal readSubData
          ; a0 = pointer to next subtitle's src data
          move $a0,$v0
          
          ; update srcptr
          sw $v0,currentSubtitlePtr
        
        lw $ra,0($sp)
;        lw $s0,4($sp)
        addiu $sp,4
        ; continue interpreter loop
        jr $ra
        li $v0,0
      
      subOp_endSub_handler:
        ; increment srcptr
        addiu $a0,4
        sw $a0,currentSubtitlePtr
        
        ; clear both render buffers' string pointers
        ; to signal empty state
        la $a0,subRenderBufA
        sw $zero,subRenderBuf_srcStrPtr($a0)
        la $a0,subRenderBufB
        sw $zero,subRenderBuf_srcStrPtr($a0)
        
        ; continue interpreter loop
        jr $ra
        li $v0,0
      
      subOp_offsetTimer_handler:
        ; get arg
        lw $v0,4($a0)
        ; advance srcptr
        addiu $a0,8
        sw $a0,currentSubtitlePtr
        
        ; add amount to timer
        la $a0,subtitleTimer
        lw $a1,0($a0)
        nop
        addu $a1,$v0
        sw $a1,0($a0)
        
        ; continue interpreter loop
        jr $ra
        li $v0,0

      ;==================================
      ; op handler call table
      ;==================================
      
      subOp_handlerTable:
        ; 00: subOp_terminator (dummy)
        .dw 0
        ; 01: subOp_waitUntil
        .dw subOp_waitUntil_handler
        ; 02: subOp_startSub
        .dw subOp_startSub_handler
        ; 03: subOp_endSub
        .dw subOp_endSub_handler
        ; 04: subOp_offsetTimer
        .dw subOp_offsetTimer_handler

      ;==================================
      ; main loop
      ;==================================
      
      runSubtitleInterpreter_stackSize equ 8
      
      runSubtitleInterpreter:
        subiu $sp,runSubtitleInterpreter_stackSize
        sw $ra,0($sp)
        sw $s0,4($sp)
;        sw $s1,8($sp)
          
          ; s0 = pointer to srcptr
          la $s0,currentSubtitlePtr
          
          @@interpreterLoop:
            ; a0 = srcptr
            lw $a0,0($s0)
            li $a1,~0x3
            
            ; enforce op alignment by rounding up to next word boundary
            addiu $a0,3
            and $a0,$a1
            
            ; a1 = fetch opcode from src
            lw $a1,0($a0)
            li $a2,subOp_terminator
            ; increment src
;            addi $a0,1
            ; save updated srcptr
;            sw $a0,0($s0)
            
            ; do nothing if terminator
            beq $a1,$a2,@@done
            li $a2,subOp_handlerTable
            
            ; otherwise, call op handler from table
            sll $a1,2
            addu $a1,$a2
            lw $v0,0($a1)
            nop
            jalr $v0
            nop
            
            ; handler returns 0 if we should continue the interpreter loop
            ; or nonzero otherwise
            beq $v0,$zero,@@interpreterLoop
            nop
        
        @@done:
        
        lw $ra,0($sp)
        lw $s0,4($sp)
;        lw $s1,8($sp)
        jr $ra
        addiu $sp,runSubtitleInterpreter_stackSize
        
      currentSubtitlePtr:
        .dw subtitleData

    ;============================================================================
    ; subtitle renderer
    ;============================================================================

      ;==================================
      ; subtitle render data
      ;==================================
      
      makeSubRenderBuf subRenderBufA
      makeSubRenderBuf subRenderBufB

      ;==================================
      ; render buffer operations
      ;==================================

      ;==================================
      ; read subtitle data to a render buffer
      ;
      ; a0 = srcptr
      ; a1 = dst subRenderBuf ptr
      ; returns pointer to end of src data
      ;==================================
      
      readSubData_stackSize equ 28
      
      readSubData:
        subiu $sp,readSubData_stackSize
        sw $ra,0($sp)
        sw $s0,4($sp)
        sw $s1,8($sp)
        sw $s2,12($sp)
        sw $s3,16($sp)
        sw $s4,20($sp)
        sw $s5,24($sp)
        
          ; s0 = srcptr
          move $s0,$a0
          ; s1 = dstptr
          move $s1,$a1
          
          ;======
          ; read src string
          ;======
          
          ; s2 = x-pos
          move $s2,$zero
          ; s3 = point counter
          move $s3,$zero
          ; s4 = previous char ID
          li $s4,font_spaceIndex
          ; s5 = string pointer start
          move $s5,$s0
          
          ; set string pointer
          sw $s0,subRenderBuf_srcStrPtr($s1)
          
          @@stringReadLoop:
            ; fetch next char
            lbu $a0,0($s0)
            ; increment src
            addiu $s0,1
            
            ; done if next char zero == terminator
            beq $a0,$zero,@@stringReadLoopDone
            nop
            
            ; check if this character is '<' or '>',
            ; indicating start/end of a point sequence
            ; (both characters are handled identically;
            ; this is purely for notational convenience)
            beq $a0,font_leftAngleBracketIndex,@@isPoint
            nop
            bne $a0,font_rightAngleBracketIndex,@@notPoint
            nop
            
            @@isPoint:
              ; a1 = offset to current position in point data
              li $v0,subTargetPoint_size
              mult $v0,$s3
              mflo $a1
              ; a0 = pointer to target position
              addiu $a0,$s1,subRenderBuf_pointData
              addu $a0,$a1
              
              ; save point x-pos
              sw $s2,subTargetPoint_pixelX($a0)
              
              ; save point's byte position within string
              subu $a1,$s0,$s5
              sw $a1,subTargetPoint_bytePos($a0)
              
              j @@stringReadLoop
              ; increment point counter
              addiu $s3,1
            @@notPoint:
            
            ; look up char width
            la $a1,fontWidthTable
            addu $a1,$a0
            lbu $a2,0($a1)
            nop
            ; add width to X
            addu $s2,$a2
            
/*            ; look up kerning if not a space
            beq $a0,font_spaceIndex,@@skipKerning
            ; a1 = previous char id
            move $a1,$s4
              jal getCharKerning
              ; s4 = new char id
              ; (not updated if a space; this is intentional)
              move $s4,$a0
              
              ; add kerning offset to X
              addu $s2,$v0
            @@skipKerning:*/
            
            ; look up kerning if not a space
            ; a1 = previous char id
            move $a1,$s4
            beq $s4,font_spaceIndex,@@skipKerning
            ; s4 = new char id
            move $s4,$a0
              jal getCharKerning
              nop
              ; s4 = new char id
              ; (not updated if a space; this is intentional)
;              move $s4,$a0
              
              ; add kerning offset to X
              addu $s2,$v0
            @@skipKerning:
            
            j @@stringReadLoop
            nop
          @@stringReadLoopDone:
          
          ;======
          ; save results
          ;======
          
          ; width
          sw $s2,subRenderBuf_srcStrW($s1)
          ; point count
          sw $s3,subRenderBuf_numPoints($s1)
          ; placeholder point index
          sw $zero,subRenderBuf_currentPointIndex($s1)
          
          ;======
          ; read point timing data
          ;======
          
          ; advance srcptr to next word boundary
          li $a0,~0x3
          addiu $s0,3
          and $s0,$a0
          
          ; done if no points
          beq $s3,$zero,@@pointTimeReadLoopDone
          ; a0 = dst for point data
          addiu $a0,$s1,subRenderBuf_pointData
            ; save as initial point pointer
;            sw $a0,subRenderBuf_currentPointPtr($s1)
            @@pointTimeReadLoop:
              ; v0 = fetch word = target time for point
              lw $v0,0($s0)
              ; increment srcptr
              addiu $s0,4
              
              ; copy to dst
              sw $v0,subTargetPoint_time($a0)
              
              ; decrement point counter
              subiu $s3,1
              bne $s3,$zero,@@pointTimeReadLoop
              ; advance dstptr
              addiu $a0,subTargetPoint_size
          @@pointTimeReadLoopDone:
          
        ;======
        ; return updated srcptr
        ;======
        
        move $v0,$s0
        
        lw $ra,0($sp)
        lw $s0,4($sp)
        lw $s1,8($sp)
        lw $s2,12($sp)
        lw $s3,16($sp)
        lw $s4,20($sp)
        lw $s5,24($sp)
        jr $ra
        addiu $sp,readSubData_stackSize

      ;==================================
      ; a0 = raw char id
      ; returns base texpage x/y as
      ; 0000YYXX
      ;==================================
      
      getCharXy:
        addiu $a0,font_texCharGap
        ; x
        andi $v0,$a0,0x0F
        sll $v0,4
        ; y
        andi $v1,$a0,0xF0
        ; place y in higher byte
        sll $v1,8
        jr $ra
        or $v0,$v1
        
      ;==================================
      ; 
      ;==================================
      
      renderSubtitles_stackSize equ 8
      
      renderSubtitles:
        subiu $sp,renderSubtitles_stackSize
        sw $ra,0($sp)
        sw $s0,4($sp)
        
          la $a0,subRenderBufA
          ; clut
          li $a1,fontKaraokeFgClut
          ; base Y
          li $a2,subtitlesUpperBaseY
          jal renderSubtitleBuffer
          nop
        
          la $a0,subRenderBufB
          ; clut
          li $a1,fontTranslationClut
          ; base Y
          li $a2,subtitlesLowerBaseY
          jal renderSubtitleBuffer
          nop
        
        lw $ra,0($sp)
        lw $s0,4($sp)
        jr $ra
        addiu $sp,renderSubtitles_stackSize

      ;==================================
      ; a0 = subRenderBuffer pointer
      ; a1 = target point index
      ;==================================
      
      getSubRenderBufferPointPtr:
        ; convert index to offset
        li $a2,subTargetPoint_size
        mult $a2,$a1
        mflo $a2
        ; add point data base offset
        addiu $a2,subRenderBuf_pointData
        
        jr $ra
        ; add buffer pointer
        addu $v0,$a0,$a2

      ;==================================
      ; a0 = subRenderBuffer pointer
      ; a1 = base clut
      ; a2 = base y
      ;==================================
      
      renderSubtitleBuffer_stackSize equ 32
      
      renderSubtitleBuffer:
        subiu $sp,renderSubtitleBuffer_stackSize
        sw $ra,0($sp)
        sw $s0,4($sp)
        sw $s1,8($sp)
        sw $s2,12($sp)
        sw $s3,16($sp)
        sw $s4,20($sp)
        sw $s5,24($sp)
        sw $s6,28($sp)
        
          ; s1 = render string ptr
          ; ensure buffer has content
          lw $s1,subRenderBuf_srcStrPtr($a0)
          ; v1 = buffer pixel width
          lw $v1,subRenderBuf_srcStrW($a0)
          beq $s1,$zero,@@done
          ; s0 = render buffer ptr
          move $s0,$a0
          
          ; s5 = y-base
          move $s5,$a2
          ; s6 = base clut
          move $s6,$a1
          
          ; s2 = x-centering offset: (fullW - actualW) / 2
          li $s2,creditsScreenW
          subu $s2,$v1
          srl $s2,1
          ; save for use as param to renderSubtitleChar
          la $v0,subtitleCharParam
          sh $s2,8($v0)
          
          ;=====
          ; if more point pairs remain in buffer,
          ; check if (current time >= next start point's time).
          ; if so, advance current point pointer.
          ;=====
          
          lw $a1,subRenderBuf_currentPointIndex($s0)
          lw $v0,subRenderBuf_numPoints($s0)
          ; a1 = next start point's index
          addiu $a1,$a1,2
          ; if on final point pair, do nothing:
          ; final span lasts "infinitely" until interrupted
          bge $a1,$v0,@@noPointChange
          nop
            ; look up next start point's buffer
            jal getSubRenderBufferPointPtr
            move $a0,$s0
            
            ; a0 = current time
            lw $a0,subtitleTimer
            ; a1 = next point's start time
            lw $a1,subTargetPoint_time($v0)
            nop
            
            ; no change if current time less than next start point's time
            blt $a0,$a1,@@noPointChange
            nop
              lw $v1,subRenderBuf_currentPointIndex($s0)
              ; move to next point
              nop
              addiu $v1,2
              sw $v1,subRenderBuf_currentPointIndex($s0)
          @@noPointChange:
          
          ;=====
          ; compute completion rate of current point span
          ;=====
          
          sw $zero,currentSpanStartX
          sw $zero,currentSpanEndX
          
          ; fill percentage is zero if no points
          lw $v0,subRenderBuf_numPoints($s0)
          la $a0,currentSpanGradEndX
          beq $v0,$zero,@@noFillPercentCheck
          sw $zero,0($a0)
            ;=====
            ; compute completion percentage of current span:
            ; fillPercent = (currentTime - spanStartTime) / (endTime - startTime)
            ;=====
            
            ; s3 = start point's buffer
            lw $a1,subRenderBuf_currentPointIndex($s0)
            jal getSubRenderBufferPointPtr
            move $a0,$s0
            move $s3,$v0
            
            ; s4 = end point's buffer
            lw $a1,subRenderBuf_currentPointIndex($s0)
            move $a0,$s0
            jal getSubRenderBufferPointPtr
            addiu $a1,1
            move $s4,$v0
            
            ; fill percentage is zero if start time not yet reached
            ; (should only happen on first point)
            lw $a0,subtitleTimer
            lw $a1,subTargetPoint_time($s3)
;            la $a2,currentSpanFillPercent
            la $a2,currentSpanGradEndX
            blt $a0,$a1,@@noFillPercentCheck
            sw $zero,0($a2)
            
            ; a0 = (currentTime - spanStartTime)
            ; this should technically be capped at 0xFFFF,
            ; but since it would take 18 minutes to reach that high,
            ; it's really not a problem in practice
            subu $a0,$a1
            
            ; a3 = spanTime = (spanEndTime - spanStartTime)
            lw $a3,subTargetPoint_time($s4)
            nop
            subu $a3,$a1
            
            ; a0 = (currentTime - spanStartTime) / (endTime - startTime),
            ; as fixed-point with 16 bits of precision
            ; we're assuming endTime - startTime is nonzero
            ; (there is no reason it should ever not be)
            sll $a0,16
            divu $a0,$a3
            mflo $a0
;            sw $a0,currentSpanFillPercent
            
            ;=====
            ; compute how many pixels into the span the gradation extends:
            ; gradePixelEndX = (spanEndX - spanStartX) * fillPercent
            ; gradePixelStartX = gradePixelEndX - gradientWidth
            ; everything left of the startX is pure shade;
            ; everything right of the endX is pure base;
            ; everything between uses an intermediate shade
            ;=====
            
            ; v0 = spanWidth = (spanEndX - spanStartX)
            lw $v0,subTargetPoint_pixelX($s4)
            lw $v1,subTargetPoint_pixelX($s3)
            ; save these values for future use
            sw $v0,currentSpanEndX
            sw $v1,currentSpanStartX
            subu $v0,$v1
            
            ; multiply by percentage
            multu $v0,$a0
            ; take high word to get pixel result
            mflo $v0
            srl $v0,16
            ; save to currentSpanGradEndX
            sw $v0,0($a2)
            
          @@noFillPercentCheck:
          
          ; compute gradient start pos
          lw $v0,currentSpanGradEndX
          nop
          subiu $v0,colorGradientPixelW
          sw $v0,currentSpanGradStartX
          
          ;=====
          ; render characters
          ;=====
          
          ; s3 = previous character id (dummy for now)
          li $s3,font_spaceIndex
          
          @@charRenderLoop:
            ; s4 = fetch from src
            lbu $s4,0($s1)
            addiu $s1,1
            
            ; done if terminator
            beq $s4,$zero,@@charRenderLoopDone
            nop
            
            ; ignore if a target point marker
            beq $s4,font_leftAngleBracketIndex,@@charRenderLoop
            nop
            beq $s4,font_rightAngleBracketIndex,@@charRenderLoop
            nop
            
            ;======
            ; apply kerning
            ;======
            
            ; apply kerning if prevous char not a space
;            beq $s4,font_spaceIndex,@@skipKerning
            beq $s3,font_spaceIndex,@@skipKerning
            ; a1 = previous char id
            move $a1,$s3
              jal getCharKerning
              move $a0,$s4
              ; s3 = new char id
              ; (not updated if a space; this is intentional)
;              move $s3,$s4
              
              ; add kerning offset to X
              addu $s2,$v0
            @@skipKerning:
            ; s3 = new char id
            move $s3,$s4
            
            ;======
            ; render new char
            ;======
            
            ; a0 = render buffer pointer
            ; a1 = codepoint
            move $a0,$s0
            move $a1,$s4
            ; a2 = param struct
            ;      - 2b dstX
            ;      - 2b dstY
            ;      - 2b base clut
            ;      - 2b bytepos of this char in src string
            la $a2,subtitleCharParam
            ; X
            sh $s2,0($a2)
            ; Y = baseY - fontH / 2
            move $a3,$s5
            subiu $a3,(font_charH / 2)
            sh $a3,2($a2)
            ; base clut
            sh $s6,4($a2)
            ; bytepos
            lw $v0,subRenderBuf_srcStrPtr($s0)
            nop
            subu $v0,$s1,$v0
            ; we incremented our src earlier, so account for that
            subiu $v0,1
            sh $v0,6($a2)
            
            ;======
            ; update width
            ;======
            
            la $v1,fontWidthTable
            addu $v1,$s4
            lbu $v0,0($v1)
            ; save width as param
;            la $v1,subtitleCharParam
;            sh $v0,10($v1)
            nop
            sh $v0,10($a2)
            ; add width to X
            addu $s2,$v0
            
            ;======
            ; render char
            ;======
            
            jal renderSubtitleChar
            nop
            
/*            ;======
            ; update width
            ;======
            
            la $a1,fontWidthTable
            addu $a1,$s4
            lbu $a2,0($a1)
            nop
            ; add width to X
            addu $s2,$a2 */
            
            j @@charRenderLoop
            nop
          @@charRenderLoopDone:
        
/*          ; TEST
          lw $a0,currentRenderBufPutPtr
          ; size + link dummy
          li $v0,0x09000000
          sw $v0,0($a0)
          ; command + color
          li $v0,0x2D808080
          sw $v0,4($a0)
          ; vertex 1
          li $v0,0x00800080
          sw $v0,8($a0)
          ; texcoord1 + palette
          li $v0,0x7FC80808
          sw $v0,12($a0)
          ; vertex 2
          li $v0,0x00800090
          sw $v0,16($a0)
          ; texcoord2 + texpage
          li $v0,0x001F0818
          sw $v0,20($a0)
          ; vertex 3
          li $v0,0x00900080
          sw $v0,24($a0)
          ; texcoord3
          li $v0,0x00001808
          sw $v0,28($a0)
          ; vertex 4
          li $v0,0x00900090
          sw $v0,32($a0)
          ; texcoord4
          li $v0,0x00001818
          sw $v0,36($a0)
          
          addiu $a1,$a0,0x28
          sw $a1,currentRenderBufPutPtr
          
          ; link into display list
          move $a1,$a0
          lw $a0,currentDisplayStructPtr_gp($gp)
          nop
          addiu $a0,currentDisplayStructListStdTarget
          jal linkIntoDisplayList
          nop */
        
        @@done:
        lw $ra,0($sp)
        lw $s0,4($sp)
        lw $s1,8($sp)
        lw $s2,12($sp)
        lw $s3,16($sp)
        lw $s4,20($sp)
        lw $s5,24($sp)
        lw $s6,28($sp)
        jr $ra
        addiu $sp,renderSubtitleBuffer_stackSize
        
;        currentSpanFillPercent:
;          .dw 0
        currentSpanStartX:
          .dw 0
        currentSpanEndX:
          .dw 0
        currentSpanGradStartX:
          .dw 0
        currentSpanGradEndX:
          .dw 0
        subtitleCharParam:
      ;   0 - 2b dstX
          .dh 0
      ;   2 - 2b dstY
          .dh 0
      ;   4 - 2b base clut
          .dh 0
      ;   6 - 2b bytepos of this char in src string
          .dh 0
      ;   8 - 2b base x-pos of entire string
          .dh 0
      ;  10 - 2b charW
          .dh 0
        .align 4

      ;==================================
      ; a0 = render buffer pointer
      ; a1 = codepoint
      ; a2 = pointer to struct:
      ;      - 2b dstX
      ;      - 2b dstY
      ;      - 2b base clut
      ;      - 2b bytepos of this char in src string
      ;      - 2b base x-pos of entire string
      ;           (such that dstX - this
      ;           yields this character's
      ;           raw x-pos within the string)
      ;      - 2b charW
      ;=================================
      
      renderSubtitleChar_stackSize equ 36
      
      renderSubtitleChar:
        subiu $sp,renderSubtitleChar_stackSize
        sw $ra,0($sp)
        sw $s0,4($sp)
        sw $s1,8($sp)
        sw $s2,12($sp)
        sw $s3,16($sp)
        sw $s4,20($sp)
        sw $s5,24($sp)
        sw $s6,28($sp)
        sw $s7,32($sp)
        
          move $s0,$a0
          move $s1,$a1
          move $s2,$a2
          
          ;=====
          ; check active points in buffer.
          ; if none, everything is base color.
          ; (no need to check, this will be caught below since
          ; currentSpanGradEndX is zeroed in this case)
          ;=====
          
          ;=====
          ; if char bytepos is < start point,
          ; use all shaded color.
          ; do NOT do this if (current time > active span end time),
          ; because we need to allow the gradient to "flow out".
          ;=====
          
          ;=====
          ; if char bytepos is >= end point,
          ; or (current time < active span start time), <-- already checked
          ; use all base color
          ;=====
          
          ;=====
          ; otherwise, we're in the active zone.
          ; compute our pixel offset within the current span:
          ; ourSpanStartX = (thisCharStringX - spanStartX)
          ; ourSpanEndX = ourSpanStartX + charW
          ;=====
          
          ; a0 = dstX
          lhu $a0,0($s2)
          ; a1 = stringBaseX
          lhu $a1,8($s2)
          lw $a2,currentSpanStartX
          ; a0 = thisCharStringX
          subu $a0,$a1
          ; a0 = ourSpanStartX
          subu $a0,$a2
          
          ; s3 = charW
          lhu $s3,10($s2)
          ; a1 = ourSpanEndX
;          addu $a1,$a0,$v0
          
          ; a2 = currentSpanGradStartX
          lw $a2,currentSpanGradStartX
          ; a3 = currentSpanGradEndX
          lw $a3,currentSpanGradEndX
          nop
          
          ;=====
          ; compute three line segments relative to our position:
          ; - pure shade
          ;   - left point: zero
          ;   - right point: currentSpanGradStartX - ourSpanStartX
          ;     - clamp(0, charW)
          ; - pure base
          ;   - left point: currentSpanGradEndX - ourSpanStartX
          ;     - clamp(0, charW)
          ;   - right point: charW
          ; - gradient area
          ;   - left point: currentSpanGradStartX - ourSpanStartX
          ;     - cap at charX, but allow to be negative
          ;   - right point: currentSpanGradEndX - ourSpanStartX
          ;     - clamp(0, charW)
          ;=====
          
          ; s4 = currentSpanGradStartX - ourSpanStartX
          subu $s4,$a2,$a0
          ; s5 = currentSpanGradEndX - ourSpanStartX
          subu $s5,$a3,$a0
          
          ; check if we fall outside the byte boundaries of the active span
          lw $v0,subRenderBuf_numPoints($s0)
          nop
          beq $v0,$zero,@@noPoints
          nop
            ; v0 = start point's buffer
            lw $a1,subRenderBuf_currentPointIndex($s0)
            jal getSubRenderBufferPointPtr
            move $a0,$s0
            
            ; v1 = span's byte start
            lw $v1,subTargetPoint_bytePos($v0)
            ; a0 = this char's byte position
            lhu $a0,6($s2)
            nop
            bge $a0,$v1,@@notToLeft
            nop
            ; we are to the left of the span
              ; force shade coloration
              ; pretend the gradient is just to the right of us
;              move $s5,$s3
              li $s5,colorGradientPixelW
              j @@noPoints
              move $s4,$s3
            @@notToLeft:
            
            ; v0 = end point's buffer
            lw $a1,subRenderBuf_currentPointIndex($s0)
            move $a0,$s0
            jal getSubRenderBufferPointPtr
            addiu $a1,1
            
            ; v1 = span's byte end
            lw $v1,subTargetPoint_bytePos($v0)
            ; a0 = this char's byte position
            lhu $a0,6($s2)
            nop
            blt $a0,$v1,@@notToRight
            nop
            ; we are to the right of the span
              ; force base coloration
;              move $s4,$zero
              ; pretend the gradient is just to the left of us
              li $s4,-colorGradientPixelW
              j @@noPoints
;              move $s4,$s3
              move $s5,$zero
            @@notToRight:
            
          @@noPoints:
          
          ;=====
          ; draw shade area (unless width is zero or less)
          ;=====
          
          blez $s4,@@noShade
          nop
            ; set up call to renderSubtitleCharSegment
          
            ; ensure shade width <= total width
            blt $s4,$s3,@@noShadeCap
            move $a3,$s4
            ; if right endpoint > charW
              ; set target to charW
              move $a3,$s3
            @@noShadeCap:
            
            ; set up param struct
            la $a1,renderSubtitleCharSegment_param
            ; dstX
            lhu $v0,0($s2)
            ; dstY
            lhu $v1,2($s2)
            sh $v0,0($a1)
            sh $v1,2($a1)
            ; clut
            li $v0,fontKaraokeBgClut
            sh $v0,4($a1)
            
            ; x-offset
            li $a2,0
            jal renderSubtitleCharSegment
            ; codepoint
            move $a0,$s1
          @@noShade:
          
          ;=====
          ; draw base area (unless width is zero or less)
          ;=====
          
          ; if base x >= charW, do nothing
          bge $s5,$s3,@@noBase
          nop
            ; set up call to renderSubtitleCharSegment
          
            ; ensure base x >= 0
            bgez $s5,@@noBaseCap
            move $a2,$s5
            ; if left endpoint < zero
              ; set target to zero
              move $a2,$zero
            @@noBaseCap:
          
            ; width
            ; charW - leftX
            subu $a3,$s3,$a2
            
            ; set up param struct
            la $a1,renderSubtitleCharSegment_param
            ; dstX
            lhu $v0,0($s2)
            ; dstY
            lhu $v1,2($s2)
            sh $v0,0($a1)
            sh $v1,2($a1)
            ; clut
            lhu $v0,4($s2)
            nop
            sh $v0,4($a1)
            
            jal renderSubtitleCharSegment
            ; codepoint
            move $a0,$s1
          @@noBase:
          
          ;=====
          ; draw gradient by iterating over each pixel column
          ; starting from its left boundary (which may be negative).
          ; if x relative to us is negative for that pixel column,
          ; or is >= charX,
          ; skip it; otherwise, draw it.
          ;=====
          
          ; skip drawing if no columns intersect target area
          addiu $v0,$s4,colorGradientPixelW
          blez $v0,@@gradientDrawLoopDone
          nop
          
          ; s7 = pixel column counter
          li $s7,0
          @@gradientDrawLoop:
            ; a2 = target column x
            addu $a2,$s7,$s4
            ; skip if negative
            bltz $a2,@@gradientDrawLoopNext
;            addiu $s7,1
            nop
            ; done if >= charW
            bge $a2,$s3,@@gradientDrawLoopDone
;            subiu $s7,1
            nop
            
            ; set up param struct
            la $a1,renderSubtitleCharSegment_param
            ; dstX
            lhu $v0,0($s2)
            ; dstY
            lhu $v1,2($s2)
            sh $v0,0($a1)
            sh $v1,2($a1)
            ; clut
            li $v0,fontGradientClutBase
            ; adjust gradient level according to column
            addu $v0,$s7
            sh $v0,4($a1)
            
            ; width
            li $a3,1
            jal renderSubtitleCharSegment
            ; codepoint
            move $a0,$s1
            
            ; loop over all gradient columns
            @@gradientDrawLoopNext:
            addiu $s7,1
            bne $s7,colorGradientPixelW,@@gradientDrawLoop
            nop
          @@gradientDrawLoopDone:
        
        @@done:
        lw $ra,0($sp)
        lw $s0,4($sp)
        lw $s1,8($sp)
        lw $s2,12($sp)
        lw $s3,16($sp)
        lw $s4,20($sp)
        lw $s5,24($sp)
        lw $s6,28($sp)
        lw $s7,32($sp)
        jr $ra
        addiu $sp,renderSubtitleChar_stackSize
      
      renderSubtitleCharSegment_param:
        .dh 0
        .dh 0
        .dh 0
      .align 4

      ;==================================
      ; draws a horizontal "slice" of a
      ; character
      ;
      ; a0 = char codepoint
      ; a1 = param struct pointer
      ;      - 2b dstX (of entire char)
      ;      - 2b dstY (of entire char)
      ;      - 2b clut
      ; a2 = x-offset of start of slice
      ;      (should not exceed 16)
      ; a3 = width of slice
      ;      (should not exceed 16)
      ;=================================
      
      renderSubtitleCharSegment_stackSize equ 24
      
      renderSubtitleCharSegment:
        subiu $sp,renderSubtitleCharSegment_stackSize
        sw $ra,0($sp)
        sw $s0,4($sp)
        sw $s1,8($sp)
        sw $s2,12($sp)
        sw $s3,16($sp)
        sw $s4,20($sp)
        
          move $s0,$a0
          move $s1,$a1
          move $s2,$a2
          move $s3,$a3
          lw $s4,currentRenderBufPutPtr
          
          ;=====
          ; basic setup
          ;=====
          
          ; size + link dummy
          li $v0,0x09000000
          sw $v0,0($s4)
          
          ; command + color
          li $v0,0x2D808080
;          li $v0,0x2E606060
          sw $v0,4($s4)
          
          ; texpage
          li $v0,0x001F
;          li $v0,0x003F
          sh $v0,22($s4)
          
          ;=====
          ; set vertices
          ;=====
          
          ; a0 = X
          lhu $a0,0($s1)
          ; a1 = Y
          lhu $a1,2($s1)
          ; add slice offset to X
          addu $a0,$s2
          
          ; do vertices
          ; a0 = leftX
          ; a1 = topY
          
          ; UL-X
          sh $a0,8($s4)
          ; LL-X
          sh $a0,24($s4)
          ; add width
          addu $a0,$s3
;          subiu $a0,1
          ; UR-X
          sh $a0,16($s4)
          ; LR-X
          sh $a0,32($s4)
          
          ; UL-Y
          sh $a1,10($s4)
          ; UR-Y
          sh $a1,18($s4)
          ; add height
;          addiu $a1,font_charH-1
          addiu $a1,font_charH
          ; LL-Y
          sh $a1,26($s4)
          ; LR-Y
          sh $a1,34($s4)
          
          ;=====
          ; set texcoords
          ;=====
          
          ; get char position in texpage as 0000YYXX
          jal getCharXy
          move $a0,$s0
          
          ; a0 = x
          andi $a0,$v0,0x000000FF
          ; add slice offset to x
          addu $a0,$s2
          ; a1 = y
          srl $a1,$v0,8
          
          ; UL-X
          sb $a0,12($s4)
          ; LL-X
          sb $a0,28($s4)
          ; add width - 1
;          subiu $a2,$s3,1
;          addu $a0,$a2
          addu $a0,$s3
          ; UR-X
          sb $a0,20($s4)
          ; LR-X
          sb $a0,36($s4)
          
          ; UL-Y
          sb $a1,13($s4)
          ; UR-Y
          sb $a1,21($s4)
          ; add height-1
;          addiu $a1,font_charH-1
          addiu $a1,font_charH
          ; LL-Y
          sb $a1,29($s4)
          ; LR-Y
          sb $a1,37($s4)
          
          ;=====
          ; set clut
          ;=====
          
          ; v1 = clut
          lhu $v1,4($s1)
          nop
          sh $v1,14($s4)
          
          ;=====
          ; link into display list
          ;=====
          
          ; advance putptr
          addiu $a1,$s4,0x28
          sw $a1,currentRenderBufPutPtr
          
          ; link into display list
          move $a1,$s4
          lw $a0,currentDisplayStructPtr_gp($gp)
          nop
          addiu $a0,currentDisplayStructListStdTarget
          jal linkIntoDisplayList
          nop
        
        lw $ra,0($sp)
        lw $s0,4($sp)
        lw $s1,8($sp)
        lw $s2,12($sp)
        lw $s3,16($sp)
        lw $s4,20($sp)
        jr $ra
        addiu $sp,renderSubtitleCharSegment_stackSize
        
    ;============================================================================
    ; subtitle data
    ;============================================================================
      
      subtitleData:
;        sub_waitUntilMinSec 0, 40.095
        sub_waitUntilMinSec 0, 40.462
        sub_startSub_A "<saiteta> <hana sae mo>"
;          genTimeMinSec 0, 3.000
;          genTimeMinSec 0, 4.000
;          genTimeMinSec 0, 6.000
;          genTimeMinSec 0, 8.000
          genTimePairMinSec 0, 40.462,     0, 42.196
          genTimePairMinSec 0, 43.006,     0, 44.929
        sub_startSub_B "Even the flowers that were in bloom"
        
;        sub_waitUntilMinSec 0, 44.929
        sub_waitUntilMinSec 0, 45.537
        sub_startSub_A "<karete yuku> <sukoshi zutsu>"
          genTimePairMinSec 0, 45.537,     0, 47.258
          genTimePairMinSec 0, 48.081,     0, 49.751
        sub_startSub_B "are withering away, little by little"
        
        sub_waitUntilMinSec 0, 50.599
        sub_startSub_A "<kirei na> <inochi wa>"
          genTimePairMinSec 0, 50.599,     0, 52.485
          genTimePairMinSec 0, 53.156,     0, 55.016
        sub_startSub_B "The more life is beautiful,"
        
        sub_waitUntilMinSec 0, 55.598
        sub_startSub_A "<setsunaku> <hakanaku>"
          genTimePairMinSec 0, 55.598,     0, 57.535
          genTimePairMinSec 0, 58.180,     1, 00.066
        sub_startSub_B "the more it is painfully short"
        
        sub_waitUntilMinSec 1, 00.674
        sub_startSub_A "<subete ga> <uso dakara>"
          genTimePairMinSec 1, 00.674,     1, 02.585
          genTimePairMinSec 1, 03.230,     1, 05.091
        sub_startSub_B "Everything is a lie;"
        
        sub_waitUntilMinSec 1, 05.761
        sub_startSub_A "<nidome wa> <arienai>"
          genTimePairMinSec 1, 05.761,     1, 07.609
          genTimePairMinSec 1, 08.318,     1, 09.849
        sub_startSub_B "you never get a second chance"
        
        sub_waitUntilMinSec 1, 10.836
        sub_startSub_A "<kanashii> <koto de mo>"
          genTimePairMinSec 1, 10.836,     1, 12.393
          genTimePairMinSec 1, 13.355,     1, 15.215
        sub_startSub_B "As sad as it is,"
        
        sub_waitUntilMinSec 1, 15.861
        sub_startSub_A "<yume de mo> <kanawanai>"
          genTimePairMinSec 1, 15.861,     1, 17.747
          genTimePairMinSec 1, 18.405,     1, 20.265
        sub_startSub_B "dreams never come true"
        
        
        
        sub_waitUntilMinSec 1, 21.214
        sub_endSub
        
        ; something seems to lag the scene around here despite the
        ; relative lack of anything actually going on.
        ; maybe the special effect on the mirror is more intensive
        ; than i thought?
        ; or is my subtitle code just that bad??
        ; well, this appears to account for it
        sub_offsetTimer 20
        
        sub_waitUntilMinSec 1, 41.401
        sub_startSub_A "<oiru ni wa> <yuuutsu o mazete>"
          genTimePairMinSec 1, 41.401,     1, 45.046
          genTimePairMinSec 1, 45.552,     1, 50.235
        sub_startSub_B "We live like machines,"
        
        sub_waitUntilMinSec 1, 51.526
        sub_startSub_A "<seimitsu na> <kikai no> <you ni>"
          genTimePairMinSec 1, 51.526,     1, 55.019
          genTimePairMinSec 1, 55.627,     1, 57.525
          genTimePairMinSec 1, 58.158,     2, 00.081
        sub_startSub_B "fueled by depression,"
        
        sub_waitUntilMinSec 2, 01.626
        sub_startSub_A "<saigo made tsudzuite> <shimau>"
          genTimePairMinSec 2, 01.626,     2, 07.169
          genTimePairMinSec 2, 08.156,     2, 10.156
        sub_startSub_B "forced to live forever,"
        
        sub_waitUntilMinSec 2, 11.725
        sub_startSub_A "<genjitsu no botan o> <tomete>"
          genTimePairMinSec 2, 11.725,     2, 17.294
          genTimePairMinSec 2, 18.306,     2, 20.913
        sub_startSub_B "until we press the {End} button"
        
        
        
        sub_waitUntilMinSec 2, 21.951
        sub_endSub
        
        sub_waitUntilMinSec 2, 24.027
        sub_startSub_A "<toumei na> <mizu no naka>"
          genTimePairMinSec 2, 24.027,     2, 25.976
          genTimePairMinSec 2, 26.685,     2, 28.507
;        sub_startSub_B "The fishes that have moved"
        sub_startSub_B "The fish that have moved"
        
        sub_waitUntilMinSec 2, 29.127
        sub_startSub_A "<utsurisunda> <sakanatachi>"
          genTimePairMinSec 2, 29.127,     2, 30.861
          genTimePairMinSec 2, 31.659,     2, 33.380
        sub_startSub_B "to crystal-clear, transparent water"
        
        sub_waitUntilMinSec 2, 34.190
        sub_startSub_A "<miesugiru> <genjitsu ni>"
          genTimePairMinSec 2, 34.190,     2, 36.088
          genTimePairMinSec 2, 36.658,     2, 38.430
        sub_startSub_B "turn their eyes away"
        
        sub_waitUntilMinSec 2, 39.227
        sub_startSub_A "<nageite> <me o fuseru>"
          genTimePairMinSec 2, 39.227,     2, 41.125
          genTimePairMinSec 2, 41.720,     2, 43.657
        sub_startSub_B "to avoid facing this harsh reality"
        
        
        
        sub_waitUntilMinSec 2, 44.606
        sub_endSub
        
        ; terminator
        .dw subOp_terminator
      .align 4

    ;============================================================================
    ; pad to end of sector
    ;============================================================================
    
    .align 0x800
      
  .endarea
  
.close

  
