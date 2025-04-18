# ./hosts/hetzner-1/configuration.nix
{ config, pkgs, lib, specialArgs, modulesPath, ... }: # Added modulesPath for qemu profile
{
  imports = [
    # Role and Feature Modules
    ../../modules/k3s-worker.nix # Worker role
    ../../modules/tailscale.nix
    ../../modules/netdata.nix

    # Profile from hardware-configuration.nix
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  # --- Hardware Configuration for hetzner-1 ---
  # Populated from provided hardware-configuration.nix output
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
  boot.initrd.kernelModules = [ "nvme" ]; # Keeping nvme as it was listed
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/sda1"; # Using device path as specified
    fsType = "ext4";
  };
  # No separate /boot partition specified
  swapDevices = [ ]; # Explicitly empty

  # Bootloader config - GRUB on /dev/sda as specified
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda"; # Set directly from hardware config
    useOSProber = false;
  };
  boot.loader.systemd-boot.enable = false; # Disable systemd-boot if using GRUB

  # --- Host Specific Settings ---
  networking.hostName = "hetzner-1"; # Matches hostname used in flake.nix
  # networking.useDHCP = true; # Set by commonBaseModule in flake.nix
  # nixpkgs.hostPlatform inherited from commonBaseModule
}
