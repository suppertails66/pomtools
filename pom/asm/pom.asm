
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
  
  ; wait until GPU queue empty?
  gpuQueueWait equ 0x80102918
  ; write to GPU
  loadImage equ 0x80102BDC
  ; read from GPU
  storeImage equ 0x80102C40
  
  ; a0 = entry to insert after
  ; a1 = new entry
  linkIntoDisplayList equ 0x80101E90
  
  ; a0 = dstX
  ; a1 = dstY
  ; a2 = texpage
  ; a3 = srcX
  ; sp+0x10 = srcY
  ; sp+0x14 = w
  ; sp+0x18 = h
  ; sp+0x1C = clut
  genTextBoxRenderCmd equ 0x800FA024
  
  updateTextBoxWait equ 0x800FFC28
  
  setRectRenderCmdTransparency equ 0x80101F44
  
  blankTextBoxBuffer equ 0x800FFB5C
  
  memcpy equ 0x80100820
  memcmp equ 0x801008B4
  memset equ 0x801009A0

;  decmpFontChar equ 0x80016A78
;  sendCharToGpu equ 0x8001DDC0
;  queueSubPacFileLoad equ 0x8003B914
;  free equ 0x80030528

;========================================
; old memory
;========================================
  
  nameScreenNameEntryBuffer equ 0x8012C624
  systemStrCpy equ 0x800DE0A8
  systemStrLen equ 0x800DE0F0
  
  buttonsPressed equ 0x8012BFF4
  buttonsTriggered equ 0x8012BFFC
  
  luluName_std equ 0x801EFFB4
  ; FIXME: is this actually the "standard" version?
  pomCommunityName_std equ 0x80170E5C
  
  textBoxRenderCmdIndexPosGp equ 0x054C
  
  areaNameOverlayTimer equ 0x8012C150
  
;  textBoxSrcPtrGp equ 0x428
    
    compom_attachedBldgPtr equ 0x6C
    bldg_typeId equ 0x0
    fieldTypeId equ 0x0

;========================================
; defines
;========================================

  ;=====
  ; font
  ;=====

  fontCharW equ 12
  ; actual width of the character as stored in GPU.
  ; this is 16 instead of 12 in order to facilitate the
  ; buffering and composition process
  fontPhysicalW equ 16
  fontCharH equ 12
  textBufGpuH equ 12
  
  fontLineSpacing equ 16

  fontDataGpuX equ 0x500/2
  fontDataGpuY equ 0x0
  ; width = size of all data, including 4b width at start,
  ; in halfwords
  fontDataGpuW equ ((fontPhysicalW*fontCharH)/2+4)/2
  fontDataGpuH equ 1
  
  

  textBoxBufStartIndex equ 12
  stdTextBufLimit equ textBoxBufStartIndex
  textBoxBufLimit equ 16
  numTextBoxBuffers equ textBoxBufLimit - textBoxBufStartIndex
  
  

  textBufGpuX equ 0x480/2

  numFontChars equ 0x80
  fontBaseChar equ 0x10
  dteBaseChar equ fontBaseChar+numFontChars

  strOp_terminator    equ 0x00
  strOp_newline       equ 0x01
  strOp_wait          equ 0x02
  strOp_lulu          equ 0x03
  strOp_mono          equ 0x04
  strOp_center        equ 0x05
  strOp_underline     equ 0x06
  strOp_color         equ 0x07
  strOp_clear         equ 0x08
  strOp_tradingCardPlural equ 0x09

  strOp_tradingCardPlural_paramsSize equ 4
  
  strChar_space       equ 0x10
  strChar_hyphen      equ 0x5A
  strChar_minus       equ 0x5A
  strChar_dash        equ 0x5D
  
  strDigitBase        equ 0x11
  
  
  textBoxBaseX equ 0x20-4
  ; moved up slightly to avoid overlap with wait-for-input indicator
  textBoxBaseY equ 0xA1-1
  textBoxWidth equ 192+8
  textBoxHeight equ 48
  textBoxLineSpacing equ 12
  
  ; x-offset of text box choices from normal base position,
  ; including cursor
  ; (these are shifted left to allow for slightly longer text)
;  promptChoiceXOffset equ -8
  promptChoiceXOffset equ -7
  
  ; FIXME: is this always correct?
  textClut equ 0x7ACE
  
  ; alternate text color's index in the character palette.
  ; 8 = red, 9 = orange, A = purple, B = green
  altCharColorIndex equ 0x8
  ; underline color
;  underlineColorIndex equ 0x6
  underlineColorIndex equ 0x9
  underlineSubIndex equ 0xE
;  underlineColorFillHalfword equ 0x8888
;  underlineColorFillHalfword equ (underlineColorIndex|(underlineColorIndex<<4)|(underlineColorIndex<<8)|(underlineColorIndex<<12))

;   underlineColorFillHalfword equ (0|(0<<4)|(underlineColorIndex<<8)|(underlineColorIndex<<12))
;   underlineColorMaskHalfword equ ~(0|(0<<4)|(0xF<<8)|(0xF<<12))
;   
;   underlineColorFillHalfwordLower equ (underlineColorIndex|(underlineColorIndex<<4)|(underlineColorIndex<<8)|(0<<12))
;   underlineColorMaskHalfwordLower equ ~(0xF|(0xF<<4)|(0xF<<8)|(0<<12))

  ; chunky
;   underlineColorFillHalfword equ (underlineColorIndex|(underlineColorIndex<<4)|(0<<8)|(0<<12))
;   underlineColorMaskHalfword equ ((0x0|(0x0<<4)|(0xF<<8)|(0xF<<12))
;   
;   underlineColorFillHalfwordLower equ (underlineColorIndex|(underlineColorIndex<<4)|(underlineColorIndex<<8)|(underlineColorIndex<<12))
;   underlineColorMaskHalfwordLower equ ((0x0|(0x0<<4)|(0x0<<8)|(0x0<<12))
;   
;   underlineColorFillHalfwordLower2 equ (0|(0<<4)|(underlineColorIndex<<8)|(underlineColorIndex<<12))
;   underlineColorMaskHalfwordLower2 equ ((0xF|(0xF<<4)|(0x0<<8)|(0x0<<12))

  ; "aliased"
;   underlineColorFillHalfword equ       (0x9|(0xE<<4)|(0xC<<8)|(0xC<<12))
;   underlineColorFillHalfwordLower equ  (0xE|(0x9<<4)|(0xE<<8)|(0x9<<12))
;   underlineColorFillHalfwordLower2 equ (0xC|(0xC<<4)|(0x9<<8)|(0xE<<12))

  ; "aliased"
  
;   underlineColorFillHalfword equ       (0x9|(0xE<<4)|(0x0<<8)|(0xE<<12))
;   underlineColorMaskHalfword equ       (0x0|(0x0<<4)|(0xF<<8)|(0x0<<12))
;   
;   underlineColorFillHalfwordLower equ  (0xE|(0x9<<4)|(0xE<<8)|(0x9<<12))
;   underlineColorMaskHalfwordLower equ  (0x0|(0x0<<4)|(0x0<<8)|(0x0<<12))
;   
;   underlineColorFillHalfwordLower2 equ (0x0|(0xE<<4)|(0x9<<8)|(0xE<<12))
;   underlineColorMaskHalfwordLower2 equ (0xF|(0x0<<4)|(0x0<<8)|(0x0<<12))

  ; chunky highlight
  
  underlineColorFillHalfword equ       (0x0|(0x0<<4)|(0x9<<8)|(0x9<<12))
  underlineColorMaskHalfword equ       (0xF|(0xF<<4)|(0x0<<8)|(0x0<<12))
  
  underlineColorFillHalfwordLower equ  (0x9|(0x9<<4)|(0x9<<8)|(0x9<<12))
  underlineColorMaskHalfwordLower equ  (0x0|(0x0<<4)|(0x0<<8)|(0x0<<12))
  
  underlineColorFillHalfwordLower2 equ (0x9|(0xE<<4)|(0xC<<8)|(0xE<<12))
  underlineColorMaskHalfwordLower2 equ (0x0|(0x0<<4)|(0x0<<8)|(0x0<<12))

  ; chunky highlight green
  
;   underlineColorFillHalfword equ       (0x0|(0x0<<4)|(0xB<<8)|(0xB<<12))
;   underlineColorMaskHalfword equ       (0xF|(0xF<<4)|(0x0<<8)|(0x0<<12))
;   
;   underlineColorFillHalfwordLower equ  (0xB|(0xB<<4)|(0xB<<8)|(0xB<<12))
;   underlineColorMaskHalfwordLower equ  (0x0|(0x0<<4)|(0x0<<8)|(0x0<<12))
;   
;   underlineColorFillHalfwordLower2 equ (0xB|(0x3<<4)|(0x0<<8)|(0x3<<12))
;   underlineColorMaskHalfwordLower2 equ (0x0|(0x0<<4)|(0xF<<8)|(0x0<<12))
  

  ;=====
  ; name entry
  ;=====
  
  nameEntry_nameBaseX equ 0x38
  
  ; maximum width of names (so we can position them
  ; without danger of overflowing boxes)
  nameEntry_luluMaxW equ 100
  nameEntry_pomMaxW equ 92
;  nameEntry_communityMaxW equ 160
  ; 160 pixels bumps the community name against the rank indicator,
  ; so as arbitrary as it is, limit name to 159 pixels
  nameEntry_communityMaxW equ 159
    
;getGlyphIndex equ 0x0208cb88
;allocHeapMem equ 0x02008a18

;newStaticCodeSize equ 0x1000
;newHeapEndAddress equ 0x801FE000-newStaticCodeSize
;newStaticCodeStartAddress equ newHeapEndAddress

;scriptExecStruct equ 0x80055E60
;  scriptExecStruct_curTextOffset equ 0x98

;printStruct equ 0x80059608
;  printStruct_cellX equ 0x4
;  printStruct_cellY equ 0x5

;===========
; struct: text buffer
;===========

textBuf_size            equ 24
  ; 4
  textBuf_srcPtr          equ 0
  ; 4
  textBuf_srcHash         equ 4
  ; 2
  textBuf_width           equ 8
  ; 1
  textBuf_flags           equ 10
  ; 1
  textBuf_indexNum        equ 11
  ; 1
  textBuf_numSubLines     equ 12
  ; 11
  textBuf_subLines        equ 13


.macro makeTextBuf,index,label
  .align 4
  
  label:
    ; srcPtr
    .dw 0
    ; srcHash
    .dw 0
    
    ; width
    .dh 0
    
    ; flags
    .db 0
    
    ; index num
    .db index
    ; numSubLines
    .if index == textBoxBufStartIndex
      .db 2
    .else
      .db 0
    .endif
    
    ; subLines
    .if index == textBoxBufStartIndex
      .db textBoxBufStartIndex+1,textBoxBufStartIndex+2
    .else
      .fill 2,0
    .endif
    .fill 9,0
  
  .align 4
  
.endmacro

textBufFlagMask_isUsed                  equ (1<<0)
textBufFlagMask_wasUsedLastFrame        equ (1<<1)

;===========
; struct: print state buffer
;===========

printStateBuf_size             equ 36
  ; 4
  printStateBuf_srcPtr         equ 0
  ; 4
  printStateBuf_retAddr        equ 4
  ; 1
  printStateBuf_flags          equ 8
  ; 24
  printStateBuf_lastHalfwordCol  equ 12

.macro makePrintStateBuf
  .align 4
  
    ; srcPtr
    .dw 0
  
    ; retAddr
    .dw 0
    
    ; flags
    .db 0
    ; callActive
;    .db 0
  
  .align 4
    
    ; lastHalfwordCol
    .fill fontCharH*2,0
  
  .align 4
  
.endmacro

printStateBufFlagMask_dteOn             equ (1<<0)
printStateBufFlagMask_callActive        equ (1<<1)
printStateBufFlagMask_monospace         equ (1<<2)
printStateBufFlagMask_lastCharWasSpace  equ (1<<3)
printStateBufFlagMask_underline         equ (1<<4)

;============================================================================
; SLPS_008.17
;============================================================================
  
.open "out/asm/SLPS_008.17", 0x8000F800
; size field in exe header
;.org 0x8000F800+0x1C
;  .word 0x1EE000

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

  ;============================================================================
  ; pad to end of sector
  ;============================================================================
  
  .align 0x800
  
.close




;============================================================================
; deployment subtitles
;============================================================================

; .create "out/asm/roboselect_subs.bin"
;   .dw 
;   
;   .loadtable 
;   robosubs_vordanDeployFull:
;     
;   
; .close


;============================================================================
; MAIN.EXE
;============================================================================
  
.open "out/asm/MAIN.EXE", 0x8000F800

  ;============================================================================
  ; FREE SPACE: old debug printf
  ;============================================================================
  
  ;=========================================
  ; remove debug printf so we can use its
  ; space for new stuff
  ;=========================================
  
  .org 0x80100BE0
;  .area 0x6C4,0xFF
  ; this is probably safe, but check
;  .area 0x714,0xFF
  .area 0x801012F4-.,0xFF
    ;=========
    ; original callers will simply return here
    ;=========
    
    oldPrintf:
      jr $ra
      nop
    
    ;=========================================
    ; *** NEW STUFF ***
    ;=========================================
    
    ;=========================================
    ; text buffers
    ;=========================================
    
    ; each buffer corresponds to one 11-pixel-high line in VRAM,
    ; starting at X=0x480, Y=0.
    ; these occupy the space formerly used for the first page of the font.
    textBufs:
      makeTextBuf  0x00,textBuf00
      makeTextBuf  0x01,textBuf01
      makeTextBuf  0x02,textBuf02
      makeTextBuf  0x03,textBuf03
      makeTextBuf  0x04,textBuf04
      makeTextBuf  0x05,textBuf05
      makeTextBuf  0x06,textBuf06
      makeTextBuf  0x07,textBuf07
      makeTextBuf  0x08,textBuf08
      makeTextBuf  0x09,textBuf09
      makeTextBuf  0x0A,textBuf0A
      makeTextBuf  0x0B,textBuf0B
      makeTextBuf  0x0C,textBuf0C
      makeTextBuf  0x0D,textBuf0D
      makeTextBuf  0x0E,textBuf0E
      makeTextBuf  0x0F,textBuf0F
;      makeTextBuf  0x10,textBuf10
    
    ;=========================================
    ; gets pointer to a text buffer
    ; from its array index
    ;
    ; a0 = target buffer index
    ; returns v0 = pointer to target buffer
    ;=========================================
    
    getTextBufByIndex:
      ; multiply bufferSize * index
      li $a1,textBuf_size
      mult $a0,$a1
      
      ; a1 = base position of buffer array
      la $a1,textBufs
      ; add offset to target buffer
      mflo $a2
      addu $v0,$a1,$a2
      
      jr $ra
      nop
    
    ;=========================================
    ; finds an open text buffer
    ; (neither isUsed nor wasUsedLastLoop set)
    ; if one exists; otherwise, returns NULL
    ; 
    ; a0 = bitfield of flags that must be clear
    ;      for a result to be valid
    ; returns v0 = pointer to buffer, or NULL
    ;=========================================
    
/*    getTextBufWithClearedFlags:
      addiu $sp,-12
      sw $ra,0($sp)
      sw $s0,4($sp)
      sw $s1,8($sp)
        
        ; s0 = loop counter
        move $s0,$zero
        move $s1,$a0
        @@loop:
          
          ; v0 = pointer to current buffer
          jal getTextBufByIndex
          move $a0,$s0
          
          ; a0 = buffer's flags
          lbu $a0,textBuf_flags($v0)
          nop
          
          ; AND flags with target bitfield
          and $a0,$s1
          
          ; if result is zero, we're done
          beq $a0,$zero,@@done
          ; increment loop counter
          addiu $s0,1
          
            ; fail if at end of std buffers
            li $a0,stdTextBufLimit
            bne $s0,$a0,@@loop
            ; failure
            move $v0,$r0
          
      @@done:
      lw $ra,0($sp)
      lw $s0,4($sp)
      lw $s1,8($sp)
      jr $ra
      addiu $sp,12*/
    
    ;=========================================
    ; calls a function on all text buffers up to
    ; a specified limit.
    ; if this function returns nonzero, returns
    ; a pointer to the buffer that triggered
    ; the call.
    ; if all buffers fail, returns NULL.
    ; 
    ; a0 = function pointer: bool f(textBuf*, void*)
    ; a1 = void* passed to f()
    ; a2 = limit of iteration
    ;=========================================
    
    findTextBufThatMatchesCondition:
      addiu $sp,-24
      sw $ra,0($sp)
      sw $s0,4($sp)
      sw $s1,8($sp)
      sw $s2,12($sp)
      sw $s3,16($sp)
      sw $s4,20($sp)
        
        ; s0 = loop counter
        move $s0,$zero
        ; s1 = fptr
        move $s1,$a0
        ; s2 = void*
        move $s2,$a1
        ; s3 = iteration limit
        move $s3,$a2
        @@loop:
          
          ; v0 = pointer to current buffer
          jal getTextBufByIndex
          move $a0,$s0
          
          ; call the provided function
          ; s4 = a0 = buffer pointer
          move $a0,$v0
          move $s4,$v0
          jalr $s1,$ra
          ; a1 = void*
          move $a1,$s2
          
          ; done if result nonzero
          bne $v0,$zero,@@done
          move $v0,$s4
          
          ; increment loop counter
          addiu $s0,1
          
          ; done if limit reached
          bne $s0,$s3,@@loop
          ; fail
          move $v0,$zero
          
      @@done:
      lw $ra,0($sp)
      lw $s0,4($sp)
      lw $s1,8($sp)
      lw $s2,12($sp)
      lw $s3,16($sp)
      lw $s4,20($sp)
      jr $ra
      addiu $sp,24
    
    ;=========================================
    ; call a function on all text buffers
    ; up to a specified index
    ; 
    ; a0 = function pointer: void f(textBuf*, void*)
    ; a1 = void* passed to f()
    ; a2 = limit of iteration
    ;=========================================
    
    callFuncOnTextBufs:
      addiu $sp,-20
      sw $ra,0($sp)
      sw $s0,4($sp)
      sw $s1,8($sp)
      sw $s2,12($sp)
      sw $s3,16($sp)
        
        ; s0 = loop counter
        move $s0,$zero
        ; s1 = fptr
        move $s1,$a0
        ; s2 = void*
        move $s2,$a1
        ; s3 = iteration limit
        move $s3,$a2
        @@loop:
          
          ; v0 = pointer to current buffer
          jal getTextBufByIndex
          move $a0,$s0
          
          ; call the provided function
          ; a0 = buffer pointer
          move $a0,$v0
          jalr $s1,$ra
          ; a1 = void*
          move $a1,$s2
          
          ; increment loop counter
          addiu $s0,1
          
          ; done if limit reached
          bne $s0,$s3,@@loop
          nop
          
      lw $ra,0($sp)
      lw $s0,4($sp)
      lw $s1,8($sp)
      lw $s2,12($sp)
      lw $s3,16($sp)
      jr $ra
      addiu $sp,20
    
    ;=========================================
    ; return true if the given textBuf has
    ; the specified flags cleared
    ; 
    ; a0 = textBuf*
    ; a1 = flags bitfield
    ;=========================================
    
    textBufHasFlagsCleared:
      ; a2 = buffer's flags
      lbu $a2,textBuf_flags($a0)
      nop
      
      ; AND flags with target bitfield
      and $a2,$a1
      
      ; if result is zero, return true
      bne $a2,$zero,@@done
      move $v0,$zero
        li $v0,1
      @@done:
      jr $ra
      nop
    
/*    textBufIsPrimaryAndHasFlagsCleared:
;      addiu $sp,-4
;      sw $ra,0($sp)

        ; a2 = buffer srcptr
        lw $a2,textBuf_srcPtr($a0)
        ; if -1, this is a subline buffer: return false
        li $a3,-1
        beq $a2,$a3,@@false
        li $v0,0
          ; otherwise, do flags cleared check
          j textBufHasFlagsCleared
          nop
        @@false:
        jr $ra
        nop */
      
;      lw $ra,0($sp)
;      jr $ra
;      addiu $sp,4
      
      
    
    ;=========================================
    ; return true if the given textBuf is not a sub-buffer
    ; and matches a given srcPtr/hash
    ; 
    ; a0 = textBuf*
    ; a1 = struct pointer:
    ;        +0 = srcPtr
    ;        +4 = hash
    ;=========================================
    
    textBufIsCached:
      ; make sure this is not a sub-buffer
;      lw $a3,textBuf_srcPtr($a0)
      
      ; a3 = this srcPtr
      lw $a3,textBuf_srcPtr($a0)
      ; a2 = check srcPtr
      lw $a2,0($a1)
      ; fail if this srcPtr is -1 (sub-buffer)
      ; wait, -1 wouldn't match anything anyway, so why bother
;      bltz $a3,@@fail
      nop
      ; fail if no srcPtr match
      bne $a2,$a3,@@fail
      nop
      
      ; a2 = check hash
      lw $a2,4($a1)
      ; a3 = this hash
      lw $a3,textBuf_srcHash($a0)
      nop
      bne $a2,$a3,@@fail
      nop
      
      ; ensure this was used last frame
/*      lbu $v0,textBuf_flags($a0)
      nop
      andi $v0,textBufFlagMask_wasUsedLastFrame
      beq $v0,$zero,@@fail
      nop */
      
      @@success:
      jr $ra
      ori $v0,$zero,1
      
      @@fail:
      jr $ra
      move $v0,$zero
    
    ;=========================================
    ; update a textBuf for end-of-frame
    ; 
    ; a0 = textBuf*
    ;=========================================
    
    updateTextBufForFrameEnd:
      ;=========
      ; set flags_wasUsedLastFrame to flags_isUsed,
      ; and clear flags_isUsed
      ;=========
      
      ; a1 = flags
      lbu $a1,textBuf_flags($a0)
      nop
      
      ; a2 = flags_isUsed
      li $a3,textBufFlagMask_isUsed
      and $a2,$a1,$a3
      ; shift into position of flags_wasUsedLastFrame
      sll $a2,1
      ; mask off both flags
;      nor $a3,$a3,$zero
      li $a3,~(textBufFlagMask_isUsed|textBufFlagMask_wasUsedLastFrame)
      and $a1,$a3
      ; OR with new flags_wasUsedLastFrame
      or $a1,$a2
      
      ; write result back to buf
      sb $a1,textBuf_flags($a0)
      
      jr $ra
      nop
    
    ;=========================================
    ; clear a printStateBuf
    ; 
    ; a0 = printStateBuf*
    ;=========================================
    
    resetPrintStateBuf:
      ; reset printStateBuf for line
      sw $r0,printStateBuf_lastHalfwordCol+0($a0)
      sw $r0,printStateBuf_lastHalfwordCol+4($a0)
      sw $r0,printStateBuf_lastHalfwordCol+8($a0)
      sw $r0,printStateBuf_lastHalfwordCol+12($a0)
      sw $r0,printStateBuf_lastHalfwordCol+16($a0)
      sw $r0,printStateBuf_lastHalfwordCol+20($a0)
      
      jr $ra
      nop
    
    ;=========================================
    ; prints a char or handles next op,
    ; whatever is needed.
    ; note that the caller should peek at the stream
    ; after each call to check for the string terminator
    ; and for newline commands (which have to be specially
    ; handled depending on the situation).
    ; 
    ; there is some special handling here of
    ; terminators during a call sequence --
    ; if we are in a string call, and the
    ; target character/op is immediately followed
    ; by a terminator, the return is silently handled
    ; and the terminator is "eaten"
    ; so that callers to this routine will not
    ; receive it. this allows anything that uses
    ; this function not to worry about whether
    ; a given terminator is for the entire string
    ; or just a subcall -- if you peek and
    ; see a terminator, it's the end of the string.
    ; 
    ; a0 = printStateBuf*
    ; a1 = textBuf*
    ; returns v0 = zero if this call is not a 
    ;              "breaking" action.
    ;              "breaking" actions are those that,
    ;              if text is being printed char-
    ;              -by-char, should result in a
    ;              break until the next printing time.
    ;              these include a character actually
    ;              being printed, a delay op, etc.
    ;              if the action is breaking,
    ;              returns nonzero.
    ;              HACK: returns 2 if aborted
    ;              (for dynamic word wrap check)
    ;=========================================
    
    handleNextTextAction:
      addiu $sp,-16
      sw $ra,0($sp)
      sw $s0,4($sp)
      sw $s1,8($sp)
      sw $s2,12($sp)
      
        ; s2 = srcPtr
        lw $s2,printStateBuf_srcPtr($a0)
        ; s0 = printStateBuf
        move $s0,$a0
        ; s1 = textBuf
        move $s1,$a1
        
        ; a0 = fetch from srcPtr
        lbu $a0,0($s2)
        ; increment srcPtr
        addiu $s2,1
        sw $s2,printStateBuf_srcPtr($s0)
        
        ;==========
        ; decide what kind of action this is
        ; (standard character, control op, or DTE sequence)
        ;==========
        
        bgeu $a0,dteBaseChar,handleNextTextAction__isDte
        nop
        
        blt $a0,fontBaseChar,handleNextTextAction__isOp
        nop
        
        ; i would very much like for these to be local labels!
        ; but then i ran out of room in this block and needed to
        ; add a jump to some external code.
        ; assemblers like WLA-DX would allow a jump back to a local label
        ; using some syntax such as handleNextTextAction@@isChar.
        ; but armips, in its infinite wisdom, makes it completely and totally
        ; impossible to access local labels outside of their scope.
        ; so i have to define a global label so i can jump back from
        ; the new code.
        ; which then invalidates any existing jumps to local labels
        ; that cross the new global label (since it starts a new scope).
        ; so i instead have to just convert all the labels to global labels.
        ; wonderful design!
        handleNextTextAction__isChar:
          ;==========
          ; standard character
          ;==========
          
          ; NOTE: a0 load from memory is pending if jumping here
          ; from DTE handler, so don't read it right away
          
          lbu $a3,abortPrintAtNextSpaceOrOp
          ; a0 = char ID
          ; a1 = printStateBuf
          ; a2 = textBuf
          move $a1,$s0
          beq $a3,$zero,handleNextTextAction__noAbortCheck_char
          nop
            ; abort if next char is space (end of word)
            beq $a0,strChar_space,handleNextTextAction__done
            li $v0,2
            beq $a0,strChar_hyphen,handleNextTextAction__done
            nop
;            beq $a0,strChar_dash,handleNextTextAction__done
;            nop
          handleNextTextAction__noAbortCheck_char:
          
          jal printStdChar
          move $a2,$s1
          
          j handleNextTextAction__handled
          ; breaking
          addiu $v0,$zero,1
        
        handleNextTextAction__isOp:
          ;==========
          ; check for abort
          ;==========
          
          lbu $a3,abortPrintAtNextSpaceOrOp
          nop
          beq $a3,$zero,handleNextTextAction__doOp
          li $v0,2
            ; upon further reflection, why would an op terminate
            ; word wrap checking?
            ; that will miss things like changing color followed by a comma.
            ; we just need to ignore the op (so that we don't e.g. flip
            ; on color mode while merely testing the next word's length)
            
            ; ...though we do have to account for box breaks
            beq $a0,strOp_wait,handleNextTextAction__handled
            li $v0,2
            
            ; ...and for ops that have parameters
            bne $a0,strOp_tradingCardPlural,handleNextTextAction__notSkipPlural
            nop
              addiu $s2,strOp_tradingCardPlural_paramsSize
              sw $s2,printStateBuf_srcPtr($s0)
            handleNextTextAction__notSkipPlural:
            ; actually, we need this to go through normally
            ; so we can test the full length of the printed material
;            beq $a0,strOp_tradingCardPlural,handleNextTextAction__doOp
;            nop
            
            
            j handleNextTextAction__handled
            li $v0,0
          handleNextTextAction__doOp:
          
          ;==========
          ; script ops
          ;==========
          
          bne $a0,strOp_lulu,handleNextTextAction__notLulu
          lbu $a1,printStateBuf_flags($s0)
            nop
            ; start call
            ori $a1,printStateBufFlagMask_callActive
            sb $a1,printStateBuf_flags($s0)
            
            ; set retaddr to srcptr
            sw $s2,printStateBuf_retAddr($s0)
            ; set srcptr to lulu name
            li $s2,0x8012BC84
            sw $s2,printStateBuf_srcPtr($s0)
            
            ; non-breaking
            j handleNextTextAction__handled
            move $v0,$zero
          handleNextTextAction__notLulu:
          
          ; HACK: someone on this project is apparently a perfectionist
          ; and wants the message that tells you how many trading cards you
          ; have when visiting the trade shop to be properly pluralized.
          ; due to the highly limited context in which pluralization is
          ; needed here, i've taken a cudgel to the problem and added
          ; this op to the script system, its sole purpose being to print
          ; the letter "s" if you don't have exactly one card in your
          ; inventory so that "card" becomes "cards".
          bne $a0,strOp_tradingCardPlural,handleNextTextAction__notTradingCardPlural
          lbu $a1,printStateBuf_flags($s0)
/*            ; skip call if player has exactly one trading card
            lbu $a2,0x801F575C
            ; start call
            ori $a1,printStateBufFlagMask_callActive
            beq $a2,1,handleNextTextAction__onlyOneCard
            nop
            
              sb $a1,printStateBuf_flags($s0)
              
              ; set retaddr to srcptr
              sw $s2,printStateBuf_retAddr($s0)
              ; set srcptr to plural pointer
              li $s2,tradingCardPluralSuffixStr
              sw $s2,printStateBuf_srcPtr($s0)
            
            ; non-breaking
            handleNextTextAction__onlyOneCard:
            j handleNextTextAction__handled
            move $v0,$zero */
            
            ; we're out of room in this block and i don't feel like
            ; doing a memory shuffle, so just jump out and jump back
            ; when done
            j doTradingCardPluralAppend
            nop
          handleNextTextAction__notTradingCardPlural:
          
          bne $a0,strOp_mono,handleNextTextAction__notMono
          lbu $a1,printStateBuf_flags($s0)
            nop
            ; toggle monospace mode
            xori $a1,printStateBufFlagMask_monospace
            sb $a1,printStateBuf_flags($s0)
            
            ; non-breaking
            j handleNextTextAction__handled
            move $v0,$zero
          handleNextTextAction__notMono:
          
          bne $a0,strOp_underline,handleNextTextAction__notUnderline
          lbu $a1,printStateBuf_flags($s0)
            nop
            ; toggle underline mode
            xori $a1,printStateBufFlagMask_underline
            sb $a1,printStateBuf_flags($s0)
            
            ; non-breaking
            j handleNextTextAction__handled
            move $v0,$zero
          handleNextTextAction__notUnderline:
          
          bne $a0,strOp_center,handleNextTextAction__notCenter
          lbu $a1,textBox_centeringOn
            nop
            ; toggle center mode
            xori $a1,0xFF
            sb $a1,textBox_centeringOn
            
            ; non-breaking
            j handleNextTextAction__handled
            move $v0,$zero
          handleNextTextAction__notCenter:
          
          bne $a0,strOp_color,handleNextTextAction__notColor
          lbu $a1,altTextColorOn
            nop
            ; toggle color mode
            xori $a1,0xFF
            sb $a1,altTextColorOn
            
            ; non-breaking
            j handleNextTextAction__handled
            move $v0,$zero
          handleNextTextAction__notColor:
          
          ; return breaking code from op handler?
          j handleNextTextAction__handled
          nop
        
        handleNextTextAction__isDte:
          ;==========
          ; DTE sequence
          ;==========
          
          ; a1 = print buf flags
          lbu $a1,printStateBuf_flags($s0)
          
          ; a0 = raw DTE index * 2
          subiu $a0,dteBaseChar
          sll $a0,1
          
          ; check if this is the first or second character of the pair
          andi $a2,$a1,printStateBufFlagMask_dteOn
          ; a1 = flags with DTE flag set
          ori $a1,printStateBufFlagMask_dteOn
          beq $a2,$zero,handleNextTextAction__notSecondDteChar
          ; preemptively decrement srcpos (so we see this char again
          ; on the next run if not on the second half of the sequence)
          addiu $s2,-1
            ; increment DTE offset so we target the second character
            ; of the pair
            addiu $a0,1
            ; re-increment srcpos (targeting next char)
            addiu $s2,1
            ; clear DTE state flag
            andi $a1,~(printStateBufFlagMask_dteOn)
          handleNextTextAction__notSecondDteChar:
          ; save updated (or not) srcpos
          sw $s2,printStateBuf_srcPtr($s0)
          ; save updated flags
          sb $a1,printStateBuf_flags($s0)
          
          ; fetch target character from DTE dictionary
          la $a2,dteDict
          addu $a0,$a2
          
          ; handle as standard char
          j handleNextTextAction__isChar
          lbu $a0,0($a0)
          
;          j handleNextTextAction__handled
          ; breaking
;          addiu $v0,$zero,1
        
        handleNextTextAction__handled:
        
        ;==========
        ; check for return-terminator
        ;==========
        
        ; a0 = callActive flag
        lbu $a0,printStateBuf_flags($s0)
        nop
        andi $a1,$a0,printStateBufFlagMask_callActive
        beq $a1,$zero,handleNextTextAction__noSubRet
        ; a2 = next op
        lbu $a2,0($s2)
          ; check if next op in src is terminator
          nop
          bne $a2,$zero,handleNextTextAction__noSubRet
          lw $a2,printStateBuf_retAddr($s0)
            ;==========
            ; trigger ret
            ;==========
            
            ; set srcPtr to retAddr
            ; clear flag
            andi $a0,~printStateBufFlagMask_callActive
            sw $a2,printStateBuf_srcPtr($s0)
            sb $a0,printStateBuf_flags($s0)
            
        handleNextTextAction__noSubRet:
        
      handleNextTextAction__done:
      lw $ra,0($sp)
      lw $s0,4($sp)
      lw $s1,8($sp)
      lw $s2,12($sp)
      jr $ra
      addiu $sp,16
    
    ; HACK: if nonzero, printing terminates under the conditions
    ; we consider equivalent to "the end of a word".
    ; used for dynamic word wrapping.
    abortPrintAtNextSpaceOrOp:
      .db 0x00
    altTextColorOn:
      .db 0x00
    .align 4
    
    ;=========================================
    ; print a standard string and return
    ; pointer to text buffer containing content.
    ; if the string is cached, printing will
    ; be skipped and the existing buffer
    ; returned.
    ; 
    ; a0 = string pointer
    ; returns v0 = pointer to primary buffer,
    ;              or NULL if fail
    ;=========================================
    
    printStdString_stackRegsSize        equ 24
    printStdString_stackStructsSize     equ max(8,printStateBuf_size)
    printStdString_stackSize equ printStdString_stackRegsSize+printStdString_stackStructsSize
    
    printStdString:
      subiu $sp,printStdString_stackSize
      sw $ra,0($sp)
      sw $s0,4($sp)
      sw $s1,8($sp)
      sw $s2,12($sp)
      sw $s3,16($sp)
      sw $s4,20($sp)
        
        ;==========
        ; "fail" if input string is null
        ; (since we obviously don't need to reserve a buffer
        ; or print anything in that case)
        ;==========
        
        lbu $a1,0($a0)
        move $v0,$zero
        beq $a1,$zero,@@done
        ; s0 = string pointer
        move $s0,$a0
        
        ;==========
        ; save params and compute hash
        ;==========
      
        
        lbu $a1,0($a0)
        ; s1 = string hash (which is a simple checksum of the content;
        ; we should only really need this to detect changes to the name
        ; on the name entry screen, maybe some other sporadic dynamic content,
        ; so a weak hash is fine)
        move $s1,$zero
        beq $a1,$zero,@@hashDone
        @@hashLoop:
        ; add to hash
        addu $s1,$a1
          
          ; increment src
          addiu $a0,1
          ; get next char
          lbu $a1,0($a0)
          nop
          bne $a1,$zero,@@hashLoop
          nop
        @@hashDone:
        
        ; for a little extra security, set the high 10 bits of the hash
        ; to the length of the string in bytes
        ; (this is out of concern for e.g. the name display on
        ; the name entry screen)
        subu $a0,$s0
        sll $a0,22
        or $s1,$a0
        
        ;==========
        ; check if cached
        ;==========
        
        ; check if string is cached
        la $a0,textBufIsCached
        addiu $a1,$sp,printStdString_stackRegsSize
        sw $s0,0($a1)
        sw $s1,4($a1)
        jal findTextBufThatMatchesCondition
        addiu $a2,$zero,stdTextBufLimit
        
        ; done if cached
        beq $v0,$zero,@@notCached
        nop
          ;==========
          ; mark primary buffer and all sublines as used
          ; and return primary buffer
          ;==========
          
          ; mark as used
          lbu $a0,textBuf_indexNum($v0)
          jal setTextBufIsUsedFlag
          ; s0 = primary buffer
          move $s0,$v0
          
          ;==========
          ; mark sublines as used
          ;==========
          
          ; s1 = subline counter
          lbu $s1,textBuf_numSubLines($s0)
          ; s2 = pointer to subline array
          addiu $s2,$s0,textBuf_subLines
          
          @@sublineMarkLoop:
            ; get target index
            lbu $a0,0($s2)
            
            ; mark as used
            jal setTextBufIsUsedFlag
            ; decrement counter
            addiu $s1,-1
            
            bge $s1,$zero,@@sublineMarkLoop
            ; increment array position
            addiu $s2,1
          
          ; return primary buffer
          j @@done
          move $v0,$s0
        @@notCached:
        
        ;==========
        ; not cached: we need to print the string.
        ; set up
        ;==========
        
        ; get primary buffer
        jal findUnusedTextBuffer
        nop
        
        ; if we couldn't get a primary buffer, give up
        beq $v0,$zero,@@done
        nop
        
        ; s2 = primary buffer
        move $s2,$v0
        
        ; prep buffer for use
        move $a0,$v0
        move $a1,$s0
        jal initTextBuf
        move $a2,$s1
        
        ;==========
        ; set up printStateBuf
        ;==========
        
        ; s4 = printStateBuf pointer
        addiu $s4,$sp,printStdString_stackRegsSize
        
        ; init fields
        sw $s0,printStateBuf_srcPtr($s4)
        sw $r0,printStateBuf_retAddr($s4)
        sb $r0,printStateBuf_flags($s4)
        
        ;==========
        ; print all lines
        ;==========
        
        ; s3 = line buffer
        ; (first line = primary buffer)
        move $s3,$s2
        
        @@linePrintLoop:
          ; reset printStateBuf for line
;          sw $r0,printStateBuf_lastHalfwordCol+0($s4)
;          sw $r0,printStateBuf_lastHalfwordCol+4($s4)
;          sw $r0,printStateBuf_lastHalfwordCol+8($s4)
;          sw $r0,printStateBuf_lastHalfwordCol+12($s4)
;          sw $r0,printStateBuf_lastHalfwordCol+16($s4)
;          sw $r0,printStateBuf_lastHalfwordCol+20($s4)
          jal resetPrintStateBuf
          move $a0,$s4
          
          ; print next line
          ; a0 = printStateBuf
          ; a1 = textBuf
          move $a0,$s4
          jal printStdLine
          move $a1,$s3
          
          ; if we did not just write to the primary buffer,
          ; save this buffer to the primary buffer's subline array
          beq $s2,$s3,@@isNotSubline
          nop
            ; a0 = current number of sublines
            lbu $a0,textBuf_numSubLines($s2)
            ; a1 = index of the buffer we just wrote to
            lbu $a1,textBuf_indexNum($s3)
            ; a2 = pointer to base
            addu $a2,$s2,$a0
            sb $a1,textBuf_subLines($a2)
            
            ; increment subline count
            addiu $a0,1
            sb $a0,textBuf_numSubLines($s2)
          @@isNotSubline:
          
          ; done if printStdLine returned zero (= terminator found)
          beq $v0,$zero,@@done
          ; return primary buffer
          move $v0,$s2
          
          ;==========
          ; more content exists:
          ; allocate new subline buffera
          ;==========
          
          jal findUnusedTextBuffer
          nop
          
          ; give up if no buffer available
/*          beq $v0,$zero,@@done
          nop */
/*          bne $v0,$zero,@@lineSuccess
          nop
            ; flag primary buffer as unused.
            ; otherwise, it will be treated as cached even though
            ; printing was terminated on some later line,
            ; resulting in display errors
            ;textBufFlagMask_isUsed
            li $a0,-1
            sw $a0,textBuf_srcPtr($s2)
            sw $a0,textBuf_srcHash($s2)
            j @@done
            sb $zero,textBuf_flags($s2)
          @@lineSuccess: */
          
          ; upon failure, flag primary buffer and all sublines
          ; as unused.
          ; things don't end well otherwise.
          ; i think this *should* only ever happen on the second page
          ; of the naming screen, where you have to give a name to
          ; the community; that screen requires 11 out of the 12
          ; text buffers to display everything, and the way it
          ; quickly switches between lines of text when you go to
          ; confirm the entry leads to a 1-frame window where
          ; there aren't enough buffers to display everything.
          ; doing this check causes a 1-frame flicker while we wait
          ; for the game loop to run again and flag the material that's
          ; no longer in use as deallocated, but otherwise works fine.
          bne $v0,$zero,@@lineSuccess
          li $s3,-1
            
            ; flag all subline buffers as unused
            
            ; s0 = subline counter
            lbu $s0,textBuf_numSubLines($s2)
            ; clear subline count in buffer
            sb $zero,textBuf_numSubLines($s2)
            ; flag primary buffer as unused.
            ; otherwise, it will be treated as cached even though
            ; printing was terminated on some later line,
            ; resulting in display errors
            ;textBufFlagMask_isUsed
            sw $s3,textBuf_srcPtr($s2)
;            sw $a0,textBuf_srcHash($s2)
            sb $zero,textBuf_flags($s2)
            ; s1 = pointer to subline array
            addiu $s1,$s2,textBuf_subLines
            
            @@sublineUnmarkLoop:
              ; get target index
              lbu $a0,0($s1)
        
              jal getTextBufByIndex
              ; decrement counter
              addiu $s0,-1
              
;              lbu $a0,textBuf_flags($v0)
              sw $s3,textBuf_srcPtr($v0)
;              sw $a1,textBuf_srcHash($v0)
;              andi $a0,~(textBufFlagMask_isUsed|textBufFlagMask_wasUsedLastFrame)
;              sb $a0,textBuf_flags($v0)
              sb $zero,textBuf_flags($v0)
              
              bge $s0,$zero,@@sublineUnmarkLoop
              ; increment array position
              addiu $s1,1
            
            j @@done
            li $v0,0
          @@lineSuccess:
          
          ; s3 = new subline buffer
          move $s3,$v0
          
          ; prep buffer for use
          ; a0 = buffer pointer
          move $a0,$s3
          ; a1 = srcPtr (dummy to flag subline entries)
          li $a1,-1
          jal initTextBuf
          ; a2 = hash (doesn't matter)
          li $a2,-1
          
          ; loop
          j @@linePrintLoop
          nop
        
      @@done:
      lw $ra,0($sp)
      lw $s0,4($sp)
      lw $s1,8($sp)
      lw $s2,12($sp)
      lw $s3,16($sp)
      lw $s4,20($sp)
      jr $ra
      addiu $sp,printStdString_stackSize
    
  .endarea

  ;============================================================================
  ; FREE SPACE: old SJIS encoding table
  ;============================================================================
  
  ;=========================================
  ; TEMP: return dummy value from charToSjis
  ;=========================================
  
  .org 0x800DE16C
    li $v0,0x82A0
    jr $ra
    nop
    
  ;=========================================
  ; free stuff
  ;=========================================
  
  ; FIXME: the actual size may be more like 0x444 bytes
  .org 0x8012507C
  .area 0x3B8,0xFF
    
    ;=========================================
    ; initializes a textBuf for use
    ; 
    ; a0 = textBuf*
    ; a1 = srcPtr
    ; a2 = srcHash
    ;=========================================
    
    initTextBuf:
      ; set flags to indicate buffer in use
      li $v0,textBufFlagMask_isUsed
      sb $v0,textBuf_flags($a0)
      
      ; clear width
      sh $zero,textBuf_width($a0)
      
      ; clear subline count
      sb $zero,textBuf_numSubLines($a0)
      
      ; save srcPtr+hash
      sw $a1,textBuf_srcPtr($a0)
      sw $a2,textBuf_srcHash($a0)
      
      jr $ra
      nop
    
    ;=========================================
    ; set the isUsed flag of a textBuf
    ; 
    ; a0 = textBuf index
    ;=========================================
    
    setTextBufIsUsedFlag:
      addiu $sp,-4
      sw $ra,0($sp)
      
        jal getTextBufByIndex
        nop
        
        lbu $a0,textBuf_flags($v0)
        nop
        ori $a0,textBufFlagMask_isUsed
        sb $a0,textBuf_flags($v0)
      
      lw $ra,0($sp)
      addiu $sp,4
      jr $ra
      nop
    
    ;=========================================
    ; prints a char to a textBuf.
    ; printStateBuf* is used to do the 4bpp
    ; composition and save the rightmost nybble column
    ; when targeting an odd pixel column.
    ; 
    ; a0 = char ID (standard encoding, not raw index)
    ; a1 = printStateBuf*
    ; a2 = textBuf*
    ;=========================================
    
    printStdChar_stackRegsSize        equ 20
    printStdChar_stackStructsSize     equ 8
    printStdChar_stackSize equ printStdChar_stackRegsSize+printStdChar_stackStructsSize
    
    printStdChar:
      subiu $sp,printStdChar_stackSize
      sw $ra,0($sp)
      sw $s0,4($sp)
      sw $s1,8($sp)
      sw $s2,12($sp)
      sw $s3,16($sp)
      
        ;==========
        ; set up
        ;==========
        
        ; s0 = char index
;        move $s0,$a0
        subi $s0,$a0,fontBaseChar
        ; s1 = printStateBuf
        move $s1,$a1
        ; s2 = textBuf
        move $s2,$a2
        
        ; if char is space, flag as such in printStateBuf
        lbu $a1,printStateBuf_flags($s1)
        beq $a0,strChar_space,@@isSpace
        andi $a1,~printStateBufFlagMask_lastCharWasSpace
;        beq $a0,strChar_dash,@@isSpace
;        nop
        bne $a0,strChar_hyphen,@@notSpace
        nop
        @@isSpace:
          ori $a1,printStateBufFlagMask_lastCharWasSpace
        @@notSpace:
        sb $a1,printStateBuf_flags($s1)
        
        ;==========
        ; load char data from gpu
        ;==========
      
        ; set up storeImage call
        ; a0 = struct pointer:
        ;      - 2b x (in halfwords)
        ;      - 2b y (in lines)
        ;      - 2b w (in halfwords)
        ;      - 2b h (in lines)
        addiu $a0,$sp,printStdChar_stackRegsSize
        ; x
        li $a1,fontDataGpuX
        sh $a1,0($a0)
        ; y = raw char index
        sh $s0,2($a0)
        ; w
        li $a1,fontDataGpuW
        sh $a1,4($a0)
        ; h
        li $a1,fontDataGpuH
        sh $a1,6($a0)
        
        ; a1 = dst
        la $a1,charReadBuf
        jal storeImage
        nop
        
        ; wait for transfer to actually occur
        jal gpuQueueWait
        move $a0,$zero
        
        ;==========
        ; if in monospace mode, override the character width
        ;==========
        
        lbu $a0,printStateBuf_flags($s1)
        la.u $a3,charReadBuf_w
        andi $a1,$a0,printStateBufFlagMask_monospace
        beq $a1,$zero,@@notMonospace
        la.l $a3,charReadBuf_w
          ; a0 = old width
          lw $a0,0($a3)
          ; set width to monospace width
          li $a1,fontCharW
          sw $a1,0($a3)
          ; right-shift by ((charW - actualW) / 2) to center
          subu $a1,$a1,$a0
          sra $a1,1
          la.u $a0,charReadBuf_charData
          jal rightShiftCharBuf
          la.l $a0,charReadBuf_charData
        @@notMonospace:
        
        ;==========
        ; add underline if turned on
        ;==========
        
        lbu $a0,printStateBuf_flags($s1)
        nop
        andi $a1,$a0,printStateBufFlagMask_underline
        beq $a1,$zero,@@notUnderline
        lw $a2,charReadBuf_w
          lhu $a1,textBuf_width($s2)
          li $v0,underlineColorFillHalfword|(underlineColorFillHalfword<<16)
          li $v1,underlineColorFillHalfwordLower|(underlineColorFillHalfwordLower<<16)
          li $t4,underlineColorFillHalfwordLower2|(underlineColorFillHalfwordLower2<<16)
;          li $t0,underlineColorMaskHalfword|(underlineColorMaskHalfword<<16)
;          li $t1,underlineColorMaskHalfwordLower|(underlineColorMaskHalfwordLower<<16)
;          li $t5,underlineColorMaskHalfwordLower2|(underlineColorMaskHalfwordLower2<<16)
          andi $a1,0x3
          sll $a1,2
          srlv $v0,$a1
          srlv $v1,$a1
          srlv $t0,$a1
          srlv $t1,$a1
          srlv $t4,$a1
          srlv $t5,$a1
;          srl $v0,16
          ; target bottom lines of buffer
          la $a3,charReadBuf_charData_end-((fontPhysicalW*3)/2)
          li $a1,0xFFF0
          
          @@underlineLoop:
            bge $a2,4,@@notLast
            nop
            @@last:
              srl $a1,4
              addiu $a2,1
              bne $a2,4,@@last
              and $v0,$a1
              and $v1,$a1
              and $t0,$a1
              and $t1,$a1
              and $t4,$a1
              and $t5,$a1
              
              lhu $t2,0($a3)
              lhu $t3,(fontPhysicalW*1)/2($a3)
              lhu $t6,(fontPhysicalW*2)/2($a3)
              
;              and $t2,$t0
;              and $t3,$t1
;              and $t6,$t5
              or $t2,$v0
              or $t3,$v1
              or $t6,$t4
              
              sh $t2,0($a3)
              sh $t3,(fontPhysicalW*1)/2($a3)
              j @@underlineDone
              sh $t6,(fontPhysicalW*2)/2($a3)
            @@notLast:
              lhu $t2,0($a3)
              lhu $t3,(fontPhysicalW*1)/2($a3)
              lhu $t6,(fontPhysicalW*2)/2($a3)
              
;              and $t2,$t0
;              and $t3,$t1
;              and $t6,$t5
              or $t2,$v0
              or $t3,$v1
              or $t6,$t4
              sh $t2,0($a3)
              sh $t3,(fontPhysicalW*1)/2($a3)
              sh $t6,(fontPhysicalW*2)/2($a3)
              
              subiu $a2,4
              bne $a2,$zero,@@underlineLoop
              addiu $a3,2
          @@underlineDone:
          
;        lw $a2,charReadBuf_w
;          move $a1,$zero
;          la $a3,charReadBuf_charData_end-8
;          @@underlineLoopOuter:
;          li $v1,0xF
;          move $v0,$zero
;            @@underlineLoopInner:
;              or $v0,$v1
;              sll $v1,4
;              addiu $a1,1
;              andi $a0,$a1,0x3
;              bne $a0,$zero,@@underlineLoopInner
;              nop
;            sh $v0,0($a3)
;            addiu $a3,2
;              
;          @@underlineDone:
          
;          sh $a2,charReadBuf_charData_end-8
;          sh $a2,charReadBuf_charData_end-6
;          sh $a2,charReadBuf_charData_end-4
        @@notUnderline:
        
        ;==========
        ; switch color if alt color on
        ;==========
        
        lbu $a0,altTextColorOn
        nop
        beq $a0,$zero,@@noAltTextColor
        nop
          la.u $a0,charReadBuf_charData
          jal convertCharBufToAltColor
          la.l $a0,charReadBuf_charData
        @@noAltTextColor:
        
        ;==========
        ; if doing dynamic word wrap check, don't print anything;
        ; only advance the width
        ;==========
        
        lbu $a0,abortPrintAtNextSpaceOrOp
        nop
        bne $a0,$zero,@@updateWidth
        nop
        
        ;==========
        ; right-shift input data by (textBuf->width % 4)
        ;==========
        
        lhu $a1,textBuf_width($s2)
        la $a0,charReadBuf_charData
        andi $a1,0x3
        jal rightShiftCharBuf
        ; s3 = (textBuf->width % 4)
        move $s3,$a1
        
        ;==========
        ; OR first column of charBuf with printStateBuf->lastHalfwordCol
        ;==========
        
        ; a0 = row loop counter
        li $a0,fontCharH
        ; a1 = src
        addiu $a1,$s1,printStateBuf_lastHalfwordCol
        ; a2 = dst
        la $a2,charReadBuf_charData
        @@charCompositeLoop:
          ; a3 = read from src
          lhu $a3,0($a1)
          ; v0 = read from dst
          lhu $v0,0($a2)
          nop
          
          ; v0 = composition of src and dst
          or $v0,$a3
          ; write back to dst
          sh $v0,0($a2)
          
          ; inc src
          addiu $a1,2
          ; dec counter
          subiu $a0,1
          bne $a0,$zero,@@charCompositeLoop
          ; inc dst
          addiu $a2,(fontPhysicalW/2)
        
        ;==========
        ; save the rightmost halfword of the composition
        ; to printStateBuf->lastHalfwordCol
        ;==========
        
        ; a0 = byte offset of rightmost halfword of composition
        ;    = ((trueCharW + (textBuf->width % 4)) / 4) * 2
        lw $a0,charReadBuf_w
        nop
        ; add (textBuf->width % 4)
        addu $a0,$s3
        ; save this back to s3 for later
        move $s3,$a0
        srl $a0,2
        sll $a0,1
        
        ; a0 = src = pointer to rightmost halfword column
        la $a1,charReadBuf_charData
        addu $a0,$a1
        ; a1 = dst
        addiu $a1,$s1,printStateBuf_lastHalfwordCol
        ; a2 = row loop counter
        li $a2,fontCharH
        
        @@rightmostColSaveLoop:
          ; a3 = fetch from src
          lhu $a3,0($a0)
          ; dec counter
          subiu $a2,1
          
          ; copy to dst
          sh $a3,0($a1)
          
          ; inc src
          addiu $a0,(fontPhysicalW/2)
          bne $a2,$zero,@@rightmostColSaveLoop
          ; inc dst
          addiu $a1,2
        
        ;==========
        ; send charBuf to (textBufBase + (textBuf->width / 4))
        ;==========
      
        ;==========
        ; set up loadImage call
        ; a0 = dst struct pointer:
        ;      - 2b x (in halfwords)
        ;      - 2b y (in lines)
        ;      - 2b w (in halfwords)
        ;      - 2b h (in lines)
        ;==========
        
        addiu $a0,$sp,printStdChar_stackRegsSize
        
        ; x
        ; a2 = textBuf->width / 4
        lhu $a2,textBuf_width($s2)
        ; add to base offset
        li $a1,textBufGpuX
        srl $a2,2
        addu $a1,$a2
        sh $a1,0($a0)
        
        ; y = textBuf->indexNum * textBufGpuH
        lbu $a1,textBuf_indexNum($s2)
;        li $a2,fontCharH
        li $a2,textBufGpuH
        mult $a2,$a1
        mflo $a1
        sh $a1,2($a0)
        
        ; w
        ; retrieve true-send-width from s3
;        move $a1,$s3
;        ; divide by 4, add 1 to get halfword count
;        srl $a1,2
;        addiu $a1,1
        ; FIXME: will overflow end of texpage if dst > 240?
        ; though in practice, i doubt that'll happen
        li $a1,fontPhysicalW/4
        sh $a1,4($a0)
        
        ; h
;        li $a1,fontCharH
        li $a1,textBufGpuH
        sh $a1,6($a0)
        
        ; a1 = src
        la $a1,charReadBuf_charData
        jal loadImage
        nop
        
        ;==========
        ; textBuf->width += trueCharW
        ;==========
        
        @@updateWidth:
        
        lhu $a0,textBuf_width($s2)
        lw $a1,charReadBuf_w
        nop
        addu $a0,$a1
        sh $a0,textBuf_width($s2)
      
      @@done:
      lw $ra,0($sp)
      lw $s0,4($sp)
      lw $s1,8($sp)
      lw $s2,12($sp)
      lw $s3,16($sp)
      jr $ra
      addiu $sp,printStdChar_stackSize
    
    charReadBuf:
      ; width (stored with character data and read along with it)
      charReadBuf_w:
        .dw 0
      ; 12x12 4bpp character data
      ; (but stored and read as 16x12 to provide an extra word
      ; for the composition process)
      charReadBuf_charData:
        .fill (fontPhysicalW*fontCharH)/2,0
      charReadBuf_charData_end:
    .align 4
    
  .endarea

  ;============================================================================
  ; FREE SPACE: old genNameScreenCharRenderCmd
  ;============================================================================
  
  .org 0x800DD6B0
  .area 0x800DD7FC-.,0xFF
    
    ;=========================================
    ; generate a rendering command for a
    ; rectangle-based (non-scalable) textBuf
    ; 
    ; a0 = buffer index
    ; a1 = dst x
    ; a2 = dst y
    ; a3 = pointer to dst for rendering command
    ;=========================================
    
    genTextBufRectRenderCmd:
      subiu $sp,8
      sw $ra,0($sp)
      sw $s0,4($sp)
      
        ; s0 = dst
        move $s0,$a3
        
        ; size = 04 (link must be filled in by caller)
        li $a3,0x04
        sb $a3,3($s0)
        
        ; color+command = 64808080
        ; "Textured Rectangle, variable size, opaque, texture-blending"
        ; with all components set to 0x80 = even
        li $a3,0x64808080
        sw $a3,4($s0)
        
        ; vertex = YYYYXXXX
        sll $a2,16
        or $a2,$a1
        sw $a2,8($s0)
        
        ; texcoord+palette = 7ACE YY 00
        ; get target Y
        li $a3,textBufGpuH
        mult $a3,$a0
        ; FIXME: is this always the correct CLUT?
        lui $a3,textClut
        mflo $a2
        sll $a2,8
        or $a3,$a2
        ; width+height = HHHHWWWW
        ; get text buffer pointer
        jal getTextBufByIndex
        sw $a3,12($s0)
        
        ; get buffer width
        lhu $a0,textBuf_width($v0)
        lui $a1,textBufGpuH
        or $a0,$a1
        sw $a0,16($s0)
      
      lw $ra,0($sp)
      lw $s0,4($sp)
      jr $ra
      addiu $sp,8
    
    ;=========================================
    ; generate a texpage+nop rendering
    ; command to be inserted before a
    ; text rendering command
    ; 
    ; a0 = pointer to dst for rendering command
    ;=========================================
    
    genTextTexpageRenderCmd:
      ; size = 0x02
      ; link must be filled in by caller
      li $a1,0x02
      sb $a1,3($a0)
      
      ; texpage = 0xE1000029
      li $a1,0xE1000029
      sw $a1,4($a0)
      
      ; nop
      jr $ra
      sw $zero,8($a0)
    
    ;=========================================
    ; new map of naming screen positions
    ; to character indices
    ;=========================================
    
    namingScreenCharMap:
      .loadtable "table/pom_en.tbl"
      
      .stringn "ABCDE abcde 01234 "
      .stringn "FGHIJ fghij 56789 "
      .stringn "KLMNO klmno .,!?& "
      .stringn "PQRST pqrst -_ÅäÅâ[intersex] "
      .stringn "UVWXY uvwxy       "
      .stringn "Z     z           "
    .align 4
    
    nameEntryXGp equ 0x04A8
    nameEntryYGp equ 0x04AC
    
/*    isNameScreenOnLastRow:
      lh $a0,nameEntryYGp($gp)
      li $a1,5
      blt $a0,$a1,@@done
      move $v0,$zero
        li $v0,1
      @@done:
      jr $ra
      nop
    
    isNameScreenXInBannedColumn:
      li $v0,1
      lh $a0,nameEntryXGp($gp)
      li $a1,0xA
      beq $a0,$a1,@@done
      li $a1,0xB
        beq $a0,$a1,@@done
        nop
          move $v0,$zero
      @@done:
      jr $ra
      nop */
  
/*      ; do nothing if y < 5
      jal isNameScreenOnLastRow
      nop
      beq $v0,$zero,@@done
      nop
      
      jal isNameScreenXInBannedColumn
      nop
      beq $v0,$zero,@@done */
  .endarea

  ;============================================================================
  ; REPLACEMENT + FREE SPACE: renderNameScreenString
  ;============================================================================
  
  .org 0x800DD7FC
  .area 0x170,0xFF
    
    ;=========================================
    ; naming screen and many others:
    ; render src string, generate display list
    ; to put it at a particular x/y position.
    ; as basic as it gets.
    ; 
    ; a0 = src string pointer
    ; a1 = dst x-pos
    ; a2 = dst y-pos
    ;=========================================
    
    nameScreenRenderDstPtr equ 0x8012C3F8
    nameScreenTexpageDstPtr equ 0x8012C194
    displayListTablePtr equ 0x8012C290
    
    new_renderNameScreenString:
      subiu $sp,28
      sw $ra,0($sp)
      sw $s0,4($sp)
      sw $s1,8($sp)
      sw $s2,12($sp)
      sw $s3,16($sp)
      sw $s4,20($sp)
      sw $s5,24($sp)
        
        ; s0 = x
        move $s0,$a1
        ; s1 = y
        ; print the target string
        jal printStdString
        move $s1,$a2
        
        ; ensure printing was successful
        beq $v0,$zero,@@done
        ; s2 = pointer to primary buffer
        move $s2,$v0
        
        ; s3 = pointer to render cmd dst
        lw $s3,nameScreenRenderDstPtr
        ; s4 = pointer to texpage cmd dst
        lw $s4,nameScreenTexpageDstPtr
        ; s5 = current subline index
        ; (initialized to -1 due to preincrement)
        li $s5,-1
        
        ; set up render cmd for primary buffer
        lbu $a0,textBuf_indexNum($s2)
        @@renderLoop:
          ; a0 = buffer index
          ; a1 = x
          ; a2 = y
          ; a3 = dst
          move $a1,$s0
          move $a2,$s1
          jal genTextBufRectRenderCmd
          move $a3,$s3
          
          ; link into display list
          lw $a0,displayListTablePtr
          move $a1,$s3
          addiu $a0,0x3FC
          jal linkIntoDisplayList
          ; increment render dst ptr
          addiu $s3,0x14
          
          sw $s3,nameScreenRenderDstPtr
          
          ; set up texpage command
          jal genTextTexpageRenderCmd
          move $a0,$s4
          
          ; link into display list
          lw $a0,displayListTablePtr
          move $a1,$s4
          addiu $a0,0x3FC
          jal linkIntoDisplayList
          ; increment texpage dst ptr
          addiu $s4,0xC
          
          sw $s4,nameScreenTexpageDstPtr
          
          ; reached final subline buffer?
          lbu $a0,textBuf_numSubLines($s2)
          ; increment subline number
          addiu $s5,1
          beq $s5,$a0,@@done
          ; return pointer to primary buffer if done
          move $v0,$s2
          ; a0 = next buffer's index number
          addiu $a0,$s2,textBuf_subLines
          addu $a0,$s5
          lbu $a0,0($a0)
          
          ; advance y-pos to next line
          j @@renderLoop
          addiu $s1,fontLineSpacing
        
      @@done:
      lw $ra,0($sp)
      lw $s0,4($sp)
      lw $s1,8($sp)
      lw $s2,12($sp)
      lw $s3,16($sp)
      lw $s4,20($sp)
      lw $s5,24($sp)
      jr $ra
      addiu $sp,28
    
    ;=========================================
    ; correctly draw the underscore on the
    ; name entry screen
    ; 
    ; a0 = string pointer (preserve)
    ; a1 = original X (replace)
    ; a2 = original Y (preserve)
    ;=========================================
    
/*    positionNameScreenUnderscore:
      subiu $sp,8
      sw $a0,0($sp)
        
        ; get length of name string
        la $a0,nameScreenNameEntryBuffer
        jal computeStringWidth
        sw $a2,4($sp)
        
        ; a1 = actual width
        ; add base x-offset
        addiu $a1,$v0,nameEntry_nameBaseX
        
      lw $a0,0($sp)
      lw $a2,4($sp)
      j 0x800DE9F0
      addiu $sp,8 */
    
      doNamingStringSpecialConfirmDisplay_bufferSize equ 32
      
      doNamingStringSpecialConfirmDisplay_srcString:
        .incbin "out/script/generic/new_0x8.bin"
      doNamingStringSpecialConfirmDisplay_underscoreString:
        .incbin "out/script/generic/new_0x9.bin"
      doNamingStringSpecialConfirmDisplay_underscoreFlashString:
        .incbin "out/script/generic/new_0xA.bin"
      doNamingStringSpecialConfirmDisplay_buffer:
        .fill doNamingStringSpecialConfirmDisplay_bufferSize,0x00
      .align 4
    
  .endarea

  ;============================================================================
  ; MODIFICATION: when confirmation prompt for name is displayed,
  ;               use new strings
  ;============================================================================

    .org 0x800DE938
      j doNameEntryPromptMsgCheck
      ori $a2, $zero, 0x0028
  
  ;============================================================================
  ; MODIFICATION: use new charmap for naming screen
  ;============================================================================
    
    ;=========================================
    ; when displaying selected character
    ; in magnifying glass
    ;=========================================
  
    .org 0x800DEBBC
      li.u $v0,namingScreenCharMap
      li.l $v0,namingScreenCharMap
      ; do not do final multiplication by 2 when computing
      ; position in charmap (since we are now using an 8-bit
      ; rather than 16-bit encoding)
      sra $s2,15+1
      addu $v0,$s2
      ; fetch only one byte
      lbu $a0,0($v0)
      
      ; make up work
      sra $s3,16
      ; resume normal logic
      j 0x800DEBE8
      sw $s3,0x10($sp)

  ;============================================================================
  ; REPLACEMENT + FREE SPACE:
  ; draw magnifying lens character on naming screen
  ;============================================================================
  
  .org 0x800DECD0
  .area 0x800DEEB8-.,0xFF
    
    ;=========================================
    ; REPLACEMENT: draw character for magnifying lens
    ; a0 = char index
    ; a1 = dstX UL
    ; a2 = dstY UL
    ; a3 = dstX LR
    ; sp+0x10 = dstY LR
    ;=========================================
    
    drawNameScreenSelectedChar_stackRegsSize equ 28
    drawNameScreenSelectedChar_stackStructsSize equ 16
    drawNameScreenSelectedChar_stackSize equ drawNameScreenSelectedChar_stackRegsSize+drawNameScreenSelectedChar_stackStructsSize
    
    drawNameScreenSelectedChar_displayListGp equ 0x8E4
    drawNameScreenSelectedChar_renderDstGp equ 0x930
    
    ; offset within buffer at which target char should be placed
    drawNameScreenSelectedChar_stringBuf_charPos equ 1
    
    drawNameScreenSelectedChar:
      subiu $sp,drawNameScreenSelectedChar_stackSize
      sw $ra,0($sp)
      sw $s0,4($sp)
      sw $s1,8($sp)
      sw $s2,12($sp)
      sw $s3,16($sp)
      sw $s4,20($sp)
      sw $s5,24($sp)
      
        ; save params
        move $s0,$a0
        lw $a0,0x10+drawNameScreenSelectedChar_stackSize($sp)
        move $s1,$a1
        move $s2,$a2
        move $s3,$a3
        move $s4,$a0
        
        ;==========
        ; draw selected char
        ;==========
        
        ; set up string containing char
        la $a0,drawNameScreenSelectedChar_stringBuf
        ; print string
        jal printStdString
        sb $s0,drawNameScreenSelectedChar_stringBuf_charPos($a0)
        ; terminator
;        sb $zero,1($a0)
        
        ; ensure print succeeded
        beq $v0,$zero,@@done
        ; s0 = textBuf
        move $s0,$v0
        
        ;==========
        ; generate polygon render command
        ;==========
        
        ; a3 = create dst rect
        addiu $a3,$sp,drawNameScreenSelectedChar_stackRegsSize+8
        sh $s1,0($a3)
        sh $s2,2($a3)
        sh $s3,4($a3)
        sh $s4,6($a3)
        
        ; a2 = create src rect
        ; get buffer y
        lbu $a0,textBuf_indexNum($s0)
        li $a1,textBufGpuH
        addiu $a2,$sp,drawNameScreenSelectedChar_stackRegsSize+0
        mult $a0,$a1
        mflo $a0
        sh $a0,2($a2)
        ; lower Y = upper Y + height
        addiu $a0,textBufGpuH
        sh $a0,6($a2)
        ; left x = zero
        sh $zero,0($a2)
        ; right x = char width
;        lhu $a0,textBuf_width($s0)
        li $a0,fontCharW
        sh $a0,4($a2)
        
        ; a0 = buffer index
        lbu $a0,textBuf_indexNum($s0)
        
        ; a1 = s5 = render dstaddr
        lw $s5,drawNameScreenSelectedChar_renderDstGp($gp)
        
        jal genPolyTextRenderCmd
        move $a1,$s5
        
        ;==========
        ; link into display list
        ;==========
        
        ; a0 = old
        ; a1 = new
        lw $a0,drawNameScreenSelectedChar_displayListGp($gp)
        ; increment render dst
        move $a1,$s5
        addiu $a0,0x3FC
        addiu $s5,0x28
        jal linkIntoDisplayList
        sw $s5,drawNameScreenSelectedChar_renderDstGp($gp)
        
      @@done:
      lw $ra,0($sp)
      lw $s0,4($sp)
      lw $s1,8($sp)
      lw $s2,12($sp)
      lw $s3,16($sp)
      lw $s4,20($sp)
      lw $s5,24($sp)
      jr $ra
      addiu $sp,drawNameScreenSelectedChar_stackSize
    
    drawNameScreenSelectedChar_stringBuf:
;      .fill 4,strOp_terminator
      .db strOp_mono
      .db strOp_terminator
      .db strOp_mono
      .db strOp_terminator
    .align 4
    
    ;=========================================
    ; generate a rendering command for a
    ; polygon-based (scalable) text display
    ; 
    ; a0 = buffer index (not currently used,
    ;      but might be needed if implementation
    ;      changes so that buffers are located on
    ;      multiple texpages)
    ; a1 = pointer to dst for rendering command
    ; a2 = src rect struct pointer (coords within texpage):
    ;      +0 = x UL
    ;      +2 = y UL
    ;      +4 = x LR
    ;      +6 = y LR
    ; a3 = dst rect struct pointer:
    ;      +0 = x UL
    ;      +2 = y UL
    ;      +4 = x LR
    ;      +6 = y LR
    ;=========================================
    
    genPolyTextRenderCmd:
      subiu $sp,8
;      sw $ra,0($sp)
      sw $s0,0($sp)
      sw $s1,4($sp)
      
        ; s0 = dst
        move $s0,$a1
        ; s1 = srcrect
        move $s1,$a2
        ; s2 = dstrect
;        move $s2,$a3
        
        ; size = 9
        li $a0,9
        sb $a0,3($s0)
        
        ; color+command = 0x2C808080
        li $a0,0x2C808080
        sw $a0,4($s0)
        
        ; clut
        ; FIXME: is this always correct?
        lui $a0,textClut
        sw $a0,12($s0)
        
        ; texpage = 0x29
        lui $a0,0x0029
        sw $a0,20($s0)
        
        ; dummy fields
        sw $zero,28($s0)
        sw $zero,36($s0)
        
        ;==========
        ; dst vertices
        ;==========
        
        ; a0 = ulX
        ; a1 = ulY
        lh $a0,0($a3)
        lh $a1,2($a3)
        
        ; set ulX
        sh $a0,8($s0)
        ; set llX
        sh $a0,24($s0)
        ; set ulY
        sh $a1,10($s0)
        ; set urY
        sh $a1,18($s0)
        
        ; a0 = lrX
        ; a1 = lrY
        lh $a0,4($a3)
        lh $a1,6($a3)
        
        ; set urX
        sh $a0,16($s0)
        ; set lrX
        sh $a0,32($s0)
        ; set llY
        sh $a1,26($s0)
        ; set lrY
        sh $a1,34($s0)
        
        ;==========
        ; src texcoords
        ;==========
        
        ; a0 = ulX
        ; a1 = ulY
        lh $a0,0($s1)
        lh $a1,2($s1)
        
        ; set ulX
        sb $a0,12($s0)
        ; set llX
        sb $a0,28($s0)
        ; set ulY
        sb $a1,13($s0)
        ; set urY
        sb $a1,21($s0)
        
        ; a0 = lrX
        ; a1 = lrY
        lh $a0,4($s1)
        lh $a1,6($s1)
        
        ; set urX
        sb $a0,20($s0)
        ; set lrX
        sb $a0,36($s0)
        ; set llY
        sb $a1,29($s0)
        ; set lrY
        sb $a1,37($s0)
      
;      lw $ra,0($sp)
      lw $s0,0($sp)
      lw $s1,4($sp)
      jr $ra
      addiu $sp,8
    
    ;=========================================
    ; compute the display width of a string
    ; (should contain only one line)
    ; 
    ; a0 = string pointer
    ;=========================================
    
    computeStringWidth:
      subiu $sp,4
      sw $ra,0($sp)
      
        ; do the easiest, and dumbest, thing possible:
        ; actually render the string, check the width,
        ; and return that.
        ; this is stupidly inefficient due to the gpu readbacks,
        ; and could theoretically fail if there are no free buffers
        ; available at the time thie function is called, but hopefully
        ; we can get away with it.
        
        jal printStdString
        nop
        
        ; if fail
        beq $v0,$zero,@@done
        nop
        
        ; clear buffer's flags so it's available for future use
;        sb $zero,textBuf_flags($v0)
        ; wait... if we call this at all, we're probably going to draw
        ; the string anyway (or may have already drawn it, and are getting
        ; the cached version back!)
        ; so just let it remain as it is
        ; return buffer width
        lhu $v0,textBuf_width($v0)
        
      @@done:
      lw $ra,0($sp)
      addiu $sp,4
      jr $ra
      nop
  
  .endarea

  ;============================================================================
  ; MODIFICATION:
  ; add only one byte at a time to the name on the naming screen
  ;============================================================================

    .org 0x800DE6B4
      ; a0 = pointer to new charset array
      li $a0,namingScreenCharMap
      ; v0 = targetIndex
      sra $v0,16
      ; a0 = pointer to target char
      addu $a0,$v0
      ; v0 = char
      lbu $v0,0($a0)
      ; write to dst
      lui $at,0x8013
      addu $at,$a1
      sb $v0,-0x39DC($at)
      ; write terminator after dst
      sb $zero,-0x39DC+1($at)
      
      ; a0 = index of thing being named
      jal ensureNamingScreenNameFitsWidth
      move $a0,$s3
      
      ; dst has already been incremented,
      ; so we're done
      j 0x800DE710
      nop

  ;============================================================================
  ; MODIFICATION:
  ; erase only one byte at a time to the name on the naming screen
  ;============================================================================
    
    ; if controller X button pressed
    .org 0x800DE378
  ;    addiu $v0,$v1,-2
      addiu $v0,$v1,-1
    
    ; if on-screen erase button pressed
    .org 0x800DE5A4
  ;    addiu $v0,$v1,-2
      addiu $v0,$v1,-1

  ;============================================================================
  ; MODIFICATION:
  ; position naming screen underscore cursor correctly
  ;============================================================================
  
    ; do not draw if name is full
    ; (because this is less complicated than trying to determine
    ; the position of the last character rather than the width
    ; of the whole string)
    .org 0x800DE988
      j 0x800DE9F8
  
;    .org 0x800DE99C
;      j positionNameScreenUnderscore
;      ori $a2,$zero,0x004C

  ;============================================================================
  ; MODIFICATION:
  ; correctly check if the player has input a name that is empty
  ; or consists solely of spaces
  ;============================================================================
  
    .macro m_doPlayerNameCheck,doneTarget
      la $a0,nameScreenNameEntryBuffer
;      lbu $a1,0($a0)
      li $a1,strChar_space
;      beq $a1,$zero,@@useDefaultName
      @@loop:
        lbu $a2,0($a0)
        addiu $a0,1
        ; if terminator found, use default name
        beq $a2,$zero,@@useDefaultName
        nop
        ; if not a space, done
        bne $a2,$a1,@@done
        nop
        ; otherwise, continue checking
        j @@loop
        nop
      @@useDefaultName:
        ; NOTE: s3 = index of thing being named
        sll $v0,$s3,2
        
        ; index into pointer table at 8012502C
        lui $at, 0x8012
        addu $at, $at, $v0
        lw $s0, 0x502C($at)
        ; strlen
        jal 0x800DE0F0
        move $a0,$s0
        
        la $a0,nameScreenNameEntryBuffer
        ; set new name size
        sh $v0,0x04B8($gp)
        ; strcpy
        jal 0x800DE0A8
        move $a1,$s0
      @@done:
      j doneTarget
      nop
    .endmacro
    
    ; if start pressed
    .org 0x800DE3F0
    .area 0x800DE488-.,0xFF
      m_doPlayerNameCheck 0x800DE488
    .endarea
    
    ; if on-screen "end" button pressed
    .org 0x800DE5B8
    .area 0x800DE654-.,0xFF
      m_doPlayerNameCheck 0x800DE654
    .endarea

  ;============================================================================
  ; MODIFICATION:
  ; reposition string following player name on name entry confirmation screen
  ;============================================================================
  
    .org 0x800DE9B4
    .area 0x800DE9F0-.,0xFF
      ; get length of name
      la.u $a0,nameScreenNameEntryBuffer
      jal computeStringWidth
      la.l $a0,nameScreenNameEntryBuffer
      
      ; add base x-offset to get target pos
      addiu $a1,$v0,nameEntry_nameBaseX
      
      ; string pointer
      lw $a0,0x80125020
      
      j 0x800DE9F0
      ; y-pos
      li $a2,0x48
    .endarea

  ;============================================================================
  ; MODIFICATION:
  ; disable alternate charsets
  ;============================================================================
    
    ;=========================================
    ; disable switch with select button
    ;=========================================
    
    .org 0x800DE3A0
      j 0x800DE3DC
      addu $a0, $zero, $zero
    
    ;=========================================
    ; extra logic to avoid allowing the charset
    ; buttons to be selected by the cursor
    ;=========================================
    
    .org 0x800DE738
      j doNameEntryRightMakeup
    
    .org 0x800DE768
      j doNameEntryLeftMakeup
    
    .org 0x800DE7C8
      j doNameEntryDownMakeup
    
    ;=========================================
    ; hide the charset buttons
    ;=========================================
    
    ; standard 1
    .org 0x800DEC48
      nop
    
    ; standard 2
    .org 0x800DEC68
      nop
  
  ;============================================================================
  ; MODIFICATION:
  ; convert systemStrLen to 8-bit encoding
  ;============================================================================
    
    .org 0x800DE100
      j 0x800DE114
      nop

  ;============================================================================
  ; MODIFICATION:
  ; convert systemStrCpy to 8-bit encoding
  ;============================================================================
    
    .org 0x800DE0B8
      j 0x800DE0D4
      nop

  ;============================================================================
  ; MODIFICATION + FREE SPACE:
  ; don't convert pom names to SJIS when copying after naming screen
  ;============================================================================
  
  .org 0x8001C36C
  .area 0x8001C41C-.,0xFF
    
    ;=========================================
    ; skip sjis conversion
    ;=========================================
      
      ; dst
;      la $a0,0x8012BC84
      lbu $a0,0x80170EA9
      jal 0x800EF52C
      nop
      move $a0,$v0
      ; src
;      la.u $a1,0x801EFFB4
      jal systemStrCpy
;      la.l $a1,0x801EFFB4
      move $a1,$s7
      
      ; done
      j 0x8001CB1C
      nop
    
    ;=========================================
    ; new stuff
    ;=========================================
    
  .endarea

  ;============================================================================
  ; MODIFICATION + FREE SPACE:
  ; don't convert... some other pom names to SJIS when copying after naming
  ; screen
  ; (affects e.g. ÉSÉäÉä/Goliry, possibly others)
  ;============================================================================
  
  .org 0x8001C5CC
  .area 0x8001C67C-.,0xFF
    
    ;=========================================
    ; skip sjis conversion
    ;=========================================
      
      ; dst
      lbu $a0,0x80170EA9
      jal 0x800EF52C
      nop
      move $a0,$v0
      ; src
      jal systemStrCpy
      move $a1,$s7
      
      ; done
      j 0x8001CB1C
      nop
    
    ;=========================================
    ; properly generate x-pos of pom hat on
    ; party status screen
    ; (original games computes this using optimized
    ; shift-based multiplication, so new code is
    ; needed for fine adjustments)
    ;=========================================
  
    pomStatusHatXOffset equ -4
    pomStatusHatXBase equ 8+pomStatusHatXOffset
    pomStatusHatXEnd equ pomStatusHatXBase+24
    
    ; return a0 = x-base
    prepPomPartyHatXBase:
      ; first, we want v0 to be the raw offset
      li $a0,pomStatusHatXBase
      ; multiply by scale
      mult $a0,$s7
      mflo $v0
      sra $v0,8
      ; a0 = base pos + window offset
      addu $a0, $t1, $v0
      
      ; make up work
      lw $a1, 0x0A2C($gp)
      j 0x80044E44
      sra $v0,$s0,8
      
    
    ; return v1 = x-end
    prepPomPartyHatXEnd:
      li $v1,pomStatusHatXEnd
      ; multiply by scale
      mult $v1,$s7
      mflo $v1
      sra $v1,8
      
      ; make up work
      addu $v0, $t0, $v0
      ; add base pos to offset
      j 0x80044E54
      addu $v1, $t1, $v1
    
  .endarea

  ;============================================================================
  ; MODIFICATION + FREE SPACE:
  ; don't convert lulu's name to SJIS when copying after naming screen
  ;============================================================================
  
  .org 0x8001B468
  .area 0x8001B508-.,0xFF
      
      ; dst
      la $a0,0x8012BC84
      ; src
      la.u $a1,0x801EFFB4
      jal systemStrCpy
      la.l $a1,0x801EFFB4
      
      ; done
      j 0x8001B508
      nop
    
    ;=========================================
    ; extra logic to prevent charset buttons
    ; on naming screen from being selected
    ;=========================================
    
      ; a0 = X to switch to if on banned position
      doBannedNameScreenEntryCheck:
        ; check if in last row
        lh $a1,nameEntryYGp($gp)
        li $a2,5
        blt $a1,$a2,@@done
        ; check if X is on one of the charset buttons
        lh $a1,nameEntryXGp($gp)
        li $a2,0xA
        beq $a1,$a2,@@isBanned
        li $a2,0xB
          bne $a1,$a2,@@done
          nop
          @@isBanned:
            ; move to non-banned position
            sh $a0,nameEntryXGp($gp)
        
        @@done:
        jr $ra
        nop
      
      doNameEntryRightMakeup:
        ; make up work
        jal 0x800DA38C
        nop
        
        jal doBannedNameScreenEntryCheck
        li $a0,0xC
  ;      beq $v0,$zero,@@done
  ;      ; force
  ;      li $a0,0xC
  ;        sw $a0,nameEntryXGp($gp)
          
        @@done:
        j 0x800DE740
        nop
      
      doNameEntryLeftMakeup:
        ; make up work
        jal 0x800DA38C
        nop
        
        jal doBannedNameScreenEntryCheck
        li $a0,0x9
        
        @@done:
        j 0x800DE770
        nop
      
      doNameEntryDownMakeup:
        ; make up work
        jal 0x800DA38C
        nop
        
        jal doBannedNameScreenEntryCheck
        li $a0,0xC
        
        @@done:
        j 0x800DE7D0
        nop
    
  .endarea

  ;============================================================================
  ; FREE SPACE:
  ; printConsole
  ;============================================================================
  
  .org 0x801012F4
  .area 0x80101344-.,0xFF
    
    ;=========================================
    ; dummy original function
    ;=========================================
    
    jr $ra
    nop
    
    ;=========================================
    ; new stuff
    ;=========================================
    
    maxMenuBoxDisplayStrings equ 8
    menuBoxDisplayStringQueueSize equ maxMenuBoxDisplayStrings*4
    
    ; pointers to all strings to be displayed in the menu box
    menuBoxDisplayQueue:
      .fill menuBoxDisplayStringQueueSize,0x00
    
    ; the queue's state on the last menu draw.
    ; if not the same as the current one after evaluating
    ; the menu, content is rerendered.
    menuBoxDisplayQueue_previous:
      .fill menuBoxDisplayStringQueueSize,0x00
      
    ; count of entries in queue
    menuBoxDisplayQueue_size:
      .db 0x00
      
    ; count of entries in previous queue
;    menuBoxDisplayQueue_previousSize:
;      .db 0x00
    
    .align 4
    
  .endarea

  ;============================================================================
  ; FREE SPACE:
  ; printConsoleChar
  ;============================================================================
  
  .org 0x801009D0
  .area 0x80100A84-.,0xFF
    
    ;=========================================
    ; dummy original function
    ;=========================================
    
      jr $ra
      nop
    
    ;=========================================
    ; extra end-of-frame code
    ;=========================================
    
    newFrameEndUpdate:
      subiu $sp,4
      sw $ra,0($sp)
      
        ;=========
        ; reset text buffers for new frame
        ;=========
        
        la $a0,updateTextBufForFrameEnd
        jal callFuncOnTextBufs
        addiu $a2,$zero,stdTextBufLimit
      
        ;=========
        ; reset menu box display queue for new frame
        ;=========
        
        ; copy current queue to previous
;        la $a0,menuBoxDisplayQueue_previous
;        la $a1,menuBoxDisplayQueue
;        jal memcpy
;        li $a2,menuBoxDisplayStringQueueSize
        
        ; reset current queue size
;        sb $zero,menuBoxDisplayQueue_size
      
        ;=========
        ; TEST
        ;=========
        
;        li $a0,testString
;        jal printStdString
;        nop
      
      lw $ra,0($sp)
      addiu $sp,4
      jr $ra
      nop
    
    
    
  .endarea
  
  ;============================================================================
  ; MODIFICATION:
  ; call additional end-of-frame handler
  ;============================================================================
  
    .org 0x800213C8
      j newFrameEndUpdate
      nop

  ;============================================================================
  ; FREE SPACE:
  ; printRegDump
  ;============================================================================
  
  .org 0x800FAC28
  .area 0x800FAD28-.,0xFF
    
    ;=========================================
    ; dummy original function
    ;=========================================
    
    jr $ra
    nop
    
    ;=========================================
    ; new stuff
    ;=========================================
    
    dteDict:
      .incbin "out/script/script_dictionary.bin"
    .align 4
    
  .endarea

  ;============================================================================
  ; FREE SPACE:
  ; a whole bunch of debug console strings
  ;============================================================================
  
  .org 0x8001A794
  .area 0x8001ACAC-.,0xFF
    
    ;=========================================
    ; print up through the next breaking action
    ; in the text box (normally, advance through
    ; operations until a character print occurs)
    ;
    ; return nonzero if break reached
    ;=========================================
    
      advanceTextBoxPrinting:
        subiu $sp,16
        sw $ra,0($sp)
        sw $s0,4($sp)
        sw $s1,8($sp)
        sw $s2,12($sp)
        
          ; clear terminator flag
          sb $zero,textBoxTerminated
          
          lbu $a0,textBox_activeBufferId
          ; s0 = printStateBuf
          la.u $s0,textBox_printStateBuf
          jal getTextBufByIndex
          la.l $s0,textBox_printStateBuf
          
          ; s1 = textBuf
          move $s1,$v0
          
          @@loop:
            ; check if terminator or newline reached
            lw $a2,printStateBuf_srcPtr($s0)
            nop
            
            lbu $a3,0($a2)
            li $v0,1
            ; terminator: return nonzero (break reached)
            bne $a3,$zero,@@notTerminator
              ; srcptr++
            addiu $a2,1
              li $a0,1
              sb.u $a0,textBoxTerminated
              j @@done
              sb.l $a0,textBoxTerminated
            @@notTerminator:
            
            ; check for newline
            bne $a3,strOp_newline,@@notNewline
            nop
              ; update srcptr
              sw $a2,printStateBuf_srcPtr($s0)
              
              @@newlineSubEntry:
              
              ; reset print buffer
              jal resetPrintStateBuf
              move $a0,$s0
              
              ; increment linenum
              lbu $a0,textBox_lineNum
              nop
              addiu $a0,1
              sb $a0,textBox_lineNum
              
              ; advance buffer index
              lbu $a0,textBox_activeBufferId
              ; wrap to start if we go past the last buffer
              li $a1,textBoxBufLimit
              addiu $a0,1
              blt $a0,$a1,@@noBufferWrap
              nop
                li $a0,textBoxBufStartIndex
              @@noBufferWrap:
              
              ; v0 = new textBuf pointer
              jal getTextBufByIndex
              sb $a0,textBox_activeBufferId
              
              ; s1 = new textBuf pointer
              move $s1,$v0
              
              ; init new buffer
              jal initTextBuf
              move $a0,$s1
              
              ; loop (in case of multiple sequential newlines)
              j @@loop
              nop
            @@notNewline:
            
            ; check for box clear
            bne $a3,strOp_clear,@@notClear
            nop
              ; update srcptr
              jal blankTextBoxBuffer
              sw $a2,printStateBuf_srcPtr($s0)
              
;              j @@loop
;              nop
              
              ; this is a breaking action
              ; (otherwise, the next character will get printed
              ; before the clear actually goes through)
              j @@done
              li $v0,1
            @@notClear:
            
            ; check for waitForInput
            bne $a3,strOp_wait,@@notWait
            nop
              ; handle the command, or update current wait state?
              ; if this returns nonzero, do not advance srcpos
              jal updateTextBoxWait
              nop
              
              ; do not advance srcpos if result nonzero
              bne $v0,$zero,@@done
              ; return break code
              li $v0,1
              
              ; s1 = new textBuf pointer
              lbu.u $a0,textBox_activeBufferId
              jal getTextBufByIndex
              lbu.l $a0,textBox_activeBufferId
              move $s1,$v0
              
              ; advance src
              lw $a2,printStateBuf_srcPtr($s0)
              nop
              addiu $a2,1
;              j @@loop
;              sw $a2,printStateBuf_srcPtr($s0)
;              j @@doBreakTimerCheck
;              sw $a2,printStateBuf_srcPtr($s0)
              
              ; end of a wait IS a breaking action.
              ; otherwise, pressing the "advance text" button while holding
              ; fast-forward just gets us stuck in a loop of endlessly terminating
              ; every break instantly, then fast-forwarding through the next message,
              ; until the string terminator is reached.
              ; breaking allows the buttonsTriggered state to "drain out"
              ; before that happens.
              sw $a2,printStateBuf_srcPtr($s0)
              j @@done
              li $v0,1
            @@notWait:
            
            ; dynamic line wrap check
            ; was the last thing we printed a space?
            lbu $a0,printStateBuf_flags($s0)
            nop
            andi $a0,printStateBufFlagMask_lastCharWasSpace
            beq $a0,$zero,@@noDynamicWrap
            li $a0,1
              sb $a0,abortPrintAtNextSpaceOrOp
                ; print from current position with special abort condition
;                jal printStdLine
;                lw $a0,printStateBuf_srcPtr($s0)
                ; a0 = "dummy" printStateBuf
                subiu $sp,printStateBuf_size
                  ; set up srcptr
                  lw $a1,printStateBuf_srcPtr($s0)
                  lbu $a3,printStateBuf_flags($s0)
                  move $a0,$sp
                  sw $a1,printStateBuf_srcPtr($a0)
                  lw $a1,printStateBuf_retAddr($s0)
                  
                  ; inherit flags (particularly DTE and call flags)
                  ; from our print buffer
                  sb $a3,printStateBuf_flags($a0)
                  
                  sw $a1,printStateBuf_retAddr($a0)
                  
                  ; s2 = current textBuf width
                  ; (which we need to restore after the width check)
                  lhu $s2,textBuf_width($s1)
                  
                  ; a1 = textBuf = our own buffer
                  ; (nothing will actually be printed;
                  ; only width is modified)
                  jal printStdLine
                  move $a1,$s1
                addiu $sp,printStateBuf_size
              sb $zero,abortPrintAtNextSpaceOrOp
                
                ; check for fail
;                  beq $v0,$zero,@@dynamicWrapCheckDone
                ; a0 = width of the content we printed
                ; (which should correspond to the next word)
;                  lhu $a0,textBuf_width($v0)
              
              ; a1 = new buffer width after printing next word
              lhu $a1,textBuf_width($s1)
              ; a2 = width of text box
              li $a2,textBoxWidth
              
              ; set width back to original value
              sh $s2,textBuf_width($s1)
                
                ; would next word overflow box?
              bgt $a1,$a2,@@newlineSubEntry
              @@dynamicWrapCheckDone:
            sb $zero,abortPrintAtNextSpaceOrOp
            @@noDynamicWrap:
            
            ; handle next char or control code
            ; a0 = printStateBuf
            ; a1 = textBuf
            move $a0,$s0
            jal handleNextTextAction
            move $a1,$s1
            
            ; loop while breaking operation not encountered
            beq $v0,$zero,@@loop
            nop
          
          ;==========
          ; breaking operation encountered:
          ; reset delay timer if needed,
          ; per the original game's logic
          ;==========
          
          @@doBreakTimerCheck:
          
          ; forcibly clear the printing timer
          ; if centering is on, so such messages
          ; print instantly
          lbu $a0,textBox_centeringOn
          nop
          bne $a0,$zero,@@noTimerReload
          move $a0,$zero
          
          ; BUGFIX: the original game checks merely that
          ; the fast-forward button is pressed before turning it on.
          ; however, this is problematic due to the behavior of the
          ; updateTextBoxWait function, which checks buttonsTriggered
          ; for the same button to determine whether the player has
          ; pressed a button to advance the input.
          ; 
          ; if the player hits the fast-forward button on the frame
          ; that the print counter ticks over and triggers the next
          ; action, then all the text will fast-forward immediately,
          ; and the wait will be triggered right away.
          ; at that point, buttonsTriggered still indicates that the
          ; player has just triggered the fast-forward/advance box
          ; button, so the wait is immediately cancelled and the
          ; currently dialogue box is cleared.
          ; on the other hand, if the fast-forward gets triggered
          ; on a frame when the counter does not tick over, the
          ; "triggered" state gets cleared before updateTextBoxWait
          ; sees it, meaning the dialogue box does _not_ get cleared
          ; immediately (which was probably the intended behavior).
          ;
          ; the simplest thing we can do to fix this is check
          ; that buttonsTriggered is NOT set before engaging the fast-forward.
          ; this means the player might have to hold the button for 2 frames
          ; rather than 1... but frankly, i doubt anyone will ever notice.
          ; especially since we're covering up a frustrating bug in the process.
          ; and also i'm probably going to double the print speed later,
          ; meaning this check will occur every frame,
          ; meaning the possible 1-frame delay won't happen anyway.
          ; so whatever!
          
          ; v1 = buttons to check for fast-forward?
          lbu $v1,0x8012C33C
          
          ; if button triggered, ignore
          lw $v0,buttonsTriggered
          nop
          and $v0,$v1
          bne $v0,$zero,@@timerReload
          ; v0 = buttons pressed
          lw $v0,buttonsPressed
            nop
            
            and $v0,$v1
            bne $v0,$zero,@@noTimerReload
            move $a0,$zero
            @@timerReload:
              lbu $a0,0x423($gp)
              nop
          @@noTimerReload:
          sb $a0,0x422($gp)
          
          ;==========
          ; return zero (break not reached)
          ;==========
          
          move $v0,$zero
        
        @@done:
        lw $ra,0($sp)
        lw $s0,4($sp)
        lw $s1,8($sp)
        lw $s2,12($sp)
        jr $ra
        addiu $sp,16
    
    textBoxTerminated:
      .db 0
    .align 4
    
    ;=========================================
    ; render a buffer to the text box render list
    ;
    ; a0 = buffer
    ; a1 = x
    ; a2 = y
    ;=========================================
    
    renderTextBufToTextBoxList_stackRegsSize        equ 8
    renderTextBufToTextBoxList_stackStructsSize     equ 16+16
    renderTextBufToTextBoxList_stackSize equ renderTextBufToTextBoxList_stackRegsSize+renderTextBufToTextBoxList_stackStructsSize
    
    renderTextBufToTextBoxList:
      subiu $sp,renderTextBufToTextBoxList_stackSize
      sw $ra,renderTextBufToTextBoxList_stackStructsSize+0($sp)
        
        ;==========
        ; set up call to genTextBoxRenderCmd
        ;==========
        
        lhu $v0,textBuf_width($a0)
        li $a3,textClut
        beq $v0,$zero,@@done
        ; sp+0x14 = width
        sw $v0,0x14($sp)
        
        ; sp+0x1C = clut
        sw $a3,0x1C($sp)
        ; sp+0x18 = height
        lbu $v0,textBuf_indexNum($a0)
        li $a3,textBufGpuH
        mult $a3,$v0
        sw $a3,0x18($sp)
        ; sp+0x10 = srcY
        mflo $a3
        sw $a3,0x10($sp)
        ; a3 = srcX
        move $a3,$zero
        ; a0 = dstX
        move $a0,$a1
        ; a1 = dstY
        move $a1,$a2
        
        ; a2 = texpage
        jal genTextBoxRenderCmd
        li $a2,0x29
      
      @@done:
      lw $ra,renderTextBufToTextBoxList_stackStructsSize+0($sp)
      addiu $sp,renderTextBufToTextBoxList_stackSize
      jr $ra
      nop
    
    ;=========================================
    ; overflow
    ;=========================================
    
    renderTextBoxLine_stackRegsSize        equ 12
    renderTextBoxLine_stackStructsSize     equ 16+16
    renderTextBoxLine_stackSize equ renderTextBoxLine_stackRegsSize+renderTextBoxLine_stackStructsSize
        
    renderTextBoxLine_overflow:
        
        ; a0 = dstX
        beq $a0,$zero,@@doRender
        li $a0,textBoxBaseX
          ; center the buffer horizontally:
          ; x = baseX + ((boxW - bufferW) / 2)
          
          ; v1 = bufferW
          lbu $v1,0x14($sp)
          ; v0 = boxW
          li $v0,textBoxWidth
          ; v0 = (boxW - bufferW) / 2
          subu $v0,$v1
          srl $v0,1
          ; add to baseX
          addu $a0,$v0
        @@doRender:
        ; apply global y-offset
        lb $v0,textBoxContentGlobalYOffset
        jal genTextBoxRenderCmd
        addu $a1,$v0
      
      renderTextBoxLine_overflow_done:
      @@done:
      lw $ra,renderTextBoxLine_stackStructsSize+0($sp)
      lw $s0,renderTextBoxLine_stackStructsSize+4($sp)
      lw $s1,renderTextBoxLine_stackStructsSize+8($sp)
      jr $ra
      addiu $sp,renderTextBoxLine_stackSize
  
    ; an offset to the y-position of all generated
    ; text box rendering commands.
    ; this is necessary because for whatever stupid reason,
    ; the developers positioned the dialogue box 4 pixels lower than
    ; the menu message box, despite having otherwise identical appearances.
    ; as we now use the same rendering functions for both,
    ; we need to be able to offset everything to account for this.
    textBoxContentGlobalYOffset:
      .db 0x00
    .align 4
    
  .endarea

  ;============================================================================
  ; REPLACEMENT:
  ; text box script pointer initialization
  ;============================================================================
  
  .org 0x800FDE50
  .area 0x800FDE9C-.,0xFF
  
    ;=========================================
    ; set up text box srcptr
    ; a0 = new pointer
    ;=========================================
    
      sw $a0,textBox_printStateBuf+printStateBuf_srcPtr
      
      ; let the game know we've initialized this
      ; by putting it at the original target address
      ; (we don't use this any more, but it prevents the game from repeatedly
      ; running the initialization code)
      sw $a0,0x0428($gp)
      
      ; other initialization
      ; print timer?
      sb $zero, 0x0422($gp)
      ; ???
      sw $zero, 0x05D0($gp)
      
      jr $ra
      nop
  
  .endarea

  ;============================================================================
  ; MODIFICATION:
  ; init print buf for printTextBoxSubstr
  ;============================================================================
  
  .org 0x800FE528
    jal doPrintTextBoxSubstrInit
    nop
  
  ;============================================================================
  ; REPLACEMENT + FREE SPACE:
  ; printTextBoxSubstr
  ;============================================================================
  
  .org 0x800FE540
  .area 0x800FE5B8-.,0xFF
  
    ;=========================================
    ; use our new standard handler
    ;=========================================
    
    jal textBox_stdPrintLoop
    nop
    
    lbu $a0,textBoxTerminated
    nop
    beq $a0,$zero,0x800FE5F0
    nop
    
    ; do termination logic
    j 0x800FE5C0
    nop
    
    ;=========================================
    ; extra init
    ;=========================================
    
    ; a0 = new srcptr
    doPrintTextBoxSubstrInit:
      ; use new srcptr
      sw $a0,textBox_printStateBuf+printStateBuf_srcPtr
      
      ; finish regular init
      j 0x800FE4A8
      nop
    
    ;=========================================
    ; returns nonzero if current menuBoxDisplayQueue
    ; differs from previous
    ;=========================================
    
    isMenuBoxDisplayStringPtrQueueChanged:
      subiu $sp,4
      sw $ra,0($sp)
      
        ; compare queue memory space
        ; (the actual number ot items in the queue shouldn't matter,
        ; since we copy the whole memory space over before doing the comparison)
        la $a0,menuBoxDisplayQueue
        la $a1,menuBoxDisplayQueue_previous
        jal memcmp
        li $a2,menuBoxDisplayStringQueueSize
      
      lw $ra,0($sp)
      addiu $sp,4
      jr $ra
      nop
      
  
  .endarea

  ;============================================================================
  ; MODIFICATION + FREE SPACE:
  ; standard text box character fetch + print
  ;============================================================================
  
  .org 0x800FDED4
  .area 0x800FDF4C-.,0xFF
    
    ;=========================================
    ; use print loop
    ;=========================================
    
    jal textBox_stdPrintLoop
    nop
    
    lbu $a0,textBoxTerminated
    nop
    beq $a0,$zero,0x800FDF84
    nop
    
    ; do termination logic
    j 0x800FDF54
    nop
    
    ;=========================================
    ; new standard printing loop
    ;=========================================
    
    textBox_stdPrintLoop:
      subiu $sp,4
      sw $ra,0($sp)
    
      @@loop:
        jal advanceTextBoxPrinting
        nop
        
        ; done if break reached
        bne $v0,$zero,@@done
        nop
        
        ; check for auto-advance
        lb $v0,0x422($gp)
        nop
        beq $v0,$zero,@@loop
        nop
      
      @@done:
      ; any previous button prompt has no longer just been confirmed
      sw $zero,buttonPromptJustConfirmed
      
      lw $ra,0($sp)
      addiu $sp,4
      jr $ra
      nop
    
  .endarea
  

  ;============================================================================
  ; FREE SPACE:
  ; fetchTextBoxChar
  ;============================================================================
  
  .org 0x800FDDBC
  .area 0x800FDE1C-.,0xFF
    
    ;=========================================
    ; dummy original function
    ;=========================================
    
      jr $ra
      nop
    
/*    new_fetchTextBoxChar:
      ; v0 = *(srcptr++)
      lw $v1,textBoxSrcPtrGp($gp)
      nop
      lbu $v0,0($v1)
      addiu $v1,1
      sw $v1,textBoxSrcPtrGp($gp)
      
      
      jr $ra
      nop */
    
    ;=========================================
    ; permanent print buffer for text box
    ;=========================================
    
      textBox_printStateBuf:
        makePrintStateBuf
    
    ;=========================================
    ; extra text box memory
    ;=========================================
    
      ; ID of the buffer currently being printed to
      textBox_activeBufferId:
        .db textBoxBufStartIndex
      
      ; current output line number.
      ; if this equals or exceeds the count of lines in the box:
      ; - lineOffset = ((lineNum + 1) % maxLines)
      ; - each buffer's target render y-position becomes
      ;   baseY + (((lineOffset + bufSubNum) % maxLines) * lineSpacing)
      textBox_lineNum:
        .db 0
      
      ; if nonzero, each line of the text box will be centered
      ; horizontally and vertically
      textBox_centeringOn:
        .db 0
      
      .align 4
      
    ;=========================================
    ; overflow
    ;=========================================
    
/*      clearAndResetTextBox_overflow:
        la.u $a0,textBox_printStateBuf
        jal resetPrintStateBuf
        la.l $a0,textBox_printStateBuf
        
        sb.u $zero,textBox_lineNum
        j clearAndResetTextBox_reentry
        sb.l $zero,textBox_lineNum */
    
  .endarea

  ;============================================================================
  ; REPLACEMENT:
  ; correctly reset text box buffer
  ;============================================================================
  
  .org 0x800FFB5C
  .area 0x800FFBA4-.,0xFF
    
    ;=========================================
    ; blankTextBoxBuffer
    ;=========================================
  
    clearAndResetTextBox_full:
      subiu $sp,4
      sw $ra,0($sp)
;      sw $s0,4($sp)
        
        jal clearAndResetTextBox_sub
        nop
        
        ; clear menubox queue (as it is guaranteed to be no longer valid)
        la $a0,menuBoxDisplayQueue
        li $a1,0x00
        jal memset
        li $a2,menuBoxDisplayStringQueueSize
        
      @@done:
      lw $ra,0($sp)
      addiu $sp,4
;      lw $s0,4($sp)
      jr $ra
      nop
    
  .endarea

  ;============================================================================
  ; MODIFICATION:
  ; text box content rendering
  ;============================================================================
    
    .org 0x801002F0
    
    ;=========================================
    ; render all text box lines
    ;=========================================
    
      ; line counter
      move $s0,$zero
      @@loop:
        ; render line
        jal renderTextBoxLine
        move $a0,$s0
        
        ; loop over all lines
        addiu $s0,1
        bne $s0,numTextBoxBuffers,@@loop
        nop
      j 0x80100338
      nop

  ;============================================================================
  ; FREE SPACE:
  ; renderTextBoxChar
  ; (all original calls are overwritten)
  ;============================================================================
  
  .org 0x800FFE58
  .area 0x800FFF30-.,0xFF
    
    ;=========================================
    ; renderTextBoxLine
    ;
    ; a0 = buffer subnum
    ;      (0 = first line buffer, 1 = second, etc.)
    ;=========================================
  
    renderTextBoxLine:
      subiu $sp,renderTextBoxLine_stackSize
      sw $ra,renderTextBoxLine_stackStructsSize+0($sp)
      sw $s0,renderTextBoxLine_stackStructsSize+4($sp)
      sw $s1,renderTextBoxLine_stackStructsSize+8($sp)
      
        ; s0 = buffer subnum
        move $s0,$a0
        
        ;==========
        ; look up this line's textBuf
        ;==========
        
        ; s1 = textBuf for this line
        jal getTextBufByIndex
        addiu $a0,$s0,textBoxBufStartIndex
        
        ; a0 = textBuf width
        lhu $a0,textBuf_width($v0)
        move $s1,$v0
        ; done if width is zero
;        beq $a0,$zero,@@done
        bne $a0,$zero,@@widthNotZero
        ; sp+0x14 = width
        sw $a0,0x14($sp)
          j renderTextBoxLine_overflow_done
        @@widthNotZero:
        
        ;==========
        ; set up call to genTextBoxRenderCmd
        ;==========
        
        ; sp+0x1C = clut
        li $a0,textClut
        sw $a0,0x1C($sp)
        ; sp+0x18 = height
        lbu $a1,textBuf_indexNum($s1)
        li $a0,textBufGpuH
        mult $a0,$a1
        sw $a0,0x18($sp)
        ; sp+0x10 = srcY
        mflo $a0
        sw $a0,0x10($sp)
        ; a3 = srcX
        move $a3,$zero
        ; a1 = dstY
      ; current output line number.
      ; if this equals or exceeds the count of lines in the box:
      ; - lineOffset = ((lineNum + 1) % maxLines)
      ; - each buffer's target render y-position becomes
      ;   baseY + (((lineOffset + bufSubNum) % maxLines) * lineSpacing)
        lbu $a0,textBox_lineNum
        li $a2,numTextBoxBuffers
        blt $a0,$a2,@@noLineOffset
        ; a1 = raw buffer subnum
        move $a1,$s0
          ; set a1 to target display linenum
          ; a0 = lineOffset = (lineNum+1 % maxLines)
          addiu $a0,1
;          divu $a0,$a2
;          mfhi $a0
          ; a1 = (bufSubNum-lineOffset % maxLines)
          subu $a1,$a0
          ; a1 = modulo
          divu $a1,$a2
          mfhi $a1
          
          j @@applyDstY
          ; no y-centering
          li $v0,0
        @@noLineOffset:
          ; we know fewer lines are displayed than there are in the box,
          ; so check for centering
          lbu $v1,textBox_centeringOn
          ; no y-centering
          li $v0,0
          beq $v1,$zero,@@applyDstY
          addiu $a0,1
            ; centering = (boxYCenter - (((lineNum + 1) * lineHeight) / 2)) / 2
            ; multiply textBox_lineNum by lineHeight
            li $v1,textBoxLineSpacing
            mult $a0,$v1
            li $v1,textBoxHeight
            mflo $a0
            ; subtract computed offset from center
            subu $v0,$v1,$a0
            srl $v0,1
        @@applyDstY:
        li $a2,textBoxLineSpacing
        mult $a2,$a1
        ; a2 = texpage
        li $a2,0x29
        mflo $a1
        ; add y-centering offset
        addu $a1,$v0
        lbu $a0,textBox_centeringOn
        j renderTextBoxLine_overflow
        addiu $a1,textBoxBaseY
        
;        jal genTextBoxRenderCmd
;        ; a0 = dstX
;        li $a0,textBoxBaseX
    
  .endarea

  ;============================================================================
  ; MODIFICATION:
  ; printTextBoxNumber
  ;============================================================================
  
    ;=========================================
    ; use our new standard handler
    ;=========================================
    
    .org 0x800FE338
      jal textBox_stdPrintLoop
      nop
      
      lbu $a0,textBoxTerminated
      nop
      ; do termination logic
      bne $a0,$zero,0x800FE3B8
      nop
      
      ; loop if timer zero
      lb $v0,0x0422($gp)
      nop
      beq $v0,$zero,0x800FE340
      nop
      
      j 0x800FE3E8
      nop

  ;============================================================================
  ; MODIFICATION:
  ; initTextBoxBuffer
  ;============================================================================
  
  ; minus sign if negative
  .org 0x800FE000
    ; flip sign of input
    subu $s0,$zero,$s0
    ; place minus sign in buffer
    lw $a0,0x0428($gp)
    li $a1,strChar_minus
    sb $a1,0($a0)
    addiu $a0,1
    j 0x800FE03C
    sw $a0,0x0428($gp)
  
  

  ; ten thousands place:
  ; use new base value when converting from raw digit value
  ; to printable string digit
  .org 0x800FE05C
    addiu $a0,$a1,strDigitBase
  
  ; ten thousands place:
  ; write 8-bit value to buffer instead of 16-bit
  .org 0x800FE070
    sb $a0,0x0000($v1)
    move $s1,$a1
    j 0x800FE08C
    nop
  
    
  
  ; thousands place:
  ; use new base value when converting from raw digit value
  ; to printable string digit
  .org 0x800FE0DC
    addiu $a0,$a1,strDigitBase
  
  ; thousands place:
  ; write 8-bit value to buffer instead of 16-bit
  .org 0x800FE0E8
    sb $a0,0x0000($v1)
    or $s1,$a1
    j 0x800FE104
    nop
  
  
  
  ; hundreds place:
  ; use new base value when converting from raw digit value
  ; to printable string digit
  .org 0x800FDFFC
    li $s2,strDigitBase
  
  ; hundreds place:
  ; write 8-bit value to buffer instead of 16-bit
  .org 0x800FE178
    sb $v0,0x0000($v1)
    or $s1,$a0
    j 0x800FE198
    nop
  
  
  
  ; tens place:
  ; use new base value when converting from raw digit value
  ; to printable string digit
  ; (recycled register, same as previous)
;  .org 0x800FDFFC
;    li $s2,strDigitBase
  
  ; tens place:
  ; write 8-bit value to buffer instead of 16-bit
  .org 0x800FE20C
    sb $v0,0x0000($v1)
;    or $s1,$a0
    j 0x800FE22C
    nop
  
  ; ones place:
  ; use new base value when converting from raw digit value
  ; to printable string digit
  ; (recycled register, same as previous)
;  .org 0x800FDFFC
;    li $s2,strDigitBase
  
  ; ones place:
  ; write 8-bit value to buffer instead of 16-bit
  .org 0x800FE26C
    sb $v0,0x0000($a0)
;    or $s1,$a0
    j 0x800FE28C
    nop
  
  ; finish up by writing buffer
  .org 0x800FE28C
    lw $v1,0x0428($gp)
    ; a0 = buffer start pointer
    la $a0,0x8013BA80
    ; terminator
    sb $zero,0($v1)
    ; save buffer start pos to printStateBuf
    sw $a0,textBox_printStateBuf+printStateBuf_srcPtr
    j 0x800FE2C0
    ; save buffer start pos to original srcptr
    sw $a0,0x0428($gp)
  
  ;============================================================================
  ; MODIFICATION:
  ; render text box choice strings
  ;============================================================================
  
  .org 0x80100258
  .area 0x8010028C-.,0xFF
    
    ;=========================================
    ; draw choice string
    ; (pointer currently in v0)
    ;=========================================
    
      ; print string
      jal printStdString
      move $a0,$v0
      
      ; check if fail
      beq $v0,$zero,0x8010028C
      nop
      
      ; render
      ; a0 = buffer pointer
      ; a1 = x
      ; a2 = y
      move $a0,$v0
      move $a1,$s0
      jal renderTextBufToTextBoxList
      addu $a2,$s5,$s2
      
      j 0x8010028C
      nop
    
  .endarea
  
  ;============================================================================
  ; MODIFICATION:
  ; shift prompt choice strings + cursor left to allow
  ; slightly longer strings
  ;============================================================================
  
  .org 0x80100250
    ; text x
    ori $s0, $zero, 0x0024+promptChoiceXOffset
  
  .org 0x80100228
    ; cursor x
    ori $a0, $zero, 0x0015+promptChoiceXOffset

  ;============================================================================
  ; MODIFICATION:
  ; text printing speed
  ;============================================================================
    
    ; number of frames per character
    .org 0x8012BDCF
      .db 0x02-1

  ;============================================================================
  ; MODIFICATION:
  ; make sure printing speed remains doubled no matter what
  ;============================================================================
    
    .org 0x800FEC74
      ; when setting printing speed via scripting system,
      ; right-shift one additional place to halve delay per character
      sra $a0, $v0, 16+1
  
  ;============================================================================
  ; FREE SPACE:
  ; a SJIS to printable conversion function that was
  ; barely used in the original game, and now isn't used at all
  ;============================================================================
  
  .org 0x800FFAB8
  .area 0x800FFB5C-.,0xFF
    
    ;=========================================
    ; dummy original routine
    ;=========================================
    
    jr $ra
    nop
    
    ;=========================================
    ; extra init logic injected to start of
    ; renderMenuBoxMsg
    ;=========================================
    
    newMenuBoxPrintInit:
      ; nonstandard stack usage -- we are injecting into
      ; the start of a function and need to save its params
      ; for when we return back to it
      subiu $sp,12
      sw $ra,0($sp)
      sw $a0,4($sp)
      sw $a1,8($sp)
        
        ; copy "current" (now old) queue to previous
        la $a0,menuBoxDisplayQueue
        la $a1,menuBoxDisplayQueue_previous
        jal memcpy
        li $a2,menuBoxDisplayStringQueueSize
        
        ; reset current queue size
        sb $zero,menuBoxDisplayQueue_size
      
      lw $ra,0($sp)
      lw $a0,4($sp)
      lw $a1,8($sp)
      addiu $sp,12
      
      ; make up work
      addiu $sp,-0x90
      ; jump past injection point
      j 0x8003AABC+8
      sw $s2,0x78($sp)
    
    ;=========================================
    ; extra end logic injected to end of
    ; renderMenuBoxMsg
    ;=========================================
    
    newMenuBoxPrintEnd:
      ; save return value only; everything else is already saved
      subiu $sp,4
      sw $v0,0($sp)
;      sw $s0,4($sp)
      
        ;==========
        ; evaluate menu box queue to see if printing needed
        ;==========
        
        jal isMenuBoxDisplayStringPtrQueueChanged
        nop
        
        beq $v0,$zero,@@noPrintNeeded
        nop
        
          ;==========
          ; print menu box queue
          ;==========
          
          jal printMenuBoxQueue
          nop
          
        @@noPrintNeeded:
        
        ;==========
        ; render menu box queue
        ;==========
        
        jal renderMenuBoxQueue
        nop
      
      lw $v0,0($sp)
;      lw $s0,4($sp)
      addiu $sp,4
      
      ; make up work
      lw $ra,0x88($sp)
      j 0x8003C058+8
      lw $s5,0x84($sp)
  
  .endarea

  ;============================================================================
  ; MODIFICATION:
  ; y-position of lulu face "press a button" indicator
  ;============================================================================
    
    ; this needs to be lowered to avoid overlapping
    ; the new fourth line of text
    .org 0x8003D0C0
;      li $v0,0xC7+7
      ; except lol, it turns out they actually positioned it where they did
      ; specifically so it would be covered up by the text box when inactive,
      ; because it continues to get drawn even after the prompt is dismissed.
      ; maybe i'll fix it if i have to.
      ; ...actually, a few pixels of this icon poke out from behind the box
      ; even in the original game!
      ; pay more attention, programmer!
      ;
      ; so if i'm not mistaken, what's happening here is that the game ceases
      ; to redraw the "game" content while the menu is open, and whatever's
      ; in the background just sits there, left over from the last frame drawn.
      ; where this poses a problem is that anything that is not specifically
      ; drawn over by the menu every frame remains where it is.
      ; this includes anything that the menu draws and does not continuously
      ; draw over... such as this icon, which spills over into the "game area"
      ; and continues to sit in the framebuffer permanently.
      ; effectively, we _can't_ get rid of it without rerendering the whole
      ; game area!
      li $v0,0xC7+0
  
  ;============================================================================
  ; REPLACEMENT + FREE SPACE:
  ; printSjisString
  ; TODO: ensure anything that calls printSjisString outside of
  ;       renderMenuBoxMsg is redirected elsewhere, as this function
  ;       now sends content to menuBoxDisplayQueue for future evaluation
  ;       instead of actually rendering it
  ;       (there are a grand total of 4 calls to printSjisString outside
  ;       of renderMenuBoxMsg, which is why i did it this way)
  ;============================================================================
  
  .org 0x8003C080
  .area 0x8003C274-.,0xFF
  
    ;=========================================
    ; replace original routine
    ;=========================================
    
    printSjisString:
      subiu $sp,4
      sw $ra,0($sp)
;      sw $s0,4($sp)
      
        ; add to menu box queue
        jal queueToMenuBoxDisplayQueue
        ; a0 = string pointer
        lw $a0,0x0AB4($gp)
      
      lw $ra,0($sp)
;      lw $s0,4($sp)
      addiu $sp,4
      jr $ra
      nop
    
    ;=========================================
    ; queue a string pointer entry to back of
    ; menuBoxDisplayQueue
    ;
    ; a0 = string pointer to queue
    ;=========================================
    
    queueToMenuBoxDisplayQueue:
      la $a1,menuBoxDisplayQueue_size
      ; a2 = number of items in queue
      lbu $a2,0($a1)
      ; a3 = pointer to current queue position
      la $a3,menuBoxDisplayQueue
      ; do nothing if queue full
      beq $a2,maxMenuBoxDisplayStrings,@@done
      ; v0 = offset into queue for current item
      sll $v0,$a2,2
        addu $a3,$v0
        ; save pointer to queue
        sw $a0,0($a3)
        ; ++size
        addiu $a2,1
      @@done:
      jr $ra
      sb $a2,0($a1)
    
    ;=========================================
    ; queue a string pointer entry X entries
    ; back from the end of the queue
    ;
    ; a0 = NOTHING, IGNORE
    ; a1 = count of entries from back
    ;      (0 = place at end,
    ;       1 = place one before end,
    ;       etc.)
    ;=========================================
    
    cutLineOfMenuBoxDisplayQueue:
      ; a0 = string pointer
      lw $a0,0x0AB4($gp)
      
      ; if not cutting line, handle as normal
      beq $a1,$zero,queueToMenuBoxDisplayQueue
      la $v1,menuBoxDisplayQueue_size
      ; a2 = number of items in queue
      lbu $a2,0($v1)
      ; a3 = pointer to current queue position
      la $a3,menuBoxDisplayQueue
      ; do nothing if queue full
      beq $a2,maxMenuBoxDisplayStrings,@@done
      ; increment queue size while we have it available
      addiu $v0,$a2,1
        sb $v0,0(v1)
        
        @@loop:
          ; decrement target item index
          subiu $a2,1
          
          ; t0 = pointer to target item
          sll $v0,$a2,2
          addu $t0,$a3,$v0
          
          ; t1 = current item
          lw $t1,0($t0)
          ; decrement places to cut
          subiu $a1,1
          ; move to next position
          ; done if no places left to cut
          bne $a1,$zero,@@loop
          sw $t1,4($t0)
        ; save new item to new position
        sw $a0,0($t0)
      @@done:
      jr $ra
      nop
    
    ;=========================================
    ; queue a string pointer entry 1 entry
    ; back from the end of the queue
    ;=========================================
    
    cutLineOfMenuBoxDisplayQueueBy1:
      j cutLineOfMenuBoxDisplayQueue
      li $a1,1
    
    ;=========================================
    ; render the menu box queue
    ; (i.e. the text box buffer)
    ;=========================================
    
    renderMenuBoxQueue:
      subiu $sp,8
      sw $ra,0($sp)
      sw $s0,4($sp)
        
        ; reset index position for rendering commands
        ; (since the original game did not use the "text box"
        ; on the menus, it does not reset this itself;
        ; if we don't reset it, it will fill up to the limit of 64
        ; entries and then stop rendering)
        sw $zero,textBoxRenderCmdIndexPosGp($gp)
        
        ; temporarily set the global text box content y-offset
        ; to account for discrepancy between main and menu box positions
        li $a0,-4
        sb $a0,textBoxContentGlobalYOffset
      
        ;==========
        ; render all text box lines
        ;==========
      
        ; line counter
        move $s0,$zero
        @@loop:
          ; render line
          jal renderTextBoxLine
          move $a0,$s0
          
          ; loop over all lines
          addiu $s0,1
          bne $s0,numTextBoxBuffers,@@loop
          nop
        
        ; reset global text box content y-offset
        sb $zero,textBoxContentGlobalYOffset
      
      lw $ra,0($sp)
      lw $s0,4($sp)
      jr $ra
      addiu $sp,8
  
    ;=========================================
    ; print the menu box queue to the
    ; text box buffer
    ;=========================================
    
    printMenuBoxQueue:
      subiu $sp,12
      sw $ra,0($sp)
      sw $s0,4($sp)
      sw $s1,8($sp)
      
        ;==========
        ; clear existing content from box buffer
        ;==========
        
        jal clearAndResetTextBox_sub
        nop
        
        ;==========
        ; print each queued string
        ;==========
        
        ; s0 = counter
        lbu $s0,menuBoxDisplayQueue_size
        ; s1 = queue position
        la $s1,menuBoxDisplayQueue
        @@loop:
          ; a0 = string pointer
          lw $a0,0($s1)
          nop
          ; set as srcptr
          sw $a0,textBox_printStateBuf+printStateBuf_srcPtr
          
          ; print until terminator reached
          @@printLoop:
            jal advanceTextBoxPrinting
            nop
            lbu $a0,textBoxTerminated
            nop
            beq $a0,$zero,@@printLoop
            nop
          
          subiu $s0,1
          bne $s0,$zero,@@loop
          addiu $s1,4
      
      lw $ra,0($sp)
      lw $s0,4($sp)
      lw $s1,8($sp)
      jr $ra
      addiu $sp,12
    
    ;=========================================
    ; substep for clearing text box
    ;=========================================
    
    clearAndResetTextBox_sub:
      subiu $sp,8
      sw $ra,0($sp)
      sw $s0,4($sp)
        
        la.u $a0,textBox_printStateBuf
        jal resetPrintStateBuf
        la.l $a0,textBox_printStateBuf
        
        sb $zero,textBox_lineNum
        
        li $s0,numTextBoxBuffers
        @@loop:
          addiu $a0,$s0,textBoxBufStartIndex-1
          ; textBoxBufStartIndex will ultimately get set to
          ; the index of the first buffer
          sb $a0,textBox_activeBufferId
          jal getTextBufByIndex
          subiu $s0,1
          
          ; this sets the srcptr/hash to garbage values,
          ; but they're ignored for the text box buffers so it doesn't matter
          jal initTextBuf
          move $a0,$v0
          
      bne $s0,$zero,@@loop
      @@done:
      lw $ra,0($sp)
      lw $s0,4($sp)
      jr $ra
      addiu $sp,8
  
  .endarea
  
  ;============================================================================
  ; REPLACEMENT + FREE SPACE:
  ; lulu name print loop within item msg handler 4
  ;============================================================================
  
  .org 0x8003B6A8
  .area 0x8003B7E4-.,0xFF
  
    ;=========================================
    ; replace original code
    ;=========================================
    
      ; a0 = lulu name pointer
;      li.u $a0,luluName_std
      ; print
;      jal printSjisString
;      li.l $a0,luluName_std
      ; lol i forgot this function uses a global instead of a param
      la $a0,luluName_std
      jal printSjisString
      sw $a0,0x0AB4($gp)
      
      j 0x8003B7E4
      nop
  
    ;=========================================
    ; new stuff
    ;=========================================
    
      ; s2 = item ID
      doSecondLineConsumableItemDescriptionCheck:
        ; items 34-38 need first/second line flipped
        blt $s2,34,@@noFlip
        nop
        bge $s2,39,@@noFlip
        nop
          j cutLineOfMenuBoxDisplayQueueBy1
          nop
        @@noFlip:
          j printSjisString
          nop
      
      ; s0 = first string offset
      ; s1 = second string offset
      ; s2 = item ID
      doSpecialItemDescriptionCheck:
        ; meymey (112), reliefs (113-133) need flip
        blt $s2,112,@@notRelief
        nop
        ble $s2,133,@@flip
        nop
        @@notRelief:
        
        ; maps (0x98-0x9F) need flip
        blt $s2,152,@@notMap
        nop
        ble $s2,159,@@flip
        nop
        @@notMap:
        
        ; keys (134-137) need flip
        blt $s2,134,@@notKey
        nop
        ble $s2,137,@@flip
        nop
        @@notKey:
        
        @@noMatch:
          j @@noFlip
          nop
        
        @@flip:
          ; switch s1 and s2
          move $v0,$s1
          move $s1,$s0
          move $s0,$v0
        @@noFlip:
        
        ; make up work
        sll $v0,$s1,2
        lui $at, 0x8012
        j 0x8003AF70
        addu $at, $at, $v0
     
    cutMenuBoxQueueAndFinish:
      jal cutLineOfMenuBoxDisplayQueueBy1
      nop
      j 0x8003C054
      nop
    
    doStatIncreaseMessageFix:
      ; make up work
      sw $zero, 0x0694($gp)
      sw $v0, 0x0698($gp)
      sw $v1, 0x0AB4($gp)
      
      jal cutLineOfMenuBoxDisplayQueueBy1
      nop 
      j 0x8003BEA0
      nop
  
/*    doGoldenScarabFix:
      ; make up work
      jal printSjisString
      nop
      
      ;==========
      ; evaluate menu box queue to see if printing needed
      ;==========
      
      jal isMenuBoxDisplayStringPtrQueueChanged
      nop
      
      beq $v0,$zero,@@noPrintNeeded
      nop
      
        ;==========
        ; print menu box queue
        ;==========
        
        jal printMenuBoxQueue
        nop
        
      @@noPrintNeeded:
      
      ;==========
      ; render menu box queue
      ;==========
      
      jal renderMenuBoxQueue
      nop
      
      j 0x8003EA78
      nop*/
    
    doGoldenScarabStartFix:
      ; copy "current" (now old) queue to previous
      la $a0,menuBoxDisplayQueue
      la $a1,menuBoxDisplayQueue_previous
      jal memcpy
      li $a2,menuBoxDisplayStringQueueSize
      
      ; reset current queue size
      sb $zero,menuBoxDisplayQueue_size
      
      ; make up work
      lw $v1, 0x0994($gp)
      j 0x8003E1C4
      ori $v0, $zero, 0x0006
  
  .endarea
  
  ;============================================================================
  ; MODIFICATION:
  ; inject new init logic into renderMenuBoxMsg
  ;============================================================================
  
    .org 0x8003AABC
      j newMenuBoxPrintInit
      nop
  
  ;============================================================================
  ; MODIFICATION:
  ; inject new finish logic into renderMenuBoxMsg
  ;============================================================================
  
    .org 0x8003C058
      j newMenuBoxPrintEnd
      nop

  ;============================================================================
  ; MODIFICATION:
  ; correct order of ~min stat increase item descriptions
  ;============================================================================
  
    .org 0x8003ADA4
      jal cutLineOfMenuBoxDisplayQueueBy1

  ;============================================================================
  ; MODIFICATION:
  ; correct order of ~min stat increase item inventory use messages
  ;============================================================================
  
    .org 0x8003B324
      j cutMenuBoxQueueAndFinish
      nop

  ;============================================================================
  ; MODIFICATION:
  ; correct order of stat increase message after using ~min item
  ;============================================================================
  
    .org 0x8003BC10
      j doStatIncreaseMessageFix
      ori $v0, $zero, 0x0001

  ;============================================================================
  ; MODIFICATION:
  ; flush queued messages when using golden scarab
  ;============================================================================
    
    ; inexplicably, this one menu is programmed completely differently from
    ; every other use menu in the game and bypasses the normal menu
    ; printing entirely.
    ; so we have to have an entirely separate queue init/check cycle
    ; just to make sure it works.
    ; why??
  
;    .org 0x8003EA70
;      j doGoldenScarabFix
;      addu $s3, $zero, $zero
  
    .org 0x8003E1BC
      j doGoldenScarabStartFix
      nop
  
    .org 0x8003EA70
      j doGoldenScarabEndFix
      addu $s3, $zero, $zero
      
  ;============================================================================
  ; MODIFICATION:
  ; invert order of grimoire description messages
  ;============================================================================
  
;    .org 0x8003ADE0
;;      lhu $s1, 0x5B5C($at)
;      lhu $s1, 0x5B5E($at)
    
;    .org 0x8003AE10
;;      lhu $s1, 0x5B5E($at)
;      lhu $s1, 0x5B5C($at)
    
    ; these are the index numbers of the two strings to print
    ; for each item, in order.
    ; the hack simply swaps them as needed.
    .org 0x80115B5C
      ; ÅqÇ”ÇüÇ¢Ç†ÇÒÇÃñ{År
;      .dh 0x10D,0x111
      .dh 0x111,0x10D
      ; ÅqÇ”ÇÎÇ∑Ç∆ÇÒÇÃñ{År
;      .dh 0x10E,0x111
      .dh 0x111,0x10E
      ; ÅqÇ∑ÇØÇ∑ÇØÇÃñ{År
;      .dh 0x112,0x114
      .dh 0x114,0x112
      ; ÅqÇƒÇÍÇ€Ç€ÇÃñ{År
;      .dh 0x113,0x114
      .dh 0x114,0x113
      ; ÅqÇ–Å`ÇÁÇÁÇÃñ{År
;      .dh 0x115,0x116
      .dh 0x116,0x115
      ; ÅqÇŒÇ⁄Å`ÇÒÇÃñ{År
;      .dh 0x10F,0x111
      .dh 0x111,0x10F
      ; ÅqÇ´Ç„Ç†Ç€ÇÒÇÃñ{År
;      .dh 0x117,0x118
      .dh 0x118,0x117
      ; ÅqÇŒÇËÇŒÇËÇÃñ{År
;      .dh 0x110,0x111
      .dh 0x111,0x110

  ;============================================================================
  ; MODIFICATION:
  ; fix various descriptions by inverting composite structure order
  ; (fertilizer, meymey food, building stat increase items...)
  ;============================================================================
  
  .org 0x8003AD40
    jal doSecondLineConsumableItemDescriptionCheck
    
/*  .org 0x8003ABBC
  .area 0x8003AC04-.,0xFF
  
    ; look up pointer to "use X action type" string
    andi $v0, $s2, 0x0001
    addiu $s1, $v0, 0x00CC
    sll $v0, $s1, 2
    addu $v0, $v0, $s4
    lw $v0, 0x0000($v0)
    nop
    sw $v0, 0x0AB4($gp)
    jal printSjisString
    nop
  
    ; look up pointer to "X times" string
    addiu $s1, $v0, 0x00C8
    sll $v0, $s1, 2
    addu $v0, $v0, $s4
    lw $v0, 0x0000($v0)
;    ori $s0, $zero, 0x0002
;    sw $zero, 0x0694($gp)
;    sw $s0, 0x0698($gp)
;    sw $v0, 0x0AB4($gp)
;    jal printSjisString
;    nop
    
    j 0x8003AC64
    nop
  
  .endarea */

  ;============================================================================
  ; MODIFICATION:
  ; fix some more descriptions (maps, etc.)
  ;============================================================================
  
  .org 0x8003AF68
    j doSpecialItemDescriptionCheck
    nop
  
  ;============================================================================
  ; FREE SPACE:
  ; renderFixedChar
  ;============================================================================
  
  .org 0x800434C8
  .area 0x800436A8-.,0xFF
    
    ;=========================================
    ; dummy original routine
    ;=========================================
    
    jr $ra
    nop
    
    ;=========================================
    ; render a string with scaling
    ; 
    ; a0 = string pointer
    ; a1 = struct:
    ;      +0 = bounding box X
    ;      +2 = bounding box Y
    ;      +4 = unscaled dst x-offset of string from bounding box X
    ;      +6 = unscaled dst y-offset of string from bounding box Y
    ;      (bounding box coordinates are used
    ;      to correctly position the output
    ;      after scaling)
    ; a2 = scale factor
    ;      fixed-point, 8 bits of decimal precision
    ;      0x100 = full-scale, 0x80 = half-scale,
    ;      0x200 = double-scale, etc.
    ; a3 = dst for rendering command
    ;      (note: 0x28 bytes)
    ;=========================================
    
    renderScaledString_stackRegsSize        equ 20
    renderScaledString_stackStructsSize     equ 16
    renderScaledString_stackSize equ renderScaledString_stackRegsSize+renderScaledString_stackStructsSize
    
    renderScaledString:
      subiu $sp,renderScaledString_stackSize
      sw $ra,renderScaledString_stackStructsSize+0($sp)
      sw $s0,renderScaledString_stackStructsSize+4($sp)
      sw $s1,renderScaledString_stackStructsSize+8($sp)
      sw $s2,renderScaledString_stackStructsSize+12($sp)
      sw $s3,renderScaledString_stackStructsSize+16($sp)
      
        ;==========
        ; set up
        ;==========
      
        ; s0 = dstbox
        move $s0,$a1
        ; s1 = scale factor
        move $s1,$a2
        
        ; print string
        jal printStdString
        ; s3 = dst for rendering command
        move $s3,$a3
        
        ; done if print failed
        beq $v0,$zero,@@done
        ; s2 = result textBuf pointer
        move $s2,$v0
        
        ;==========
        ; compute src coords
        ;==========
        
        ; sp+0 = srcbox
        
        ; v0 = raw width
        lhu $v0,textBuf_width($s2)
        ; v1 = raw height
        li $v1,textBufGpuH
        
        ; a3 = srcY UR = buffer gpu Y
        lbu $a3,textBuf_indexNum($s2)
        ; srcX UR = always zero
;        li $a2,0
        ; set srcX UR
        sh $zero,0($sp)
        mult $a3,$v1
        mflo $a3
        sh $a3,2($sp)
        
        ; set srcX LR
        ; x = width
        sh $v0,4($sp)
        ; y = UR-y + height
        addu $a3,$v1
        sh $a3,6($sp)
        
        ;==========
        ; compute dst coords
        ;==========
        
        ; sp+8 = dstbox
        
        ; a0 = dstXOffset UL
        lh $a0,4($s0)
        ; a1 = dstYOffset UL
        lh $a1,6($s0)
        
        ; multiply X by scale factor
        mult $a0,$s1
        ; a2 = base x-coordinate
        lh $a2,0($s0)
        ; drop fixed-width decimal part
        mflo $a0
        sra $a0,8
        ; add base X
        addu $a0,$a2
        ; save to box
        sh $a0,8($sp)
        
        ; multiply Y by scale factor
        mult $a1,$s1
        ; a2 = base y-coordinate
        lh $a2,2($s0)
        mflo $a1
        ; drop fixed-width decimal part
        sra $a1,8
        ; add base Y
        addu $a1,$a2
        ; save to box
        sh $a1,10($sp)
        
        ; multiply raw width by scale factor
        mult $v0,$s1
        mflo $v0
        ; drop fixed-width decimal part
        sra $v0,8
        ; add to UL-x get LR-x
        addu $v0,$a0
        ; save
        sh $v0,12($sp)
        
        ; multiply raw height by scale factor
        mult $v1,$s1
        mflo $v1
        ; drop fixed-width decimal part
        sra $v1,8
        ; add to UL-y get LR-y
        addu $v1,$a1
        ; save
        sh $v1,14($sp)
        
        ;==========
        ; render
        ;==========
        
        ; a0 = buffer index
        ; a1 = pointer to dst for rendering command
        ; a2 = srcrect
        ; a3 = dstrect
        move $a0,$s2
        move $a1,$s3
        addiu $a2,$sp,0
        jal genPolyTextRenderCmd
        addiu $a3,$sp,8
      
      @@done:
      lw $ra,renderScaledString_stackStructsSize+0($sp)
      lw $s0,renderScaledString_stackStructsSize+4($sp)
      lw $s1,renderScaledString_stackStructsSize+8($sp)
      lw $s2,renderScaledString_stackStructsSize+12($sp)
      lw $s3,renderScaledString_stackStructsSize+16($sp)
      jr $ra
      addiu $sp,renderScaledString_stackSize
    
    ;=========================================
    ; render a scaled string in "standard" format
    ; (replacing stuff that used renderFixedChar)
    ;
    ; a0 = string pointer
    ; a1 = dstbox struct (see renderScaledString)
    ; a2 = scale factor (see renderScaledString)
    ; a3 = packed params:
    ;      - byte 0-1 (lowest) = transparency setting
    ;      - byte 2-3 = clut index (into table at 0x801C0590)
    ;=========================================
    
    renderStdScaledString:
      subiu $sp,12
      sw $ra,0($sp)
      sw $s0,4($sp)
      sw $s1,8($sp)
        
        ; s1 = packed params
        move $s1,$a3
        
        ; s0 = a3 = dst for rendering command
        lw $a3,0x0A2C($gp)
        jal renderScaledString
        move $s0,$a3
        
        ; link into display list
        ; a0 = old link
        ; a1 = new link
        move $a1,$s0
        lw $a0,0x8012C0B0
        jal linkIntoDisplayList
        addiu $a0,0x408
        
        ; adjust transparency setting
        ; a0 = render cmd pointer
        ; a1 = flag
        move $a0,$s0
        jal setRectRenderCmdTransparency
        andi $a1,$s1,0xFFFF
        
        ; adjust clut
        ; a1 = table pointer
        li $a1,0x801C0590
        ; a0 = index
        srl $a0,$s1,16
        andi $a0,0xFFFF
        ; fetch from table
        sll $a0,1
        addu $a0,$a1
        lhu $a0,0($a0)
        nop
        sh $a0,0xE($s0)
        
        ; update render dst
        addiu $s0,0x28
        sw $s0,0x0A2C($gp)
      
      lw $ra,0($sp)
      lw $s0,4($sp)
      lw $s1,8($sp)
      jr $ra
      addiu $sp,12
    
  .endarea

  ;============================================================================
  ; REPLACEMENT + FREE SPACE:
  ; render lulu name on pause menu
  ;============================================================================
  
  .org 0x8003EF8C
  .area 0x8003F0C4-.,0xFF
  
    ;=========================================
    ; render lulu name
    ;=========================================
    
    ; a1 = dstbox struct
    la $a1,stdScaledStringDstbox
    ; v0 = bounding-x
    lw $v0,0x28($sp)
    ; v1 = bounding-y
    lw $v1,0x30($sp)
    sh $v0,0($a1)
    ; v0 = offset-x
    li $v0,0x60-14
    sh $v1,2($a1)
    ; v1 = offset-y
    li $v1,0x8+2
    sh $v0,4($a1)
    sh $v1,6($a1)
    
    ; a3 = transparency setting
    lbu $a3,0x8012C3A4
    ; a2 = scale factor
    lw $a2,0x38($sp)
    ; v0 = clut index
    li $v0,0x0001
    sll $v0,16
    or $a3,$v0
    ; a0 = string pointer
    li $a0,luluName_std
    jal renderStdScaledString
    nop
    
    j 0x8003F0C4
    nop
    
    ;=========================================
    ; new stuff
    ;=========================================
    
    ; i don't feel like trying to juggle the stack every single
    ; time i need to scale a string, so here's some static memory for
    ; the dstbox parameter that should properly go on the stack
    stdScaledStringDstbox:
      .fill 8,0x00
    .align 4
    
    
   
  .endarea

  ;============================================================================
  ; REPLACEMENT + FREE SPACE:
  ; render current area name on world map
  ;============================================================================
  
  .org 0x8004A66C
  .area 0x8004A8D4-.,0xFF
   
    ;=========================================
    ; render area name
    ;=========================================
    
    ; trick: go ahead and print the string, since we need to know
    ; its width in order to center it.
    ; this doesn't cost us any significant time, since the pre-printed content
    ; will be cached and immediately available when the "real" print occurs.
    ; a0 = string pointer
    jal printStdString
    move $a0,$s1
    
    ; a0 = string width
    lhu $a0,textBuf_width($v0)
    ; subtract from 256 (full box width)
;    li $a1,256
    ; for whatever reason (probably related to the 0x104 scaling)
    ; we need to make sure this is offset 2 pixels to the right,
    ; so make the width 260 rather than 256
    li $a1,260
    subu $a0,$a1,$a0
    ; divide by 2
    srl $a0,1
    ; multiply by scale
;    mult $a0,$fp
    
    ; a1 = dstbox struct
    la $a1,stdScaledStringDstbox
    ; v0 = bounding-x
    move $v0,$s7
    ; v1 = bounding-y
;    move $v1,$s7
    lw $v1,0x18($sp)
    sh $v0,0($a1)
    ; v0 = offset-x
;    li $v0,0x60
    ; get result of centering operation above
;    mflo $v0
    move $v0,$a0
;    sra $v0,8
    sh $v1,2($a1)
    ; v1 = offset-y
    li $v1,0x18
    sh $v0,4($a1)
    sh $v1,6($a1)
    
    ; save target render offset to s6
    ; (which is saved and doesn't matter)
    lw $s6,0x0A2C($gp)
    
    ; a3 = clut index (dummy) + transparency setting
    lw $a3,0x8012C3A4
    ; a2 = scale factor
    move $a2,$fp
    ; mysteriously, this screen gets scaled to 0x104 rather than 0x100,
    ; so cap at 0x100 to prevent minor distortion in the full-scale output
    ble $fp,0x100,@@notTooLarge
    andi $a3,0xFFFF
      li $a2,0x100
    @@notTooLarge:
    ; a0 = string pointer
    move $a0,$s1
    jal renderStdScaledString
    nop
    
    ; set clut
    lhu $a0,0x801C058E
    nop
    sh $a0,0xE($s6)
    
    j 0x8004A8D4
    nop
   
    ;=========================================
    ; new stuff
    ;=========================================
   
  .endarea

  ;============================================================================
  ; REPLACEMENT + FREE SPACE:
  ; render current area name on dungeon map
  ;============================================================================
  
  .org 0x800462A0
  .area 0x80046504-.,0xFF
   
    ;=========================================
    ; render area name
    ;=========================================
    
    ; trick: go ahead and print the string, since we need to know
    ; its width in order to center it.
    ; this doesn't cost us any significant time, since the pre-printed content
    ; will be cached and immediately available when the "real" print occurs.
    ; a0 = string pointer
    jal printStdString
    move $a0,$s1
    
    ; a0 = string width
    lhu $a0,textBuf_width($v0)
    ; subtract from 256 (full box width)
    li $a1,256
    subu $a0,$a1,$a0
    ; divide by 2
    srl $a0,1
    ; multiply by scale
;    mult $a0,$fp
    
    ; a1 = dstbox struct
    la $a1,stdScaledStringDstbox
    ; v0 = bounding-x
    move $v0,$s6
    ; v1 = bounding-y
;    move $v1,$s7
    lw $v1,0x20($sp)
    sh $v0,0($a1)
    ; get result of centering operation above
    move $v0,$a0
    sh $v1,2($a1)
    ; v1 = offset-y
    li $v1,0x18
    sh $v0,4($a1)
    sh $v1,6($a1)
    
    ; save target render offset to s4
    lw $s4,0x0A2C($gp)
    
    ; a3 = clut index (dummy) + transparency setting
    li $a3,0
    ; a2 = scale factor
    move $a2,$s3
    ; a0 = string pointer
    move $a0,$s1
    jal renderStdScaledString
    nop
    
    ; set clut
    lhu $a0,0x801C058E
    nop
    sh $a0,0xE($s4)
    
    j 0x80046504
    nop
   
    ;=========================================
    ; new stuff
    ;=========================================
   
    ;=========================================
    ; script extension to fix dumb number
    ; display bugs
    ;=========================================
    
    script_setSpecialValue:
      ; goal: set 0x7CC($gp) to *(0x03F0($gp) + 0x059C($gp) + signedParamByte)
      ; ...and convert from game's stupid number format
    
      ; v0 = current script srcOffset
      lhu $v0, 0x0598($gp)
      ; a1 = current script base address
      lw $a1, 0x03EC($gp)
      ; srcOffset in memory += 1
      addiu $v1,$v0,1
      sh $v1,0x0598($gp)
      
      ; v0 = current script pointer
      addu $v0,$a1
      
      lw $a1,0x03F0($gp)
      lhu $a0,0x059C($gp)
      
      ; v1 = fetch param byte (signed)
      lb $v1,0($v0)
      
      ; a0 = pointer to src value
      addu $a0,$a1
      addu $a0,$v1
      
      ; copy src to dst
      ; v0 = low byte
      lbu $v0,0($a0)
      ; v1 = "high byte" (actually the hundreds place of the target amount)
      lbu $v1,1($a0)
      ; multiply hundreds place by 100 and add to low byte to get true amount
      li $a1,100
      mult $v1,$a1
      mflo $a1
      ; v0 = result
      addu $v0,$a1
      
      ; save to dst
      j 0x800FDCB8
      sh $v0,0x07CC($gp)
   
    ;=========================================
    ; fix for box-after-prompt skip bug
    ;=========================================
    
    doExtraWaitConfirmCheck:
      ; we think the player has triggered the confirm button;
      ; check if a prompt choice was just confirmed.
      ; if so, ignore the confirmation and continue waiting
      la $a0,buttonPromptJustConfirmed
      lw $a1,0($a0)
      nop
      beq $a1,$zero,@@confirmSuccessful
      ; prompt has no longer just occurred now that we've checked this,
      ; so reset it to zero
      sw $zero,0($a0)
        ; jump to branch for when button is not pressed
        j 0x800FFC60
        nop
      @@confirmSuccessful:
      ; make up work
      addu $a0, $zero, $zero
      j 0x800FFCA4
      ori $a1, $zero, 0x0004
   
    ;=========================================
    ; fix to show community name on world map
    ; during disasters
    ;=========================================
    
    communityDisasterSubmapId equ 0x215
    
    checkForCommunityDisasterName:
      ; s0 = target submap id
      ; check if disaster submap
      bne $s0,communityDisasterSubmapId,@@notDisaster
      nop
      @@isDisaster:
        ; jump to branch for using community name
        j 0x8004A5F4
        nop
      @@notDisaster:
      ; make up work
      lui $at, 0x8011
      j 0x8004A5E8
      addu $at, $at, $v0
   
    ;=========================================
    ; "fix" bug that prevents building
    ; construction/upgrade under some circumstance.
    ; the root problem still occurs, but
    ; this prevents it from having any effect.
    ;=========================================
    
    doBldgConstructionFix:
      ; v0 = building's attached pom pointer
      ; v1 = preserve
      ; a0 = preserve
      ; s1 = target building pointer +0x10
      ; s5 = this pom pointer
      
      ; make up work
      ; check if building's pom == this pom
      bne $v0,$s5,@@doAdditionalChecks
      nop
      
      @@canBuild:
        j 0x800F4AB8
        nop
      @@doAdditionalChecks:
      
      ; this building appears to already have another pom
      ; attached to it.
      ; however, some bug can cause building/pom states to become
      ; desynchronized, so check if the pom this building
      ; claims to have working on it actually lists that building
      ; as its target.
      ; if not, the building is in fact available for construction.
      
      ; a2 = pom's attached building pointer
      lw $a2,compom_attachedBldgPtr($v0)
      nop
      ; if null, we can build
      beq $a2,$zero,@@canBuild
      ; check if pom's pointer is actually to target building
      ; account for s1 actually being +0x10 from the building struct's
      ; start position
      addiu $a2,0x10
      
      ; if pom's target building not this building, allow construction
      bne $a2,$s1,@@canBuild
      nop
      
      ; build not allowed
      j 0x800F4BA4
      nop
      
   
  .endarea
  
  .org 0x800F4AB0
    j doBldgConstructionFix
    nop

  ;============================================================================
  ; REPLACEMENT + FREE SPACE:
  ; render current floor number on dungeon map
  ;============================================================================
  
  .org 0x8004657C
  .area 0x800467E0-.,0xFF
   
    ;=========================================
    ; render area name
    ;=========================================
    
    ; trick: go ahead and print the string, since we need to know
    ; its width in order to center it.
    ; this doesn't cost us any significant time, since the pre-printed content
    ; will be cached and immediately available when the "real" print occurs.
    ; a0 = string pointer
    jal printStdString
    move $a0,$s1
    
    ; a0 = string width
    lhu $a0,textBuf_width($v0)
    ; subtract from 256 (full box width)
    li $a1,256
    subu $a0,$a1,$a0
    ; divide by 2
    srl $a0,1
    
    ; a1 = dstbox struct
    la $a1,stdScaledStringDstbox
    ; v0 = bounding-x
    move $v0,$s6
    ; v1 = bounding-y
;    move $v1,$s7
    lw $v1,0x20($sp)
    sh $v0,0($a1)
    ; get result of centering operation above
    move $v0,$a0
    sh $v1,2($a1)
    ; v1 = offset-y
    li $v1,0x24
    sh $v0,4($a1)
    sh $v1,6($a1)
    
    ; save target render offset to s4
    lw $s4,0x0A2C($gp)
    
    ; a3 = clut index (dummy) + transparency setting
    li $a3,0
    ; a2 = scale factor
    move $a2,$s3
    ; a0 = string pointer
    move $a0,$s1
    jal renderStdScaledString
    nop
    
    ; set clut
    lhu $a0,0x801C058E
    nop
    sh $a0,0xE($s4)
    
    j 0x800467E0
    nop
   
    ;=========================================
    ; new stuff
    ;=========================================
   
    ;=========================================
    ; end-of-project space-wasting perfectionism:
    ; properly pluralize inventory messages
    ; referring to items with plural names
    ; (lunagic shoes and magic earrings).
    ; the normal composite descriptions are simply
    ; substituted for prebaked replacements.
    ;=========================================
    
    lunagicShoesId equ 0x4D
    magicEarringsId equ 0x8C
    
    doNewEquipMsg:
      ; s2 = item ID
      
      la.u $a0,earringsEquipMsg
      bne $s2,magicEarringsId,@@noMatch
      la.l $a0,earringsEquipMsg
      
      @@match:
;        jal printSjisString
        j 0x8003C04C
        sw $a0, 0x0AB4($gp)
      
      @@noMatch:
      ; make up work
      lui $s4, 0x8012
      j 0x8003AFD8
      addiu $s4, $s4, 0x38F4
    
    doNewUseMsg:
      ; s2 = item ID
      
      ; make up work
      jal printSjisString
      nop
      
      la.u $a0,shoesUseMsg
      beq $s2,lunagicShoesId,@@match
      la.l $a0,shoesUseMsg
      
      la.u $a0,earringsUseMsg
      bne $s2,magicEarringsId,@@noMatch
      la.l $a0,earringsUseMsg
      
      @@match:
        j 0x8003C04C
        sw $a0, 0x0AB4($gp)
      
      @@noMatch:
      j 0x8003B210
      nop
    
    doNewDropMsg:
      ; s2 = item ID
      
      ; make up work
      jal printSjisString
      ori $s0, $zero, 0x0002
    
      la.u $a0,shoesDropMsg
      beq $s2,lunagicShoesId,@@match
      la.l $a0,shoesDropMsg
      
      la.u $a0,earringsDropMsg
      bne $s2,magicEarringsId,@@noMatch
      la.l $a0,earringsDropMsg
      
      @@match:
        j 0x8003C04C
        sw $a0, 0x0AB4($gp)
      
      @@noMatch:
      j 0x8003B51C
      nop
    
    shoesUseMsg:
      .incbin "out/script/generic/new_0xB.bin"
    shoesDropMsg:
      .incbin "out/script/generic/new_0xC.bin"
    earringsEquipMsg:
      .incbin "out/script/generic/new_0xD.bin"
    earringsUseMsg:
      .incbin "out/script/generic/new_0xE.bin"
    earringsDropMsg:
      .incbin "out/script/generic/new_0xF.bin"
    .align 4
   
    ;=========================================
    ; fix softlock if summon animation is
    ; occurring when community attack ends
    ;=========================================
    
    fixCommunityAttackFreeze:
      ; turn off control lock
      sb $zero,0x8012C1E0
      
      ; make up work
      j 0x8001C1AC
      ori $a1, $zero, 0x0008
   
    ;=========================================
    ; "fix" bug that prevents farming under
    ; some circumstance.
    ; the root problem still occurs, but
    ; this prevents it from having any effect.
    ;=========================================
    
    doFarmingFix:
      ; v0 = pointer to pom registered with field
      ; v1 = pointer to farm level (preserve)
      ; s1 = pointer to this pom's state struct
      
      ; if zero, field is empty and we're done
      bne $v0,$zero,@@pomAlreadyInField
      nop
      @@success:
        ; start farming
        j 0x800F5DC0
        nop
      @@pomAlreadyInField:
      
      ; if nonzero, field *should* already have a pom working in it.
      ; however, some unknown bug may cause the field to have a pom registered
      ; but not vice versa, a state which permanently prevents any farming
      ; from occurring.
      ; we can prevent this by ensuring that the building pointer (pomState+0x6C)
      ; of the pom registered with the field:
      ; (1.) is not null
      ; (2.) actually points to the field (bldgState+0x0 == 0x00)
      
      lw $v0,compom_attachedBldgPtr($v0)
      nop
      ; if pom's building pointer is null, we can start farming
      beq $v0,$zero,@@success
      nop
      
      ; otherwise, check what building pom is actually attached to
      ; v0 = building type id
      lbu $v0,bldg_typeId($v0)
      nop
      ; if not field, we can start farming
      bne $v0,fieldTypeId,@@success
      nop
      
      @@fail:
      ; unable to start farming
      j 0x800F6954
      ori $v0, $zero, 0x0001
   
  .endarea
  
  .org 0x8003AFD0
    j doNewEquipMsg
    nop
  
  .org 0x8003B208
    j doNewUseMsg
    nop
  
  .org 0x8003B514
    j doNewDropMsg
    nop
  
  .org 0x8001C1A4
    j fixCommunityAttackFreeze
    ori $a0, $zero, 0x0003
  
  .org 0x800F5DB8
    j doFarmingFix
    nop

  ;============================================================================
  ; REPLACEMENT + FREE SPACE:
  ; renderAreaNameEntryOverlay
  ;============================================================================
  
  ; i expended a tremendous amount of effort here to make the letters fly in
  ; one at a time instead of just slicing up the text buffers into 12px chunks
  ; to meet the limitations of the original algorithm.
  ; hope you appreciate it!!
  
  .org 0x80036FB0
  .area 0x800378A4-.,0xFF
   
    renderAreaNameEntryOverlay_timerGp equ 0x7A4
    renderAreaNameEntryOverlay_timerStartValue equ 0x12C
    renderAreaNameEntryOverlay_firstSeenTimerValue equ renderAreaNameEntryOverlay_timerStartValue-1
    
    defaultAreaNameOverlayRenderPutIndex equ 16
    
    ;=========================================
    ; main function
    ;
    ; a0 = area id?
    ;=========================================
    
    renderAreaNameEntryOverlay_stackRegsSize        equ 8
    renderAreaNameEntryOverlay_stackStructsSize     equ 0
    renderAreaNameEntryOverlay_stackSize equ renderAreaNameEntryOverlay_stackRegsSize+renderAreaNameEntryOverlay_stackStructsSize
    
    renderAreaNameEntryOverlay:
      subiu $sp,renderAreaNameEntryOverlay_stackSize
      sw $ra,renderAreaNameEntryOverlay_stackStructsSize+0($sp)
      sw $s0,renderAreaNameEntryOverlay_stackStructsSize+4($sp)
;      sw $s1,renderAreaNameEntryOverlay_stackStructsSize+8($sp)
;      sw $s2,renderAreaNameEntryOverlay_stackStructsSize+12($sp)
;      sw $s3,renderAreaNameEntryOverlay_stackStructsSize+16($sp)
;      sw $s4,renderAreaNameEntryOverlay_stackStructsSize+20($sp)
;      sw $s5,renderAreaNameEntryOverlay_stackStructsSize+24($sp)
;      sw $s6,renderAreaNameEntryOverlay_stackStructsSize+28($sp)
;      sw $s7,renderAreaNameEntryOverlay_stackStructsSize+32($sp)
;      sw $fp,renderAreaNameEntryOverlay_stackStructsSize+36($sp)
      
        ; save area number as needed
        andi $a1,$a0,0xFF
        ; save low byte
        sw $a1,0x8012C3A4
        ; save full value
        sh $a0,0x18($sp)
      
        ;==========
        ; reset render put index to default
        ;==========
        
        li $v0,defaultAreaNameOverlayRenderPutIndex
        sb $v0,currentAreaNameOverlayRenderPutIndex
      
        ;==========
        ; line 1: get pointer to target string
        ;==========
        
        ; check if the pom community
        bne $a1,0x75,@@notPomCommunity
        la.u $a0,pomCommunityName_std
          j @@line1StrPtrPicked
          la.l $a0,pomCommunityName_std
        @@notPomCommunity:
          ; string = from pointer table at 0x801164E4
          sll $v0,$a1,2
          lui $at,0x8011
          addu $at,$v0
          lw $a0,0x64E4($at)
        @@line1StrPtrPicked:
        
;        lw $a0,0x8012C2B8
      
        ;==========
        ; line 1: init buffer if needed
        ;==========
        
;        lw $a0,renderAreaNameEntryOverlay_timerGp($gp)
        la.u $a1,areaNameOverlayBuffer1
        jal readyAreaNameOverlayBuffer
        la.l $a1,areaNameOverlayBuffer1
      
        ;==========
        ; line 1: print buffer
        ;==========
        
        la $a0,areaNameOverlayBuffer1
        jal displayAreaNameOverlayBuffer
        ; a1 = base y-pos
        li $a1,0x40
      
        ;==========
        ; line 2: check if exists
        ;==========
        
        lhu $v0,0x18($sp)
        nop
        srl $v1,$v0,8
        slti $v0,$v1,0xF0
        sw $v1,0x8012C3A4
        bne $v0,$zero,@@done
        andi $v0,$v1,0xF
        
        addiu $v0,0x64
        sll $v1,$v0,2
        lui $at,0x8011
        addu $at,$v1
        ; a0 = pointer to second line's string
        lw $a0,0x64E4($at)
      
        ;==========
        ; line 2: init buffer if needed
        ;==========
        
        la.u $a1,areaNameOverlayBuffer2
        jal readyAreaNameOverlayBuffer
        la.l $a1,areaNameOverlayBuffer2
      
        ;==========
        ; line 2: print buffer
        ;==========
        
        la $a0,areaNameOverlayBuffer2
        jal displayAreaNameOverlayBuffer
        ; a1 = base y-pos
        li $a1,0x58
      
      @@done:
      lw $ra,renderAreaNameEntryOverlay_stackStructsSize+0($sp)
      lw $s0,renderAreaNameEntryOverlay_stackStructsSize+4($sp)
;      lw $s1,renderAreaNameEntryOverlay_stackStructsSize+8($sp)
;      lw $s2,renderAreaNameEntryOverlay_stackStructsSize+12($sp)
;      lw $s3,renderAreaNameEntryOverlay_stackStructsSize+16($sp)
;      lw $s4,renderAreaNameEntryOverlay_stackStructsSize+20($sp)
;      lw $s5,renderAreaNameEntryOverlay_stackStructsSize+24($sp)
;      lw $s6,renderAreaNameEntryOverlay_stackStructsSize+28($sp)
;      lw $s7,renderAreaNameEntryOverlay_stackStructsSize+32($sp)
;      lw $fp,renderAreaNameEntryOverlay_stackStructsSize+36($sp)
      jr $ra
      addiu $sp,renderAreaNameEntryOverlay_stackSize
      
      currentAreaNameOverlayRenderPutIndex:
        .db 0
      .align 4
   
    ;=========================================
    ; name overlay buffers
    ;=========================================
    
      areaNameOverlayBuffer_keyOffset equ 0
      areaNameOverlayBuffer_srcStringPtrOffset equ 4
      areaNameOverlayBuffer_textBufPtrOffset equ 8
      areaNameOverlayBuffer_trueWidthOffset equ 12
      areaNameOverlayBuffer_contentOffset equ 16
    
      areaNameOverlayBuffer_terminator equ 0xFF
      
      ;==========
      ; buffer 1 (line 1 = main name)
      ;==========
    
      areaNameOverlayBuffer1MaxEntries equ 48
      
      areaNameOverlayBuffer1:
        ; 4-byte "key" -- this is used in place of
        ; the actual hash value in the textBuf.
        ; necessary because what we print is not actually the normal
        ; string content (we have to pad each character's start to an
        ; even pixel position), and the area name strings are shared.
        ; should something else want to print the area name at the same
        ; time as us, we could potentially get the wrong data if we
        ; didn't do this.
        ; 
        ; first byte is 0x7F to minimize the possibility
        ; of an actual hash summing to this value;
        ; the remainder is arbitrary (but needs to be unique
        ; from similar special IDs)
        .db 0x7F
        .ascii "AO1"
        
        ; current srcptr
        .dw 0x00000000
        
        ; current textBuf pointer
        .dw 0x00000000
        
        ; true width
        .dw 0x00000000
        
        ; entries
        ; - 1b srcx in buffer
        ; - 1b width of character
        .fill areaNameOverlayBuffer1MaxEntries*2,0xFF
      
      .align 4
      
      ;==========
      ; buffer 2 (line 2 = floor number, if applicable)
      ;==========
      
      areaNameOverlayBuffer2MaxEntries equ 16
      
      areaNameOverlayBuffer2:
        ; 4-byte "key"
        .db 0x7F
        .ascii "AO2"
        
        ; current srcptr
        .dw 0x00000000
        
        ; current textBuf pointer
        .dw 0x00000000
        
        ; true width
        .dw 0x00000000
        
        ; entries
        .fill areaNameOverlayBuffer2MaxEntries*2,0xFF
      
      .align 4
      
      ;==========
      ; additional resources
      ;==========
      
      ; padding string
      areaNameOverlay_paddingString:
      .string "[space1px]"
;        .db 0x00
      .align 4
      
    ;=========================================
    ; load an area name buffer (if not already loaded)
    ;
    ; a0 = string pointer
    ; a1 = target buffer
    ;=========================================
    
    readyAreaNameOverlayBuffer:
      subiu $sp,32
      sw $ra,0($sp)
      sw $s0,4($sp)
      sw $s1,8($sp)
      sw $s2,12($sp)
      sw $s3,16($sp)
      sw $s4,20($sp)
      sw $s5,24($sp)
      sw $s6,28($sp)
      
        ; s0 = string pointer
        move $s0,$a0
        ; s1 = target buffer
        move $s1,$a1
        
        ;==========
        ; cache check: if this string is already loaded
        ; and drawn, don't redraw it
        ;==========
        
        ; check if this is not the string currently in the areaNameBuf
        ; (meaning we have to redraw even if the textBuf itself is
        ; cached)
        lw $a0,areaNameOverlayBuffer_srcStringPtrOffset($s1)
        nop
        bne $a0,$s0,@@isNotCached
        nop
        
        ; try to find a textBuf corresponding to this content
        subiu $sp,8
        move $a1,$sp
          ; save string pointer
          sw $s0,0($a1)
          ; save target hash
          lw $v0,areaNameOverlayBuffer_keyOffset($s1)
          nop
;          jal textBufIsCached
          sw $v0,4($a1)
          
          la $a0,textBufIsCached
          jal findTextBufThatMatchesCondition
          addiu $a2,$zero,stdTextBufLimit
        addiu $sp,8
        
        ; if textBuf found, use it
        beq $v0,$zero,@@isNotCached
        nop
          ; flag as used
          lbu $a0,textBuf_flags($v0)
          nop
          ori $a0,textBufFlagMask_isUsed
          sb $a0,textBuf_flags($v0)
          
          ; save buffer pointer
          j @@done
          sw $v0,areaNameOverlayBuffer_textBufPtrOffset($s1)
        @@isNotCached:
        
        ;==========
        ; string not cached: render it.
        ; try to find an open buffer
        ;==========
        
        jal findUnusedTextBuffer
        nop
        ; if no buffer available, give up
        beq $v0,$zero,@@done
        sw $v0,areaNameOverlayBuffer_textBufPtrOffset($s1)
        
        ; s2 = target textBuf pointer
        move $s2,$v0
        
        ; s6 = true width (without even-alignment padding)
        move $s6,$zero
        
        ; save our sentinel value as the "hash"
;        move $a1,$s0
;        lw $a2,0($s1)
;        ; save srcptr to textBuf
;        sw $s0,textBuf_srcPtr($s2)
;        sw $a0,textBuf_srcHash($s2)
        
        ; prep buffer for use
        ; a0 = buffer
        ; a1 = srcptr
        ; a2 = hash
        lw $a2,0($s1)
        move $a0,$s2
        jal initTextBuf
        move $a1,$s0
        
        ; save new srcptr to areaNameBuf
        sw $s0,areaNameOverlayBuffer_srcStringPtrOffset($s1)
        
        ;==========
        ; render each character in the string,
        ; applying padding to ensure each one begins
        ; at an even pixel position,
        ; and recording each character's position+width
        ; to the areaNameBuf
        ;==========
        
        ; s3 = pointer to putpos for areaNameBuf
        addiu $s3,$s1,areaNameOverlayBuffer_contentOffset
        subiu $sp,printStateBuf_size
          
          ; s4 = printStateBuf
          move $s4,$sp
          
          ; init printStateBuf
          jal resetPrintStateBuf
          move $a0,$s4
          sw $s0,printStateBuf_srcPtr($s4)
          sw $zero,printStateBuf_retAddr($s4)
          sb $zero,printStateBuf_flags($s4)
          
          @@charRenderLoop:
            ; check for terminator
            lw $v0,printStateBuf_srcPtr($s4)
            nop
            lbu $v0,0($v0)
            nop
            beq $v0,$zero,@@charRenderLoopDone
            nop
            
            ; if current width is odd, print a 1px space
            ; (origin x-coords for 4bpp textures must be even)
            lhu $a0,textBuf_width($s2)
            nop
            andi $a0,1
            beq $a0,$zero,@@noPadNeeded
            nop
              ; current srcptr becomes retaddr,
              ; padding string becomes srcptr
              lw $a0,printStateBuf_srcPtr($s4)
              la $a1,areaNameOverlay_paddingString
              sw $a0,printStateBuf_retAddr($s4)
              ; set call flag
              lbu $a2,printStateBuf_flags($s4)
              sw $a1,printStateBuf_srcPtr($s4)
              ori $a2,printStateBufFlagMask_callActive
              sb $a2,printStateBuf_flags($s4)
              
              ; print padding
              move $a0,$s4
              jal handleNextTextAction
              move $a1,$s2
              
              ; we shouldn't need to loop here,
              ; but just in case...
              j @@charRenderLoop
              nop
            @@noPadNeeded:
            
            ; current width = character src x-pos
            lhu $s5,textBuf_width($s2)
            nop
            sb $s5,0($s3)
            
            ; print next character
            ; WARNING: assumes no breaking actions!
            @@renderSubLoop:
              ; check for terminator
;              lbu $v0,0($s0)              
              move $a0,$s4
;              beq $v0,$zero,@@charRenderLoopDone
              
              jal handleNextTextAction
              move $a1,$s2
            @@renderSubLoopDone:
            
            ; a0 = new width after latest print
            lhu $a0,textBuf_width($s2)
            nop
            ; subtract previous width to get width of new character
            subu $a0,$s5
            ; save
            sb $a0,1($s3)
            ; add width to true width counter
            addu $s6,$a0
            
            ; advance areaNameBuf putpos
            j @@charRenderLoop
            addiu $s3,2
            
          @@charRenderLoopDone:
          
          ; terminate areaNameBuf
          li $a0,areaNameOverlayBuffer_terminator
          sb $a0,0($s3)
          
          ; save true width
          sw $s6,areaNameOverlayBuffer_trueWidthOffset($s1)
        
        addiu $sp,printStateBuf_size
        
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
      addiu $sp,32
    
    ;=========================================
    ; write material to an index position
    ; in the textbox-reserved command area
    ;
    ; a0 = target index
    ; a1 = data struct:
    ;      +0 dstX
    ;      +4 dstY
    ;      +8 texpage
    ;      +12 srcX
    ;      +16 srcY
    ;      +20 w
    ;      +24 h
    ;      +28 clut
    ;      +32 command
    ; a2 = offset in display list to link to
    ;=========================================
    
    writeToOldTextboxRenderIndex_stackRegsSize        equ 24
    writeToOldTextboxRenderIndex_stackStructsSize     equ 0
    writeToOldTextboxRenderIndex_stackSize equ writeToOldTextboxRenderIndex_stackRegsSize+writeToOldTextboxRenderIndex_stackStructsSize
      
    writeToOldTextboxRenderIndex:
      subiu $sp,writeToOldTextboxRenderIndex_stackSize
      sw $ra,writeToOldTextboxRenderIndex_stackStructsSize+0($sp)
      sw $s0,writeToOldTextboxRenderIndex_stackStructsSize+4($sp)
      sw $s1,writeToOldTextboxRenderIndex_stackStructsSize+8($sp)
      sw $s2,writeToOldTextboxRenderIndex_stackStructsSize+12($sp)
      sw $s3,writeToOldTextboxRenderIndex_stackStructsSize+16($sp)
      sw $s4,writeToOldTextboxRenderIndex_stackStructsSize+20($sp)
      
        ; s0 = target index
        move $s0,$a0
        ; s1 = src struct
        move $s1,$a1
        ; s4 = target offset in display list
        move $s4,$a2
        
        ;==========
        ; compute dst pointers
        ;==========
        
        lw $v1,0x8012C2B8
        
        ; s2 = target for main
        ; add (index*20)
        sll $a0,$s0,2
        addu $a0,$s0
        sll $a0,2
        addu $s2,$v1,$a0
        ; add offset
        li $v0,0x9AD8
        addu $s2,$v0
        
        ; s3 = target for texpage
        ; add (index*12)
        sll $a0,$s0,1
        addu $a0,$s0
        sll $a0,2
        addu $s3,$v1,$a0
        ; add offset
        li $v0,0xD840
        addu $s3,$v0
        
        ;==========
        ; write main command
        ;==========
        
        ; size = 04 (link must be filled in by caller)
        li $a3,0x04
        sb $a3,3($s2)
        
        ; color+command = 64808080
        ; "Textured Rectangle, variable size, opaque, texture-blending"
        ; with all components set to 0x80 = even
;        li $a0,0x64808080
        lw $a0,32($s1)
        nop
        sw $a0,4($s2)
        
        ; vertex = YYYYXXXX
        ; a0 = x
        lw $a0,0($s1)
        ; a1 = y
        lw $a1,4($s1)
        sh $a0,8($s2)
        sh $a1,10($s2)
        
        ; texcoord+palette
        ; a0 = srcX
        lw $a0,12($s1)
        ; a1 = srcY
        lw $a1,16($s1)
        sb $a0,12($s2)
        sb $a1,13($s2)
        
        ; a0 = clut
        lw $a0,28($s1)
        ; a1 = w
        lw $a1,20($s1)
        ; a2 = h
        lw $a2,24($s1)
        sh $a0,14($s2)
        sh $a1,16($s2)
        sh $a2,18($s2)
        
        ;==========
        ; link in main command
        ;==========
        
;        lw $a0,0x8012C2B8
        lw $a0,0x8012C0B0
        nop
        addu $a0,$s4
        
        jal linkIntoDisplayList
        move $a1,$s2
        
        ;==========
        ; write texpage command
        ;==========
        
        ; size = 0x02
        ; link must be filled in by caller
        li $a0,0x02
        sb $a0,3($s3)
        
        ; texpage
        lw $a0,8($s1)
        li $a1,0xE100
        sh $a1,6($s3)
        sh $a0,4($s3)
        
        ; nop
        sw $zero,8($s3)
        
        ;==========
        ; link in texpage command
        ;==========
        
        lw $a0,0x8012C0B0
        nop
        addu $a0,$s4
        
        jal linkIntoDisplayList
        move $a1,$s3
      
      @@done:
      lw $ra,writeToOldTextboxRenderIndex_stackStructsSize+0($sp)
      lw $s0,writeToOldTextboxRenderIndex_stackStructsSize+4($sp)
      lw $s1,writeToOldTextboxRenderIndex_stackStructsSize+8($sp)
      lw $s2,writeToOldTextboxRenderIndex_stackStructsSize+12($sp)
      lw $s3,writeToOldTextboxRenderIndex_stackStructsSize+16($sp)
      lw $s4,writeToOldTextboxRenderIndex_stackStructsSize+20($sp)
      jr $ra
      addiu $sp,writeToOldTextboxRenderIndex_stackSize
      
    ;=========================================
    ; display an area name overlay
    ;
    ; a0 = buffer to show
    ; a1 = base y-pos of display
    ;=========================================
    
    displayAreaNameOverlayBuffer_stackRegsSize        equ 40
    displayAreaNameOverlayBuffer_stackStructsSize     equ 36
    displayAreaNameOverlayBuffer_stackRenderParamStruct     equ 0
    displayAreaNameOverlayBuffer_stackSize equ displayAreaNameOverlayBuffer_stackRegsSize+displayAreaNameOverlayBuffer_stackStructsSize
      
    displayAreaNameOverlayBuffer:
      subiu $sp,displayAreaNameOverlayBuffer_stackSize
      sw $ra,displayAreaNameOverlayBuffer_stackStructsSize+0($sp)
      sw $s0,displayAreaNameOverlayBuffer_stackStructsSize+4($sp)
      sw $s1,displayAreaNameOverlayBuffer_stackStructsSize+8($sp)
      sw $s2,displayAreaNameOverlayBuffer_stackStructsSize+12($sp)
      sw $s3,displayAreaNameOverlayBuffer_stackStructsSize+16($sp)
      sw $s4,displayAreaNameOverlayBuffer_stackStructsSize+20($sp)
      sw $s5,displayAreaNameOverlayBuffer_stackStructsSize+24($sp)
      sw $s6,displayAreaNameOverlayBuffer_stackStructsSize+28($sp)
      sw $s7,displayAreaNameOverlayBuffer_stackStructsSize+32($sp)
      sw $fp,displayAreaNameOverlayBuffer_stackStructsSize+36($sp)
      
        ; s0 = areaNameBuf
        move $s0,$a0
        ; s1 = base y-pos
        move $s1,$a1
        
        ; s2 = textBuf
        lw $s2,areaNameOverlayBuffer_textBufPtrOffset($s0)
        ; s3 = index in text box render memory to place commands
        ; (since we're using no more than 4 of these + change for
        ; the actual text box, we can use the disused portion for
        ; new things)
        lbu $s3,currentAreaNameOverlayRenderPutIndex
        ; ensure we have a textBuf to display
        beq $s2,$zero,@@done
        nop
        
        ; s4 = base x-pos,
        ;      initialized to position needed to center content
;        lhu $a0,textBuf_width($s2)
        ; a0 = true width of buffer content
        lw $a0,areaNameOverlayBuffer_trueWidthOffset($s0)
        li $s4,0x100
        subu $s4,$a0
        sra $s4,1
        
        ; s5 = angle modifier (incremented per character)
        li $s5,0
        
        ; s6 = srcpos in areaNameBuf
        addiu $s6,$s0,areaNameOverlayBuffer_contentOffset
        
        ; s7 = parity counter for current character
        li $s7,0
        
        ; fp = sine table pointer
        la $fp,0x80118308
        
        ;==========
        ; render content
        ;==========
        
        ; check for terminator in areaNameBuf content
        ; (in case of a null string)
        lbu $a0,0($s6)
        nop
        beq $a0,areaNameOverlayBuffer_terminator,@@renderLoopDone
        nop
        
        @@renderLoop:
        
          ;==========
          ; basic params
          ;==========
          
          ; a0 = next character's x-pos from src
          lbu $a0,0($s6)
          ; a1 = next character's width from src
          lbu $a1,1($s6)
          ; save
          sw $a0,12+displayAreaNameOverlayBuffer_stackRenderParamStruct($sp)
          sw $a1,20+displayAreaNameOverlayBuffer_stackRenderParamStruct($sp)
          
          ; set up srcY
          ; a0 = buffer's index
          lbu $a0,textBuf_indexNum($s2)
          li $a1,textBufGpuH
          sw $a1,24+displayAreaNameOverlayBuffer_stackRenderParamStruct($sp)
          mult $a0,$a1
          ; clut
          lhu $a2,0x801C058E
          mflo $a0
          sw $a0,16+displayAreaNameOverlayBuffer_stackRenderParamStruct($sp)
          sw $a2,28+displayAreaNameOverlayBuffer_stackRenderParamStruct($sp)
          
          ; base command (may get overwritten if transparency needed)
          li $a0,0x64808080
          sw $a0,32+displayAreaNameOverlayBuffer_stackRenderParamStruct($sp)
          
          ; base dstX
          sw $s4,0+displayAreaNameOverlayBuffer_stackRenderParamStruct($sp)
          ; base dstY
          sw $s1,4+displayAreaNameOverlayBuffer_stackRenderParamStruct($sp)
          
          ; FIXME: texpage
          li $a0,0x29
          sw $a0,8+displayAreaNameOverlayBuffer_stackRenderParamStruct($sp)
          
          ;==========
          ; decide on our state based on areaNameOverlayTimer
          ;==========
          
          ; a1 = parity multiplier
          andi $a1,$s7,1
          bne $a1,$zero,@@oddParity
          li $a1,1
            li $a1,-1
          @@oddParity:
          
          ; a0 = timer
          lhu $a0,areaNameOverlayTimer
          nop
          
          blt $a0,0xF0,@@notFlyingIn
          nop
            
            ;==========
            ; text is flying in
            ;==========
            
            ;==========
            ; compute target angle
            ;==========
            
            ; a2 = (0x12D - stateTimer)
            li $a2,0x12D
            subu $a2,$a0
            
            ; v0 = stateTimer * 32
            sll $v0,$a0,5
            ; add baseAngle
            addu $v0,$s5
            ; multiply by parity value to get angle
            mult $v0,$a1
            ; a1 = angle
            mflo $a1
            ; take only low byte (angles are computed in 256 degrees)
            andi $a1,0xFF
            
            ; lookup from sine table based on angle
            ; v0 = sine table pointer
            sll $a1,2
            addu $v0,$a1,$fp
            ; a0 = result = x-offset
            lw $a0,0($v0)
            
            ;==========
            ; okay, here's where my trig knowledge starts to fail me...
            ;==========
            
            ; a0 = divide computed sine by ((0x12D - stateTimer) << 8)
            sll $v0,$a2,8
            div $a0,$v0
            ; compiler would check for invalid division conditions here,
            ; but we are not a compiler
            mflo $a0
            
            ; now do a lookup from some other table...
            la $v1,0x80118708
            addu $v1,$a1
            lw $v1,0($v1)
            nop
            ; divide in the same manner
            div $v1,$v0
            ; v1 = result = y-offset
            mflo $v1
            
            ; write x and y offsets
            lw $v0,0+displayAreaNameOverlayBuffer_stackRenderParamStruct($sp)
            lw $a3,4+displayAreaNameOverlayBuffer_stackRenderParamStruct($sp)
            addu $v0,$a0
            addu $a3,$v1
            sw $v0,0+displayAreaNameOverlayBuffer_stackRenderParamStruct($sp)
            sw $a3,4+displayAreaNameOverlayBuffer_stackRenderParamStruct($sp)
            
            ; set color modifiers to (0x12D - stateTimer)?
            sb $a2,32+displayAreaNameOverlayBuffer_stackRenderParamStruct($sp)
            sb $a2,33+displayAreaNameOverlayBuffer_stackRenderParamStruct($sp)
            sb $a2,34+displayAreaNameOverlayBuffer_stackRenderParamStruct($sp)
            ; set command to enable semi-transparency
            li $v0,0x66
            sb $v0,35+displayAreaNameOverlayBuffer_stackRenderParamStruct($sp)
            
            j @@offsetCalculationsDone
            nop
          
          @@notFlyingIn:
          bge $a0,0x3C,@@notFlyingOut
          nop
            
            ;==========
            ; text is flying out
            ;==========
            
            ; (this is an exact copy-paste of the above but with
            ; the stateTimer not inverted, so the letters move
            ; in the opposite direction)
            
            ;==========
            ; compute target angle
            ;==========
            
            ; a2 = stateTimer
            move $a2,$a0
            
            ; v0 = stateTimer * 32
            sll $v0,$a0,5
            ; add baseAngle
            addu $v0,$s5
            ; multiply by parity value to get angle
            mult $v0,$a1
            ; a1 = angle
            mflo $a1
            ; take only low byte (angles are computed in 256 degrees)
            andi $a1,0xFF
            
            ; lookup from sine table based on angle
            ; v0 = sine table pointer
            sll $a1,2
            addu $v0,$a1,$fp
            ; a0 = result = x-offset
            lw $a0,0($v0)
            
            ;==========
            ; okay, here's where my trig knowledge starts to fail me...
            ;==========
            
            ; a0 = divide computed sine by (stateTimer << 8)
            sll $v0,$a2,8
            div $a0,$v0
            ; compiler would check for invalid division conditions here,
            ; but we are not a compiler
            mflo $a0
            
            ; now do a lookup from some other table...
            la $v1,0x80118708
            addu $v1,$a1
            lw $v1,0($v1)
            nop
            ; divide in the same manner
            div $v1,$v0
            ; v1 = result = y-offset
            mflo $v1
            
            ; write x and y offsets
            lw $v0,0+displayAreaNameOverlayBuffer_stackRenderParamStruct($sp)
            lw $a3,4+displayAreaNameOverlayBuffer_stackRenderParamStruct($sp)
            addu $v0,$a0
            addu $a3,$v1
            sw $v0,0+displayAreaNameOverlayBuffer_stackRenderParamStruct($sp)
            sw $a3,4+displayAreaNameOverlayBuffer_stackRenderParamStruct($sp)
            
            ; set color modifiers to (stateTimer)?
            sb $a2,32+displayAreaNameOverlayBuffer_stackRenderParamStruct($sp)
            sb $a2,33+displayAreaNameOverlayBuffer_stackRenderParamStruct($sp)
            sb $a2,34+displayAreaNameOverlayBuffer_stackRenderParamStruct($sp)
            ; set command to enable semi-transparency
            li $v0,0x66
            sb $v0,35+displayAreaNameOverlayBuffer_stackRenderParamStruct($sp)
            
            j @@offsetCalculationsDone
            nop
            
          @@notFlyingOut:
            
            ;==========
            ; text is standing still
            ;==========
            
            ; we don't actually have to do anything in this case
          
          ;==========
          ; render character
          ;==========
          
          @@offsetCalculationsDone:
          
          ; target index in display list
;          li $a2,0x478
          li $a2,0x0408
          ; src struct
          move $a1,$sp
          jal writeToOldTextboxRenderIndex
          ; target index in render memory
          move $a0,$s3
          
          ;==========
          ; finish loop
          ;==========
          
          ; advance dstX by character width
          lbu $a0,1($s6)
          ; advance to next putIndex
          addiu $s3,1
          addu $s4,$a0
          ; advance parity counter
          addiu $s7,1
          ; increase angle modifier
          addiu $s5,24
          
          ; check for terminator in areaNameBuf content
          lbu $a0,2($s6)
          nop
          bne $a0,areaNameOverlayBuffer_terminator,@@renderLoop
          ; move to next pos in areaNameBuf content
          addiu $s6,2
        
        ;      +0 dstX
        ;      +4 dstY
        ;      +8 texpage
        ;      +12 srcX
        ;      +16 srcY
        ;      +20 w
        ;      +24 h
        ;      +28 clut
        ;      +32 command
/*        li $v0,textClut
        sw $v0,28($sp)
        li $v0,textBufGpuH
        lbu $v1,textBuf_indexNum($s2)
        sw $v0,24($sp)
        mult $v1,$v0
        lhu $v0,textBuf_width($s2)
        mflo $v1
        sw $v0,20($sp)
        sw $v1,16($sp)
        ; srcX
        li $a3,0
        sw $a3,12($sp)
        ; texpage
        li $a2,0x29
        sw $a2,8($sp)
        ; dstY
        move $a1,$s1
        sw $a1,4($sp)
        ; dstX
        lhu $v0,textBuf_width($s2)
        li $v1,0x100
        subu $a0,$v1,$v0
        sra $a0,1
        sw $a0,0($sp)
        
        li $a0,0x64808080
        sw $a0,32+displayAreaNameOverlayBuffer_stackRenderParamStruct($sp)
        
        li $a2,0x478
        move $a1,$sp
        jal writeToOldTextboxRenderIndex
        li $a0,16 */
        
        ; OLD
        ; a0 = dstX
        ; a1 = dstY
        ; a2 = texpage
        ; a3 = srcX
        ; sp+0x10 = srcY
        ; sp+0x14 = w
        ; sp+0x18 = h
        ; sp+0x1C = clut
        
/*        li $v0,textClut
        sw $v0,0x1C($sp)
        li $v0,textBufGpuH
        lbu $v1,textBuf_indexNum($s2)
        sw $v0,0x18($sp)
        mult $v1,$v0
        lhu $v0,textBuf_width($s2)
        mflo $v1
        sw $v0,0x14($sp)
        sw $v1,0x10($sp)
        ; srcX
        li $a3,0
        ; texpage
        li $a2,0x29
        ; dstY
        move $a1,$s1
        ; dstX
        lhu $v0,textBuf_width($s2)
        li $v1,0x100
        subu $a0,$v1,$v0
        sra $a0,1
        
        jal genTextBoxRenderCmd
        nop */
        
        
        
        
        
        @@renderLoopDone:
        
        ;==========
        ; write updated render putindex
        ;==========
        
        sb $s3,currentAreaNameOverlayRenderPutIndex
      
      @@done:
      lw $ra,displayAreaNameOverlayBuffer_stackStructsSize+0($sp)
      lw $s0,displayAreaNameOverlayBuffer_stackStructsSize+4($sp)
      lw $s1,displayAreaNameOverlayBuffer_stackStructsSize+8($sp)
      lw $s2,displayAreaNameOverlayBuffer_stackStructsSize+12($sp)
      lw $s3,displayAreaNameOverlayBuffer_stackStructsSize+16($sp)
      lw $s4,displayAreaNameOverlayBuffer_stackStructsSize+20($sp)
      lw $s5,displayAreaNameOverlayBuffer_stackStructsSize+24($sp)
      lw $s6,displayAreaNameOverlayBuffer_stackStructsSize+28($sp)
      lw $s7,displayAreaNameOverlayBuffer_stackStructsSize+32($sp)
      lw $fp,displayAreaNameOverlayBuffer_stackStructsSize+36($sp)
      jr $ra
      addiu $sp,displayAreaNameOverlayBuffer_stackSize
    
    ;=========================================
    ; finds an unused text buffer.
    ; prefers buffers that were not used on
    ; the previous frame, but if none are
    ; available, they will be allocated.
    ; 
    ; returns v0 = pointer to buffer,
    ;              or NULL if fail
    ;=========================================
    
    findUnusedTextBuffer:
      addiu $sp,-8
      sw $ra,0($sp)
      sw $s0,4($sp)
;      sw $s1,8($sp)
;      sw $s2,12($sp)
      
        ; try to find a buffer with both flags clear,
        ; as something that wasn't used on this frame or the previous one
        ; is most likely not being redrawn and therefore can be uncached
        la $a0,textBufHasFlagsCleared
        li $a1,textBufFlagMask_isUsed|textBufFlagMask_wasUsedLastFrame
        jal findTextBufThatMatchesCondition
        addiu $a2,$zero,stdTextBufLimit
        
        ; success if not NULL
;        bne $v0,$zero,@@done
;        la $a0,textBufHasFlagsCleared
        bne $v0,$zero,@@destroyParentAndFinish
        la $a0,textBufHasFlagsCleared
        
        ; if there's nothing available that wasn't used last frame,
        ; take anything that hasn't been used yet on this frame
        li $a1,textBufFlagMask_isUsed
        jal findTextBufThatMatchesCondition
        addiu $a2,$zero,stdTextBufLimit
        
        ; if we still couldn't find anything, we're out of buffers:
        ; give up and return NULL
        beq $v0,$zero,@@done
        ; otherwise, destroy any parent of this buffer to ensure
        ; cache validity is maintained
        @@destroyParentAndFinish:
        move $s0,$v0
          
          ; destroy parent (if any) to ensure cache validity
          ; (we don't want to destroy a subline and then have
          ; its parent later reused, as the old buffer content
          ; will be overwritten)
          
          ; a0 = function pointer
          la $a0,destroyBufsWithSublineRef
          ; a1 = ID of referenced buffer
          lbu $a1,textBuf_indexNum($s0)
          jal callFuncOnTextBufs
          li $a2,stdTextBufLimit
          
          ; return result buffer
          move $v0,$s0
        @@notFound:
        
/*        beq $v0,$zero,@@notFound
        move $s0,$v0
          ; destroy parent (if any) to ensure cache validity
          ; (we don't want to destroy a subline and then have
          ; its parent later reused, as the old buffer content
          ; will be overwritten)
          
          ; a0 = function pointer
          la $a0,destroyBufsWithSublineRef
          ; a1 = ID of referenced buffer
          lbu $a1,textBuf_indexNum($s0)
          jal callFuncOnTextBufs
          li $a2,stdTextBufLimit
          
          ; return result buffer
          move $v0,$s0
        @@notFound: */
        
        ; success if not NULL
/*        bne $v0,$zero,@@done
        la $a0,textBufHasFlagsCleared
        
        li $a1,textBufFlagMask_isUsed
        jal findTextBufThatMatchesCondition
        addiu $a2,$zero,stdTextBufLimit*/
        
/*        la $a0,textBufIsPrimaryAndHasFlagsCleared
        
        ; if failure, try again, this time only checking
        ; isUsed (and only on primary buffers; if we were to
        ; overwrite a subline buffer in this way while leaving
        ; its parent buffer untouched, and the parent buffer
        ; then gets reused due to caching, the lines we used
        ; would be "corrupted")
        li $a1,textBufFlagMask_isUsed
        jal findTextBufThatMatchesCondition
        addiu $a2,$zero,stdTextBufLimit
        
        beq $v0,$zero,@@notFound
        move $s0,$v0
          ; flag all subline buffers as unused
          
          ; s1 = subline counter
          lbu $s1,textBuf_numSubLines($s0)
          ; s2 = pointer to subline array
          addiu $s2,$s0,textBuf_subLines
          
          @@sublineMarkLoop:
            ; get target index
            lbu $a0,0($s2)
      
            jal getTextBufByIndex
            ; decrement counter
            addiu $s1,-1
            
            lbu $a0,textBuf_flags($v0)
            li $a1,-1
            sw $a1,textBuf_srcPtr($v0)
            sw $a1,textBuf_srcHash($v0)
            andi $a0,~(textBufFlagMask_isUsed|textBufFlagMask_wasUsedLastFrame)
            sb $a0,textBuf_flags($v0)
            
            bge $s1,$zero,@@sublineMarkLoop
            ; increment array position
            addiu $s2,1
          move $v0,$s0
        @@notFound: */
        
        ; whether success or failure, return result
      @@done:
      lw $ra,0($sp)
      lw $s0,4($sp)
;      lw $s1,8($sp)
;      lw $s2,12($sp)
      jr $ra
      addiu $sp,8
    
    ;=========================================
    ; convert current character buffer to
    ; the specified color
    ;=========================================
    
    convertCharBufToAltColor:
      ; a1 = row loop counter
      li $a1,fontCharH
      
      @@rowLoop:
        ; a2 = col loop counter
        li $a2,fontPhysicalW/4
        
        @@colLoop:
          ; v0 = fetch next halfword
          lhu $v0,0($a0)
          ; decrement counter
          subiu $a2,1
          
          ; a3 = nybble loop counter
          li $a3,4
          ; v1 = nybble mask
          li $v1,0xF
          ; t1 = replace mask
          li $t1,altCharColorIndex
          @@nybbleLoop:
            subiu $a3,1
            
            ; t0 = value AND nybble mask
            and $t0,$v0,$v1
            beq $t0,$zero,@@noReplace
            nop
              ; if nonzero (not transparent)
              ; invert mask
              xori $v1,0xFFFF
              ; clear existing bits
              and $v0,$v1
              ; uninvert mask
              xori $v1,0xFFFF
              ; OR with replacement
              or $v0,$t1
            @@noReplace:
            
            ; shift nybble mask
            sll $v1,4
            ; loop while counter not zero
            bne $a3,$zero,@@nybbleLoop
            ; shift replacement mask
            sll $t1,4
          
          ; write result back 
          sh $v0,0($a0)
          
          ; loop while counter not zero
          bne $a2,$zero,@@colLoop
          ; advance to next halfword
          addiu $a0,2
        
        ; decrement counter
        subiu $a1,1
        bne $a1,$zero,@@rowLoop
        nop
      
      jr $ra
      nop
    
    ;=========================================
    ; prints from a src until terminator or
    ; newline reached.
    ; the terminator/newline is skipped
    ; before returning.
    ; 
    ; a0 = printStateBuf*
    ; a1 = textBuf*
    ; returns v0 = zero if terminator reached,
    ;              otherwise nonzero
    ;=========================================
    
    printStdLine:
      addiu $sp,-12
      sw $ra,0($sp)
      sw $s0,4($sp)
      sw $s1,8($sp)
      
        ; s0 = printStateBuf
        move $s0,$a0
        ; s1 = textBuf
        move $s1,$a1
        
        @@charPrintLoop:
          ; a1 = srcPtr
          lw $a1,textBuf_srcPtr($s0)
          li $a2,strOp_newline
          ; a0 = fetch from srcPtr
          lbu $a0,0($a1)
          nop
          
;          bne $a0,$zero,@@notTerminator
;          move $v0,$zero
;            j @@loopDone
;            nop
;          @@notTerminator:
          ; done if terminator (return zero)
          beq $a0,$zero,@@loopDone
          move $v0,$zero
          
          ; done if newline (return nonzero)
          beq $a0,$a2,@@loopDone
          li $v0,1
          
          ; handle next char/op
          move $a0,$s0
          jal handleNextTextAction
          move $a1,$s1
          
          ; HACK: abort if return value is 2
          beq $v0,2,@@done
          ; return zero (signalling end of input)
          move $v0,$zero
          
          j @@charPrintLoop
          nop
        
      @@loopDone:
      ; increment srcPtr
      addiu $a1,1
      ; save updated srcPtr
      sw $a1,textBuf_srcPtr($s0)
      
      @@done:
      lw $ra,0($sp)
      lw $s0,4($sp)
      lw $s1,8($sp)
      jr $ra
      addiu $sp,12
    
    ;=========================================
    ; HACK: draw game over menu options correctly
    ;=========================================
    
    gameOverMenuOptionsBaseX equ 40
    gameOverMenuOptionsBaseY equ 170
    
    doGameOverMenuFix:
      ; coming back to this project after like 4 months,
      ; it took me so many tries to remember which rendering routine
      ; i needed here...
/*      ; a0 = target string pointer
      move $a0,$v0
      
      ; a2 = target line num * 16
      sll $a2, $s0, 4
      ; add base Y position
      addiu $a2,gameOverMenuOptionsBaseY
      
      ; render string
      jal new_renderNameScreenString
      ; a1 = x
      li $a1,gameOverMenuOptionsBaseX */
      
/*      ; print the target string
      jal printStdString
      move $a0,$v0
      
      ; ensure printing was successful
      beq $v0,$zero,@@done
      ; a1 = x
      li $a1,gameOverMenuOptionsBaseX
      ; s4 = pointer to primary buffer
;      move $s4,$v0
      
        ; set up render cmd for primary buffer
        ; a0 = buffer index
        lbu $a0,textBuf_indexNum($v0)
        ; a3 = s4 = dst
;        lw $a3,0x0A2C($gp)
        lw $s4,0x0A2C($gp)
        ; a2 = target line num * 16
        sll $a2, $s0, 4
        move $a3,$s4
        jal genTextBufRectRenderCmd
        ; add base Y position
        addiu $a2,gameOverMenuOptionsBaseY
        
        ; link into display list
        lw $a0,displayListTablePtr
;        lw $a1,0x0A2C($gp)
        move $a1,$s4
        jal linkIntoDisplayList
        addiu $a0,0x408
        
        ; increment render dst ptr
;        lw $a0,0x0A2C($gp)
;        addiu $a0,0x14
        addiu $s4,0x14
        ; set up texpage command
        jal genTextTexpageRenderCmd
;        sw $a0,0x0A2C($gp)
        move $a0,$s4
        
        ; link into display list
        lw $a0,displayListTablePtr
;        lw $a1,0x0A2C($gp)
        move $a1,$s4
        jal linkIntoDisplayList
        addiu $a0,0x408
        
        ; increment render dst ptr
;        lw $a0,0x0A2C($gp)
;        addiu $a0,0xC
        addiu $s4,0xC
;        sw $a0,0x0A2C($gp)
        sw $s4,0x0A2C($gp) */
      
      subiu $sp,8
    
        ; a0 = string pointer
/*        move $a0,$v0
        ; a1 = bounding box specs
        move $a1,$sp
        
        ; x
        li $v0,gameOverMenuOptionsBaseX
        sh $v0,0($a1)
        
        ; y
        sll $v0, $s0, 4
        ; add base Y position
        addiu $v0,gameOverMenuOptionsBaseY
        sh $v0,2($a1)
        
        ; x/y offsets
        sh $zero,4($a1)
        sh $zero,6($a1)
        
        ; a3 = render cmd dst
        lw $a3,0x0A2C($gp)
        ; a2 = scale factor
        li $a2,0x100
        ; increment render dst
        addiu $v0,$a3,0x28
        jal renderScaledString
        sw $v0,0x0A2C($gp) */
    
        ; a0 = string pointer
        move $a0,$v0
        ; a1 = bounding box specs
        move $a1,$sp
        
        ; x
        li $v0,gameOverMenuOptionsBaseX
        sh $v0,0($a1)
        
        ; y
        sll $v0, $s0, 4
        ; add base Y position
        addiu $v0,gameOverMenuOptionsBaseY
        sh $v0,2($a1)
        
        ; x/y offsets
        sh $zero,4($a1)
        sh $zero,6($a1)
        
        ; a3 = packed params:
        ;      - byte 0-1 (lowest) = transparency setting
        ;      - byte 2-3 = clut index (into table at 0x801C0590)
        li $a3,0x00000000
        jal renderStdScaledString
        ; a2 = scale factor
        li $a2,0x100
      
      @@done:
      j 0x8004929C
      addiu $sp,8
    
/*    jal printMenuBoxQueue
      nop
      
      jal renderMenuBoxQueue
      nop
      
      ; make up work
      lw $a0, 0x0A40($gp)
      jal setRectRenderCmdTransparency
      addu $a1, $zero, $zero
      
      j 0x800492C0
      nop */
      
    ;=========================================
    ; HACK: print "GAME OVER" for game over screen
    ;=========================================
    
    gameOverStringRenderedY:
      .dw 0
    
    doGameOverMenuFix2:
      ; print new "GAME OVER" string
      la $a0,gameOverStr
      jal printStdString
      ; make up work
      addu $s4, $zero, $zero
      
      ; save result buffer's y-pos for future rendering
      ; a0 = buffer gpu Y
      lbu $a0,textBuf_indexNum($v0)
      ; v1 = raw height
      li $v1,textBufGpuH
      mult $a0,$v1
      mflo $a0
      
      sw $a0,gameOverStringRenderedY
      j 0x80048FF0
      nop
      
    ;=========================================
    ; HACK: we are desperate to save a text buffer
    ; on the naming confirmation prompt.
    ; to facilitate this, we concatenate the text
    ; that is added to the end of the name when it
    ; is being confirmed directly onto it before
    ; printing instead of sending it to a
    ; separate buffer.
    ;=========================================
    
/*    doNamingStringSpecialConfirmDisplay:
      ; a0 = name string pointer
      ; a1 = dst x
      
;      subiu $sp,doNamingStringSpecialConfirmDisplay_bufferSize
  
      ; s0 = buffer target
      ; (can't use stack because it breaks caching)
;      move $s0,$sp
      la $s0,doNamingStringSpecialConfirmDisplay_buffer
      ; s1 = name pointer
      move $s1,$a0
        
      ; copy name to buffer
      ; dst
      move $a0,$s0
      jal systemStrCpy
      ; src
      move $a1,$s1
      
      ; get length of name
      jal systemStrLen
      move $a0,$s1
      
      ; do nothing different if not on confirmation prompt
      lbu $v1, 0x04BC($gp)
      ; update buffer dstptr
      addu $s0,$v0
      beq $v1, $zero, @@underscoreCheck
      nop
        
        ; copy extra content for confirmation prompt
        ; src
        la $a1,doNamingStringSpecialConfirmDisplay_srcString
        jal systemStrCpy
        ; dst
        move $a0,$s0
        
        ; add terminator
;        sb $zero,filesize("out/script/generic/new_0x8.bin")($s0)
        
        ; a0 = string pointer src
;        move $a0,$sp
        ; reload x
        j @@done
        nop
      
      @@underscoreCheck:
        
        ; if name not full, append underscore
        lh $v1, 0x04B4($gp)
        lh $v0, 0x04B8($gp)
        sll $v1, $v1, 1
        
        beq $v0,$v1,@@noUnderscore
        ; copy extra content for underscore
        ; src
        la $a1,doNamingStringSpecialConfirmDisplay_underscoreString
          jal systemStrCpy
          ; dst
          move $a0,$s0
        @@noUnderscore:
      
      @@done:
      
      ; render
      la $a0,doNamingStringSpecialConfirmDisplay_buffer
      ori $a1, $zero, 0x0038
      jal new_renderNameScreenString
      ori $a2, $zero, 0x0048
      
      j 0x800DEA0C
;      addiu $sp,doNamingStringSpecialConfirmDisplay_bufferSize
      nop */
    
    ;=========================================
    ; destroy buffer if it has the specified
    ; ID in its subline array
    ; 
    ; a0 = textBuf*
    ; a1 = buffer ID
    ;=========================================
    
    destroyBufsWithSublineRef:
      ; a2 = count of sublines
      lbu $a2,textBuf_numSubLines($a0)
      ; a3 = subline pointer
      addiu $a3,$a0,textBuf_subLines
      
      ; do nothing if no sublines
      beq $a2,$zero,@@done
      nop
      @@checkLoop:
        ; v0 = next subline ID
        lbu $v0,0($a3)
        ; --counter
        addiu $a2,-1
        
        ; check if same as target ID
        bne $v0,$a1,@@noMatch
        li $v1,-1
          ; destroy buffer
          sb $v1,textBuf_srcPtr($a0)
          j @@done
          ; clear subline count
          sb $zero,textBuf_numSubLines($a0)
        @@noMatch:
        
        bne $a2,$zero,@@checkLoop
        ; ++src
        addiu $a3,1
      @@done:
      jr $ra
      nop
    
    ;=========================================
    ; addendum to handleNextTextAction's
    ; handler for strOp_tradingCardPlural:
    ; print an "s" if a specified byte in
    ; memory is not equal to 1.
    ; this has two intended uses:
    ; - tonerko telling you how many cards
    ;   you have at his shop
    ; - cruela telling you how many days
    ;   you have left on the strawberry
    ;   sidequest
    ; are you happy yet, zenki?? >:(
    ;=========================================
    
    doTradingCardPluralAppend:
      ; skip call if player has exactly one trading card
;      lbu $a2,0x801F575C
      
      ; read target address (big-endian)
      lbu $a2,0($s2)
      lbu $v1,1($s2)
      sll $a2,24
      lbu $v0,2($s2)
      sll $v1,16
      or $a2,$v1
      sll $v0,8
      lbu $v1,3($s2)
      or $a2,$v0
      or $a2,$v1
      
      ; load target byte
      lbu $a2,0($a2)
      
      ; advance srcptr past address value
      addiu $s2,strOp_tradingCardPlural_paramsSize
      ; start script call if target byte is not 1
      ori $a1,printStateBufFlagMask_callActive
      beq $a2,1,@@onlyOneCard
      sw $s2,printStateBuf_srcPtr($s0)
      
        sb $a1,printStateBuf_flags($s0)
        
        ; set retaddr to srcptr
        sw $s2,printStateBuf_retAddr($s0)
        ; set srcptr to plural pointer
        li $s2,tradingCardPluralSuffixStr
        sw $s2,printStateBuf_srcPtr($s0)
      
      ; non-breaking
      @@onlyOneCard:
      j handleNextTextAction__handled
      move $v0,$zero
      
  .endarea

  ;============================================================================
  ; REPLACEMENT + FREE SPACE:
  ; renderFixedCharPom
  ;============================================================================
  
  .org 0x8003C274
  .area 0x8003C3F4-.,0xFF
  
    ;=========================================
    ; dummy original function
    ;=========================================
    
    jr $ra
    nop
  
    ;=========================================
    ; force the current name on the naming screen
    ; to conform to pixel width limitations
    ; (assuming this is run every time a new
    ; character is added)
    ;
    ; a0 = index of item being named
    ;      0-0xF = poms;
    ;      0x10 = lulu
    ;      0x11 = pom community
    ;=========================================
    
;  nameEntry_luluPomMaxW equ 100
;  nameEntry_communityMaxW equ 160
    
    ensureNamingScreenNameFitsWidth:
      subiu $sp,8
      sw $ra,0($sp)
      sw $s0,4($sp)
      
        ; s0 = index of target item
        move $s0,$a0
        
        ;==========
        ; get current name width
        ;==========
        
        la.u $a0,0x8012C624
        jal computeStringWidth
        la.l $a0,0x8012C624
        
        ;==========
        ; compare to maximum allowable width for target
        ;==========
        
        bne $s0,0x11,@@notPomCommunity
        li $a0,nameEntry_luluMaxW
          ; if pom community
          j @@widthLimitDetermined
          li $a0,nameEntry_communityMaxW
        @@notPomCommunity:
        ; if lulu
        beq $s0,0x10,@@widthLimitDetermined
        nop
        ; if a pom
        li $a0,nameEntry_pomMaxW
        @@widthLimitDetermined:
        
        ; no action necessary if current width <= limit
        ble $v0,$a0,@@done
        nop
        
        ;==========
        ; remove last character from name
        ;==========
        
        ; a1 = character count
        lh $a1,0x04B8($gp)
        ; a2 = name pointer
        la $a2,0x8012C624
        ; decrement character count
        subiu $a1,1
        ; write terminator to that position in name
        addu $a2,$a1
        sb $zero,0($a2)
        ; save updated character count
        sh $a1,0x04B8($gp)
        
      @@done:
      lw $ra,0($sp)
      lw $s0,4($sp)
      jr $ra
      addiu $sp,8
    
    ;=========================================
    ; right-shifts a 4bpp char buffer one pixel
    ; 
    ; a0 = charBuf*
    ;=========================================
    
    rightShiftCharBuf1px:
      ; a1 = row loop counter
      li $a1,fontCharH
      
      @@rowLoop:
        ; a2 = col loop counter
        li $a2,fontPhysicalW/4
        ; a3 = last low nybble
        move $a3,$zero
        
        @@colLoop:
          ; v0 = fetch next halfword
          lhu $v0,0($a0)
          ; decrement counter
          subiu $a2,1
          
          ; v1 = high nybble (rightmost pixel)
          andi $v1,$v0,0xF000
          ; shift into low position
          srl $v1,12
          
          ; shift current halfword left
          sll $v0,4
          ; OR with last low nybble
          or $v0,$a3
          ; write result back 
          sh $v0,0($a0)
          
          ; last low nybble = new
          move $a3,$v1
          
          ; loop while counter not zero
          bne $a2,$zero,@@colLoop
          ; advance to next halfword
          addiu $a0,2
        
        ; decrement counter
        subiu $a1,1
        bne $a1,$zero,@@rowLoop
        nop
      
      jr $ra
      nop
    
    ;=========================================
    ; right-shifts a 4bpp char buffer by N pixels
    ; (N should not exceed 4)
    ; 
    ; a0 = charBuf*
    ; a1 = shift count
    ;=========================================
    
    rightShiftCharBuf:
      addiu $sp,-12
      sw $ra,0($sp)
      sw $s0,4($sp)
      sw $s1,8($sp)
        
        ; do nothing if count is zero
        beq $a1,$zero,@@done
        ; s0 = charBuf
        move $s0,$a0
        
        ; s1 = counter
        move $s1,$a1
        
        @@loop:
          jal rightShiftCharBuf1px
          ; decrement counter
          subiu $s1,1
          
          bne $s1,$zero,@@loop
          move $a0,$s0
      
      @@done:
      lw $ra,0($sp)
      lw $s0,4($sp)
      lw $s1,8($sp)
      jr $ra
      addiu $sp,12
    
    ;=========================================
    ; HACK: disable text box centering after
    ; confirming a button prompt
    ;=========================================
    
    afterButtonPromptConfirmed:
      ; make up work
      sb $r0,textBox_centeringOn
      li $v1,1
      sw $v1,buttonPromptJustConfirmed
      j 0x800FFE38
      nop
    
    buttonPromptJustConfirmed:
      .dw 0
    .align 4
    
    ;=========================================
    ; HACK: disable text box centering after
    ; closing the text box
    ;=========================================
    
    afterTextBoxClosed:
      ; ensure button prompt confirmed flag is shut off
      ; (in case a prompt is not followed by text;
      ; this isn't that important, and at worst should only result
      ; in a 1-frame window at the start of the next piece of text
      ; where the original game would allow confirmation but
      ; the translation wouldn't, but let's try to make our
      ; hacks well-behaved)
      sw $zero,buttonPromptJustConfirmed
      
      ; make up work
      sb $r0,textBox_centeringOn
      j 0x800FF750
      nop
    
    ;=========================================
    ; display alt strings if confirming name
    ; on name entry screen
    ;=========================================
    
    doNameEntryPromptMsgCheck:
      ; v0 = name type index * 4
      ;      0 = community
      ;      4 = lulu
      ;      8 = pom
      ; a0 = original string pointer
      ; a1 = x
      ; a2 = y
      
      ; check if confirming entry
      lbu $v1, 0x04BC($gp)
      la $a3,nameConfirmStringTable
      beq $v1,$zero,@@notConfirmingName
      addu $a3,$v0
        ; get new string pointer
        lw $a0,0($a3)
        ; offset y-position
        addiu $a2,0x10
      @@notConfirmingName:
      
      ; make up work
      jal new_renderNameScreenString
      nop
      j 0x800DE940
      nop
    
    nameConfirmStringTable:
      .dw nameConfirmStringCommunity
      .dw nameConfirmStringLulu
      .dw nameConfirmStringPom
    
  .endarea

  ;============================================================================
  ; MODIFICATION:
  ; disable text box centering after confirming a button prompt.
  ; this is basically a hack to allow the meymey sell prompt to be centered
  ;============================================================================
  
    .org 0x800FFD94
      j afterButtonPromptConfirmed
      nop

  ;============================================================================
  ; MODIFICATION:
  ; disable text box centering after closing the text box
  ;============================================================================
  
    .org 0x800FEC98
      j afterTextBoxClosed

  ;============================================================================
  ; MODIFICATION:
  ; draw pom name on pom community status screen
  ;============================================================================
  
  ; these are the standard coordinate offsets from what the game considers
  ; to be the upper-left corner of the infobox (which is actually larger
  ; than the box graphic itself) to the upper-left corner of where the
  ; pom name goes.
  ; irritatingly, however, these are not consistent between different
  ; versions of the boxes (e.g. they do not apply to the box shown when
  ; chatting to a pom in the community, despite appearing almost identical)
  pomFixedStrBaseX equ 0x18-10
  pomFixedStrBaseY equ 0x11
  
  .org 0x80043E50
  .area 0x80043EBC-.,0xFF
    
    subiu $sp,8
      ; a0 = string pointer
      lw $a0,0x0AB4($gp)
      
      ; a1 = dstbox struct
      ;      +0 = bounding box X
      ;      +2 = bounding box Y
      ;      +4 = unscaled dst x-offset of string from bounding box X
      ;      +6 = unscaled dst y-offset of string from bounding box Y
      move $a1,$sp
      lw $t0, 0x0020+8($sp)
      lw $v0, 0x0028+8($sp)
      ; bounding box x
;      addiu $t0,0x10
      sh $t0,0($a1)
      ; bounding box y
;      subiu $v0,8
      sh $v0,2($a1)
      ; x-offset
      li $v0,pomFixedStrBaseX+16-4
      sh $v0,4($a1)
      ; y-offset
      li $v0,pomFixedStrBaseY-8
      sh $v0,6($a1)
      
      ; a2 = scale factor (see renderScaledString)
      li $a2,0x100
      
      ; a3 = packed params:
      ;      - byte 0-1 (lowest) = transparency setting
      ;      - byte 2-3 = clut index (into table at 0x801C0590)
      li $a3,0x00010000
      
      jal renderStdScaledString
      nop
      
    j 0x80043EBC  
    addiu $sp,8
    
  .endarea

  ;============================================================================
  ; MODIFICATION:
  ; draw pom name on party status screen
  ;============================================================================
  
  .org 0x80044F50
  .area 0x80044FA8-.,0xFF
    
    subiu $sp,8
      ; a0 = string pointer
      lw $a0,0x0AB4($gp)
      
      ; a1 = dstbox struct
      ;      +0 = bounding box X
      ;      +2 = bounding box Y
      ;      +4 = unscaled dst x-offset of string from bounding box X
      ;      +6 = unscaled dst y-offset of string from bounding box Y
      move $a1,$sp
      ; bounding box x
      sh $a3,0($a1)
      ; bounding box y
      sh $s0,2($a1)
      ; x-offset
      li $v0,pomFixedStrBaseX-4
      sh $v0,4($a1)
      ; y-offset
      li $v0,pomFixedStrBaseY
      sh $v0,6($a1)
      
      ; a2 = scale factor
      move $a2,$s7
      
      ; a3 = packed params:
      ;      - byte 0-1 (lowest) = transparency setting
      ;      - byte 2-3 = clut index (into table at 0x801C0590)
      li $a3,0x00010000
      
      jal renderStdScaledString
      nop
    
    j 0x80044FA8
    addiu $sp,8
    
  .endarea

  ;============================================================================
  ; MODIFICATION:
  ; draw building name on building status screen
  ;============================================================================
  
  .org 0x80048844
  .area 0x800488A4-.,0xFF
    
    subiu $sp,8
      ; a0 = string pointer
      lw $a0,0x0AB4($gp)
      
      ; a1 = dstbox struct
      ;      +0 = bounding box X
      ;      +2 = bounding box Y
      ;      +4 = unscaled dst x-offset of string from bounding box X
      ;      +6 = unscaled dst y-offset of string from bounding box Y
      move $a1,$sp
      ; bounding box x
      lw $t1, 0x00A0+8($sp)
      nop
      addu $a3, $t1, $s1
      sh $a3,0($a1)
      ; bounding box y
      sh $s0,2($a1)
      ; x-offset
      li $v0,pomFixedStrBaseX-6
      sh $v0,4($a1)
      ; y-offset
      li $v0,pomFixedStrBaseY
      sh $v0,6($a1)
      
      ; a2 = scale factor
      move $a2,$fp
      
      ; a3 = packed params:
      ;      - byte 0-1 (lowest) = transparency setting
      ;      - byte 2-3 = clut index (into table at 0x801C0590)
      li $a3,0x00010000
      
      jal renderStdScaledString
      nop
    
    j 0x800488A4
    addiu $sp,8
    
  .endarea

  ;============================================================================
  ; MODIFICATION + FREE SPACE:
  ; draw pom community name on community summary screen
  ;============================================================================
  
  .org 0x8004746C
  .area 0x80047580-.,0xFF
    
    subiu $sp,8
      ; get string width for centering
      jal computeStringWidth
      ; a0 = string pointer
      move $a0,$s0
      
      ; a0 = string pointer
      move $a0,$s0
      
      ; a1 = dstbox struct
      ;      +0 = bounding box X
      ;      +2 = bounding box Y
      ;      +4 = unscaled dst x-offset of string from bounding box X
      ;      +6 = unscaled dst y-offset of string from bounding box Y
      move $a1,$sp
      ; bounding box x
      sh $s6,0($a1)
      ; bounding box y
      sh $s1,2($a1)
      ; x-offset
;      li $v0,pomFixedStrBaseX-6
      ; compute x-offset for centering:
      ; (maxWidth - actualWidth) / 2
      li $v1,nameEntry_communityMaxW
      subu $v0,$v1,$v0
      srl $v0,1
      ; add base x
      addiu $v0,pomFixedStrBaseX-6
      sh $v0,4($a1)
      ; y-offset
      li $v0,pomFixedStrBaseY-8
      sh $v0,6($a1)
      
      ; a2 = scale factor
      move $a2,$fp
      
      ; a3 = packed params:
      ;      - byte 0-1 (lowest) = transparency setting
      ;      - byte 2-3 = clut index (into table at 0x801C0590)
      lw $t2,0x0280+8($sp)
      li $a3,0x00010000
      or $a3,$t2
      
      jal renderStdScaledString
      nop
    
    lui $a1,0x4A4D
    j 0x80047580
    addiu $sp,8
  
    ;=========================================
    ; draw new community rank strings
    ;=========================================
  
    doNewCommunityRankDraw:
      ; at this point, v0 = target rank index (0-2)
      
      ; make up work
      lw $t2, 0x0278($sp)
      
      ; a0 = string pointer
      sll $v0,2
      lui $at,(pomCommunityRankTable>>16)&0xFFFF
      addu $at,$v0
      lw $a0,pomCommunityRankTable&0xFFFF($at)
      
      ; make up work
      move $s1,$t2
      
      subiu $sp,8
        ; a1 = dstbox struct
        ;      +0 = bounding box X
        ;      +2 = bounding box Y
        ;      +4 = unscaled dst x-offset of string from bounding box X
        ;      +6 = unscaled dst y-offset of string from bounding box Y
        move $a1,$sp
        ; bounding box x
        sh $s6,0($a1)
        ; bounding box y
        sh $s1,2($a1)
        ; x-offset
        li $v0,pomFixedStrBaseX-6+183
        sh $v0,4($a1)
        ; y-offset
        li $v0,pomFixedStrBaseY-8
        sh $v0,6($a1)
        
        ; a2 = scale factor
        move $a2,$fp
        
        ; a3 = packed params:
        ;      - byte 0-1 (lowest) = transparency setting
        ;      - byte 2-3 = clut index (into table at 0x801C0590)
        lw $t2,0x0280+8($sp)
        li $a3,0x00010000
        or $a3,$t2
        
        jal renderStdScaledString
        nop
      
      j 0x8004744C
      addiu $sp,8
  
    ;=========================================
    ; resources for new community rank strings
    ;=========================================
    
    pomCommunityRankTable:
      .dw pomCommunityRank0String
      .dw pomCommunityRank1String
      .dw pomCommunityRank2String
    
    pomCommunityRank0String:
      .incbin "out/script/generic/new_0x0.bin"
    pomCommunityRank1String:
      .incbin "out/script/generic/new_0x1.bin"
    pomCommunityRank2String:
      .incbin "out/script/generic/new_0x2.bin"
    
    tradingCardPluralSuffixStr:
      .incbin "out/script/generic/new_0x3.bin"
    
    gameOverStr:
      .incbin "out/script/generic/new_0x4.bin"
      
    nameConfirmStringCommunity:
      .incbin "out/script/generic/new_0x5.bin"
    nameConfirmStringLulu:
      .incbin "out/script/generic/new_0x6.bin"
    nameConfirmStringPom:
      .incbin "out/script/generic/new_0x7.bin"
    
    .align 4
    
  .endarea

  ;============================================================================
  ; MODIFICATION:
  ; shift "rank" icon on community summary screen to fit more text
  ;============================================================================
  
    .org 0x800107D2
      ; x
      .dh 0x00B0-9
      ; y
      .dh 0x0008

  ;============================================================================
  ; MODIFICATION:
  ; shift "level" label on community building summary screen to fit more text
  ;============================================================================
  
    pomCommunityBuildingLevelLabelXOffset equ 8
  
    .org 0x80010944+10
      ; x
      .dh 0x00A0+pomCommunityBuildingLevelLabelXOffset
      ; y
      .dh 0x0008
    
    .org 0x800488C8
      ori $a3, $zero, 0x00B8+pomCommunityBuildingLevelLabelXOffset

  ;============================================================================
  ; MODIFICATION:
  ; shift hat icon on pom community chat status display to fit more text
  ;============================================================================
    
    .org 0x80043D64
      ; x-left
;      addiu $v1, $t0, 0x0008+pomStatusHatXOffset
      addiu $v1, $t0, pomStatusHatXBase
    
    .org 0x80043D90
      ; x-right
;      addiu $a0, $t0, 0x0020+pomStatusHatXOffset
      addiu $a0, $t0, pomStatusHatXEnd

  ;============================================================================
  ; MODIFICATION:
  ; shift hat icon on pom party status display to fit more text
  ;============================================================================
    
    .org 0x80044E3C
      j prepPomPartyHatXBase
      nop
    
    .org 0x80044E4C
      j prepPomPartyHatXEnd
      nop

  ;============================================================================
  ; MODIFICATION:
  ; draw new rank strings on community status screen
  ; (the original game draws one of three hardcoded characters from the font)
  ;============================================================================
  
  .org 0x800473F8
  .area 0x8004744C-.,0xFF
  
    j doNewCommunityRankDraw
    nop
    
  .endarea

  ;============================================================================
  ; MODIFICATION:
  ; nudge the "more text" indicator for the dialogue box downward
  ; so it doesn't collide with the new fourth row of text
  ;============================================================================
  
  .org 0x80100178
    ; y-position of indicator
    ori $a1, $zero, 0x00CE+2

  ;============================================================================
  ; MODIFICATION:
  ; properly draw game over menu
  ;============================================================================
  
    ;=========================================
    ; properly print and render option strings
    ;=========================================
  
    .org 0x80049294
      j doGameOverMenuFix
      addiu $s2, $s2, 0x0004
    
  ;  .org 0x800492B4
  ;    j doGameOverMenuFix2
  ;    nop
  
    ;=========================================
    ; print "GAME OVER" for future use
    ;=========================================

    .org 0x80048FE8
      j doGameOverMenuFix2
      addu $s3, $zero, $zero
  
    ;=========================================
    ; render "GAME OVER"
    ; (FREE SPACE)
    ;=========================================
    
    .org 0x8004900C
    .area 0x800490AC-.,0xFF
      
      ; a0 = render dst base
      lw $a0, 0x0A2C($gp)
      ; a2 = gpu src y-pos of previously printed target string
      lw $a2,gameOverStringRenderedY
      ; a1 = gpu src x-pos, computed from char index in $s1
      li $a1,fontCharW
      mult $a1,$s1
      mflo $a1
      
      ; left-x
      sb $a1,0xC($a0)
      sb $a1,0x1C($a0)
      
      ; top-y
      sb $a2,0xD($a0)
      sb $a2,0x15($a0)
      
      ; right-x
      addiu $a1,fontCharW
      sb $a1,0x14($a0)
      sb $a1,0x24($a0)
      
      ; bottom-y
      addiu $a2,textBufGpuH-1
      sb $a2,0x1D($a0)
      sb $a2,0x25($a0)
      
      ; resume normal logic
      j 0x800490AC
      nop
  
    ;=========================================
    ; fix golden scarab display (end)
    ;=========================================
  
    doGoldenScarabEndFix:
      ; make up work
      jal printSjisString
      nop
      
      ;==========
      ; evaluate menu box queue to see if printing needed
      ;==========
      
      jal isMenuBoxDisplayStringPtrQueueChanged
      nop
      
      beq $v0,$zero,@@noPrintNeeded
      nop
      
        ;==========
        ; print menu box queue
        ;==========
        
        jal printMenuBoxQueue
        nop
        
      @@noPrintNeeded:
      
      ;==========
      ; render menu box queue
      ;==========
      
      jal renderMenuBoxQueue
      nop
      
      j 0x8003EA78
      nop
      
    .endarea

  ;============================================================================
  ; MODIFICATION:
  ; special handling for name display when on name confirmation prompt
  ;============================================================================
  
;    .org 0x800DEA04
;      j doNamingStringSpecialConfirmDisplay
;      nop
      
    ;=========================================
    ; HACK: we are desperate to save a text buffer
    ; on the naming confirmation prompt.
    ; to facilitate this, we concatenate the text
    ; that is added to the end of the name when it
    ; is being confirmed directly onto it before
    ; printing instead of sending it to a
    ; separate buffer.
    ;=========================================
    
    .org 0x800DE940
    .area 0x800DEA0C-.,0xFF
      doNamingStringSpecialConfirmDisplay:
        ; s0 = buffer target
        la $s0,doNamingStringSpecialConfirmDisplay_buffer
        ; s1 = name pointer
        la $s1,nameScreenNameEntryBuffer
          
        ; copy name to buffer
        ; dst
        move $a0,$s0
        jal systemStrCpy
        ; src
        move $a1,$s1
        
        ; get length of name
        jal systemStrLen
        move $a0,$s1
        
        ; do nothing different if not on confirmation prompt
        lbu $v1, 0x04BC($gp)
        ; update buffer dstptr
        addu $s0,$v0
        beq $v1, $zero, @@underscoreCheck
        nop
          
          ; copy extra content for confirmation prompt
          ; src
          la $a1,doNamingStringSpecialConfirmDisplay_srcString
          jal systemStrCpy
          ; dst
          move $a0,$s0
          
          j @@done
          nop
        
        @@underscoreCheck:
          
          ; if name not full, append underscore
          lh $v1, 0x04B4($gp)
          lh $v0, 0x04B8($gp)
          sll $v1, $v1, 1
          
          ; src
          la $a2,nameScreenUnderscoreFlashCounter
          
          beq $v0,$v1,@@noUnderscore
          lw $a3,0($a2)
          ; copy extra content for underscore
            la $a1,doNamingStringSpecialConfirmDisplay_underscoreString
            addiu $a3,1
            andi $a3,0x3F
            ble $a3,0x34,@@noFlash
            sw $a3,0($a2)
              la $a1,doNamingStringSpecialConfirmDisplay_underscoreFlashString
            @@noFlash:
          
            jal systemStrCpy
            ; dst
            move $a0,$s0
          @@noUnderscore:
        
        @@done:
        
        ; render
        la $a0,doNamingStringSpecialConfirmDisplay_buffer
        ori $a1, $zero, 0x0038
        jal new_renderNameScreenString
        ori $a2, $zero, 0x0048
        
        j 0x800DEA0C
        nop
      
      nameScreenUnderscoreFlashCounter:
        .dw 0
      
    .endarea

  ;============================================================================
  ; MODIFICATION:
  ; bodge to work around mistakes in the game's incredibly bad
  ; system for printing numbers within scripts
  ;============================================================================
  
  scriptOp_setSpecialValue equ 0x84
  
    ; this is where the game jumps for out-of-bounds script opcodes
    ; (0x84+). we use this to extend it with the extra code we need.
    .org 0x800FDC88
;    .area 0x800FDCB8-.,0xFF
    .area 0x800FDCA0-.,0xFF
      bne $a1,scriptOp_setSpecialValue,0x800FDCA0
      nop
      
      j script_setSpecialValue
      nop
    .endarea

  ;============================================================================
  ; MODIFICATION:
  ; modify updateTextBoxWait to not allow a wait prompt to be confirmed
  ; if a multiple-choice prompt just concluded.
  ; this prevents an issue where holding fast-forward and pressing confirm
  ; at a choice prompt will skip any immediately following box entirely
  ; (since it immediately gets fast-forwarded, then does the wait check
  ; on the same input frame that the prompt was confirmed, meaning the
  ; confirmation button is still registered as triggered)
  ;============================================================================
  
  .org 0x800FFC9C
    j doExtraWaitConfirmCheck
    nop

  ;============================================================================
  ; MODIFICATION:
  ; correctly display community name on world map during disaster
  ;============================================================================
  
  .org 0x8004A5E0
    j checkForCommunityDisasterName
    nop
  
.close



;============================================================================
; POM_END.EXE
;============================================================================

.open "out/asm/POM_END.EXE", 0x8000F800
  
.close

  
