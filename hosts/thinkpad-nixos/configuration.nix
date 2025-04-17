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
  services.netdata.enable = true;
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
    };
    swapDevices = [ ];

    # --- Bootloader Config (Corrected for EFI) ---
    boot.loader.grub = {
      enable = true;
      # <<< VERIFY THIS DEVICE PATH IS CORRECT FOR THE THINKPAD (e.g., /dev/nvme0n1 or /dev/sda) >>>
      devices = [ "/dev/nvme0n1" ]; # Physical disk path
      useOSProber = false;
      # --- Key Fix for UEFI ---
      efiSupport = true; # Tell GRUB to install the EFI version
    };
    # This setting is needed for EFI systems to allow writing boot entries
    boot.loader.efi.canTouchEfiVariables = true;
    # Explicitly disable systemd-boot since we are using GRUB
    boot.loader.systemd-boot.enable = false;
    # --- End Bootloader Config ---

    # --- Host Specific Settings ---
    networking.hostName = "thinkpad-nixos"; # Matches hostname used in flake.nix
    # Other settings inherited from commonBaseModule in flake.nix
  }
