@echo off

python3 imageConvert2.py froggo2.png               ..\build\froggo.png       140 192 1 4000 || exit

python3 imageConvert2.py cup2.png                  ..\build\cup.png          140 128 0 0 || exit
python3 imageConvert2.py car-crop2.png             ..\build\car.png          140 128 0 0 || exit
python3 imageConvert2.py loggo-crop-140x128.png    ..\build\log.png          140 128 0 0 || exit

python3 qrConvert.py qrcode.png 25 25 > ..\build\qrcode.asm || exit
python3 parallax.py parallax.png > ..\build\parallaxData.asm || exit
