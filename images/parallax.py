import sys
import os.path
from PIL import Image

# Translate rows into screen memory offsets
lineOffset = [
    0x0000, 0x0000+0x0400, 0x0000+0x0800, 0x0000+0x0c00, 0x0000+0x1000, 0x0000+0x1400, 0x0000+0x1800, 0x0000+0x1c00,
    0x0080, 0x0080+0x0400, 0x0080+0x0800, 0x0080+0x0c00, 0x0080+0x1000, 0x0080+0x1400, 0x0080+0x1800, 0x0080+0x1c00,
    0x0100, 0x0100+0x0400, 0x0100+0x0800, 0x0100+0x0c00, 0x0100+0x1000, 0x0100+0x1400, 0x0100+0x1800, 0x0100+0x1c00,
    0x0180, 0x0180+0x0400, 0x0180+0x0800, 0x0180+0x0c00, 0x0180+0x1000, 0x0180+0x1400, 0x0180+0x1800, 0x0180+0x1c00,
    0x0200, 0x0200+0x0400, 0x0200+0x0800, 0x0200+0x0c00, 0x0200+0x1000, 0x0200+0x1400, 0x0200+0x1800, 0x0200+0x1c00,
    0x0280, 0x0280+0x0400, 0x0280+0x0800, 0x0280+0x0c00, 0x0280+0x1000, 0x0280+0x1400, 0x0280+0x1800, 0x0280+0x1c00,
    0x0300, 0x0300+0x0400, 0x0300+0x0800, 0x0300+0x0c00, 0x0300+0x1000, 0x0300+0x1400, 0x0300+0x1800, 0x0300+0x1c00,
    0x0380, 0x0380+0x0400, 0x0380+0x0800, 0x0380+0x0c00, 0x0380+0x1000, 0x0380+0x1400, 0x0380+0x1800, 0x0380+0x1c00,
    0x0028, 0x0028+0x0400, 0x0028+0x0800, 0x0028+0x0c00, 0x0028+0x1000, 0x0028+0x1400, 0x0028+0x1800, 0x0028+0x1c00,
    0x00A8, 0x00A8+0x0400, 0x00A8+0x0800, 0x00A8+0x0c00, 0x00A8+0x1000, 0x00A8+0x1400, 0x00A8+0x1800, 0x00A8+0x1c00,
    0x0128, 0x0128+0x0400, 0x0128+0x0800, 0x0128+0x0c00, 0x0128+0x1000, 0x0128+0x1400, 0x0128+0x1800, 0x0128+0x1c00,
    0x01A8, 0x01A8+0x0400, 0x01A8+0x0800, 0x01A8+0x0c00, 0x01A8+0x1000, 0x01A8+0x1400, 0x01A8+0x1800, 0x01A8+0x1c00,
    0x0228, 0x0228+0x0400, 0x0228+0x0800, 0x0228+0x0c00, 0x0228+0x1000, 0x0228+0x1400, 0x0228+0x1800, 0x0228+0x1c00,
    0x02A8, 0x02A8+0x0400, 0x02A8+0x0800, 0x02A8+0x0c00, 0x02A8+0x1000, 0x02A8+0x1400, 0x02A8+0x1800, 0x02A8+0x1c00,
    0x0328, 0x0328+0x0400, 0x0328+0x0800, 0x0328+0x0c00, 0x0328+0x1000, 0x0328+0x1400, 0x0328+0x1800, 0x0328+0x1c00,
    0x03A8, 0x03A8+0x0400, 0x03A8+0x0800, 0x03A8+0x0c00, 0x03A8+0x1000, 0x03A8+0x1400, 0x03A8+0x1800, 0x03A8+0x1c00,
    0x0050, 0x0050+0x0400, 0x0050+0x0800, 0x0050+0x0c00, 0x0050+0x1000, 0x0050+0x1400, 0x0050+0x1800, 0x0050+0x1c00,
    0x00D0, 0x00D0+0x0400, 0x00D0+0x0800, 0x00D0+0x0c00, 0x00D0+0x1000, 0x00D0+0x1400, 0x00D0+0x1800, 0x00D0+0x1c00,
    0x0150, 0x0150+0x0400, 0x0150+0x0800, 0x0150+0x0c00, 0x0150+0x1000, 0x0150+0x1400, 0x0150+0x1800, 0x0150+0x1c00,
    0x01D0, 0x01D0+0x0400, 0x01D0+0x0800, 0x01D0+0x0c00, 0x01D0+0x1000, 0x01D0+0x1400, 0x01D0+0x1800, 0x01D0+0x1c00,
    0x0250, 0x0250+0x0400, 0x0250+0x0800, 0x0250+0x0c00, 0x0250+0x1000, 0x0250+0x1400, 0x0250+0x1800, 0x0250+0x1c00,
    0x02D0, 0x02D0+0x0400, 0x02D0+0x0800, 0x02D0+0x0c00, 0x02D0+0x1000, 0x02D0+0x1400, 0x02D0+0x1800, 0x02D0+0x1c00,
    0x0350, 0x0350+0x0400, 0x0350+0x0800, 0x0350+0x0c00, 0x0350+0x1000, 0x0350+0x1400, 0x0350+0x1800, 0x0350+0x1c00,
    0x03D0, 0x03D0+0x0400, 0x03D0+0x0800, 0x03D0+0x0c00, 0x03D0+0x1000, 0x03D0+0x1400, 0x03D0+0x1800, 0x03D0+0x1c00];

paletteNames       = [ "black",        "purple",       "green",        "blue",         "orange",       "white"          ]
paletteColors      = [ (  0,  0,   0 ),(217, 60,  240),( 38, 195,  15),( 38, 151, 240),(217, 104,  15),(255, 255, 255)  ]
paletteBits        = [ 0,              1,              2,              1,              2,              3                ]
paletteMSB         = [ 0,              0,              0,              1,              1,              0                ]
paletteColorBytes  = [ [0x00,0x00],    [0x55,0x2a],    [0x2a,0x55],    [0xd5,0xaa],    [0xaa,0xd5],    [0x7f,0x7f]      ]

def closestMatch(colors):
    minScore = 9999999
    minIndex = 0
    for paletteIndex in range(len(paletteColors)):
        testScore = 0
        for colorBand in range(len(paletteColors[0])):
            testScore = testScore + abs(colors[colorBand] - paletteColors[paletteIndex][colorBand]) ** 2
        if testScore < minScore:
            minIndex = paletteIndex
            minScore = testScore
    return(minIndex)

# shift 7 bit data right in 8 bit byte by shift amount, setting 8th bit to MSB
def shift7bRight(data,shift,msb):
    result = []
    shiftMod = shift % 7
    remainder = ((data[0] << (8-shiftMod)) & 0xff) >> 1
    for value in data[::-1]:
        result.append(((value & 0x7f) >> shiftMod) | remainder | msb)
        remainder = ((value << (8-shiftMod)) & 0xff) >> 1
    result.reverse()
    return(result)

# Usage: inputFile outputFile width height
# FIXME: use a real command line parser

def main():

    infile = sys.argv[1]

    source = Image.open(infile)
    print(";",infile,source.format, source.size, source.mode)
    im = source.convert("RGB")

    # byte offset range for drawing
    initialOffset = 0
    maxOffset = 40

    constantRowCode = ["",""]
    bufferRowCode = [["",""]]
    bufferData = [""]

    group = 0
    rows = im.size[1]
    lastRowConstant = True
    rowIsConstant = [False] *  rows
    rowValue = [-1] * rows
    rowMSB = [0] * rows
    line = []
    colorCount = [0] * len(paletteColors)

    for y in range(rows):
        line.append([])
        value = 0
        msb = 0
        usedColors = set();
        for x in range(im.size[0]):
            s = x*2
            color = closestMatch(im.getpixel((x,y)))
            usedColors.add(color)
            # print(x,y,color,paletteNames[color],paletteBits[color],paletteMSB[color],paletteMSB[color] << 7)
            # write out 2 bits for each pixel into a 7-bit bytes
            value = value | (paletteBits[color] << s%7)
            msb = msb | (paletteMSB[color] << 7)
            if (s%7 == 6):
                dataByte = (value & 0x7f) | msb
                line[y].append(dataByte)
                value = (value & 0x80) >> 7
                #print(f"${dataByte:02X}")
            elif (s%7 == 5):
                dataByte = (value & 0x7f) | msb
                line[y].append(dataByte)
                #print(f"${dataByte:02X}")
                value = 0

        rowMSB[y] = msb
        rowIsConstant[y] = len(usedColors) == 1

        if (rowIsConstant[y]):
            rowValue[y] = usedColors.pop()  # constant color
            colorCount[rowValue[y]] += 1
        else:
            rowValue[y] = group             # group number

        if (rowIsConstant[y] and not lastRowConstant):
            group += 1
            bufferData.append("")
            bufferRowCode.append(["",""])
        lastRowConstant = rowIsConstant[y]

    # output results
    numGroups = group
    indent = " " * 4;
    prefix = "parallax"
    print(f"\n; === Parallax Code ===")
    for screen in range(2):
        baseAddress = 0x2000 * (screen+1)

        # constant rows

        print(f"\n; Screen {screen} paint constant color rows\n")
        print(f".proc {prefix}ConsantColorRowsScreen{screen}")
        print(f"{indent}ldx #{initialOffset}")
        print(f"loop:")

        # group constant rows by color to save loads
        for color in range(len(paletteColorBytes)):
            if (colorCount[color] > 0):
                print(f"\n; Screen {screen} color {paletteNames[color]}")
                for parity in range(2):
                    print(f"{indent}lda #${paletteColorBytes[color][parity]:02X}")
                    for row in range(rows):
                        #print(f"Row {row} value {rowValue[row]}")
                        if rowIsConstant[row] and (rowValue[row] == color):
                            rowAddress = baseAddress + lineOffset[row] + parity
                            print(f"{indent}sta ${rowAddress:04X},x")

        print(f"\n{indent}inx")
        print(f"{indent}inx")
        print(f"{indent}cpx #{maxOffset}")
        print(f"{indent}beq done")
        print(f"{indent}jmp loop")
        print(f"done:")
        print(f"{indent}rts")
        print(f".endproc")

        # parallax rows

        print(f"\n; Screen {screen} paint parallax rows by group\n")
        for group in range(numGroups):
            print(f".proc {prefix}Group{group}Screen{screen}")

            left = initialOffset
            right = maxOffset
            loop = 0
            while (left<right):
                print(f"{indent}ldy {prefix}Group{group}Offset")
                print(f"{indent}ldx #0")
                print(f"loop{loop}:")
                increment = min(len(line[0]),right-left)

                for row in range(rows):
                    bufferName = f"{prefix}Buffer{group}Row{row:03}"
                    if ((not rowIsConstant[row]) and (rowValue[row] == group)):
                        rowAddress = baseAddress + lineOffset[row]
                        print(f"{indent}lda {bufferName},y")
                        offset = left
                        while(offset+increment <= right):
                            print(f"{indent}sta ${rowAddress+offset:04X},x")
                            offset=offset+increment
                print(f"{indent}iny")
                print(f"{indent}inx")
                print(f"{indent}cpx #{increment}")
                print(f"{indent}bne loop{loop}")
                loop += 1
                left += increment * int((right-left)/increment)

            print(f"{indent}rts")
            print(f".endproc")

    shiftCount = 7
    repeatCount = 2

    print();
    print(f"\n; === Parallax Data ===\n")

    for group in range(numGroups):
        print(f"{prefix}Group{group}Offset: .byte 0")


    for row in range(rows):
        if (not rowIsConstant[row]):
            bufferName = f"{prefix}Buffer{rowValue[row]}Row{row:03}"
            print(f"{bufferName}:")
            for s in range(shiftCount):
                shift = s*2
                print(f"; Shift by {shift}, repeated {repeatCount} time")
                shiftedRow = shift7bRight(line[row],shift,rowMSB[row])
                for r in range(repeatCount):
                    print(f"{indent}.byte ${shiftedRow[0]:02X}",end='')
                    for value in shiftedRow[1::]:
                        print(f",${value:02X}",end='')
                    print()
main()