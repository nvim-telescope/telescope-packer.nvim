# telescope-packer.nvim

Integration for [packer.nvim](https://github.com/wbthomason/packer.nvim) with [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim).

<img src="https://raw.githubusercontent.com/sunjon/images/master/gh_readme_telescope_packer.png" height="600">

## Requirements

- [packer.nvim](https://github.com/wbthomason/packer.nvim) (required)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) (required)
- [telescope-file-browser.nvim](https://github.com/nvim-telescope/telescope-file-browser.nvim) (optional, only for `file_browser` action)

## Available commands

`:Telescope packer`

For the command to work this line should be added
```lua
require("telescope").load_extension "packer"
```

## Available functions

```lua
require('telescope').extensions.packer.packer(opts)
```

## Available mappings

| Mappings    | Action                      |
|-------------|-----------------------------|
| `<C-o>/o`     | Open online repository      |
| `<C-f>/f`     | Open with find_files        |
| `<C-b>/b`     | Open with file_browser      |
| `<C-g>/g`     | Open with live_grep         |

## Configure plugin

Default settings can be set
```lua
telescope.setup {
	extensions = {
		packer = {
			theme = "ivy",
			layout_config = {
				height = .5
			}
		}
	}
}
```

## Actions

WIP
