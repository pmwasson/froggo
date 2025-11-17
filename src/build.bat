::---------------------------------------------------------------------------
:: Compile code
::   Assemble twice: 1 to generate listing, 2 to generate object
::---------------------------------------------------------------------------
cd ..\build

:: Game
ca65 -I ..\src -t apple2 ..\src\game.asm -l game.dis  --large-alignment || exit
cl65 -I ..\src -t apple2 -u __EXEHDR__ ..\src\game.asm apple2.lib  -o game.apple2 -C ..\src\start2000.cfg || exit

:: Font Edit
ca65 -I ..\src -t apple2 ..\src\fontEdit.asm -l fontEdit.dis || exit
cl65 -I ..\src -t apple2 -u __EXEHDR__ ..\src\fontEdit.asm apple2.lib  -o fontEdit.apple2 -C ..\src\start6000.cfg || exit

:: Parallax
ca65 -I ..\src -t apple2 ..\src\parallax.asm -l parallax.dis || exit
cl65 -I ..\src -t apple2 -u __EXEHDR__ ..\src\parallax.asm apple2.lib  -o parallax.apple2 -C ..\src\start6000.cfg || exit

::---------------------------------------------------------------------------
:: Build disk
::---------------------------------------------------------------------------

:: Start with a blank prodos disk
copy ..\disk\template_prodos.dsk froggo.dsk  || exit

:: Game
:: java -jar C:\jar\AppleCommander.jar -p  froggo.dsk game.system sys < C:\cc65\target\apple2\util\loader.system || exit
:: java -jar C:\jar\AppleCommander.jar -as froggo.dsk game bin < game.apple2  || exit
java -jar C:\jar\AppleCommander.jar -as froggo.dsk game.system sys < game.apple2  || exit

:: Basic system for title
java -jar C:\jar\AppleCommander.jar -p  froggo.dsk basic.system sys < ..\disk\BASIC.SYSTEM  || exit
java -jar C:\jar\AppleCommander.jar -bas froggo.dsk startup < ..\src\startup.bas  || exit
java -jar C:\jar\AppleCommander.jar -bas froggo.dsk hello < ..\src\hello.bas || exit

:: Parallax
java -jar C:\jar\AppleCommander.jar -p  froggo.dsk parallax.system sys < C:\cc65\target\apple2\util\loader.system || exit
java -jar C:\jar\AppleCommander.jar -as froggo.dsk parallax bin < parallax.apple2  || exit

:: Font Edit
java -jar C:\jar\AppleCommander.jar -p  froggo.dsk fedit.system sys < C:\cc65\target\apple2\util\loader.system || exit
java -jar C:\jar\AppleCommander.jar -as froggo.dsk fedit bin < fontEdit.apple2  || exit

:: Data
::java -jar C:\jar\AppleCommander.jar -p  froggo.dsk data/froggo.hgr  bin < froggo.bin    || exit

:: Copy results out of the build directory
copy froggo.dsk ..\disk || exit

::---------------------------------------------------------------------------
:: Test on emulator
::---------------------------------------------------------------------------

D:\AppleWin\AppleWin\Applewin.exe -no-printscreen-dlg -d1 froggo.dsk

