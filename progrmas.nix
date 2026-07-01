{config, ...}: let
  homeDir = config.home.homeDirectory;
in {
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.bash = {
    enable = true;
    completion.enable = true;
    shellAliases = {
      "~" = "cd ~";
      "-" = "cd -";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      ls = "ls -X --color=auto";
      ll = "eza -l --git -X --no-time -s Extension";
      la = "eza -la --git --no-time -s Extension";
      tree = "eza -T --git-ignore -s Extension";
      fzf = "fzf --style=minimal --no-mouse --reverse --height -3 --ansi --bind 'ctrl-d:preview-page-down'";
      ffmpeg = "ffmpeg -v error";
      v = "nvim";
      rm = "rm --preserve-root";
      chmod = "chmod --preserve-root -v";
      chown = "chown --preserve-root -v";
    };
    interactiveShellInit = ''
      ############################################################
      # 插件
      ############################################################
      eval "$(starship init bash)"

      ############################################################
      # fzf
      ############################################################
      fzf_history() {
        local selected
        selected=$(history | cut -c 8- | fzf)
        if [ -n "$selected" ]; then
          READLINE_LINE="$selected"
          READLINE_POINT=''${#selected}
        fi
      }
      # 绑定 Ctrl+R
      bind -x '"\C-r": fzf_history'

      ############################################################
      # 杂项
      ############################################################
      HISTCONTROL=ignoredups # 忽略连续重复命令
      HISTCONTROL=ignorespace # 忽略以空格开头的命令(不记录)
      HISTCONTROL=ignoreboth # 组合: 忽略连续重复 + 空格开头
      HISTCONTROL=erasedups # 全局去重(所有重复都只保留一条, 按最新顺序)

      stty werase undef
      bind '"\C-w": backward-kill-word'

      ############################################################
      # 加载个人配置
      ############################################################
      if [ -f "''${HOME}/.config/bash/init.bash" ]; then
        source "''${HOME}/.config/bash/init.bash"
      fi
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      format = "$username$hostname$directory$git_branch$git_commit$custom$git_state$git_status$docker_context$nodejs$golang$lua$nix_shell$direnv$sudo$jobs$status$line_break$character";
      add_newline = true;

      character = {
        success_symbol = "[↪](bold green)";
        error_symbol = "[↪](bold #f38ba8)";
      };

      username = {
        show_always = true;
        style_user = "bold";
        format = "[$user](green)";
      };

      hostname = {
        ssh_only = false;
        style = "bold";
        format = "@[$hostname]($style)";
      };

      directory = {
        truncation_length = 0;
        truncate_to_repo = false;
        style = "bold blue";
        format = " [$path]($style)[$read_only]($read_only_style)";
        read_only = " ";
        read_only_style = "bold #f38ba8";
      };

      git_branch = {
        symbol = " ";
        style = "bold #cba6f7";
        format = " on [$symbol$branch]($style)";
      };

      git_status = {
        style = "bold";
        format = "[$all_status$ahead_behind](red)";
        conflicted = " =\${count}";
        ahead = " ⇡\${count}";
        behind = " ⇣\${count}";
        diverged = " ⇡\${ahead_count} ⇣\${behind_count}";
        up_to_date = "";
        untracked = " ?\${count}";
        stashed = " \\$";
        modified = " !\${count}";
        staged = " +\${count}";
        renamed = " »\${count}";
        deleted = " ✘\${count}";
      };

      git_commit = {
        only_detached = true;
        format = "[\\($hash\\)](yellow)";
      };

      custom.git_tag = {
        command = "tag=$(git describe --exact-match --tags 2>/dev/null) && [ -n \"$tag\" ] && echo \"[$tag]\"";
        when = "git rev-parse --is-inside-work-tree 2>/dev/null";
        format = "[$output](#fff59d)";
      };

      status = {
        disabled = false;
        symbol = " -> ";
        style = "bold #f38ba8";
        format = "[$symbol$status]($style)";
      };

      nodejs.format = " [via](white) [󰎙 $version](bold #aed581)";
      golang.format = " [via](white) [ $version](bold #aed581)";
      lua.format = " [via](white) [ $version](bold #aed581)";
      nix_shell.format = " [via](white) [󱄅 $state( \\($name\\))](bold #add8e6)";

      package.disabled = true;
      cmd_duration.disabled = true;
      fill.symbol = " ";
      line_break.disabled = false;
      time.disabled = true;
      battery.disabled = true;
    };
  };

  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "";
        email = "";
      };
      credential.helper = "store";

      init.defaultBranch = "main";

      core = {
        editor = "nano";
        quotepath = false;
        symlinks = true;
        excludesfile = "${config.xdg.configHome}/git/gitignore_global";
      };

      mergetool = {
        prompt = false;
        keepBackup = false;
      };

      advice = {
        pushUpdateRejected = false;
        pushNonFFcurrent = false;
        pushNonFFMatching = false;
        pushAlreadyExists = false;
        pushFetchFirst = false;
        pushNeedsForce = false;
        statusHints = false;
        statusUoption = false;
        commitBeforeMerge = false;
        resolveConflict = false;
        implicitIdentity = false;
        detachedHead = false;
        amWorkDir = false;
        rmHints = false;
      };

      interactive = {
        singleKey = true;
        hotkeys = false;
      };

      commit = {
        status = false;
        verbose = false;
        template = "${config.xdg.configHome}/git/commit";
      };
    };
  };

  xdg.configFile = {
    "git/commit" = {
      text = ''

        # 格式: type: description
        #
        # 类型:
        #   add -> 添加: 名词短语
        #   update -> 更新: 动词(修改, 优化, 移除, 重构) + 名词短语
        #   fix -> 修复: 问题
        #   docs -> 文档: 动词 + 名词短语
        #   chore -> 杂项: 动词 + 名词短语
        #   test -> 测试: 动词 + 名词短语
        #   style -> 格式化[固定格式] -> style: 代码格式化
        #   Revert -> 回退[固定格式] -> Revert: 7位哈希值 原因
      '';
    };
    "git/gitignore_global" = {
      text = ''
        *.bak
      '';
    };
  };

  programs.npm = {
    enable = true;
    settings = {
      prefix = "${homeDir}/.npm-global";
      registry = "https://registry.npmmirror.com";
    };
  };
}
