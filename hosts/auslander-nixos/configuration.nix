# ./hosts/auslander-nixos/configuration.nix
{ config, pkgs, lib, specialArgs, ... }:
{
  imports = [
    # Role and Feature Modules
    ../../modules/k3s-worker.nix # Worker role
    ../../modules/tailscale.nix
    ../../modules/netdata.nix
  ];

  # --- Hardware Configuration for auslander-nixos ---
  # <<< ================================================================= >>>
  # <<< CRITICAL: FILL THIS SECTION WITH ACTUAL VALUES FOR auslander-nixos  >>>
  # <<< Use 'lsblk -f' or /etc/nixos/hardware-configuration.nix for reference >>>
  # <<< ================================================================= >>>
  # Example structure below - REPLACE WITH REAL DATA!

  # boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" ... ];
  # boot.kernelModules = [ ... ];
  # boot.extraModulePackages = [ ... ];

  # fileSystems."/" = {
  #   device = "/dev/disk/by-partuuid/YOUR-AUSLANDER-ROOT-PARTUUID"; # <<< Find correct UUID/Label/Path
  #   fsType = "ext4"; # Or btrfs, etc.
  # };
  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-uuid/YOUR-AUSLANDER-BOOT-UUID"; # <<< Find correct UUID/Label/Path
  #   fsType = "vfat"; # Usually vfat for EFI
  # };
  # swapDevices = [ ... ];

  # boot.loader.grub = {
  #   enable = true;
  #   devices = [ "/dev/nvme0n1" ]; # <<< Find correct physical boot disk (e.g., /dev/sda)
  #   useOSProber = false;
  #   efiSupport = true; # Set true if EFI
  # };
  # boot.loader.efi.canTouchEfiVariables = true; # If EFI
  # boot.loader.systemd-boot.enable = false; # Disable if using GRUB

  # --- End Hardware Config Placeholder ---

  # --- Host Specific Settings ---
  networking.hostName = "auslander-nixos"; # Matches hostname used in flake.nix
}
