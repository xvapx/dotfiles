# machines/xvapx-homestation.nix

{ config, pkgs, lib, ... }:

let
######################################## MACHINE

machine-name = "xvapx-homestation";

# The NixOS release to be compatible with for stateful data such as databases.
system.stateVersion = "unstable";

# Import channels
channels = import ../software/channels.nix;

#default channel for this machine
default = channels.nixos-1703;

######################################## /MACHINE
in
{
######################################## IMPORTS

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
      # See console messages during early boot.
      #"fbcon" 
    ];
    # Disable console blanking after being idle.
    #kernelParams = [ "consoleblank=0" ];
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

    # dev
    automake
    binutils
    clang
    cmake
    gcc
    gdb
    git
    gnumake
    llvm
    openssl.dev
    pkgconfig
    subversion
    zlib.dev

    # editors
    audacity
    emacs
    blender
    gimp
    inkscape
    krita
    libreoffice
    openscad
    qtcreator
    sublime3

    # browsers
    elinks
    firefox
    google-chrome

    # multimedia
    nixos-unstable-small.clementine
    comical
    ffmpeg
    geeqie
    nixos-unstable-small.tribler
    vlc
    mupdf

    # files
    bashburn
    brasero
    cdrkit
    grive2

    # system
    cabextract
    cifs_utils
    conky
    curl
    dmidecode
    file
    gist
    glxinfo
    gparted
    hddtemp
    htop
    iptables
    lshw
    lsof
    manpages
    nix-prefetch-scripts
    nmap
    nox
    ntfs3g
    pciutils
    posix_man_pages
    psmisc
    lm_sensors
    radeontop
    rsync
    screen
    smartmontools
    strace
    telnet
    tree
    usbutils
    #nixpkgs-master.vulnix #fails to download zope.testing
    wget
    xclip
    xdotool
    p7zip

    # KDE plasma
    ark
    bluedevil
    dolphin
    ffmpegthumbs
    frameworkintegration
    kde-gtk-config
    gwenview
    okular
    kate
    kactivitymanagerd
    kcalc
    kdeplasma-addons
    kinfocenter
    kmenuedit
    konsole
    kscreen
    ksysguard
    oxygen
    oxygen-icons5
    plasma-workspace-wallpapers

    # games
    crawlTiles
    rogue
    (steam.override { newStdcpp = true; })
    (steam.override { nativeOnly = true; newStdcpp = true; }).run

    # emulators
    nixos-unstable-small.retroarch                      # multi-system
    nixos-unstable-small.dolphin                        # nintendo gamecube, wii
    nixos-unstable-small.pcsx2                          # sony playstation 2
    (nixos-unstable-small.wine.override {              # microsoft windows
      wineRelease = "staging";
      wineBuild = "wineWow";
    })
    nixos-unstable-small.winetricks

    # gamepads
    nixos-unstable-small.sdl-jstest
    nixos-unstable-small.qjoypad
    nixos-unstable-small.python27Packages.ds4drv

    # security
    gnupg
    keepass

    # social
    hexchat

    # others
    googleearth
  ];

######################################## /SOFTWARE
######################################## FONTS

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
 
  # smartd to monitor HDD health
  services.smartd = {
    enable = true;
    devices = [
      { device = "/dev/sda"; options = "-d sat"; }
      { device = "/dev/sdb"; options = "-d sat"; }
    ];
    defaults.monitored = "-a -o on -S on -s (O/../.././(00|06|12|18)|S/../.././03|L/../../1/04) -W 5,35,45";
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
    useSandbox = false;
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

      # recursively symlink all the files in $1 to $2
      reclink () {
        linkdir $1 $2
        for d in $(find $1 -type d -printf '%P\n'); do
          mkdir -p -v $2/$d;
          linkdir $1/$d $2/$d;
        done
      };

      reclink ${dotfiles.xvapx} /home/xvapx
      reclink ${dotfiles.xvapx} /root

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