return {
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		keys = function()
			local keys = {
				{
					"<leader>m",
					function()
						require("harpoon"):list():add()
					end,
					desc = "Harpoon File",
				},
				{
					"<leader>h",
					function()
						local harpoon = require("harpoon")
						harpoon.ui:toggle_quick_menu(harpoon:list())
					end,
					desc = "Harpoon Quick Menu",
				},
				{
					"<C-n>",
					function()
						local harpoon = require("harpoon")
						harpoon:list():next()
					end,
					desc = "Harpoon next",
				},
				{
					"<C-p>",
					function()
						local harpoon = require("harpoon")
						harpoon:list():prev()
					end,
					desc = "Harpoon prev",
				},
			}

			for i = 1, 9 do
				table.insert(keys, {
					"<leader>" .. i,
					function()
						require("harpoon"):list():select(i)
					end,
					desc = "Harpoon to File " .. i,
				})
			end
			return keys
		end,
	},
}
