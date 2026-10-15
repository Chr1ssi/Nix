{ ... }:

{
  # Powerlevel10k-style two-line prompt, built with https://starship.ndl.au.
  flake.modules.homeManager.starship = {
    programs.starship = {
      enable = true;
      settings = builtins.fromTOML (builtins.readFile ../../dotfiles/starship/starship.toml);
    };
  };
}
