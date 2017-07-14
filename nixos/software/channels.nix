# software/channels.nix

rec {
  # nixos 17.03
  nixos-1703 = import (fetchTarball http://nixos.org/channels/nixos-17.03/nixexprs.tar.xz) {};

  # nixos unstable
  nixos-unstable = import (fetchTarball http://nixos.org/channels/nixos-unstable/nixexprs.tar.xz) {};

  # nixos unstable-small
  nixos-unstable-small = import (fetchTarball http://nixos.org/channels/nixos-unstable-small/nixexprs.tar.xz) {};

  # nixpkgs unstable
  nixpkgs-unstable = import (fetchTarball https://github.com/nixos/nixpkgs-channels/archive/nixpkgs-unstable.tar.gz) {};

  # nixpkgs master
  nixpkgs-master = import (fetchTarball https://github.com/NixOS/nixpkgs/archive/master.tar.gz) {};

  # xvapx stable
  xvapx-stable = import (fetchTarball https://github.com/xvapx/nixpkgs/archive/xvapx/stable.tar.gz) {};

  # xvapx testing
  xvapx-testing = import (fetchTarball https://github.com/xvapx/nixpkgs/archive/xvapx/testing.tar.gz) {};

  # Local nixpkgs
  local-nixpkgs = import (/mnt/projectes/nixpkgs) {};

  # xvapx dotfiles
  dotfiles = import (fetchTarball https://github.com/xvapx/nixos-dotfiles/archive/master.tar.gz) {};

  # Local dotfiles
  #local-dotfiles = import (/mnt/projectes/nixos-dotfiles) {};

}