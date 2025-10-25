::---------------------------------------------------------------------------
:: Compile code
::   Assemble twice: 1 to generate listing, 2 to generate object
::---------------------------------------------------------------------------
cd ..\build

:: Game
ca65 -I ..\src -t apple2 ..\src\game.asm -l game.dis || exit
cl65 -I ..\src -t apple2 -u __EXEHDR__ ..\src\game.asm apple2.lib  -o game.apple2 -C ..\src\start6000.cfg || exit

:: Sprite Edit
ca65 -I ..\src -t apple2 ..\src\spriteEdit.asm -l spriteEdit.dis || exit
cl65 -I ..\src -t apple2 -u __EXEHDR__ ..\src\spriteEdit.asm apple2.lib  -o spriteEdit.apple2 -C ..\src\start6000.cfg || exit

:: Font Edit
ca65 -I ..\src -t apple2 ..\src\fontEdit.asm -l fontEdit.dis || exit
cl65 -I ..\src -t apple2 -u __EXEHDR__ ..\src\fontEdit.asm apple2.lib  -o fontEdit.apple2 -C ..\src\start6000.cfg || exit

::---------------------------------------------------------------------------
:: Build disk
::---------------------------------------------------------------------------

:: Start with a blank prodos disk
copy ..\disk\template_prodos.dsk portal2e.dsk  || exit

:: Game
java -jar C:\jar\AppleCommander.jar -p  portal2e.dsk game.system sys < C:\cc65\target\apple2\util\loader.system || exit
java -jar C:\jar\AppleCommander.jar -as portal2e.dsk game bin < game.apple2  || exit

:: :: Sprite Edit
java -jar C:\jar\AppleCommander.jar -p  portal2e.dsk sedit.system sys < C:\cc65\target\apple2\util\loader.system || exit
java -jar C:\jar\AppleCommander.jar -as portal2e.dsk sedit bin < spriteEdit.apple2  || exit

:: Font Edit
java -jar C:\jar\AppleCommander.jar -p  portal2e.dsk fedit.system sys < C:\cc65\target\apple2\util\loader.system || exit
java -jar C:\jar\AppleCommander.jar -as portal2e.dsk fedit bin < fontEdit.apple2  || exit

:: Data
java -jar C:\jar\AppleCommander.jar -p  portal2e.dsk ogre1   bin < ogre1.bin     || exit
:: java -jar C:\jar\AppleCommander.jar -p  portal2e.dsk ogre2   bin < ogre2.bin     || exit
:: java -jar C:\jar\AppleCommander.jar -p  portal2e.dsk portal  bin < portal.bin    || exit
java -jar C:\jar\AppleCommander.jar -p  portal2e.dsk froggo  bin < froggo.bin    || exit

:: Throw on basic
java -jar C:\jar\AppleCommander.jar -p  portal2e.dsk basic.system sys < ..\disk\BASIC.SYSTEM  || exit
java -jar C:\jar\AppleCommander.jar -bas portal2e.dsk display < ..\src\display.bas  || exit

:: Copy results out of the build directory
copy portal2e.dsk ..\disk || exit

::---------------------------------------------------------------------------
:: Test on emulator
::---------------------------------------------------------------------------

D:\AppleWin\AppleWin\Applewin.exe -no-printscreen-dlg -d1 portal2e.dsk

