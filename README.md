# Tilecraft

Conversion (and improvements) on LGMODELER (Java App) to Haxe

Original project https://github.com/angryoctopus/lgmodeler

Original idea http://www.lostgarden.com/2013/10/prototyping-challenge-3d-modeling-tool.html

## Todos

 - [ ] Conversion of Java code to Haxe code
   - [x] Internal Model
   - [x] I/O + Base64 encoder/decoder
   - [x] Renderer (Fast+Lights)
   - [ ] Interface **<-- in progress**
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

![Comparison](https://dl.dropboxusercontent.com/u/683344/akifox/tilecraft/git/comparison.png)



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
