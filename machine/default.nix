{ config, lib, domain, ... }:
let
  inherit (lib) fileContents;
in
{
  deployment = {
    targetEnv = "hetznercloud";
    hetznerCloud = {
      apiToken = fileContents ../secrets/hetzner-api-key;
      location = "nbg1";
      serverType = "cx11";
    };
    keys.acme-dns-creds = {
      text = fileContents ../secrets/acme-dns-creds;
      user = "acme";
      group = "acme";
      permissions = "0640";
    };
  };
    
  networking.firewall.allowedTCPPorts = [ 80 443 ];

  security.acme = {
    acceptTerms = true;
    email = "admin+acme@${domain}";
    certs."${domain}" = {
      domain = "*.${domain}";
      extraDomainNames = [domain];
      dnsProvider = "cloudflare";
      credentialsFile = "/run/keys/acme-dns-creds";
      dnsPropagationCheck = true;
    };
  };

  services.nginx = {
    enable = true;
    recommendedGzipSettings = true;
    recommendedOptimisation = true;
    recommendedTlsSettings = true;
    virtualHosts."${domain}" = {
      useACMEHost = domain;
      forceSSL = true;
      locations."/".root = config.nixpkgs.pkgs.blog;
      extraConfig = "error_page 404 /404.html;";
    };
  };

  users.groups.acme.members = ["nginx"];
}
