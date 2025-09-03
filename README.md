# Scribble.nvim
A place to write down your thoughts at the speed of thought.

You also have a bunch of `notes.md`, `file.md`, `arst` (or `asdf`) everywhere
in your filesystem? And never find the thing you need when in times of trouble?

`scribble.nvim` is the solution to your problems! `scribble.nvim` creates the
temporary `Scribblepad` and caters to all the problems you might have! It creates
a new `Scribblepad` under the neovim "data" directory for every new directory. It
smartly handles git directories too!

<img width="1346" height="705" alt="2025-08-27_11-50" src="https://github.com/user-attachments/assets/eb18c559-e36d-462d-b230-38e74c93401a" />


https://github.com/user-attachments/assets/ac643403-1215-4222-9913-3352d2678e3f


## Table of Contents

- [Getting Started](#getting-started)
- [Installation](#installation)
- [Usage](#usage)
- [Customization](#customization)
- [Default Mappings](#default-mappings)

## Getting Started

Fortunately `scribble.nvim` has no dependencies!! You can use it in a faily new
neovim version! It has been tested to be fully functional in v0.12

## Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'AnkushRoy-code/scribble.nvim'
  -- startup idk figure it out yourself. I use lazy.nvim and you should too
}
```

Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
-- init.lua:
    {
        'AnkushRoy-code/scribble.nvim'
        config = function()
            require("scribble").setup()
        end,
        }
    }

-- plugins/scribble.lua:
return {
    'AnkushRoy-code/scribble.nvim'
    config = function()
        require("scribble").setup()
    end,
    }
}
```

A simple working configuration with the following mapping:
| Mappings       | Action                         |
| -------------- | -------------------------      |
| `Ctrl-L`       | Toggle the scribble pad        |
| `<leader>sl`   | Open the list of scribble pads |


```lua
return {
	"AnkushRoy-code/scribble.nvim",
	event = "VeryLazy",

	config = function()
		local scribble = require("scribble")
		scribble.setup({
			pos = "center",
		})

		vim.keymap.set("n", "<C-l>", scribble.toggle, { desc = "Toggle Scribble" })
		vim.keymap.set("n", "<leader>sl", scribble.find, { desc = "Fuzzy find scribble pads" })
	end,
}

```

## Usage

Try the command `:Scribble` to see if `scribble.nvim` is installed correctly.

Using VimL:

```viml
" Toggle Scrbble window
nnoremap <leader>sc <cmd>Scribble toggle<cr>
" You probably don't need these. The toggle and auto-close is good enough
" nnoremap <leader>so <cmd>Scribble open<cr>
" nnoremap <leader>sq <cmd>Scribble close<cr>

" Using Lua functions
nnoremap <leader>sc <cmd>lua require('scribble').toggle()<cr>
" nnoremap <leader>so <cmd>lua require('scribble').open()<cr>
" nnoremap <leader>sp <cmd>lua require('scribble').close()<cr>
```

Using Lua:

```lua
local scribble = require('scribble')
vim.keymap.set('n', '<leader>sc', scribble.toggle, { desc = 'Scribble toggle' })
-- vim.keymap.set('n', '<leader>so', scribble.open, { desc = 'Scribble open' })
-- vim.keymap.set('n', '<leader>sq', scribble.close, { desc = 'Scribble open' })
```


## Customization

This section should help you explore available options to configure and
customize your `scribble.nvim`. These are the default values


```lua
require('scribble').setup{
  pos = "center", -- possible values are (center, N, S, E, W, NW,NE, SW, SE)
  picker = nil, -- possible values are (fzf, snacks, telescope, nil)
  filetype = "markdown", -- the filetype you want of the scribble-pads
  extension = "", -- the file_extension you want, for example ".md"
  width = -1, -- any positive integer, -1 means will use 75% of the total width
  height = -1, -- any positive integer, -1 means will use 50% of the total height
  auto_save = true, -- boolean
  path = nil, -- full path to the storage directory, nil will use the standard storage directory inside `~/.local/share/nvim` or equivalent
}
```

## Default Mappings


| Mappings       | Action                    |
| -------------- | ------------------------- |
| `<C-UP>`       | Move the window up        |
| `<C-DOWN>`     | Move the window down      |
| `<C-RIGHT>`    | Move the window right     |
| `<C-LEFT>`     | Move the window left      |
| `q/<ESC>`      | Quit the Scribble window  |


# AI Usage

This is not AI usage. And neither my plugin has anything to do with AI. I just
have it to clarify AI usage to some concerned personalities.

Did I use AI? Yes I did. But I primarilly use AI as a Google replacement. I use
it to search for things. Not to make me things.

For example: When I needed a way to add markdown formatting to some file
without any suffix/extensions. I asked it to guide tell me how I can do it.
Then I reffered the docs and did the rest myself.

AI didn't write a single word in this repo. I take pride in saying that I
didn't use AI not to slow down progress but to learn through the struggels,
problems and sufferings that make me a better raw programmer.

# Contributing

It's all chil out here. Feel free to contribute

# Related Projects

- [scratchpad.nvim](https://github.com/athar-qadri/scratchpad.nvim)
- [snacks.nvim (scratch)](https://github.com/folke/snacks.nvim/blob/main/docs/scratch.md)
