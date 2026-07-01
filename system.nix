{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./progrmas.nix
  ];

  users.mutableUsers = false;

  time.timeZone = "Asia/Shanghai";

  i18n = {
    defaultLocale = "zh_CN.UTF-8";
    supportedLocales = [
      "zh_CN.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];
  };

  nix.settings = {
    substituters = [
      "https://mirror.sjtu.edu.cn/nix-channels/store"
      "https://mirrors.ustc.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
    ];
    experimental-features = ["nix-command" "flakes"];
  };

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

  users.users.user = {
    isNormalUser = true;
    extraGroups = ["wheel"];
    shell = pkgs.bash;
  };

  networking.hostName = "nix";

  # WSL 配置
  wsl = {
    enable = true;
    defaultUser = "user";
    wrapBinSh = true;
    extraBin = [
      {
        name = "bash";
        src = config.wsl.binShExe;
      }
    ];
    startMenuLaunchers = false;
  };

  services = {
    vscode-server.enable = true;
  };

  system.stateVersion = "26.11";
}
