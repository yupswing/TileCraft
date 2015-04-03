# Tilecraft

Conversion (and improvements) on LGMODELER (Java App) to Haxe

Original project https://github.com/angryoctopus/lgmodeler

Original idea http://www.lostgarden.com/2013/10/prototyping-challenge-3d-modeling-tool.html

## Todos

[ ] Conversion of Java code to Haxe code <-- in progress
[ ] Interface improvements
[ ] 90deg rotations (xyz) changing positions and primitive type

## Utilities

### Conversion regexp from java to haxe

````
(public|private) (static )?([a-z]+)([^{;]+\([^{]+)
$1 $2 function$4:$3
````
````
(int|byte|float|boolean) ([a-z0-9]+)
$2:$1
````
````
\(Int\)
Std.int
````
