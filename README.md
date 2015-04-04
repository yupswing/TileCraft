# Tilecraft

Conversion (and improvements) on LGMODELER (Java App) to Haxe

Original project https://github.com/angryoctopus/lgmodeler

Original idea http://www.lostgarden.com/2013/10/prototyping-challenge-3d-modeling-tool.html

## Todos

 - [ ] Conversion of Java code to Haxe code <-- in progress
 - [ ] Interface improvements
 - [ ] 90deg rotations (xyz) changing positions and primitive type

## Progress

Renderer translated (and minor fixes)

It looks almost the same as the original one


#### This is the test Model
http://www.angryoctopus.co.nz/lgmodler/index.php?model=FAQA____Ezw5DkBLCjwAWldvAGlIj1CrKhJwRZrNMEtIzmJFGhKCq5rNAiNnvALNRc0CzXgSAiNFEgJ4Zg9MacxpDng7eAoPDwBDEt4BQ97eAQMt3gE.
(NEKO is very slow on light rendering, run native instead)

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
