[![TileCraft](https://img.shields.io/badge/app-TileCraft%201.0.0%20alpha3-brightgreen.svg)]() <!--TODEPLOY-->
[![MIT License](https://img.shields.io/badge/license-GNU%20GPL%203-blue.svg)](LICENSE)
[![Status](https://img.shields.io/badge/type-Alpha-orange.svg)](#)

[![Haxe 3](https://img.shields.io/badge/language-Haxe%203-orange.svg)](http://www.haxe.org)
[![OpenFL 2](https://img.shields.io/badge/require-OpenFL 2-red.svg)](http://www.openfl.org)
[![Cross platform](https://img.shields.io/badge/platform-cross%20platform-lightgrey.svg)](http://www.openfl.org)

# TileCraft (alpha)

Conversion (and improvements) on LGMODELER (Java App) to Haxe

Original project https://github.com/angryoctopus/lgmodeler

Original idea http://www.lostgarden.com/2013/10/prototyping-challenge-3d-modeling-tool.html

## Alpha status

The project is in development stage. **!! Not fully working prototype !!**
The beta status will be reached on a full prototype.

## Todos

 - [ ] Conversion of Java code to Haxe code
   - [x] Internal Model
   - [x] I/O + Base64 encoder/decoder
   - [x] Renderer (Fast+Lights)
   - [ ] GUInterface **<-- in progress**
 - Interface mprovements
   - [ ] Copy, Paste, ALT (center transformation), SHIFT (keep it square), Rotation (single element, whole context)
   - [ ] Minimap (Fast top and Side view)
   - [ ] Trick NORM to have N/E Ramps and rounded N/S edges
   - [ ] Add more primitives (Prism, Arc)
   - [ ] 90deg rotations (xyz) changing positions and primitive type
 - Future improvements
   - [ ] shaders (apply FXAA to have smooth image)
   - [ ] output different size
   - [ ] batch renderer and save to file
   - [ ] online repository

## Progress

The model, renderer and i/o is fully functional
http://www.angryoctopus.co.nz/lgmodler/index.php?model=FQQA____Ezw5DkBLCjwAWldvAGlIj1CrKhJwRZrNMEtIzmJFGhKCq5rNAiNnvALNRc0CzXgSAiNFEgJ4Zg9MacxpDng7eEMS3gFD3t4BAy3eAUBF3gFDq-8B
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
