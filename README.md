# Improved Controls & Subweapons Hack for Castlevania II: Belmont's Revenge

This repository contains the source code that allows patching *Castlevania II: Belmont's Revenge* to enable the following features:

 - Improved Controls: allow the player to change direction in mid-air
 - Subweapons: introduces all three subweapons (axe, holy water, and cross) into the US/EU rom.
 
There are two asm sources: `patch.asm` and `patch-us.asm`. The former provides only the air-control changes (but is compatible with EU/US, JP, and KGBC4EU roms), whereas the `patch-us.asm` provides both air-control changes *and* the three subweapons (however, it is only compatible with the EU/US rom.)

To build, run `./build.sh` in bash. [z80asm](https://linux.die.net/man/1/z80asm) is required (Ubuntu: `apt install z80asm`).