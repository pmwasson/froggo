# Froggo
Froggo is a retro action game by Paul Wasson for the Apple // inspired by the original Frogger and the more recent Crossy Road.

# Download
Disk image (latest): https://github.com/pmwasson/froggo/raw/refs/heads/main/disk/froggo.dsk

Play on real hardwire, your favorite emulator, or online via Apple2TS emulator:

https://apple2ts.com/?theme=minimal&#https://github.com/pmwasson/froggo/raw/refs/heads/main/disk/froggo.dsk

# Requirements
- Apple //e or later with 128K of memory
- Color or monochrome monitor
- 5¼" floppy drive

# Features
- Free download -- fits on a single sided ProDOS 5¼" disk
- Uses double buffered hires graphics
- 25* unique levels of increasing difficulty
- Large, zany completion images after each level in a random order
- Original two-tone music using Electric Duet by Paul Lutus
- Smooth per pixel vertical scrolling for cars, trucks, logs, turtles and more
- Support for color and monochrome monitors, like the Apple Monitor II
- Configurable controls
- 2 game modes:
  - Casual - repeat levels until complete
  - Challenge - failure will restart the game from the beginning
- A graphics editor is included on the disk to change any of the sprites, backgrounds or Froggo himself
- Suitable for all ages

\* Complete challenge mode for an additional bonus level!

# How to play
Use the [A] and [Z] keys to hop up or down. Use [←] [→] to hop left or right.

On each level, Froggo starts on the left side of the screen.  The objective is to get him to hop off the right side of the screen.

Trees and bushes will block his way, and watch out for speeding cars and trucks. He will have to hop on rocks and logs to cross rivers, but not fall in! He can also hop on turtles, unless they go under water.

More challenges await in later levels.

Press the [ESC] key to pause and access the menu.

# Technical Details
## Why does it require 128K if only using hi-res graphics?
All the vertical environment scrolling is done using unrolled loops in extended memory.  There are 16 256-byte buffers that are used to transfer the sprite data directly onto specific columns of the screen that use absolute indexed addressing, instead of indirect addressing, that make it run faster. By offsetting into the buffer, the sprites can be displayed at any offset within the 128 row window. The code is repeated for both graphic pages.

The unrolled loops look like:

```
  ...
  LDA $A100,Y   ; read buffer
  STA $2200,X   ; write screen
  LDA $A101,Y   ; read buffer
  STA $2600,X   ; write screen
  ...
```
Where Y is the offset into the buffer and X is the screen column.

When completely unrolled, the scrolling code takes up over 24KB of extended memory of almost completely straight-line code with only a handful of branches. It doesn't need to use indirect addressing, calculate screen location or add buffer offsets since it is all baked into the code.

Other data, like levels and images are also stored in the extended memory to reduce disk access.

# Toolchain
- Using ca65 (part of the cc65 compiler) for assembling. https://cc65.github.io/
- AppleCommander to build disk images. https://applecommander.github.io/
- AppleWin for emulation. https://github.com/AppleWin/AppleWin
