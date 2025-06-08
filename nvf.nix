{
  config.vim = {
    autocomplete.nvim-cmp.enable = true;

    binds = {
      cheatsheet.enable = true;
      whichKey.enable = true;
    };

    comments.comment-nvim.enable = true;

    languages = {
      enableDAP = true;
      enableExtraDiagnostics = true;
      enableFormat = true;
      enableLSP = true;
      enableTreesitter = true;

      assembly.enable = true;
      #bash.enable = true;
      clang.enable = true;
      css.enable = true;
      go.enable = true;
      html.enable = true;
      lua.enable = true;
      markdown.enable = true;
      nix.enable = true;
      #python.enable = true;
      r.enable = true;
      rust = {
        enable = true;
        crates.enable = true;
      };
      sql.enable = true;
      svelte.enable = true;
      tailwind.enable = true;
      #ts.enable = true;
    };

    spellcheck = {
      enable = true;
      languages = [
        "en"
        "de"
      ];
      programmingWordlist.enable = true;
    };

    statusline.lualine.enable = true;
    telescope.enable = true;
    theme.enable = true;
    treesitter.enable = true;
  };
}
