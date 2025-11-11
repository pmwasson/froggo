@echo off

python3 imageConvert2.py froggo2.png       ..\build\froggo.png       140 192 1 || exit
python3 imageConvert2.py froggo-crop.png   ..\build\froggo-crop.png  126 128 0 || exit
python3 imageConvert2.py loggo3.png        ..\build\loggo.png        140 192 1 || exit
python3 parallax.py parallax.png > ..\build\parallaxData.asm || exit
