return {
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts.triggers = {
        { "<auto>", mode = "nxso" },
        { "<leader>", mode = { "n", "v" } },
      }
    end,
  },
}
