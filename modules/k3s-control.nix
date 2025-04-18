# ./modules/k3s-control.nix
{ config, lib, pkgs, specialArgs, ... }:

{
  # Base system/SSH/firewall/pkgs handled by commonBaseModule in flake.nix

  # --- K3s Server Configuration (Single Server Setup) ---
  services.k3s = {
    enable = true;
    role = "server";
    clusterInit = true; # This is the initializing server

    # Using tokenFile for secure token management
    #tokenFile = "${toString ../secrets/k3s.token}"; # Path to the K3s token file
    token = "_iw9Y4_PSJKVPJBo";

    extraFlags = toString [
      # Using default flannel CNI
      # Using default servicelb
      # Using default traefik
    ];
  };

  # --- Control Plane Firewall Rules ---
  # Assumes networking.firewall.enable = true from commonBaseModule
  networking.firewall.allowedTCPPorts = lib.mkMerge [
     [ 6443 ] # K8s API Server
  ];
  networking.firewall.allowedUDPPorts = lib.mkMerge [
     [ 8472 ] # Flannel VXLAN (default)
  ];

  # --- Control Plane Specific Packages ---
  environment.systemPackages = with pkgs; [
    kubectl # Needed to interact with the cluster
    kubernetes-helm # Needed for deploying K8s apps
  ];
}
