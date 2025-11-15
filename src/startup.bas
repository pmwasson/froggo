100 HOME : PRINT "LOADING..." : PRINT  CHR$ (4),"BLOAD DATA/FROGGO.HGR,A$2000"
110 POKE -16304,0 : POKE -16297,0 : POKE -16300,0 : POKE -16302,0
120 HOME
200 PRINT "  :----------------------------------:"
210 PRINT "  : ============ FROGGO ============ :"
220 PRINT "  :----------------------------------:"
230 PRINT "  :         BY:  PAUL WASSON         :"
240 PRINT "  :          NOVEMBER, 2025          :"
250 PRINT "  :----------------------------------:"
260 PRINT
270 PRINT
280 PRINT "* HOW TO PLAY:"
290 PRINT "                [A] UP"
300 PRINT "       [<-] LEFT        [->] RIGHT"
310 PRINT "                [Z] DOWN"
320 PRINT
330 PRINT "  [TAB] PAUSE"
340 PRINT "  [ESC] EXIT TO PRODOS"
350 PRINT
360 PRINT "* HOW FAR CAN YOU GET?"
370 PRINT
380 PRINT "* PRESS ANY KEY TO LAUNCH ";
400 GET A$ : POKE -16303,0
410 GET A$ : PRINT : PRINT
420 PRINT CHR$(4);"-GAME"
