[![TileCraft](https://img.shields.io/badge/app-TileCraft%201.0.0%20alpha8dev-brightgreen.svg)]()
[![MIT License](https://img.shields.io/badge/license-GNU%20GPL%203-blue.svg)](LICENSE)
[![Status](https://img.shields.io/badge/status-ALPHA-orange.svg)](#)

[![Haxe 3](https://img.shields.io/badge/language-Haxe%203-orange.svg)](http://www.haxe.org)
[![OpenFL 2](https://img.shields.io/badge/require-OpenFL 2-red.svg)](http://www.openfl.org)
[![Cross platform](https://img.shields.io/badge/platform-cross%20platform-lightgrey.svg)](http://www.openfl.org)

# TileCraft (alpha)
2.5D multi-platform modeler to make tiles

Based on [LGModeler](https://github.com/angryoctopus/lgmodeler) by [AngryOctupus](http://www.angryoctopus.co.nz/)

Original idea from [lostgarden.com](http://www.lostgarden.com/2013/10/prototyping-challenge-3d-modeling-tool.html)

![Alpha8 Interface](https://dl.dropboxusercontent.com/u/683344/akifox/tilecraft/git/interface.png)

## Alpha status

The project is in development stage. **!! Not fully working prototype !!**
(Basically missing some dialogs to save and load files)

The beta status will be reached on a full prototype.

## Try it

Right now if you want to try it download this project and download also the [PLIK library](https://github.com/yupswing/plik). Then set PLIK on haxelib
````
haxelib dev plik path/to/plik
````
then cd to tilecraft and run with
````
lime test mac/windows/linux -Dv2 -Dlegacy
````

**Note**: NEKO is very slow on light rendering, run native instead

**Note**: Save and load are functional but they always point to a file in /var/tmp (only mac/linux) because of troubles with *systool.Dialogs*

**Note**: There are some premade model inside the code. Just comment/uncomment the lines [here](src/TileCraft.hx#L114).

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


## Lostgarden challenge

The original idea for this tool comes from [lostgarden.com](http://www.lostgarden.com/2013/10/prototyping-challenge-3d-modeling-tool.html)

Here's the test-cases he provides to check the efficiency of the tool.

This were made in just five 5 minutes (all of them!)

![Test Cases](https://dl.dropboxusercontent.com/u/683344/akifox/tilecraft/git/test-cases.png)

# TODO
 - General
  - [x] Check online for updates
  - [ ] **BETA** Housekeeping (make the whole more coherent)
  - [ ] **RC**Unified dispatcher
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
  - [ ] **BETA** Support edge smoothing
  - [ ] **BETA** batch renderer and save to file
  - [ ] **BETA** Trick NORM to have N/E Ramps and rounded N/S edges
 - Model
  - [x] Convert LGModeler Model
  - [x] Support for PNG Output with embedded model data
  - [ ] **BETA** Add author and model name to PNG metadata
  - [ ] **BETA** Save enabled and lock to model data (tcMa)
  - [ ] **BETA** Permit change color0 to be used as floor (and render it)
  - [ ] **BETA** Add more primitives (Prism, Arc)
  - [ ] **BETA** Use color index 0 as floor color (if set)
  - [ ] **BETA** Extend to 64 shapes
  - [ ] **RC** Extend model to 32 colors (use the other 16 as replacement for batch rendering)
 - Interface
  - [x] Resizable window
  - [x] ShapeList dragging to reorder shapes in model
  - [x] Add shape to model
  - [x] Clone shape
  - [ ] Save/Load file (fix Dialogs) **TODO TO GO BETA**
  - [ ] I/O from string (Base64) **TODO TO GO BETA**
  - [ ] History (basic keep last 5 models as steps) **TODO TO GO BETA**
  - [ ] **BETA** Report error to the user via GUI
  - [ ] **BETA** Report waiting (render especially) with Thread (and GUI modal 'box')
  - [ ] **BETA** Minimap (Orthogonal Top and Side view)
  - [ ] **BETA** Copy, Paste, ALT (center transformation), SHIFT (keep it square), Rotation (single element, whole context)
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
