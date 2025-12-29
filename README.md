# Froggo
Endless fog hopping


# Setting up sublime text

```
ca65 build:
{
	//"shell_cmd": "\"$file_base_name.bat\""
	"shell_cmd": "\"build.bat\""
}

python3 build:
{
 "cmd":["python3", "-u", "$file"],
 "file_regex": "^[ ]File \"(...?)\", line ([0-9]*)",
 "selector": "source.python"
}
```

# Things to do
- [x] Smooth scrolling by unrolling loops into AUX memory
- [x] Load title screen in same file as the game
- [x] Load next cutscene while displaying the current one
- [x] Rewrite level loading code so can come from AUX memory
- [x] Added turtles
- [ ] Redo music (get help from Ben)
- [ ] Add level timer
- [x] Different level types
  - [x] Turtles
  - [x] Trains - very fast, go from emptry to full
  - [ ] Snakes - time limit by slowly filling column
  - [ ] Crosswalk - stop time briefly so must hurry across road
  - [ ] Buttons - simple puzzle solving - enable bridges or remove barriers (crosswalk may be a subset)
- [x] More levels
  - [x] 5 levels
  - [ ] 25 levels
  - [ ] 50 levels
- [ ] Scoring
  - [ ] Save high score
- [x] Remap keyboard
- [ ] Start with an inactive game, alternating between starting level and helpful tips
- [x] Add more cutscene images
  - [x] Remove lesser images
  - [ ] Fill disk
- [x] Add end of level messages
  - [x] Implement simple compression
  - [ ] Put string in AUX memory
- [x] Credits
  - [x] Smooth scrolling
- [ ] Level editor?
- [x] Load tiles from disk so users can edit.  May want to load default with game and have a keystroke to load modified version.
  - [ ] Put the player shapes back into the tile data?
  - [x] May need to extend the tile editor to handle more entries
  - [ ] Let tile editor load / save
  - [ ] Make green screen version of tiles

