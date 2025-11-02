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
270 PRINT "HOW TO PLAY:"
280 PRINT "                [A] UP"
290 PRINT "       [<-] LEFT        [->] RIGHT"
300 PRINT "                [Z] DOWN"
310 PRINT
320 PRINT "  [ESC] EXIT TO PRODOS"
330 PRINT "  [TAB] EXIT TO MONITOR"
340 PRINT
410 PRINT "TYPE '-GAME' TO RUN"
400 GET A$ : TEXT
