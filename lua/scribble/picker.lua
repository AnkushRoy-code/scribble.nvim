local config = require("scribble.config")
local data = require("scribble.data")
local fs = require("scribble.util.filesystem")

local M = {}

-- https://github.com/kawre/leetcode.nvim/blob/master/lua/leetcode/picker/init.lua#L4-L63
local provider_order = { "snacks-picker", "fzf-lua", "telescope" }

local providers = {
	["fzf-lua"] = {
		name = "fzf",
		is_available = function()
			return pcall(require, "fzf-lua")
		end,
	},
	["snacks-picker"] = {
		name = "snacks",
		is_available = function()
			return pcall(function()
				---@diagnostic disable-next-line: undefined-field, undefined-global
				assert(Snacks.config["picker"].enabled)
			end)
		end,
	},
	["telescope"] = {
		name = "telescope",
		is_available = function()
			return pcall(require, "telescope")
		end,
	},
}

local available_pickers = table.concat(
	vim.tbl_map(function(p)
		return providers[p].name
	end, provider_order),
	", "
)

---@return "fzf" | "telescope" | "snacks"
local function resolve_provider()
	---@type string
	local provider = nil

	if provider == nil then
		for _, key in ipairs(provider_order) do
			local picker = providers[key]

			if picker.is_available() then
				return picker.name
			end
		end

		error(("No picker is available. Please install one of the following: `%s`") --
			:format(available_pickers))
	end

	local picker = providers[provider]
	assert(
		picker,
		("Picker `%s` is not supported. Available pickers: `%s`") --
		:format(provider, available_pickers)
	)

	local ok = picker.is_available()
	assert(ok, ("Picker `%s` is not available. Make sure it is installed"):format(provider))
	return picker.name
end

-- get all the files
-- https://stackoverflow.com/a/76675386
local dfiles = {}
local map = {} -- map the decoded filenames to the corresponding full paths

local function populate_file_list()
	dfiles = {}
	map = {}

	local files = vim.split(vim.fn.glob(data.get_storage_dir() .. "/*"), "\n", { trimempty = true })

	for _, item in ipairs(files) do
		local raw = vim.fn.fnamemodify(item, ":t")
		if not raw or raw == "" then
			goto continue
		end

		local raw_noext = vim.fn.fnamemodify(item, ":t")

		local fname = fs.decode(raw_noext)

		if not fname or fname == "" then
			goto continue
		end

		table.insert(dfiles, fname)
		map[fname] = item

		::continue::
	end
end

-- ask the picker to find it
function M.pick()
	populate_file_list()
	local picker = config.options.picker or resolve_provider()

	if picker == "fzf" then
		-- https://github.com/ibhagwan/fzf-lua/wiki/Advanced#neovim-builtin-preview
		local fzf = require("fzf-lua")
		local builtin = require("fzf-lua.previewer.builtin")

		-- Inherit from the "buffer_or_file" previewer
		local MyPreviewer = builtin.buffer_or_file:extend()

		function MyPreviewer:new(o, opts, fzf_win)
			MyPreviewer.super.new(self, o, opts, fzf_win)
			setmetatable(self, MyPreviewer)
			return self
		end

		function MyPreviewer:parse_entry(entry_str)
			-- Assume an arbitrary entry in the format of 'file:line'
			local path = map[entry_str]
			return {
				path = path,
				line = 1,
				col = 1,
			}
		end

		fzf.fzf_exec(dfiles, {
			prompt = "Select a File > ",
			actions = {
				["default"] = function(selected)
					vim.cmd("edit " .. map[selected[1]])
					vim.api.nvim_set_option_value("filetype", config.options.filetype,
						{ buf = vim.api.nvim_get_current_buf() })
				end,
			},
			previewer = MyPreviewer,
			fzf_opts = {
				['--preview-window'] = 'right:60%,wrap,hidden'
			},
		}, 'files')

		-- https://github.com/kawre/leetcode.nvim/blob/master/lua/leetcode/picker/question/snacks.lua
	elseif picker == "snacks" then
		local snacks_picker = require("snacks.picker")
		local completed = false

		local snacks_items = {}

		for _, fname in ipairs(dfiles) do
			table.insert(snacks_items, {
				text = fname,
				value = { { fname } },
			})
		end

		snacks_picker.pick({
			-- source = snacks_items,
			items = snacks_items,

			format = function(item)
				local val = (item and item.text) or (item and item.value and item.value.text) or tostring(item)
				return { { val } }
			end,

			title = "Select a Question",
			layout = {
				preset = "select",
			},

			actions = {
				confirm = function(p, item)
					if completed then
						return
					end
					completed = true
					p:close()

					vim.schedule(function()
						vim.cmd("edit " .. map[item.text])
						vim.api.nvim_set_option_value("filetype", config.options.filetype,
							{ buf = vim.api.nvim_get_current_buf() })
					end)
				end,
			},

			on_close = function()
				if completed then
					return
				end
				completed = true
				print("No selection")
			end,
		})
	elseif picker == "telescope" then
		local pickers = require("telescope.pickers")
		local finders = require("telescope.finders")
		local actions = require("telescope.actions")
		local action_state = require("telescope.actions.state")

		pickers
			.new(require("telescope.themes").get_dropdown(), {
				prompt_title = "Select a Question",
				finder = finders.new_table({
					results = dfiles,
					-- entry_maker = entry_maker,
				}),
				attach_mappings = function()
					actions.select_default:replace(function()
						local selection = action_state.get_selected_entry()
						if not selection then
							print("No selection")
							return
						end
						vim.schedule(function()
							vim.cmd("edit! " .. map[selection[1]])
							vim.api.nvim_set_option_value("filetype", config.options.filetype,
								{ buf = vim.api.nvim_get_current_buf() })
						end)
					end)
					return true
				end,
			})
			:find()
	else
		print("Picker not recognised: " .. picker .. "possible values are fzf, snackes, telescope")
	end
end

return M
