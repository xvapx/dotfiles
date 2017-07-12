{stdenv, callPackage}:

stdenv.mkDerivation rec{

	name = "xvapx-dotfiles";

  src = ./.;

	xvapx-dotfiles-bash = callPackage ./bash/default.nix {};
	xvapx-dotfiles-git = callPackage ./git/default.nix {};

	phases = [ "unpackPhase" "buildPhase"];

	buildPhase = ''
	  mkdir $out
    cp -sr ${xvapx-dotfiles-bash}/. $out
    cp -sr ${xvapx-dotfiles-git}/. $out
  '';
}