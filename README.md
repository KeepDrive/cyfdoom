# cyfdoom
A mediocre DOOM map viewer for Create Your Frisk

## Introduction
This mod is the start of a future(?) DOOM port to Create Your Frisk. At this point it can:
- Read most of the DOOM WAD file
- Read most of the map data
- Triangulate meshes for walls and ceilings out-of-the-box reasonably quickly
- Display the maps more or less correctly(There seem to be some UV issues here and there and the floor/ceiling UV's are all over the place)
- Extract image data from a WAD file completely out-of-the-box(it just takes tens of hours to do so, which pretty much necessitates the use of an extractor python script I provide with the mod)

## Requirements
To run this you have to use Create Your Frisk(>=0.6.5)
And you have to have a working DOOM WAD file.

This mod might not work on Mac OS due to it's graphics API not supporting Geometry Shaders, I cannot test this myself, but I plan to make a workaround for this in the future.

Also this mod seems to require quite a bit of RAM, from my tests it seems to take up around 4.5 GB of RAM at worst.

The optional(but very much recommended) extractor Python script requires, well, Python, Pillow and Triangle.

## Setup
To install this mod, drop the cyfdoom folder into the mods folder of Create Your Frisk. Then take the WAD file you want to run and copy it over inside the cyfdoom folder, by default cyfdoom looks for a file named "DOOM.WAD", so either rename your wad file to that or you can change that in the cyfdoom.lua Wave script:
```
wadname="DOOM"--Note that you don't have to add .wad at the end
```
You can change the map that loads by default here as well:
```
mapname="E2M7"
```
(Note that the original Doom uses ExMy and Doom 2 uses MAPxy)

You should probably also use the extractor script at this point(unless you want to wait for over 11 hours for everything to extract on it's own), first install Python if you haven't already. 
Link: https://www.python.org/

It's tested on the current latest version, Python 3.10.

The script requires Pillow for image extraction and Triangle for map extraction.
Links to their installation guides:
https://pillow.readthedocs.io/en/stable/installation.html#basic-installation
https://rufat.be/triangle/installing.html

```
python3.10 -m pip install pillow
python3.10 -m pip install triangle
```

The script will prompt you to choose your WAD, and what to extract(choose the first option - extract everything).

It will take a minute or two to extract everything and then you're good to go, new files should appear in
```
Lua/Libraries/WADs/(wad name)/
Sprites/WADs/(wad name)/
```

## Credits
The triangulation algorithm used is s-hull(http://s-hull.org/), which was surprisingly easy to implement in Lua. To constrain the triangulation cyfdoom also uses an algorithm described on page 7 of the paper "A Fast Algorithm for Generating Constrained Delaunay Triangulations": https://www.newcastle.edu.au/__data/assets/pdf_file/0019/22519/23_A-fast-algortithm-for-generating-constrained-Delaunay-triangulations.pdf

The python script uses the Pillow and Triangle libraries

Other helpful resources I used when creating this:

Line intersection code source:
https://www.geeksforgeeks.org/check-if-two-given-line-segments-intersect/

Used this as a starting point for the point-inside-polygon check though it seems to not handle the edge case correctly at all:
https://www.geeksforgeeks.org/how-to-check-if-a-given-point-lies-inside-a-polygon/

PNG specifications from libpng:
http://www.libpng.org/pub/png/spec/1.2/PNG-Contents.html

zlib specification for png encoding:
https://github.com/libyal/assorted/blob/main/documentation/Deflate%20(zlib)%20compressed%20data%20format.asciidoc
https://datatracker.ietf.org/doc/html/rfc1951#section-3.2

Used this as a reference for my png extractor as well:
https://gist.github.com/t-mat/fed60b83735a80896fa182a77d5259d6

Most info about the inner workings of Doom are from:
https://doomwiki.org/
https://www.gamers.org/dhs/helpdocs/dmsp1666.html
https://web.archive.org/web/20100921092921/http://the-stable.lancs.ac.uk/~esasb1/doom/uds/

## Known issues
- Frequent freezes on more complex maps. Likely due to just how much RAM this uses.
- Wall UV's are not always correct.
- Floor/Ceiling UV's are always incorrect.
