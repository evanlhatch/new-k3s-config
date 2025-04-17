# flake.nix
{
  description = "NixOS K3s Cluster configuration using specific host names";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    deploy-rs.url = "github:serokell/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, deploy-rs, ... }@inputs:
  let
    lib = nixpkgs.lib;
    system = "x86_64-linux";

    # --- Define Hostnames ---
    controlPlaneHostname = "thinkpad-nixos";
    # Only include nodes with complete hardware configurations
    workerHostnames = [ "hetzner-1" ]; # "auslander-nixos" "thinkcenter-1"

    #trusted-users
    nix.settings.trusted-users = [ "root" "@wheel" "evan" ];


    # <<< VERIFY THIS IS YOUR CORRECT TAILNET NAME >>>
    tailnetName = "cinnamon-galaxy.ts.net";

    # --- Define Control Plane Address ---
    # Workers will use this to connect. Uses the control plane's Tailscale name.
    k3sControlPlaneAddr = "${controlPlaneHostname}.${tailnetName}";

    # --- Local Common Module (Applied to all hosts) ---
    commonBaseModule = { config, pkgs, lib, ... }: {
      system.stateVersion = "24.11";
      time.timeZone = "Etc/UTC";
      i18n.defaultLocale = "en_US.UTF-8";
      console.keyMap = "us";
      networking.useDHCP = lib.mkDefault true;
      services.openssh = {
        enable = true;
        settings = { PermitRootLogin = "prohibit-password"; PasswordAuthentication = false; };
      };
      users.users.root.openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRoa3k+/c6nIFLQHo4XYROMFzRx8j+MoRcrt0FmH8/BxAPpDH55SFMM2CY46LEH14M/+W0baSHhQjX//PEL93P5iN3uIlf9+I6aQr8Fi4F3c5susHqGmIWGTIEridVhEqzOQKDv/S9L1K3sDbjMYBXFyYo95dTIzYaJoxFsBF6cwxuscnKM/vb3eidYctZ61GukFvIkUTMRhO2KsEbc4RCslpTCdYgu7nkHiyCJZW7e37bRJ4AJwnjjX5ObP648wQ2UA0PpYLBUr0JQK6iQTAjwIHLNJheHYaGRf4IHP6sp9YSeY/IqnKMd4aEQd64Too1wMIsWyez9SIwgcH4fyNT"
      ];
      networking.firewall.enable = true;
      environment.systemPackages = with pkgs; [ git vim curl wget htop tmux ];
      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      nixpkgs.config.allowUnfree = true;
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
    # --- End Local Common Module ---

  in { # Start of main returned attrset

    nixosConfigurations =
      # Control Plane Definition
      { "${controlPlaneHostname}" = lib.nixosSystem {
          inherit system;
          # Pass args needed by modules (control plane doesn't need server addr)
          specialArgs = { inherit tailnetName; hostName = controlPlaneHostname; };
          modules = [
            commonBaseModule # Apply common settings
            ./hosts/${controlPlaneHostname}/configuration.nix # Host specific config + imports
          ];
        };
      }
      # Worker Definitions
      // (lib.listToAttrs (map (hostName: {
        name = hostName;
        value = lib.nixosSystem {
            inherit system;
            # Pass args needed by modules (workers need control plane addr)
            specialArgs = { inherit tailnetName k3sControlPlaneAddr; inherit hostName; };
            modules = [
              commonBaseModule
              ./hosts/${hostName}/configuration.nix
            ];
          };
        }) workerHostnames));

    # --- Deploy-rs Configuration ---
    deploy = {
      autoRollback = true;
      nodes =
        let
           # <<< VERIFY/SET DEPLOYMENT TARGETS & USERS FOR ALL HOSTS >>>
           deploymentMap = {
             "thinkpad-nixos" = { target = "100.109.40.58"; user = "nixos"; };
             "hetzner-1" = { target = "5.161.197.57"; user = "root"; };
             "auslander-nixos" = { target = "AUSLANDER_IP_OR_HOSTNAME"; user = "root"; }; # <<< SET THIS
             "thinkcenter-1" = { target = "THINKCENTER_IP_OR_HOSTNAME"; user = "root"; }; # <<< SET THIS
           };
        in lib.mapAttrs (hostName: config:
             let deploymentInfo = deploymentMap."${hostName}" or (throw "Missing deployment info for ${hostName}");
             in {
               hostname = deploymentInfo.target;
               sshUser = deploymentInfo.user;
               fastConnection = true;
               profiles.system = {
                 user = "root"; # Activation always runs as root
                 path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations."${hostName}";
               };
             }
           ) self.nixosConfigurations; # Iterate over all defined configurations
    };

    # --- Expose deploy-rs lib and checks ---
    packages.${system}.deploy-rs = deploy-rs.packages.${system}.deploy-rs;
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

  }; # End of main returned attrset
}
