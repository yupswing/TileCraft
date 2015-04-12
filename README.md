[![TileCraft](https://img.shields.io/badge/app-TileCraft%201.0.0%20alpha6-brightgreen.svg)]()
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

![alpha4](https://dl.dropboxusercontent.com/u/683344/akifox/tilecraft/git/interface.png)

## Alpha status

The project is in development stage. **!! Not fully working prototype !!**

The beta status will be reached on a full prototype.

## Todos

 - [ ] Conversion of Java code to Haxe code
   - [x] Internal Model
   - [x] I/O + Base64 encoder/decoder *(improved in alpha4)*
   - [x] Renderer (Fast+Lights)
   - [x] GUInterface
   - [ ] Model wysiwyg editor **<-- in progress**
 - General improvements
   - [x] save model to PNG (the output image include the model data)
   - [x] shaders (apply FXAA to have smooth output image)
   - [x] output different size
   - [ ] batch renderer and save to file
   - [ ] online repository (?)
   - [ ] history (basic keep last 5 models as steps)
 - Interface improvements
   - [ ] Copy, Paste, ALT (center transformation), SHIFT (keep it square), Rotation (single element, whole context)
   - [ ] Minimap (Orthogonal Top and Side view)
   - [ ] Trick NORM to have N/E Ramps and rounded N/S edges
   - [ ] Add more primitives (Prism, Arc)
   - [ ] 90deg rotations (xyz) (changing positions and primitive type to simulate rotation)

## Progress

 - **alpha:  Shape and model (load and save to Base64)**
 - **alpha2: Model renderer**
 - **alpha3: Lights renderer + postfx (Antialias+outline)**
 - **alpha4: Basic interface**
 - **alpha5: Save to PNG (image+model) and big housekeeping**
 - **alpha6: Shape list + improved gui**
 - alpha7: Model editing + dispatchers **<-- in progress**
 - beta stage

The model, renderer and i/o is fully functional ( [Same model in LGModeler](http://www.angryoctopus.co.nz/lgmodler/index.php?model=FQQA____Ezw5DkBLCjwAWldvAGlIj1CrKhJwRZrNMEtIzmJFGhKCq5rNAiNnvALNRc0CzXgSAiNFEgJ4Zg9MacxpDng7eEMS3gFD3t4BAy3eAUBF3gFDq-8B) )

(NEKO is very slow on light rendering, run native instead)

## Comparison with original LGmodeler renderer

### Model View Render (full)
![Comparison](https://dl.dropboxusercontent.com/u/683344/akifox/tilecraft/git/comparison.png)

### Final PNG Render
![Comparison](https://dl.dropboxusercontent.com/u/683344/akifox/tilecraft/git/rendercomparison.png)

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
