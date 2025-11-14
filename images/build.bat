@echo off

python3 imageConvert2.py froggo2.png               ..\build\froggo.png       140 192 1 || exit
python3 imageConvert2.py loggo-crop-140x128.png    ..\build\loggo-crop.png   140 128 0 || exit
python3 parallax.py parallax.png > ..\build\parallaxData.asm || exit
