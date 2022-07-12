# Improved Controls for Castlevania II: Belmont's Revenge (Gameboy)

*By NaOH*

## Patching Instructions

There are patches for each combination of rom (US/EU or JP) and for vcancel enabled/disabled (see "Functionality" below). Only one patch should be used.
Please note that the US and EU roms are the same. You may wish to verify your rom before patching by checking a hash (see "ROM HASHES" below).

Patch using FLIPS or any other IPS patcher. Please note that gameboy roms contain an internal checksum (which is not actually used by the gameboy!) -- this
patch does not modify the checksum, but if you so desire you may wish to correct the checksum using a utilitiy such as rgbfix.

## Functionality

This hack adjusts Christopher Belmont's control scheme to be more like Mega Man or Symphony of the Night

- Belmont can now turn around and stop in mid-air.
- Belmont regains control during knockback.
- (vcancel patches only!) When the jump button is released, Belmont immediately starts falling again; this allows the player to make smaller hops if desired.
- (inertia patches only!) When adjusting velocity in mid-air, Belmont only accelerates slowly (rather than changing direction instantaneously).

## Compatability with other hacks

Should be compatible with the speed hack: https://www.romhacking.net/hacks/213/ (apply the speed hack first.)

## ROM Hashes

US ROM:
    MD5: 7c65e9da405d2225d079f75e56276822
    SHA256: 17570ceec1b22153604622c4412d048dd8f7ccb4626daf9ddea96de8a062dbf2
    CRC32: 8875c8fe

JP ROM:
    MD5: 2be2472951eb4e25ab0c70fdee298130
    SHA256: 1e09b8dd7032db157a422d0b69cc6a384036a4ef560b08f5deed39a2fe0e21f8
    CRC32: 7582ae14