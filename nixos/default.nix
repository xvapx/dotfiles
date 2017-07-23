{stdenv}:

stdenv.mkDerivation rec{

  name = "nixos";

  src = ./.;

  phases = [ "unpackPhase" "buildPhase"];

  buildPhase = ''
    mkdir $out
    cp -r . $out
  '';
}