{ config, lib, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  networking.hostName = "metish-ash-1"; # Define your hostname.
  time.timeZone = "Etc/UTC";

  environment.variables = { EDITOR = "vim"; };

  users.users.jesse = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC/6SEKFvypDDNb14MhmZ7M4FfuCWWrsKuoOInnEpCr5 jrmather@proton.me"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIC6QJwYzI3GH5CHEf/J/s8RiMME9FcSDsVLypqi08lsc jesse2metish.io"
    ];
  };

  security.sudo.extraRules = [
      { groups = [ "wheel" ]; commands = [ { command = "ALL"; options = [ "NOPASSWD" ]; } ]; }
  ];

  networking.firewall.allowedTCPPorts = [ 22 80 443 8080 8443 ];

  services.openssh.enable = true;
  services.fail2ban.enable = true;

  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    ripgrep
    ((vim_configurable.override {  }).customize{
      name = "vim";
      vimrcConfig.packages.myplugins = with pkgs.vimPlugins; {
        start = [ vim-nix vim-lastplace ];
        opt = [];
      };
      vimrcConfig.customRC = ''
        set expandtab
        set tabstop=2
        set softtabstop=2
        set shiftwidth=2
      '';
    })
  ];

  system.stateVersion = "24.05";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
