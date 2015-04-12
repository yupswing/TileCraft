[![TileCraft](https://img.shields.io/badge/app-TileCraft%201.0.0%20alpha7dev-brightgreen.svg)]()
[![MIT License](https://img.shields.io/badge/license-GNU%20GPL%203-blue.svg)](LICENSE)
[![Status](https://img.shields.io/badge/status-ALPHA-orange.svg)](#)

[![Haxe 3](https://img.shields.io/badge/language-Haxe%203-orange.svg)](http://www.haxe.org)
[![OpenFL 2](https://img.shields.io/badge/require-OpenFL 2-red.svg)](http://www.openfl.org)
[![Cross platform](https://img.shields.io/badge/platform-cross%20platform-lightgrey.svg)](http://www.openfl.org)

# TileCraft (alpha)
2.5D multi-platform modeler to make tiles

This project is a conversion to Haxe of Java LGMODELER

**(There are actually a lot of improvements!)**

Original project https://github.com/angryoctopus/lgmodeler

Original idea http://www.lostgarden.com/2013/10/prototyping-challenge-3d-modeling-tool.html

![Alpha6 Interface](https://dl.dropboxusercontent.com/u/683344/akifox/tilecraft/git/interface.png)

## Alpha status

The project is in development stage. **!! Not fully working prototype !!**

The beta status will be reached on a full prototype.

## Milestones

 - alpha:  Shape and model (load and save to Base64)
 - alpha2: Model renderer
 - alpha3: Lights renderer + postfx (Antialias+outline)
 - alpha4: Basic interface
 - alpha5: Save to PNG (image+model) and big housekeeping
 - alpha6: Shape list + improved gui
 - *alpha7: Model editing + dispatchers* **<-- in progress**
 - *beta stage: Improve interface and renderer*
 - *rc stage: Polish the app*
 - *release: Done!*


## Comparison with original LGmodeler renderer

The model, renderer and i/o is fully functional ( [Same model in LGModeler](http://www.angryoctopus.co.nz/lgmodler/index.php?model=FQQA____Ezw5DkBLCjwAWldvAGlIj1CrKhJwRZrNMEtIzmJFGhKCq5rNAiNnvALNRc0CzXgSAiNFEgJ4Zg9MacxpDng7eEMS3gFD3t4BAy3eAUBF3gFDq-8B) )

(NEKO is very slow on light rendering, run native instead)

### Model View Render (full)
![Comparison](https://dl.dropboxusercontent.com/u/683344/akifox/tilecraft/git/comparison.png)

### Final PNG Render
![Final render comparison](https://dl.dropboxusercontent.com/u/683344/akifox/tilecraft/git/rendercomparison.png)

# TODO
 - General
  - [ ] Unified dispatcher
  - [ ] **BETA** Housekeeping (make the whole more coherent)
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
  - [ ] Model wysiwyg editor **<-- in progress**
 - Renderer
  - [x] Convert LGModeler Renderer
  - [x] POSTFX shaders (apply FXAA to have smooth output image)
  - [x] output different size
  - [x] POSTFX make FXAA support alpha channel
  - [ ] **BETA** Fix incorrect Z rendering
  - [ ] **BETA** Support edge smoothing
  - [ ] **BETA** batch renderer and save to file
  - [ ] **BETA** Trick NORM to have N/E Ramps and rounded N/S edges
 - Model
  - [x] Convert LGModeler Model
  - [x] Support for PNG Output with embedded model data
  - [ ] **BETA** Add more primitives (Prism, Arc)
  - [ ] **BETA** Use color index 0 as floor color (if set)
  - [ ] **BETA** Extend to 64 shapes
  - [ ] **RC** Extend model to 32 colors (use the other 16 as replacement for batch rendering)
 - Interface
  - [ ] ShapeList dragging
  - [ ] Save/Load file (fix Dialogs)
  - [ ] I/O from string (Base64)
  - [ ] History (basic keep last 5 models as steps)
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
