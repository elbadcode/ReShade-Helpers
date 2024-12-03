these are mostly just other people's shaders with some fun little tweaks. replace the originals since you need dependencies 

# Before After
- use for graphics show case, just set it on a keybind and record. speed is not configurable but I think its a good speed already
# DH uber mask
- added like 5 additional masks lol you can use the depth only masks for layering effects like in a photo editor almost
- added an animated mask, it needs a bit more work or a lot of manual tweaking of settings but theoretically it can animate any effect by depth 


# PD80_06_Depth_SlicerBAD.fx
- port of a glsl chromakey shader I wrote for alxr which needed accurate keying with No depth
- Was in progress adding some depth features and just pasted my code into pd80s depth slicer
- unfinished and idk if it ever will be because I don't know what the goal would be but it can do extremely accurate color replacement with minimal overhead

## Everything else is just the regular effect with animation forced in using uuniforms and a const multiplier. Most have some degreee of configuration added in the UI, generally bare minimum for my own usage but should be easy enough to understand. If you actually find a usecase please let me know! I can probably improve on it. If there's something you want that isnt currently available through the special uniforms I'll at least take a look

# optical flow
- lengthened vectors and inverted direction
- read a paper showing that inverted motion vectors could be used to mitigate VR sickness
- I do not experience VR sickness and didnt test this in a VR environment so I'm not really sure if it does anything but I was pretty excited about it for 5 minutes and I think it generally behaves as intended. Possibly could be further modified to actually be useful, probably no one including me will ever touch it (and again I cant test it myself bc no sickness)
