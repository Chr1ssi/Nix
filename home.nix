{ pkgs, ... }:

{
	home.username = "chris";
	home.homeDirectory = "/home/chris";

	home.stateVersion = "26.05";

	programs.home-manager.enable = true;

	home.packages = with pkgs; [
		kitty
	];

	wayland.windowManager.hyprland = {
		enable = true;
		configType = "lua";
		package = null;
		portalPackage = null;

		extraConfig = ''
			hl.monitor = ({
				output = "",
				mode = "preferred",
				position = "auto",
				scale = 1,
			})

			hl.config({
				input = {
					kb_layout = "de",
				},
			})

			hl.bind("SUPER + RETURN", hl.dsp.exec_cmd("kitty"))
			hl.bind("SUPER + Q", hl.dsp.window.close())
			hl.bind("SUPER + M", hl.dsp.exit())
		'';
	};
}
