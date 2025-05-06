{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flakelight.url = "github:nix-community/flakelight";
  inputs.flakelight.inputs.nixpkgs.follows = "nixpkgs";

  outputs = { flakelight, ... }@inputs: flakelight ./. {
    inherit inputs;
    nixpkgs.config.allowUnfree = true;
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    devShell.packages = pkgs: with pkgs; [
      fd
      fish
      nixd
      yaml-language-server
      lefthook
      awscli2
      kubectl
      fluxcd
      kustomize
      kubeconform
      kubernetes-helm
      helm-docs
      helm-ls
    ];
  };
}
