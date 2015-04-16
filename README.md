[![TileCraft](https://img.shields.io/badge/app-TileCraft%201.0.0%20alpha8dev-brightgreen.svg)](#)
[![MIT License](https://img.shields.io/badge/license-GNU%20GPL%203-blue.svg)](LICENSE)
[![Haxe 3](https://img.shields.io/badge/language-Haxe%203-orange.svg)](http://www.haxe.org)
[![OpenFL 2](https://img.shields.io/badge/require-OpenFL 2-red.svg)](http://www.openfl.org)
[![Cross platform](https://img.shields.io/badge/platform-win%2Bmac%2Blinux-yellow.svg)](http://www.openfl.org)
# ![TILECRAFT](https://dl.dropboxusercontent.com/u/683344/akifox/tilecraft/git/title.png)

2.5D fast multi-platform modeling tool to make tiles for games, icons or whatever you want!

- Developed by [Simone Cingano](http://akifox.com)

- Based on [LGModeler](https://github.com/angryoctopus/lgmodeler) by [AngryOctupus](http://www.angryoctopus.co.nz/)

- Original idea from [lostgarden.com](http://www.lostgarden.com/2013/10/prototyping-challenge-3d-modeling-tool.html)

![Alpha8 Interface](https://dl.dropboxusercontent.com/u/683344/akifox/tilecraft/git/interface.png)

---
[Read the Quick guide to understand how to use TileCraft](GUIDE.md)
---

## Index

- [Status of the project](#status)
- [Milestones](#milestones)
- [Download](#download)
- [Build by the sources](#try-it)
- [Sample models](#examples)
- [Lostgarden challenge](#lostgarden-challenge)
- [TODOs](#todo)

## Status

The project is in development stage. **!! Not fully working prototype !!**
(Basically missing some dialogs to save and load files)

The beta status will be reached on a full prototype.

## Milestones

 - **alpha:  Shape and model (load and save to Base64)**
 - **alpha2: Model renderer**
 - **alpha3: Lights renderer + postfx (Antialias+outline)**
 - **alpha4: Basic interface**
 - **alpha5: Save to PNG (image+model) and big housekeeping**
 - **alpha6: Shape list + improved gui**
 - **alpha7: Model editing**
 - *alpha8: Preferences + I/O + check updates* **<-- in progress**
 - *beta stage: Improve interface and renderer*
 - *rc stage: Polish the app*
 - *release: Done!*

## Download

Coming soon **Mac** and **Windows** version.

## Try it

To compile the project by yourself you need to set up some stuff

#### Haxelib

Install the needed libraries (and keep them updated)
````
haxelib install openfl
haxelib install hxColorToolkit
haxelib install format
haxelib install systools
haxelib git plik https://github.com/yupswing/plik.git
````

Rebuild systools for your platform (the project need to be revived!)
````
haxelib run lime rebuild systools [windows|mac|linux]
````

Clone this repository
````
git clone https://github.com/yupswing/TileCraft.git
````

And finally try to compile and run (need to use legacy OpenFL)

**Note**: NEKO is very slow, I strongly recommend to run native instead
````
cd tilecraft
haxelib run lime test [windows|mac|linux] -Dv2 -Dlegacy
````

*Notes*: Sadly systools has lots of problems so the native Open and Save Dialogs works perfectly only on Windows.

On Mac it works only the native save dialog (you have to put a path by hand if you want to open a model).

On Linux no native dialog works (you have to put a path by hand if you want to open a model).

## Examples

When you start the app there is a small icon on the top toolbar with a paper+arrow+64 (It means "Import model from Base64")

Click on it and `CTRL`+`V` or `CMD`+`V` one of this example models

##### A complex shape
````
Ff//1fb/QEW7PqXys9vuJDI/OVJXUpAjpswzUUY1p3At////9+F2vjJB33qSfoaPprO8Ezw5DkBLCjwAWldvAGlIj1CrKhJwRZrNMEtIzmJFGhKCq5rNAiNnvALNRc0CzXgSAiNFEgJ4Zj9MacxpDng7eEMS3gFD3t4BAy3eAUBF3gFDq+8B
````
##### A fancy home
````
Ev__1fb_QEW7PqXys9vuJDI_OVJXUpAjpswzUUY1x4J11M2l9fDJvjJB33qSfoaPprO8WzRo72tWaO9rjG2tWzdtrQk8bQgAaY0UQGl9Nghp3gAIPE0AWjeLrVk3TYtqjIutaYy9iwg8bZkwI94LMM3eCzDNVgsZNmh9
````
##### HOME (lostgarden test-case)
````
DP__1fb_QEW7PqXys9vuJDI_OVJXUpAjpswzUUY1x4J11M2l9fDJvjJB33qSfoaPprO8a4xdrVs3Xa0JPE0IAGmNFEBpfTYIad4ACDxNAFo3e61ZN02Laox7rWmMTYsIPF2Z
````
##### FACTORY (lostgarden test-case)
````
DP__1fb_QEW7PqXys9vuJDI_OVJXUpAjpswzUUY1x4J11M2l9fDJvjJB33qSpmxRprO8CS1tCAA1jRYIJt4ACC1NAAgtfZlLmt5FSIvNNkleIwlLi32rCy19qghpzUUIms1Z
````
##### STONE (lostgarden test-case)
````
CP__1fb_QEW7PqXys9vuJDI_OVJXUpAjpswzUUY1p3At6pA-9-F2vjJBY2tzfoaPoK66HTwqAh48KjUfPCpnPkQzZz6qRGc-u3dnPlWIZz5nVmc.
````
##### TREE (lostgarden test-case)
````
BP__1fb_QEW7PqXys9vuJDI_OVJXUpAjpswzUUY1p3At6pA-9-F2vjJBorAneocaoK66HTwqAh48KjUePCqbHTwqaA..
````
##### WOODCHUCK (lostgarden test-case)
````
DP__1fb_QEW7SGV9s9vuKztNOVJXUpAjpswzUUY1p3At6pA-9-F2vjJBorAneocaoK66FDwqGkRGmgFEm5oBQ0aaV0ObmldEVZpmRKqaZkQ2Vq5EnFauQqtWvUJFVr0ADwMK
````
##### An happy farm ;)
````
E____wAA____PqXys9vuJDI_OVJXUpAjpswzUUY1p3At6pA-9-F2vjJB33qSfoaPprO8OxK8AUo0qwFLq5oBO828ATgjNBg5IlUDOd1VAwgeVSIBigESMXoBIjGIAQExqgEBUYgAMzYRiAE2FCWbNiM0vBYFFpo27ncCNt40BA..
````

## Lostgarden challenge

The original idea for this tool comes from [lostgarden.com](http://www.lostgarden.com/2013/10/prototyping-challenge-3d-modeling-tool.html)

Here's the test-cases he provides to check the efficiency of the tool.

This were made in just five 5 minutes (all of them!)

![Test Cases](https://dl.dropboxusercontent.com/u/683344/akifox/tilecraft/git/test-cases.png)

# TODO

The tag in bold, before every entry, indicates at what stage that feature will be, hopefully, implemented.

 - General
  - [x] Check online for updates
  - [ ] **BETA** Housekeeping (make the whole more coherent)
  - [ ] **RC** Unified dispatcher
  - [ ] **RC** Online repository
  - [ ] **RC** Make sure everything got disposed/destroyed
  - [ ] **RC** Make sure every listener got removed
  - [ ] **RC** Look and fix every TODO in the code
  - [ ] **POST RELEASE** Support OpenFL3
 - Conversion of Java code to Haxe code
  - [x] Internal Model
  - [x] I/O + Base64 encoder/decoder *(improved in alpha4)*
  - [x] Renderer (Fast+Lights)
  - [x] GUInterface *(improved in alpha6)*
  - [x] Model wysiwyg editor
 - Renderer
  - [x] Convert LGModeler Renderer
  - [x] Output different size ( 0.5 , 0.25 , 0.125 )
  - [x] Fix incorrect rendering (ordering slices)
  - [x] POSTFX shaders (apply FXAA to have smooth output image)
  - [x] POSTFX make FXAA support alpha channel
  - [x] POSTFX Use normal scaling with no PostFx if opengl not supported
  - [x] Sync between renderers delays
  - [ ] **BETA** Support edge smoothing
  - [ ] **BETA** batch renderer and save to file
  - [ ] **BETA** Trick NORM to have N/E Ramps and rounded N/S edges
 - Model
  - [x] Convert LGModeler Model
  - [x] Support for PNG Output with embedded model data
  - [ ] **BETA** Add author and model name to PNG metadata
  - [ ] **BETA** Save enabled and lock to model data (tcMa)
  - [ ] **BETA** Permit change color0 and use it  as floor color (rendered)
  - [ ] **BETA** Add more primitives (Prism, Arc)
  - [ ] **BETA** Extend to 64 shapes
  - [ ] **RC** Extend model to 32 colors (use the other 16 as replacement for batch rendering)
 - Interface
  - [x] Resizable window
  - [x] ShapeList dragging to reorder shapes in model
  - [x] Add shape to model
  - [x] Clone shape
  - [x] I/O from string (Base64)
  - [x] Feedback on Load/Save/Boot/Errors
  - [x] Save/Load file
    - Windows: Save and load native dialogs
    - Mac: Save native + load textual (problems with systools)
    - Linux: Save and load textual (problems with systools)
  - [ ] **BETA**History (basic keep last 5 models as steps)
  - [ ] **BETA** Report error to the user via GUI
  - [ ] **BETA** Report waiting (render especially) with Thread (and GUI modal 'box')
  - [ ] **BETA** Minimap (Orthogonal Top and Side view)
  - [ ] **BETA** ALT (center transformation), SHIFT (keep it square), Rotation (single element, whole context)
  - [ ] **BETA** 90deg rotations (xyz) (changing positions and primitive type to simulate rotation)
  - [ ] **RC** Support light style scheme



  ## Utilities

  ### Conversion regexp from java to haxe

  ````
  (public|private) (static )?([a-z]+)([^{;]+\([^{]+)
  $1 $2function$4:$3
  ````
  ````
  (int|byte|float|boolean)\[\] ([a-z0-9]+)
  $2:Array<$1>
  ````
  ````
  (int|byte|float|boolean) ([a-z0-9]+)
  $2:$1
  ````
  ````
  \(Int\)
  Std.int
  ````
