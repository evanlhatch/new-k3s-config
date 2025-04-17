# ./modules/netdata.nix
{ config, pkgs, lib, ... }:

{
  # Netdata configuration module
  config = {
    # The services.netdata.enable option is set in the host configuration files
    services.netdata = {
      # Configuration applied when netdata is enabled
      config = {
        "global" = {
          "update every" = 1;
          "memory mode" = "dbengine";
          "page cache size" = 32;
          "dbengine multihost disk space" = 256;
        };
        "web" = {
          "default port" = 19999;
          # Consider restricting further if nodes have public exposure
          "allow connections from" = "localhost *"; # Allow Tailscale/local
          "allow dashboard from" = "localhost *"; # Allow Tailscale/local
        };
        "plugins" = {
          "apps" = "yes"; "cgroups" = "yes"; "diskspace" = "yes";
          "proc" = "yes"; "python.d" = "yes"; "tc" = "no"; "go.d" = "yes";
        };
      };
      python.enable = true;
      python.recommendedPythonPackages = true;
      enableAnalyticsReporting = false;
    };

    # Merge Netdata firewall port with others using lib.mkMerge
    networking.firewall.allowedTCPPorts = lib.mkMerge [ [ 19999 ] ];

    environment.systemPackages = [ pkgs.netdata ];
  };
}
