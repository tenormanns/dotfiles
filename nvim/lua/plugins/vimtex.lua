return {
  {
    "lervag/vimtex",
    ft = { "tex" },

    init = function()
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_compiler_method = "latexmk"

      -- Auto open quickfix on errors
      vim.g.vimtex_quickfix_open_on_warning = 0

      -- Better conceal
      vim.g.vimtex_syntax_conceal = {
        accents = 1,
        ligatures = 1,
        cites = 1,
      }
    end,
  },
}
