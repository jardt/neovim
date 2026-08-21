local M = {}

local paired = nil

local function notify(message, level)
	vim.notify(message, level or vim.log.levels.ERROR, { title = "Pi" })
end

local function run(args, callback)
	vim.system(args, { text = true }, function(result)
		vim.schedule(function()
			if result.code ~= 0 then
				notify(vim.trim(result.stderr ~= "" and result.stderr or result.stdout))
				callback(nil)
				return
			end
			callback(result.stdout)
		end)
	end)
end

local function agents(callback)
	local workspace = vim.env.HERDR_WORKSPACE_ID
	if vim.env.HERDR_ENV ~= "1" or not workspace or workspace == "" then
		notify("Neovim is not running in a Herdr workspace")
		callback({})
		return
	end

	run({ "herdr", "agent", "list" }, function(stdout)
		if not stdout then
			callback({})
			return
		end
		local ok, response = pcall(vim.json.decode, stdout)
		if not ok then
			notify("Could not decode Herdr's agent list")
			callback({})
			return
		end
		local found = {}
		for _, agent in ipairs(vim.tbl_get(response, "result", "agents") or {}) do
			if agent.agent == "pi" and agent.workspace_id == workspace then
				found[#found + 1] = agent
			end
		end
		callback(found)
	end)
end

local function choose(found, callback, force)
	if #found == 0 then
		paired = nil
		notify("No Pi agent is running in this Herdr workspace", vim.log.levels.WARN)
		callback(nil)
		return
	end
	if not force and paired then
		for _, agent in ipairs(found) do
			if agent.pane_id == paired then
				callback(agent)
				return
			end
		end
		paired = nil
	end
	if #found == 1 then
		paired = found[1].pane_id
		callback(found[1])
		return
	end
	vim.ui.select(found, {
		prompt = "Select Pi agent",
		format_item = function(agent)
			return string.format(
				"%s  %s  %s  %s",
				agent.tab_id,
				agent.pane_id,
				agent.agent_status or "unknown",
				agent.cwd or ""
			)
		end,
	}, function(agent)
		if agent then
			paired = agent.pane_id
		end
		callback(agent)
	end)
end

local function resolve(callback, force)
	agents(function(found)
		choose(found, callback, force)
	end)
end

function M.select()
	resolve(function(agent)
		if agent then
			notify("Paired with Pi in " .. agent.pane_id, vim.log.levels.INFO)
		end
	end, true)
end

function M.focus()
	resolve(function(agent)
		if agent then
			run({ "herdr", "agent", "focus", agent.pane_id }, function() end)
		end
	end)
end

function M.send(text, submit)
	resolve(function(agent)
		if not agent then
			return
		end
		local command = submit and { "herdr", "agent", "prompt", agent.pane_id, text }
			or { "herdr", "pane", "send-text", agent.pane_id, text }
		run(command, function(stdout)
			if stdout then
				run({ "herdr", "agent", "focus", agent.pane_id }, function() end)
			end
		end)
	end)
end

return M
