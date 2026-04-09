{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      path = "$HOME/.zsh_history";
      size = 10000;
      save = 10000;
      share = true;
    };

    initExtra = ''
      bindkey "^[[1;5D" backward-word
      bindkey "^[[1;5C" forward-word
      bindkey "^[[5D" backward-word
      bindkey "^[[5C" forward-word
    '';
  };
}