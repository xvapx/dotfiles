{ default, channels }:
with default; with channels;[
  nixos-unstable-small.retroarch        # Multi-system
  nixos-unstable-small.dolphin          # Nintendo Gamecube & Wii
  nixos-unstable-small.pcsx2            # Sony playstation 2
  (nixos-unstable-small.wine.override { # Microsoft windows
    wineRelease = "staging";
    wineBuild = "wineWow";
  })
  nixos-unstable-small.winetricks       # Microsoft windows
  nixos-unstable-small.playonlinux      # Microsoft windows
]