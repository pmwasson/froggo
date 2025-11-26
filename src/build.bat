::---------------------------------------------------------------------------
:: Compile code
::   Assemble twice: 1 to generate listing, 2 to generate object
::---------------------------------------------------------------------------
cd ..\build

:: Game
ca65 -I ..\src -t apple2 ..\src\game.asm -l game.dis  -o ..\build\game.o || exit
cl65 -I ..\src -t apple2 -u __EXEHDR__ ..\src\game.asm apple2.lib -o game.apple2 -C ..\src\start2000.cfg || exit

:: Font Edit
::ca65 -I ..\src -t apple2 ..\src\fontEdit.asm -l fontEdit.dis -o ..\build\fontEdit.o || exit
cl65 -I ..\src -t apple2 -u __EXEHDR__ ..\src\fontEdit.asm apple2.lib -l fontEdit.dis -o fontEdit.apple2 -C ..\src\start6000.cfg || exit

:: Parallax
::ca65 -I ..\src -t apple2 ..\src\parallax.asm -l parallax.dis -o ..\build\parallax.o || exit
cl65 -I ..\src -t apple2 -u __EXEHDR__ ..\src\parallax.asm apple2.lib -l parallax.dis -o parallax.apple2 -C ..\src\start6000.cfg || exit

::---------------------------------------------------------------------------
:: Build disk
::---------------------------------------------------------------------------

:: Start with a blank prodos disk
copy ..\disk\template_prodos.dsk froggo.dsk  || exit

:: Game
:: ac-windows -p  froggo.dsk game.system sys < C:\cc65\target\apple2\util\loader.system || exit
:: ac-windows -as froggo.dsk game bin < game.apple2  || exit
ac-windows  -as froggo.dsk froggo.system sys < game.apple2  || exit

:: Parallax
::ac-windows -p  froggo.dsk parallax.system sys < C:\cc65\target\apple2\util\loader.system || exit
ac-windows -as froggo.dsk parallax bin < parallax.apple2  || exit

:: Font Edit
::ac-windows -p  froggo.dsk fedit.system sys < C:\cc65\target\apple2\util\loader.system || exit
ac-windows -as froggo.dsk fedit bin < fontEdit.apple2  || exit

:: Basic system for title
ac-windows -p  froggo.dsk basic.system sys < ..\disk\BASIC.SYSTEM  || exit
::ac-windows -bas froggo.dsk startup < ..\src\startup.bas  || exit
ac-windows -bas froggo.dsk hello < ..\src\hello.bas || exit

:: Data
ac-windows -p  froggo.dsk data/scene.0  bin < log.bin       || exit
ac-windows -p  froggo.dsk data/scene.1  bin < cup.bin       || exit
ac-windows -p  froggo.dsk data/scene.2  bin < selfie.bin    || exit
ac-windows -p  froggo.dsk data/scene.3  bin < karate.bin    || exit
ac-windows -p  froggo.dsk data/scene.4  bin < cape.bin      || exit
ac-windows -p  froggo.dsk data/scene.5  bin < thumb.bin     || exit
ac-windows -p  froggo.dsk data/scene.6  bin < gamer.bin     || exit

ac-windows -p  froggo.dsk data/scene.7  bin < car.bin       || exit
ac-windows -p  froggo.dsk data/scene.8  bin < computer.bin  || exit

ac-windows -p  froggo.dsk data/quote.0  bin < thinking.bin  || exit
ac-windows -p  froggo.dsk data/quote.1  bin < aha.bin       || exit



:: Copy results out of the build directory
copy froggo.dsk ..\disk || exit

::---------------------------------------------------------------------------
:: Test on emulator
::---------------------------------------------------------------------------

Applewin -no-printscreen-dlg -d1 froggo.dsk

