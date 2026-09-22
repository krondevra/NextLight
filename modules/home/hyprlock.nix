{ ... }:

{
  programs.hyprlock = {
    enable = true;
    package = null; # already installed system-wide via modules/packages.nix

    settings = {
      background = {
        monitor = "";
        color = "rgba(25, 20, 20, 1.0)";
      };

      "input-field" = {
        monitor = "";
        size = "250, 60";
        outline_thickness = 3;
        dots_size = 0.2;
        dots_spacing = 0.3;
        outer_color = "rgb(200, 200, 200)";
        inner_color = "rgba(50, 50, 50, 0.9)";
        font_color = "rgb(255, 255, 255)";
        fade_on_empty = true;
        placeholder_text = "<i>Password...</i>";
        hide_input = false;

        position = "0, -20";
        halign = "center";
        valign = "center";
      };
    };
  };
}
