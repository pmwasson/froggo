@echo off

python3 imageConvert2.py froggo2.png               ..\build\froggo.png       140 192 1 4000 || exit


python3 imageConvert2.py aha-crop.png              ..\build\aha.png          70 64 0 0 || exit
python3 imageConvert2.py thinking-crop-flip.png    ..\build\thinking.png     70 64 0 0 || exit

python3 imageConvert2.py computer-crop.png         ..\build\computer.png     140 128 0 0 || exit
python3 imageConvert2.py karate-crop.png           ..\build\karate.png       140 128 0 0 || exit
python3 imageConvert2.py thumb-crop.png            ..\build\thumb.png        140 128 0 0 || exit
python3 imageConvert2.py cape-crop.png             ..\build\cape.png         140 128 0 0 || exit
python3 imageConvert2.py selfie-crop.png           ..\build\selfie.png       140 128 0 0 || exit
python3 imageConvert2.py gamer-crop.png            ..\build\gamer.png        140 128 0 0 || exit
python3 imageConvert2.py cup2.png                  ..\build\cup.png          140 128 0 0 || exit
python3 imageConvert2.py car-crop3.png             ..\build\car.png          140 128 0 0 || exit
python3 imageConvert2.py loggo-crop2.png           ..\build\log.png          140 128 0 0 || exit

python3 qrConvert.py qrcode.png 25 25 > ..\build\qrcode.asm || exit
python3 parallax.py parallax.png > ..\build\parallaxData.asm || exit
