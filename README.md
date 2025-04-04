# pointer.nvim

<!--toc:start-->
- [pointer.nvim](#pointernvim)
  - [Development](#development)
    - [Prerequisites](#prerequisites)
    - [Development Scripts](#development-scripts)
  - [Contributing](#contributing)
  - [License](#license)
<!--toc:end-->

![Tests](https://github.com/hoganmcdonald/pointer.nvim/actions/workflows/test.yml/badge.svg)
![Lint](https://github.com/hoganmcdonald/pointer.nvim/actions/workflows/lint.yml/badge.svg)
![Type Check](https://github.com/hoganmcdonald/pointer.nvim/actions/workflows/typecheck.yml/badge.svg)

AI tools for neovim.

```lua
-- Using lazy.nvim
{
  'HoganMcDonald/pointer.nvim',
  keys = {
    {
      '<leader>aa',
      function()
        require('pointer').toggle_sidepanel()
      end,
      desc = '[Pointer] sidepanel',
    },
  },
  opts = {},
},
```

## Development

### Prerequisites

- [LuaLS](https://github.com/LuaLS/lua-language-server) for type checking
- [Stylua](https://github.com/JohnnyMorganz/StyLua) for code formatting

Install dependencies:
```bash
brew install lua-language-server
brew install stylua
```

### Development Scripts

The project includes several development scripts in the `bin/` directory:

```bash
./bin/check-types  # Run type checking
./bin/lint        # Run linter
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
