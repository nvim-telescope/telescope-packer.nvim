local has_packer, plugin_utils = pcall(require, "packer.plugin_utils")
if not has_packer then
  error("This plugins requires wbthomason/packer.nvim")
end

-- require "packer".init{config = {}}

local MAX_SCAN_LINES = 25
local ESCAPE_SPECIAL_CHARS = "[%(%)%.%+%-%*%?%[%]%^%$%%]"

local function get_description(file_path)
  if file_path == nil then
    return nil
  end
  local description, escaped_match

  -- find first line that doesn't begin with a special character
  local line_num = 1
  for line in io.lines(file_path) do
    if line_num > 1 and line_num <= MAX_SCAN_LINES then
      -- trim leading spaces
      line = line:gsub("^%s+", "")
      if line:match("^[^#^<^>^%!^=^%-^%*]") and line:match("^%[!") == nil then
        description = line
        break
      end
    end
    line_num = line_num + 1
  end

  if description then
    -- match the first sentence delimited by `.` (or everything)
    description = description:match("^(.*)%.%s") or description

    -- remove trailing period
    description = description:gsub("%.$", "")

    -- de-linkify markdown style links `[foo](bar)` or `[foo][bar]`
    for match in description:gmatch "%[(.+)][%(%[]+.*[%)%]]" do
      -- escape any special chars in string
      escaped_match = match:gsub(ESCAPE_SPECIAL_CHARS, "%%%1")
      description = description:gsub("%[" .. escaped_match .. "][%(%[].*[%)%]]", match)
    end

    -- remove `foo` / *foo* / _foo_ enclosures
    for match in description:gmatch("`(.+)`") do
      escaped_match = match:gsub(ESCAPE_SPECIAL_CHARS, "%%%1")
      description = description:gsub("`" .. escaped_match .. "`", match)
    end

    for match in description:gmatch("%*%*(.+)%*%*") do
      escaped_match = match:gsub(ESCAPE_SPECIAL_CHARS, "%%%1")
      description = description:gsub("%*%*" .. escaped_match .. "%*%*", match)
    end

    for match in description:gmatch("_(.+)_") do
      escaped_match = match:gsub(ESCAPE_SPECIAL_CHARS, "%%%1")
      description = description:gsub("_" .. escaped_match .. "_", match)
    end

    -- capitalize first letter in line
    description = description:sub(1,1):upper()..description:sub(2)

    -- opinionated grammar restructure
    description = description:gsub("^This is a", "A")
    description = description:gsub("neovim", "Neovim")
  end

  return description
end

-- hardcoded workarounds for missing/non-standard markdown layouts! =)
local LIST_OF_SHAME = {
  ["nvim-treesitter"] = "Treesitter configurations and abstraction layer for Neovim",
  ["snippets"] = "An advanced snippets engine for Neovim",
  ["vim-parenmatch"] = "A fast alternative to matchparen that highlights matching parenthesis based on the value of matchpairs",
  ["vim-signature"] = "A plugin to place, toggle and display marks.",
  ["vim-wordmotion"] = "More useful word motions for Vim",
  ["packer"] = "A use-package inspired plugin/package management for Neovim",
  ["signify"] = "Use the sign column to indicate added, modified and removed lines in a file that is managed by a VCS",
}

-- lowest takes precedence: favors /doc/*.txt over readme.md
local README_FILE_PATTERN = {
  "/README.md",
  "/README.markdown",
  "/readme.md",
  "/Readme.md",
  -- "/doc/" .. plugin_name .. ".txt",
  -- "/doc/" .. plugin_name:gsub("^vim%-", "") .. ".txt",
}

local plugin_metadata = {}
local packer_lists = {}
packer_lists["opt"], packer_lists["start"] = plugin_utils.list_installed_plugins()

local SUBDIR_NAMES = {"opt", "start"}

local plugin_name, plugin_desc, plugin_readme
local file_path, file_found

for _, plugin_subdir in pairs(SUBDIR_NAMES) do
  for plugin_path, _ in pairs(packer_lists[plugin_subdir]) do
    -- print(vim.inspect(plugin_utils.guess_type(plugin_path)))
    -- TODO: get github author/project name here
    plugin_name = vim.fn.fnamemodify(plugin_path, ":t:r")
    plugin_readme = nil
    for _, extension in pairs(README_FILE_PATTERN) do
      file_path = plugin_path .. extension
      file_found = io.open(file_path)
      if file_found then
        io.close(file_found)
        plugin_readme = file_path
      end
    end

    plugin_desc = LIST_OF_SHAME[plugin_name] or get_description(plugin_readme) or ""
    table.insert(plugin_metadata, {
      name = plugin_name,
      directory = tostring(plugin_subdir),
      description = plugin_desc,
      readme = plugin_readme,
      path = plugin_path
    })
  end
end

return plugin_metadata
