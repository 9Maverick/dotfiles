return {
   {
      "rasulomaroff/reactive.nvim",
      config = function()
         require("reactive").setup({
            load = { "catppuccin-frappe-cursor", "catppuccin-frappe-cursorline" },
         })
      end,
   },
}
