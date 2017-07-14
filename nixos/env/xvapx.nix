# env/xvapx.nix

{ config, pkgs, ... }:

{
  environment = {
    variables = {
      BROWSER = "google-chrome";
      PATH = "$PATH:/home/xvapx/.cargo/bin";
    };
    pathsToLink = [
      "/share"
    ];
  };
  programs.bash = {
    enableCompletion = true;
  };
}