# retrop8

Intended to emulate the low-resolution rendering used by 3D PICO-8 programs like picoCAD, but in a way more comfortable for VR.
Hence, I use texels instead of screen pixels.

## Features
- Per-Texel shading + threshold slider
- Separate texture slots for lit / unlit state
- Optional dithered band between lit and shaded
- Cutout transparency + threshold slider
- Optional vertex snapping

Texel snapping based on Symm's Super Retro Shader code (MIT License)
- https://symmasolan.itch.io/srs

## Current Issues
- Lighting is not fully implemented, so the shader may appear excessively dark in some places.
- Ambient Light might not be calculated properly.
- There is no Opaque option, and only Cutout transparency.
