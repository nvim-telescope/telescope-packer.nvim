local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  error("This plugin requires nvim-telescope/telescope.nvim")
end

local actions = require "telescope.actions"
local finders = require "telescope.finders"
local pickers = require "telescope.pickers"
local sorters = require "telescope.sorters"
local previewers = require "telescope.previewers"
local action_state = require "telescope.actions.state"
local themes = require "telescope.themes"

local entry_display = require "telescope.pickers.entry_display"
local results = require "telescope._extensions.packer.plugin_list"

-- set column width to length of longest entry
local plugin_name_width = 0
for _, plugin in ipairs(results) do
  plugin_name_width = #plugin.name > plugin_name_width and #plugin.name or plugin_name_width
end

local user_opts
local setup = function(opts)
  opts = opts or {}
  if opts.theme and opts.theme ~= "" then
    user_opts = themes["get_" .. opts.theme](opts)
  else
    user_opts = opts
  end
end

local plugins = function(opts)
  opts = vim.tbl_deep_extend("force", user_opts, opts or {})

  local displayer = entry_display.create {
    separator = "",
    items = {
      { width = plugin_name_width + 1 },
      { remaining = true },
    },
  }

  local make_display = function(entry)
    local hl = entry.directory == "start" and "Operator" or "Number"
    return displayer {
      {entry.name, hl, "Normal"}, -- TODO: parameter 2 intended to be override for matcher hl-group
      {entry.description, "Comment"},
    }
  end

  pickers.new(opts, {
    prompt_title = "Plugins",
    finder = finders.new_table {
      results = results,
      entry_maker = function(entry)
        return {
          value = entry,
          display = make_display,
          ordinal = entry.directory .. " " .. entry.name,

          directory = entry.directory,
          name = entry.name,
          description = entry.description,
          readme = entry.readme,
          path = entry.path,

          preview_command = function(entry, bufnr)
            local readme = {}
            if entry.readme ~= nil then
              readme = vim.fn.readfile(entry.readme)
              vim.api.nvim_buf_set_option(bufnr, "filetype", "markdown")
            end
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, readme)
          end,
        }
      end,
    },
    sorter = sorters.get_generic_fuzzy_sorter(),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        local selection = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        vim.cmd(string.format(":e %s", selection.readme))
      end)

      local Job = require "plenary.job"
      local open_online = function()
        local selection = action_state.get_selected_entry()
        actions._close(prompt_bufnr)

        local cmd = vim.fn.has "win-32" == 1 and "start" or vim.fn.has "mac" == 1 and "open" or "xdg-open"
        local url = vim.fn.system(string.format("git -C %s ls-remote --get-url", selection.path))
        Job:new({command = cmd, args = {url}}):start()
      end

      local builtin = require("telescope.builtin")

      local open_finder = function()
        local selection = action_state.get_selected_entry()
        actions._close(prompt_bufnr, true)
        builtin.find_files({cwd = selection.path})
      end

      local open_browser = function()
        local selection = action_state.get_selected_entry()
        actions._close(prompt_bufnr, true)
        local file_browser = require("telescope").extensions.file_browser
        if not file_browser then return end
        file_browser.file_browser({cwd = selection.path})
      end

      local open_grep = function()
        local selection = action_state.get_selected_entry()
        actions._close(prompt_bufnr, true)
        builtin.live_grep({cwd = selection.path})
      end

      map("i", "<C-o>", open_online)
      map("i", "<C-f>", open_finder)
      map("i", "<C-b>", open_browser)
      map("i", "<C-g>", open_grep)
      return true
    end,
    previewer = previewers.display_content.new(opts),
  }):find()
end

return telescope.register_extension {
  setup = setup,
  exports = {
    packer = plugins,
  },
}
