# ./hosts/thinkpad-nixos/configuration.nix
{ config, pkgs, lib, specialArgs, modulesPath, ... }: # Added modulesPath for consistency if needed later
{
  imports = [
    # Role and Feature Modules
    ../../modules/k3s-control.nix # Control plane role
    ../../modules/tailscale.nix
    ../../modules/netdata.nix
    # Note: Import from hardware-config (modulesPath + "/installer/scan/not-detected.nix") generally not needed here
  ];

  # --- Enable Features ---
  services.tailscale.enable = true;
  monitoring.netdata.enable = true;
  # k3s server is enabled within its own module

  # --- Hardware Configuration for thinkpad-nixos ---
  # Populated from provided hardware-configuration.nix output
  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/1e9bf502-7ca7-4c62-ab11-755a31c0724a";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/12CE-A600";
    fsType = "vfat";
    # options = [ "fmask=0022" "dmask=0022" ]; # Usually safe to omit
  };
  swapDevices = [ ];

  boot.loader.grub = {
    enable = true;
    # <<< VERIFY THIS DEVICE PATH on the actual Thinkpad (e.g., /dev/nvme0n1, /dev/sda) >>>
    devices = [ "/dev/nvme0n1" ]; # Guess based on 'nvme' module & EFI partition
    useOSProber = false;
    efiSupport = true; # Explicitly enable EFI support
  };
  boot.loader.efi.canTouchEfiVariables = true; # Needed for EFI installs
  boot.loader.systemd-boot.enable = false; # Disable systemd-boot if using GRUB

  # --- Host Specific Settings ---
  networking.hostName = "thinkpad-nixos"; # Matches hostname used in flake.nix
  # networking.useDHCP = true; # Set by commonBaseModule in flake.nix
  # nixpkgs.hostPlatform and hardware.cpu settings also inherited from commonBaseModule
}
