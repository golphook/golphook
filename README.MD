
# golphook

> Another attempt to make a csgo internal for my personal use but this time written in [V](https://vlang.io) :) it use [nuklear](https://github.com/TsudaKageyu/minhook) for the menu and [minhook](https://github.com/TsudaKageyu/minhook) for hooking

Known issues
------------

>- memory leaks
>- exp texts are a bit shaky
>- aimbot don't shoot when too close
>- chams are fucked up
>- and other minor bugs

Features
---------

https://user-images.githubusercontent.com/42607264/171994682-db28044a-38ea-4c95-bfcc-11fef6617254.mp4

Build
-----

>- Install V
>- install MSVC
>- start a VS x86 powershell
>- git clone https://github.com/golphook/golphook && cd golphook
>- make new offsets with the hazedumper config in scripts/hazedumper
   and copy scripts/hazedumper/csgo.json to ressources/offsets.json
>- v run scripts/build_prod.vsh
   dll will be in build folder

Resources
---------

>- https://github.com/withs/golphook.fun
>- https://github.com/danielkrupinski/Anubis
>- https://github.com/balenamiaa/rust-csgo

Medias
------

>- https://www.youtube.com/watch?v=-D-PYu_BezA
>- https://www.youtube.com/watch?v=ucogJGPj-Do

