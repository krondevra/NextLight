{ ... }:

{
  programs.mpv = {
    enable = true;
    config = {
      ao = "pulse";
      fs = "no";
      vo = "gpu";
      hwdec = "vaapi-copy";
      gpu-context = "wayland";
    };
  };
}