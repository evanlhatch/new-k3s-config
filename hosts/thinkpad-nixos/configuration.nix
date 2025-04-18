# ./hosts/thinkpad-nixos/configuration.nix
{ config, pkgs, lib, specialArgs, modulesPath, ... }:
{
  imports = [
    # Role and Feature Modules
    ../../modules/k3s-control.nix
    ../../modules/tailscale.nix
    ../../modules/netdata.nix
    # REMOVED: (modulesPath + "/boot/loader/grub/grub.nix") - Not needed for systemd-boot
  ];

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
    # systemd-boot REQUIRES the ESP to be mounted at /boot
    device = "/dev/disk/by-uuid/12CE-A600";
    fsType = "vfat";
  };
  swapDevices = [ ];

  # --- Bootloader Config (Using systemd-boot for EFI) ---
  boot.loader.systemd-boot = {
    enable = true;
    # Configuration options for systemd-boot can go here if needed
    # e.g., consoleMode = "max";
  };

  # EFI settings are still relevant for systemd-boot
  boot.loader.efi = {
    canTouchEfiVariables = true;
    # efiSysMountPoint defaults to "/boot" which is standard for systemd-boot,
    # so explicitly setting it isn't usually required but doesn't hurt:
    # efiSysMountPoint = "/boot";
  };

  # Explicitly disable GRUB
  boot.loader.grub.enable = false;
  # --- End Bootloader Config ---

  # REMOVED: environment.variables.grub_PLATFORM - Not needed for systemd-boot

  # --- Host Specific Settings ---
  networking.hostName = "thinkpad-nixos"; # Matches hostname used in flake.nix
  # Other settings inherited from commonBaseModule in flake.nix
}
