@echo off

python3 imageConvert2.py parallax-logo.png  ..\build\parallax-logo.png       56 16 0 0 1 || exit

python3 imageConvert2.py froggo-title.png          ..\build\froggo.png       140 192 1 4000 0 || exit

python3 imageConvert2.py aha-crop.png              ..\build\aha.png          70 64 0 0 0 || exit
python3 imageConvert2.py thinking-crop-flip.png    ..\build\thinking.png     70 64 0 0 0 || exit

python3 imageConvert2.py astro-crop.png            ..\build\astro.png        140 128 0 0 0 || exit
python3 imageConvert2.py turtle-crop.png           ..\build\turtle.png       140 128 0 0 0 || exit
python3 imageConvert2.py red-car-crop.png          ..\build\red-car.png      140 128 0 0 1 || exit
python3 imageConvert2.py scared-crop.png           ..\build\scared.png       140 128 0 0 0 || exit
python3 imageConvert2.py karate-crop.png           ..\build\karate.png       140 128 0 0 0 || exit
python3 imageConvert2.py thumb-crop.png            ..\build\thumb.png        140 128 0 0 0 || exit
python3 imageConvert2.py cape-crop.png             ..\build\cape.png         140 128 0 0 0 || exit
python3 imageConvert2.py selfie-crop.png           ..\build\selfie.png       140 128 0 0 0 || exit
python3 imageConvert2.py gamer-crop.png            ..\build\gamer.png        140 128 0 0 0 || exit
python3 imageConvert2.py cup2.png                  ..\build\cup.png          140 128 0 0 0 || exit
python3 imageConvert2.py loggo-crop2.png           ..\build\log.png          140 128 0 0 0 || exit

python3 imageConvert2.py menu_right.png            ..\build\menu_right.png   42 128 0 0 0 || exit
python3 imageConvert2.py menu_bottom.png           ..\build\menu_bottom.png  98 48 0 0 0  || exit
python3 imageConvert2.py qrcode_63x64.png          ..\build\qrcode_hgr.png   63 64 0 0 0  || exit

python3 parallax.py parallax.png > ..\build\parallaxData.asm || exit

:: python3 imageConvert2.py computer-crop.png         ..\build\computer.png     140 128 0 0 0 || exit
:: python3 imageConvert2.py car-crop3.png             ..\build\car.png          140 128 0 0 0 || exit

:: python3 qrConvert.py qr_code_a2sw.png 31 31 qrcode_2x.png || exit
