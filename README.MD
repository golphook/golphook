```
golphook
========

    Another attempt to make a csgo internal for my personal use but this time written in V :)


Known issues
------------

    - memory leaks
    - exp texts are a bit shaky
    - aimbot don't shoot when too close
    - and other minor bugs

Features
---------
```
https://github.com/golphook/golphook/medias/menu.mp4

```
Build
-----

    - Install V
    - install MSVC
    - start a VS x86 powershell
    - git clone https://github.com/golphook/golphook && cd golphook
    - make new offsets with the hazedumper config in scripts/hazedumper
      and copy scripts/hazedumper/csgo.json to ressources/offsets.json
    - v run scripts/build_prod.vsh
      dll will be in build folder
```
