return {
	{
		"mfussenegger/nvim-dap",
		desc = "Debugging support. Requires language specific adapters to be configured. (see lang extras)",
		dependencies = {
			{
				"leoluz/nvim-dap-go",
				"rcarriga/nvim-dap-ui",
				dependencies = { "nvim-neotest/nvim-nio" },
				keys = {
					{
						"<leader>Du",
						function()
							require("dapui").toggle({})
						end,
						desc = "Dap UI",
					},
					{
						"<leader>De",
						function()
							require("dapui").eval()
						end,
						desc = "Eval",
						mode = { "n", "v" },
					},
				},
				opts = {},
				config = function(_, opts)
					local dap = require("dap")
					local dapui = require("dapui")
					dapui.setup(opts)
					dap.listeners.after.event_initialized["dapui_config"] = function()
						dapui.open({})
					end
					dap.listeners.before.event_terminated["dapui_config"] = function()
						dapui.close({})
					end
					dap.listeners.before.event_exited["dapui_config"] = function()
						dapui.close({})
					end
					dap.adapters.lldb = {
						type = "executable",
						command = "/usr/bin/lldb", -- adjust as needed, must be absolute path
						name = "lldb",
					}
				end,
			},
			{
				"theHamsta/nvim-dap-virtual-text",
				opts = {},
			},
		},

        -- stylua: ignore
        keys = {
          { "<leader>DB", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Breakpoint Condition" },
          { "<leader>Db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
          { "<leader>Dc", function() require("dap").continue() end, desc = "Run/Continue" },
          { "<leader>Da", function() require("dap").continue({ before = get_args }) end, desc = "Run with Args" },
          { "<leader>DC", function() require("dap").run_to_cursor() end, desc = "Run to Cursor" },
          { "<leader>Dg", function() require("dap").goto_() end, desc = "Go to Line (No Execute)" },
          { "<leader>Di", function() require("dap").step_into() end, desc = "Step Into" },
          { "<leader>Dj", function() require("dap").down() end, desc = "Down" },
          { "<leader>Dk", function() require("dap").up() end, desc = "Up" },
          { "<leader>Dl", function() require("dap").run_last() end, desc = "Run Last" },
          { "<leader>Do", function() require("dap").step_out() end, desc = "Step Out" },
          { "<leader>DO", function() require("dap").step_over() end, desc = "Step Over" },
          { "<leader>DP", function() require("dap").pause() end, desc = "Pause" },
          { "<leader>Dr", function() require("dap").repl.toggle() end, desc = "Toggle REPL" },
          { "<leader>Ds", function() require("dap").session() end, desc = "Session" },
          { "<leader>Dq", function() require("dap").terminate() end, desc = "Terminate" },
          { "<leader>Dw", function() require("dap.ui.widgets").hover() end, desc = "Widgets" },
        },

		config = function() end,
	},
}
