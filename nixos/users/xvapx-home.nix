# users/xvapx-home.nix

{ config, pkgs, ... }:

{  
  users = {
  	# disable mutable users
  	#mutableUsers = false;
  	# Groups
    extraGroups = {
      SMBread.gid = 1999;
    };
    # Users
    extraUsers = {
      admin =  {
        description = "Administrador";
        isNormalUser = true;
        uid = 1000;
        createHome = true;
        home = "/home/admin";
        extraGroups = [ "wheel" "networkmanager" "SMBread" ];
      };
   		xvapx = {
  	    description = "XvapX";
  		  isNormalUser = true;
  		  uid = 1030;
  		  createHome = true;
  		  home = "/home/xvapx";
  		  extraGroups = [ "wheel" ];
      };
      iguana = {
        description = "Iguana";
        isNormalUser = true;
        uid = 1031;
        home = "/home/iguana";
        extraGroups = [ "wheel" ];
      };
      SMBread = {
        isNormalUser = true;
        home = "/home/SMBread";
        description = "Samba read-only user";
        group = "SMBread";
        uid = 1999;
      };
      SMBwrite = {
        isNormalUser = true;
        home = "/home/SMBwrite";
        description = "Samba admin user";
        group = "SMBread";
        uid = 2000;
      };
	  };
  };
}
