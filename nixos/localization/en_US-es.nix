# XvapX localization.nix

{ config, pkgs, ... }:

{
  i18n = {
    consoleFont = "lat0-16";
    consoleKeyMap = "es";
    defaultLocale = "en_US.UTF-8";
  };
  time.timeZone = "Europe/Madrid";

  services.xserver.layout = "es";
  services.xserver.xkbOptions = "eurosign:e";
}