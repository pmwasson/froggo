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
