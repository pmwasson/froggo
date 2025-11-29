import sys
import os.path
from PIL import Image


def scaleImage(bitArray,scale,color1):
    height = len(bitArray)
    width = len(bitArray[0])
    im = Image.new("1", (width*scale,height*scale), 0)
    for y in range(height):
        for x in range(width):
            if (bitArray[y][x] == color1):
                for sx in range(scale):
                    for sy in range(scale):
                        im.putpixel((x*scale+sx,y*scale+sy),1)
    return(im)

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

    infile = sys.argv[1]
    width = int(sys.argv[2])
    height = int(sys.argv[3])
    outfile = sys.argv[4]

    source = Image.open(infile)
    im = source.convert("1")

    qrcode = readPixels(im,width,height,".","#")
    printArray(qrcode)

    outImage = scaleImage(qrcode,2,"#")
    outImage.save(outfile)

    # see earlier version of this file for low-res usage

main()