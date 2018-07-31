 ;
 ;HELLO SCREEN (COARSE)
 ;
  *=$3000
  JMP INIT
 ;
 TCKPTR=$2000
 ;
 SDMCTL=$022F; 0 TURNS ANTIC OFF ; 22 TURNS ANTIC BACK ON (SHADOW, DMA CONTROL)
 ;
 SDLSTL=$0230
 SDLSTH=$0231
 ;
 COLOR0=$02C4; OS COLOR REGISTERS
 COLOR1=$02C5
 COLOR2=$02C6
 COLOR3=$02C7
 COLOR4=$02C8
 ;
 ;DISPLAY LIST DATA
 ;
 START
 LINE1 .SBYTE "        PRESENTING    "
 LINE2 .SBYTE "                      "
   .SBYTE "THE BIG PROGRAM"
   .SBYTE "                      "
 LINE3 .SBYTE "                By "
   .SBYTE "Spacewreck             "
 LINE4 .SBYTE "   PLEASE STAND BY  "
 ;
 ; HELLO DISPLAY LIST
 ;
 HLIST
  .BYTE $70,$70,$70
  .BYTE $70, $70, $70, $70,$70
  .BYTE $46
  .WORD LINE1
  .BYTE $70,$70,$70,$70,$47
 SCROLN NOP
  .WORD $00; this is the initial value for the location of LINE2 in memory
  .BYTE $70,$42; blank line + LMS for second line
  .WORD LINE3 
  .BYTE $70,$70,$70,$70,$46
  .WORD LINE4
  .BYTE $70,$70,$70,$70,$70
  .BYTE $41
  .WORD HLIST
 ;
 ;RUN PROGRAM
 ;
 INIT NOP
  LDA COLOR3
  STA COLOR1
  LDA COLOR4
  STA COLOR2
 ; 
  LDA #0
  STA SDMCTL; turn antic off
  LDA #HLIST&255; store address (HLIST) of
  STA SDLSTL; new
  LDA #HLIST/256; display 
  STA SDLSTH; list
  LDA #$22; turn antic back on
  STA SDMCTL
 ;
 ; COARSE SCROLLING ROUTINE
 ;
  LDA #10
  STA TCKPTR; tckptr ($2000) stores the number of characters that are to be scrolled(???)- set it to 40 to start
  JSR TCKSET; this stores the starting address of the LINE2 in the display list at SCROLN
 ;
 COARSE NOP
  LDY TCKPTR; 40 TO START
  DEY; decrement the index
  BNE SCORSE; if the index is not 0 then branch to SCORSE
  LDY #10; if the index is zero, then set the index back to 40
  JSR TCKSET; start over by loading accumulator with start of LINE2 string
 SCORSE NOP
  STY TCKPTR; store the new decremented or reset index
  INC SCROLN; increment the high byte of the starting address of LINE2 in the DL
  BNE LEAP; it it isnt zero, then do the delay loop
  INC SCROLN+1; if it is zero, then increment low high byte of LINE2 in the DL and then do the delay loop
 ;
 ; DELAY LOOP
 ;
 LEAP NOP
  TYA; load Y to accumulator
  PHA
  LDX #$FF; - Load X REGISTER w/ FF
 XLOOP NOP
  LDY #$80; - Load Y REGISTER w/ 80
 YLOOP NOP
  DEY
  BNE YLOOP; decrement Y and branch back if its not zero
 ;
  DEX ; if Y is 0, decrement X
  BNE XLOOP ; if X isnt zero, then branch back to the xloop
  PLA ; Push Y into A
  TAY ; Put A into Y register to get the original Y back there
 ;
 ; END DELAY LOOP
  
  JMP COARSE
 ;
 TCKSET NOP
  LDA #LINE2&255; load the accumulator with the low byte of the address of the LINE2 string
  STA SCROLN; store the low byte in the display list 
  LDA #LINE2/256; load the accumulator with the high byte of the address of the LINE2 string
  STA SCROLN+1; store this in the display list at the next location
 ENDIT NOP
  RTS