# drainable-combiner
A Project Zomboid mod that will combine all of a selected combineable item(s) with a single click. Items selected from a container other than the characters main inventory will be transferred, combined, and then returned to the original container.

## Status
| Mode | Works | Notes |
| ----- | ----- | ----- | 
| Singleplayer | ✔️ | |
| Splitscreen Co-op | ⚠️ - Unverified | |
| Multiplayer | ✔️ | Seems to work fine on 41.66 |


## How
Right click on the drainable item and click "Combine All". Your character will go through the process of combining the glue until it is as condensed as possible.

![image](https://user-images.githubusercontent.com/15162189/155799635-44a6f4cb-7091-4d68-9248-7c923c96602d.png)

#### Note
This functionality only works for items with a `canConsolidate = true` according to Project Zomboid. Things like Car Batteries/etc will not present the option by default.

## Supported Languages
- English
- French

### Translations
If you know a language that is currently not supported and would like to contribute, open up a PR or get a hold of me!

See existing text to translate [here](https://github.com/vanwinlaw/drainable-combiner/blob/master/Contents/mods/Drainable%20Combiner/media/lua/shared/Translate/EN/UI_EN.txt). 

## Mod Disclaimer
Use at your own risk. This is just an excuse for me to play around with PZ modding, however I hope others find it useful and that it works as well.