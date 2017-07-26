# machines/xvapx-home-server.nix

{ config, pkgs, lib, ... }:

let
#################################### MACHINE

machine-name = "xvapx-server";

# The NixOS release to be compatible with for stateful data such as databases.
system.stateVersion = "17.03";

# Import channels
channels = import ../channels.nix;

#default channel for this machine
default = channels.nixos-1703;

#################################### /MACHINE
in
{
#################################### IMPORTS

  imports = [ 
      # ENVIRONMENT
      ../env/xvapx.nix
      # LOCALIZATION
      ../localization/en_US-es.nix
      # USERS
      ../users/xvapx-home.nix
      # TERMINAL SERVER
      ../software/terminal-server.nix
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
        5900   # terminal-server
        9091   # transmission RPC interface
        51413  # transmission
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

  nixpkgs.config = {
    allowUnfree = true;
    permittedInsecurePackages = [ ];
  };

  # List packages installed in system profile. To search by name, run:
  environment.systemPackages = with default; with channels;[

    # dotfiles
    dotfiles.xvapx
    dotfiles.nixos

    # dev
    git

    # editors
    emacs
    nano
    sublime3

    # browsers
    elinks
    chromium
    firefox

    # files
    grive2
    p7zip
    transmission_remote_gtk

    # system
    cifs_utils
    curl
    crashplan
    file
    gparted
    htop
    inotifyTools
    iptables
    lshw
    lsof
    manpages
    nmap
    nox
    pciutils
    posix_man_pages
    psmisc
    rsync
    screen
    samba
    smartmontools
    strace
    swt
    telnet
    tigervnc
    tree
    unrar
    usbutils
    wget
    xclip

    # security
    gnupg
  ];

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
      workgroup = VEGANS
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

      [downloads]
      comment = Downloads
      path = /mnt/magatzem/downloads
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
    desktopManager.default = "xfce";
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

  # Guests Wireless Access Point
  services.hostapd = {
    enable = true;
    interface = "wlp0s29f7u5";
    ssid = "invitados";
    channel = 3;
    wpa = true;
    wpaPassphrase = "Password Wifi 2017.";
  };

  # Transmission bittorrent
  services.transmission = {
    enable = true;
    settings = {
      download-dir = "/mnt/magatzem/downloads/transmission/complete";
      incomplete-dir =  "/mnt/magatzem/downloads/transmission/incomplete";
      incomplete-dir-enabled = true;
      rpc-whitelist = "127.0.0.1,192.168.1.*";
    };
  };

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
######################################## SECURITY
security = {
  sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };
};

######################################## /SECURITY
}
