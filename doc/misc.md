# Miscellaneous notes

## Homebrew

## Mise

## OBS
- Output resolution to ABR:
  - 2408x1506: 2500 to 4000 Kbps
  - 2880x1800: 3350 to 5680 Kbps
  - 3072x1920: 3785 to 6418 Kbps
  - 3456x2234: 4920 to 8343 Kbps
  - 3840x2160: 9317 to 14767 Kbps

## SSH
- Generate new keys
  - RSA: `ssh-keygen -t rsa-sha2-512 -b 8192 -f id_rsa -C <hostname>`
  - ED25519: `ssh-keygen -t ed25519 -f id_ed25519 -C <hostname>`
- Set strict permissions
  - For the keys: `chmod u=r,g=,o= id_*`
  - For the folder where they're stored: `chmod u=rwx,g=,o= <folder>`
- Check the size of a RSA key: `ssh-keygen -l -f id_rsa.pub`

## Other
- Get Apple's CLI Tools version: `pkgutil --pkg-info=com.apple.pkg.CLTools_Executables`.
