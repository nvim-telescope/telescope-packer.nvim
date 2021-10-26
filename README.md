# telescope-packer.nvim

Integration for [packer.nvim](https://github.com/wbthomason/packer.nvim) with [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim).

<img src="https://raw.githubusercontent.com/sunjon/images/master/gh_readme_telescope_packer.png" height="600">

## Requirements

- [packer.nvim](https://github.com/wbthomason/packer.nvim) (required)
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) (required)

## Available commands

`:Telescope packer`

## Available functions

```lua
require('telescope-packer').packer(opts)
```

## Available mappings

| Mappings    | Action                                      |
|-------------|---------------------------------------------|
| `<C-o>`     | Open with online repository                 |
| `<C-f>`     | Open with find_files                        |
| `<C-b>`     | Open with file_browser                      |
| `<C-g>`     | Open with live_grep                         |

## Actions

WIP
