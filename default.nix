{stdenv}:

stdenv.mkDerivation rec{

  name = "xvapx-dotfiles";

  src = ./.;

  phases = [ "unpackPhase" "buildPhase"];

  buildPhase = ''
    mkdir $out
    cp ./bash/bashrc $out/.bashrc
    cp ./bash/bash_profile $out/.bash_profile
    cp ./git/gitconfig $out/.gitconfig
    cp -r ./nixos $out/nixos
  '';
}