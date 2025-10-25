1    REM :--------------------:
2    REM : ===== FROGGO ===== :
3    REM :--------------------:
4    REM :  BY:  PAUL WASSON  :
5    REM :   NOVEMBER, 2025   :
6    REM :--------------------:
100  HOME : PRINT "LOADING..." : PRINT  CHR$ (4),"BLOAD FROGGO,A$2000"
110  POKE -16304,0 : POKE -16297,0 : POKE -16300,0 : POKE -16302,0
120  GET A$ : PRINT CHR$(4) ; "-GAME"