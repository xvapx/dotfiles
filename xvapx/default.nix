{stdenv}:

stdenv.mkDerivation rec{

  name = "xvapx";

  src = ./.;

  phases = [ "unpackPhase" "buildPhase"];

  buildPhase = ''
    mkdir $out
    cp ./bash/bashrc $out/.bashrc
    cp ./bash/bash_profile $out/.bash_profile
    cp ./git/gitconfig $out/.gitconfig
    mkdir -p $out/.config/conky
    cp ./conky/conky.conf $out/.config/conky/conky.conf
    mkdir -p $out/.config/autostart
    cp ./conky/conky.desktop $out/.config/autostart/conky.desktop
  '';
}