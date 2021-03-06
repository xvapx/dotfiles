{ config, pkgs, lib, ... }:

let
######################################## MACHINE

machine-name = "xvapx-homestation";

# The NixOS release to be compatible with for stateful data such as databases.
system.stateVersion = "unstable";

######################################## /MACHINE
######################################## CHANNELS

# Import channels
channels = import ../software/channels.nix;

# Default channel for this machine
default = channels.nixos-1703;

######################################## /CHANNELS
######################################## IMPORTS

in
{

  # Import configuration files
  imports = [ 
      # ENVIRONMENT
      ../env/xvapx.nix
      # LOCALIZATION
      ../localization/en_US-es.nix
      # USERS
      ../users/xvapx-home.nix
    ];

######################################## /IMPORTS
######################################## HARDWARE

  # Boot loader
  boot = {
    loader = {
      grub = {
        enable = true;
        version = 2;
        device = "/dev/sda";
        extraEntries = ''
          menuentry "Windows 7" {
            chainloader (hd0,1)+1
          }
        '';
      };
      timeout = 5;
    };
    initrd.availableKernelModules = [ 
      "ehci_pci" 
      "ata_piix" 
      "ahci" 
      "pata_jmicron" 
      "firewire_ohci" 
      "usbhid" 
      "usb_storage" 
      "sd_mod" 
      "sr_mod" 
      ];
    kernelModules = [ 
      "kvm-intel"
    ];
    extraModulePackages = [ ];
    # Clean /tmp on boot.
    cleanTmpDir = true;
  };

  # Devices
  hardware = {
    pulseaudio = {
      enable = true;
      support32Bit = true;
      package = pkgs.pulseaudioFull;
      zeroconf.discovery.enable = true;
    };
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
    bluetooth.enable = true;
    enableAllFirmware = true;
  };
  
  # File Systems
  fileSystems = [
    {
      mountPoint = "/";
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    }
    {
      mountPoint = "/mnt/data";
      device = "/dev/disk/by-label/data";
      fsType = "ntfs";
    }
    {
      mountPoint = "/mnt/projectes";
      device = "dev/disk/by-label/projectes";
      fsType = "ext4";
    }
    {
      mountPoint = "/mnt/windows";
      device = "/dev/sda2";
      fsType = "ntfs";
    }
  ];
  swapDevices = [
    { device = "/dev/disk/by-label/swap"; }
  ];
  systemd.automounts = [ {
    where = "/mnt/magatzem";
    wantedBy = [ "multi-user.target" ];
  } ];
  systemd.mounts = [ {
    what = "//192.168.1.10/magatzem";
    where = "/mnt/magatzem";
    type = "cifs";
    options = "ro,credentials=/home/xvapx/.credentials.servidor,iocharset=utf8";
  } ];
  
  # Network
  networking = {
    hostName = machine-name;
    interfaces.enp0s25.ip4 = [ { address = "192.168.1.40"; prefixLength = 24; } ];
    defaultGateway = "192.168.1.1";
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
    enableIPv6 = false;
    firewall = {
       enable = true;
       allowPing = true;
       allowedTCPPorts = [];
       allowedUDPPorts = [];
       allowedTCPPortRanges = [ { from = 0000; to = 0000; } ];
       allowedUDPPortRanges = [ { from = 0000; to = 0000; } ];
    };
  };

######################################## /HARDWARE
######################################## SOFTWARE

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [ ];

  };

  # List packages installed in system profile. 
  environment.systemPackages = with default; with channels;[

    # dotfiles
    dotfiles.xvapx
    dotfiles.nixos

    # dev
    openssl.dev
    python
    zlib.dev
    nixpkgs-master.android-studio

    # editors
    fontforge

    # files
    grive2
    transgui
    nixos-unstable-small.tribler

    # radio
    bluedevil

    # gamepads
    nixos-unstable-small.sdl-jstest
    nixos-unstable-small.qjoypad
    nixos-unstable-small.python27Packages.ds4drv

    # others
    googleearth
    tigervnc
    stow
  ]
  ++ import ../software/dev-base.nix { default = default; channels = channels; }
  ++ import ../software/editors-documents.nix { default = default; channels = channels; }
  ++ import ../software/editors-image.nix { default = default; channels = channels; }
  ++ import ../software/editors-modelling.nix { default = default; channels = channels; }
  ++ import ../software/editors-multimedia.nix { default = default; channels = channels; }
  ++ import ../software/emulators.nix { default = default; channels = channels; }
  ++ import ../software/games.nix { default = default; channels = channels; }
  ++ import ../software/multimedia.nix { default = default; channels = channels; }
  ++ import ../software/plasma5.nix { default = default; channels = channels; }
  ++ import ../software/social.nix { default = default; channels = channels; }
  ++ import ../software/system-cli.nix { default = default; channels = channels; }
  ++ import ../software/system-gui.nix { default = default; channels = channels; }
  ;

######################################## /SOFTWARE
######################################## FONTS

  fonts = {
    enableFontDir = true;
    enableCoreFonts = true;
    enableGhostscriptFonts = true;
    fontconfig = {
      defaultFonts = {
        monospace = [ "Noto Mono" ];
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

######################################## /FONTS
######################################## SERVICES

  # Enable the X11 windowing system, the displayManager and the desktopManager
  services.xserver = {
    enable = true;
    autorun = true;
    displayManager.sddm.enable = true;
    desktopManager.plasma5.enable = true;
    exportConfiguration = true;
    # graphics card driver. either "radeon", "ati_unfree" or "amdgpu-pro" for this machine
    videoDrivers = [ "amdgpu-pro" ]; 
    xrandrHeads = [ "DVI-0" "HDMI-0" ];
  };
  
  # ssh
  services.openssh.enable = true;
  programs.ssh.startAgent = true;

  # Android Debug Bridge
  programs.adb.enable = true;
  users.extraUsers.xvapx.extraGroups = [ "adbusers" ];
 
  # smartd to monitor HDD health
  services.smartd = {
    enable = true;
    devices = [
      { device = "/dev/sda"; options = "-d sat"; }
      { device = "/dev/sdb"; options = "-d sat"; }
    ];
    defaults.monitored = "-a -o on -S on -s (O/../.././(00|06|12|18)|S/../.././03|L/../../1/04) -W 5,35,45";
  };

  # redshift
  services.redshift = {
    enable = true;
    latitude = "41.421000";
    longitude = "2.155000";
  };

  # NixOS Manual
  services.nixosManual.showManual = true;

######################################## /SERVICES
######################################## MAINTENANCE

  # System Auto Upgrade
  system.autoUpgrade = {
    enable = true;
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

######################################## /MAINTENANCE
######################################## DOTFILES

  system.activationScripts = with default; with channels;{
    dotfiles = 
    ''
      # symlink all the files in $1 to $2, $1 needs to be an absolute path
      linkdir() {
        for f in $(find $1 -maxdepth 1 -type f -printf '%P\n'); do
          ln -s -b -v $1/$f $2/$f;
        done
      }

      # recursively symlink all the files in $1 to $2, $1 needs to be an absolute path
      reclink () {
        linkdir $1 $2
        for d in $(find $1 -type d -printf '%P\n'); do
          mkdir -p -v $2/$d;
          linkdir $1/$d $2/$d;
        done
      };

      reclink ${dotfiles.xvapx} /home/xvapx
      reclink ${dotfiles.xvapx} /root
      reclink ${dotfiles.nixos} /root

      unset -f reclink
      unset -f linkdir
    '';
  };
######################################## /DOTFILES
######################################## TESTS



######################################## /TESTS
######################################## SECURITY
security = {
  sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };
};
#security.hideProcessInformation = true;

######################################## /SECURITY
}