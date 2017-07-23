{stdenv, callPackage}:

rec{

  name = "dotfiles";

  src = ./.;

  xvapx = callPackage ./xvapx {};
  nixos = callPackage ./nixos {};
}