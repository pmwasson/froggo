@echo off

python3 imageConvert2.py portal-colored.png ..\build\portal.png 140 192 || exit
python3 imageConvert2.py ogre-colored.png  ..\build\ogre1.png   140 192 || exit
python3 imageConvert2.py ogre-title.png    ..\build\ogre2.png   140 192 || exit
python3 imageConvert2.py froggo2.png       ..\build\froggo.png  140 192 || exit

python3 tileMapConvert.py road.png road_tileset.asm 7 8 || exit