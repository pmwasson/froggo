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
- [ ] Rewrite level loading code so can come from AUX memory
- [ ] More levels
  - [ ] 5 levels
  - [ ] 25 levels
  - [ ] 50 levels 	
- [ ] Start with an inactive game, alternating between starting level and helpful tips
- [ ] Add more cutscene images
- [ ] Add end of level messages
  - [ ] Implement simple compression
  - [ ] Put string in AUX memory	
- [ ] Credits
- [ ] Level editor?
- [ ] Load tiles from disk so users can edit.  May want to load default with game and have a keystroke to load modified version.
  - [ ] Put the player shapes back into the tile data?
  - [ ] May need to extend the tile editor to handle more entries

