{pkgs, ...}: {
  home.packages = with pkgs; [
    eza
    fd
    ripgrep
    fzf
    git
    wget
    mihomo
    metacubexd
    python3
    nodejs
    pnpm
    bun
    rustc
    cargo
    go
    podman
    sshfs
    sqlite
  ];

  # 环境变量
  home.sessionVariables = {
    GOPATH = "$HOME/.config/go";
  };

  # PATH 扩展
  home.sessionPath = [
    "$HOME/.config/go/bin"
    "$HOME/.npm-global/bin"
    "$HOME/.cargo/bin"
  ];

  home.stateVersion = "26.11";
}
