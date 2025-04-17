# ./hosts/thinkcenter-1/configuration.nix
{ config, pkgs, lib, specialArgs, ... }:
{
  imports = [
    # Role and Feature Modules
    ../../modules/k3s-worker.nix # Worker role
    ../../modules/tailscale.nix
    ../../modules/netdata.nix
  ];

  # --- Enable Features ---
  services.tailscale.enable = true;
  monitoring.netdata.enable = true;
  # k3s agent is enabled within its own module

  # --- Hardware Configuration for thinkcenter-1 ---
  # <<< ================================================================== >>>
  # <<< CRITICAL: FILL THIS SECTION WITH ACTUAL VALUES FOR thinkcenter-1     >>>
  # <<< Use 'lsblk -f' or /etc/nixos/hardware-configuration.nix for reference >>>
  # <<< ================================================================== >>>
  # Example structure below - REPLACE WITH REAL DATA!

  # boot.initrd.availableKernelModules = [ ... ];
  # boot.kernelModules = [ ... ];
  # boot.extraModulePackages = [ ... ];

  # fileSystems."/" = {
  #   device = "/dev/disk/by-uuid/THINKCENTER_ROOT_UUID"; # <<< Find correct UUID/Label/Path
  #   fsType = "ext4";
  # };
  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-uuid/THINKCENTER_BOOT_UUID"; # <<< Find correct UUID/Label/Path
  #   fsType = "vfat"; # If EFI
  # };
  # swapDevices = [ ... ];

  # boot.loader.grub = {
  #   enable = true;
  #   devices = [ "/dev/sda" ]; # <<< Find correct physical boot disk
  #   useOSProber = false;
  #   # efiSupport = true; # Set true if EFI
  # };
  # # boot.loader.efi.canTouchEfiVariables = true; # If EFI
  # boot.loader.systemd-boot.enable = false; # Disable if using GRUB

  # --- End Hardware Config Placeholder ---

  # --- Host Specific Settings ---
  networking.hostName = "thinkcenter-1"; # Matches hostname used in flake.nix
}
