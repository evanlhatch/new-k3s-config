# ./modules/tailscale.nix
{ config, lib, pkgs, specialArgs, ... }: # Added specialArgs to get tailnetName

{
  # Config block active if services.tailscale.enable = true in host file
  config = lib.mkIf config.services.tailscale.enable {

    services.tailscale = {
      # enable = true; # This is the trigger condition
      # Using authKeyFile for secure key management
      authKeyFile = "/run/secrets/tailscale.key"; # Path to the Tailscale auth key
      extraUpFlags = [ "--ssh" "--accept-routes" "--accept-dns=true" ];
    };

    networking = {
      firewall = {
        # Firewall enabled by commonBaseModule
        # Using lib.mkMerge to combine firewall ports safely with other modules
        allowedUDPPorts = lib.mkMerge [ [ config.services.tailscale.port ] ]; # Default 41641
        trustedInterfaces = lib.mkMerge [ [ "tailscale0" ] ];
        checkReversePath = lib.mkDefault "loose"; # Set default, can be overridden
      };
      # MagicDNS search domain - Use specialArgs for consistency
      search = [ "${specialArgs.tailnetName}" ];
    };

    services.resolved = {
      enable = true; # Ensure resolved itself is enabled
      # Use specialArgs for consistency
      domains = [ "~${specialArgs.tailnetName}" ];
    };

    # Ensure Tailscale package is installed
    environment.systemPackages = [ pkgs.tailscale ];
  };
}
