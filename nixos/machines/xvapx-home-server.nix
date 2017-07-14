# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
#################################### MACHINE

machine-name = "xvapx-server";

channels = import ../channels.nix;

# The NixOS release to be compatible with for stateful data such as databases.
system.stateVersion = "17.03";

#default channel for this machine
default = channels.nixos-1703;

#################################### /MACHINE
in

{
#################################### IMPORTS

  imports = [ 
      # ENVIRONMENT
      ../environment.nix
      # LOCALIZATION
      ../localization.nix
      # USERS
      ../home-users.nix
    ];

#################################### /IMPORTS
#################################### HARDWARE

  # Boot loader
  boot = {
    loader = {
      grub = {
        enable = true;
        version = 2;
        devices = [ "/dev/sdb" ];
      };
      timeout = 5;
    };
    initrd.availableKernelModules = [ 
      "uhci_hcd"
      "ehci_pci" 
      "ata_piix" 
      "ahci" 
      "firewire_ohci" 
      "tifm_7xx1"
      "sd_mod" 
      "sr_mod" 
      "sdhci_pci"
      ];
    kernelModules = [ ];
    extraModulePackages = [ ];
    # Clean /tmp on boot.
    cleanTmpDir = true;
    kernel.sysctl = {
      # useful for miniDLNA
      "fs.inotify.max_user_watches" = 524288;
    };
  };

  # Devices
  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
    enableAllFirmware = true;
  };

  # File Systems
  fileSystems =  [ 
  {
    mountPoint = "/";
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
    neededForBoot = true;
  }
  {
     mountPoint = "/mnt/magatzem";
     device = "/dev/disk/by-label/magatzem";
     fsType = "ext4";
     neededForBoot = false;
  }  ];
  swapDevices = [
    { device = "/dev/disk/by-label/swap"; }
  ]; 

  # Network
  networking = {
    hostName = "servidor";
    interfaces.enp2s0.ip4 = [ { address = "192.168.1.10"; prefixLength = 24; } ];
    defaultGateway = "192.168.1.1";
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
    enableIPv6 = false;
    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ 
        22     # openssh
        443    # crashplan
        445    # Samba
        139    # Samba Netbios
        8200   # miniDLNA
        4242   # crashplan
        4243   # crashplan
      ];
      allowedUDPPorts = [ 
        137    # Samba Netbios Name Service
        138    # Samba Netbios Datagram Service
        139    # Samba Netbios Session Service
      ]; 
    };
  };

#################################### /HARDWARE
#################################### SOFTWARE

  # List packages installed in system profile. To search by name, run:
  environment.systemPackages = with pkgs; [
    chromium
    crashplan
    firefox
    file
    git
    gnupg
    gparted
    inotifyTools
    libreoffice
    lsof
    nmap
    rogue
    samba
    smartmontools
    swt
    telnet
    unrar
    vlc
    wget
  ];

  nixpkgs.config = import ./nixpkgs-config.nix;

#################################### /SOFTWARE
#################################### FONTS

  fonts = {
    enableFontDir = true;
    enableCoreFonts = true;
    enableGhostscriptFonts = true;
    fontconfig = {
      defaultFonts = {
        monospace = [ "Inconsolata" ];
        sansSerif = [ "Open Sans" ];
        serif     = [ "Linux Libertine" ];
      };
    };
    fonts = with default; with channels; [
      corefonts
      dejavu_fonts
      freefont_ttf
      google-fonts
      inconsolata
      libertine
      opensans-ttf
      terminus_font 
      unifont
    ];
  };

#################################### /FONTS
#################################### SERVICES

  # Pulseaudio
  hardware.pulseaudio.enable = true;

  # Samba server
  services.samba = {
    enable = true;
    securityType = "user";
    extraConfig = ''
      [global]
      workgroup = HOME
      server string = servidor
      netbios name = servidor
      interfaces = enp2s0
      invalid users = root admin
      encrypt passwords = yes
      log level = 3
      max log size = 1000
      unix password sync = yes
      printcap name = /dev/null
      load printers = no
      printing = bsd 

      [magatzem]
      comment = magatzem
      path = /mnt/magatzem/public
      browseable = yes
      read only = yes
      guest ok = no
      valid users = SMBread SMBwrite
      read list = SMBread 
      write list = SMBwrite
      create mask = 0755
      directory mask = 0755
    '';
  };

  #miniDLNA
  services.minidlna = {
    enable = true;
    mediaDirs = [ "V,/mnt/magatzem/public/Video" "A,/mnt/magatzem/public/Audio" ];
    config = ''
      network_interface=enp2s0
      friendly_name=Servidor
      notify_interval=60
      inotify=yes
      listening_ip=192.168.1.10
      serial=12345678
      model_number=1
      log_level=debug
      force_sort_criteria=+upnp:class,+upnp:originalTrackNumber,+dc:title
    '';
  };
  users.extraUsers.minidlna = {
    extraGroups = [ "SMBread" ];
  };  

  # X11
  services.xserver = {
    enable = true;
    autorun = true;
    displayManager.lightdm.enable = true;
    desktopManager.xfce.enable = true;
    exportConfiguration = true;
    # touchpad
    synaptics.enable = true;
  };

  # Manual
  services.nixosManual.showManual = true;

  # Crashplan
  services.crashplan.enable = true;

  # openssh
  services.openssh = {
    enable = true;
    forwardX11 = true;
  };

  # smartd
  services.smartd = {
    enable = true;
    devices = [
      { device = "/dev/sda"; options = "-d sat"; }
      { device = "/dev/sdb"; options = "-d sat"; }
      { device = "/dev/sdc"; options = "-d sat"; }
    ];
    defaults.monitored = "-a -o on -S on -s (O/../.././(00|06|12|18)|S/../.././03|L/../../1/04) -W 5,35,45";
  };

  # avoid suspending when closing the lid
  services.logind.extraConfig = "HandleLidSwitch=ignore";

  # Wireless Access Point
  #services.hostapd = {
  #  enable = true;
  #  interface = "wlp0s29f7u5";
  #  ssid = "invitados";
  #  channel = 3;
  #  wpa = true;
  #  wpaPassphrase = "Hunter2"; 
  #};

#################################### /SERVICES
#################################### MAINTENANCE

  # System Auto Upgrade
  system.autoUpgrade = {
    enable = true;
    channel = https://nixos.org/channels/nixos-17.03;
  };

  # Garbage collection, store optimisation & nixPath
  nix = {
    extraOptions = "auto-optimise-store = true";
    gc = {
      automatic = true;
      dates = "02:00";
      options = "--delete-older-than 20d";
    };
    # Use sandbox to build packages
    useSandbox = true;
    maxJobs = lib.mkDefault 4;
    buildCores = 0;
    readOnlyStore = true;
    trustedBinaryCaches = [
      https://cache.nixos.org
      https://hydra.nixos.org
    ];
    binaryCachePublicKeys = [
      "hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs="
    ];
  };

  # Max journald log size
  services.journald.extraConfig = ''
    SystemMaxUse=100M
  '';  

#################################### /MAINTENANCE

}