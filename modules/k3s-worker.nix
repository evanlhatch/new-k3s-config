# ./modules/k3s-worker.nix
{ config, pkgs, lib, specialArgs, ... }:

{
  # Base system/SSH/firewall/pkgs handled by commonBaseModule in flake.nix

  # --- K3s Worker Configuration ---
  services.k3s = {
    enable = true;
    role = "agent";
    # k3sControlPlaneAddr passed via specialArgs from flake.nix
    serverAddr = "https://${specialArgs.k3sControlPlaneAddr}:6443";

    # Using tokenFile for secure token management (MUST MATCH SERVER)
    tokenFile = "${toString ../secrets/k3s.token}"; # Path to the K3s token file
  };

  # --- Worker Firewall Rules ---
  # Assumes networking.firewall.enable = true from commonBaseModule
  networking.firewall.allowedUDPPorts = lib.mkMerge [
    [ 8472 ] # Flannel VXLAN (default)
  ];

  # --- Worker Specific Packages ---
  environment.systemPackages = with pkgs; [
    kubectl # Often useful for debugging on the worker itself
  ];
}
