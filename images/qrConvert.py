import sys
import os.path
from PIL import Image


def readPixels(im,width,height,bgChar,fgChar):
    xScale = im.size[0]/width
    yScale = im.size[1]/height
    qrcode = [[bgChar for _ in range(width)] for _ in range(height)]
    for y in range(height):
        for x in range(width):
            px = int((x+0.5)*xScale)
            py = int((y+0.5)*yScale)
            pixelSet = (im.getpixel((px,py)) != 0)
            if (pixelSet):
                qrcode[y][x] = fgChar
    return(qrcode)

def loRes(bitArray,fg,color0,color1):
    height = len(bitArray)
    width = len(bitArray[0])
    colorBG = color1
    colorDiff = color1 - color0
    for y in range(int((height+1)/2)):
        print(f".byte ",end='')
        for x in range(width):
            value = (color0 + colorDiff * (bitArray[y*2][x]==fg))
            if (y*2+1 < height):
                value = value + 16*(color0 + colorDiff * (bitArray[y*2+1][x]==fg))
            else:
                value = value + 16*colorBG
            print(f"${value:02X}",end='')
            if (x<width-1):
                print(f",",end='')
            else:
                print(f" ; lines {y*2} and {y*2+1}")

def loResCompress(bitArray,compressFG):
    height = len(bitArray)
    width = len(bitArray[0])
    print(f"; {width} x {height}")
    for y in range(int((height+1)/2)):
            print(f".byte ",end='')
            value = 0
            for x in range(width):
                bit0 = (bitArray[y*2][x]==compressFG)
                bit1 = 0
                if (y*2+1 < height):
                    bit1 = (bitArray[y*2+1][x]==compressFG)
                value = value | ((bit0 + 2*bit1) << (x % 4)*2)
                if (x%4==3):
                    print(f"${value:02X}",end='')
                    value = 0
                    if (x<width-1):
                        print(f",",end='')
                if(x==width-1):
                    if (x%4!=3):
                        print(f"${value:02X}",end='')
                    print(f" ; lines {y*2} and {y*2+1}")

def printArray(bitArray):
    height = len(bitArray)
    width = len(bitArray[0])
    for y in range(height):
        print(f";   {y:3}: ",end='')
        for x in range(width):
            print(bitArray[y][x],end='')
        print()


def main():

    memoryRowOrder = [  0,1,16,17,32,33, 2, 3,18,19,34,35, 4, 5,20,21,36,37, 6, 7,22,23,38,39,
                        8,9,24,25,40,41,10,11,26,27,42,43,12,13,28,29,44,45,14,15,30,31,46,47 ]


    # infile = sys.argv[1]
    # width = int(sys.argv[2])
    # height = int(sys.argv[3])

    # source = Image.open(infile)
    # print(";",infile,source.format, source.size, source.mode)
    # im = source.convert("1")

    # qrcode = readPixels(im,width,height,".","#")
    # printArray(qrcode)

    # print(f"img_qrcode_lores:")
    # loRes(qrcode,"#",0x4,0xF)

    # print(f"img_qrcode_lores_compressed:")
    # loResCompress(qrcode,"#")

    qrcode =    [
                "       ## #  #   #       ",
                " ##### # # ##   ## ##### ",
                " #   # ##    # # # #   # ",
                " #   # # #### #  # #   # ",
                " #   # ##  # ##### #   # ",
                " ##### # # #     # ##### ",
                "       # # # # # #       ",
                "######### # # ## ########",
                "     #   # ###    # # # #",
                " #  ###   # ##  # #  ### ",
                "  #### #  #     #  # # ##",
                " ###  #   #  ###  #######",
                "#    # #  ####  #     #  ",
                " #  ### # ####    #  ####",
                " # ##    ##    ##  # #  #",
                " #   ####   ####  #####  ",
                " # # #  ## ##         ## ",
                "########    ##   ### ### ",
                "       #       # # # #   ",
                " ##### ###  # ## ###  ###",
                " #   # #   ##  #      ###",
                " #   # #     #     # ##  ",
                " #   # # # #  # # ## # # ",
                " ##### #    # ##      # #",
                "       #   #   ## ####   "
                ]
    #loRes(qrcode,"#",0x4,0xF)

    #                      111111111122222222223333333333
    #            0123456789012345678901234567890123456789
    froggo = [  "########################################",
                "#                                      #",
                "#  ####  ###    ##    ###   ###   ##   #",
                "#  #     #  #  #  #  #     #     #  #  #",
                "#  ###   ###   #  #  # ##  # ##  #  #  #",
                "#  #     #  #  #  #  #  #  #  #  #  #  #",
                "#  #     #  #   ##    ###   ###   ##   #",
                "#                                      #",
                "########################################"
            ]

    #print(f"img_froggo_lores:")
    #printArray(froggo)
    #loRes(froggo,"#",0x4,0xF)

    # print(f"img_froggo_compressed:")
    # loResCompress(froggo,"#")


    #                      111111111122222222223333333333
    #            0123456789012345678901234567890123456789
    pause = [   "    ####    ###   #   #   ###  #####    ",
                "    #   #  #   #  #   #  #     #        ",
                "    ####   #####  #   #   ###  ###      ",
                "    #      #   #  #   #      # #        ",
                "    #      #   #   ###    ###  #####    "
            ]
    #print(f"img_pause_lores:")
    #printArray(pause)
    #loRes(pause,"#",0x4,0xF)


    #                      111111111122222222223333333333
    #            0123456789012345678901234567890123456789
    pauseScreen = [
                "                                        ",     #0
                " ###################################### ",     #1
                " ##    ##   ####  ####   ###   ###  ### ",     #2
                " ## ##### ## ## ## ## ##### ##### ## ## ",     #3
                " ##   ###   ### ## ## #  ## #  ## ## ## ",     #4
                " ## ##### ## ## ## ## ## ## ## ## ## ## ",     #5
                " ## ##### ## ###  ####   ###   ###  ### ",     #6
                " ###################################### ",     #7
                "                                        ",     #8
                "                                        ",     #9
                "                                        ",     #10
                "       #######  # ## ### #######        ",     #11
                "       #     # # #  ###  #     #        ",     #12
                "       # ### #  #### # # # ### #        ",     #13
                "       # ### # #    # ## # ### #        ",     #14
                "       # ### #  ## #     # ### #        ",     #15
                "       #     # # # ##### #     #        ",     #16
                "       ####### # # # # # #######        ",     #17
                "                # # #  #                ",     #18
                "       ##### ### #   #### # # #         ",     #19
                "       # ##   ### #  ## # ##   #        ",     #20
                "       ##    # ## ##### ## # #          ",     #21
                "       #   ## ### ##   ##               ",     #22
                "        #### # ##    ## ##### ##        ",     #23
                "       # ##   # #    #### ##            ",     #24
                "       # #  ####  ####  ## # ##         ",     #25
                "       # ###    ###    ##     ##        ",     #26
                "       # # # ##  #  #########  #        ",     #27
                "               ####  ###   #   #        ",     #28
                "       ####### ####### # # # ###        ",     #29
                "       #     #   ## #  #   ##           ",     #30
                "       # ### # ###  ## ######           ",     #31
                "       # ### # ##### ##### #  ##        ",     #32
                "       # ### # # # ## # #  # # #        ",     #33
                "       #     # #### #  ###### #         ",     #34
                "       ####### ### ###  #    ###        ",     #35
                "                                        ",     #36
                "                                        ",     #37
                "                                        ",     #38
                "                                        ",     #39
                " ###################################### ",     #40
                " ###    ####   ### ### ###   ##     ### ",     #41
                " ### ### ## ### ## ### ## ##### ####### ",     #42
                " ###    ###     ## ### ###   ##   ##### ",     #43
                " ### ###### ### ## ### ###### # ####### ",     #44
                " ### ###### ### ###   ####   ##     ### ",     #45
                " ###################################### ",     #46
                "                                        ",     #47
                ]


    sortedPauseScreen = [pauseScreen[i] for i in memoryRowOrder]
    print(f"img_pause_compressed:")
    loResCompress(sortedPauseScreen,"#")
main()