
{stdenv}:

stdenv.mkDerivation {

	name = "xvapx-dotfiles-git";

  src = ./.;

  phases = [ "unpackPhase" "buildPhase"];

  buildPhase = ''
    mkdir $out
    cp .gitconfig $out/
    '';
}
