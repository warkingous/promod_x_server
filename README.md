# PROMOD X SERVER FILES

This repository contains essential files for setting up a CoD4X Server with FPS Promod.

## Required cod4x18_dedrun binary

```bash
You must use provided cod4x18_dedrun for extra demo functionality
```

## Required Shared Libraries for plugins

```bash
move libphobos2.so.0.100 to /usr/lib
```

## Required Server Commands

```bash
// Plugins must be called first
loadplugin fps_h
loadplugin fps_m
loadplugin fps_i
loadplugin fps_d
loadplugin fps_a

// Xasset limit
set r_xassetnum "image=3000 material=2560 xmodel=1200 xanim=3200"

// Rest settings
set g_friendlyPlayerCanBlock 1
set g_FFAPlayerCanBlock 1
set sv_autodemorecord 0
set sv_steamforce 1
set promod_mode "knockout"

// Mod
set fs_game mods/fps_promod_275

```


