@echo off

python3 imageConvert2.py froggo2.png       ..\build\froggo.png  140 192 || exit
python3 parallax.py parallax.png > ..\build\parallaxData.asm || exit
