
{stdenv}:

stdenv.mkDerivation {

	name = "xvapx-dotfiles-bash";

  src = ./.;

  phases = [ "unpackPhase" "buildPhase"];

  buildPhase = ''
    mkdir $out
    cp .bashrc $out/
    cp .bash_profile $out/
    '';
}
