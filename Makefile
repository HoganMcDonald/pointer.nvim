test:
	nvim --headless -c "PlenaryBustedDirectory tests/ {minimal_init = './tests/minimal_init.lua'}"
format:
	stylua lua/
check-types:
	lua-language-server --check lua/
	lua-language-server --check tests/
