{ pkgs, ... }:

{
	home.username = "chris";
	home.homeDirectory = "/home/chris";

	home.stateVersion = "26.05";

	programs.home-manager.enable = true;

	home.packages = with pkgs; [
		kitty
		quickshell
		fuzzel
		mako
		libnotify
		polkit_gnome
	];

	home.file.".config/quickshell/nixos-shell/shell.qml".source =
		./quickshell/shell.qml;

	wayland.windowManager.hyprland = {
		enable = true;
		configType = "lua";
		package = null;
		portalPackage = null;

		extraConfig = ''
			hl.config({
				input = {
					kb_layout = "de",
				},
			})

			hl.on("hyprland.start", function()
				hl.monitor({
					output = "Virtual-1",
					mode = "preferred",
					position = "auto",
					scale = 1,
				})

				hl.exec_cmd("qs -c nixos-shell")
				hl.exec_cmd("mako")
				hl.exec_cmd("${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1")
			end)

			hl.bind("SUPER + RETURN", hl.dsp.exec_cmd("kitty"))
			hl.bind("SUPER + Q", hl.dsp.window.close())
			hl.bind("SUPER + M", hl.dsp.exit())
			hl.bind("SUPER + SPACE", hl.dsp.exec_cmd("fuzzel"))
		'';
	};
}
