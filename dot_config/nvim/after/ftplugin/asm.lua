-- GNU as (.s / .S) -- comment character.
--
-- Neovim's runtime ftplugin/asm.vim ships `commentstring=; %s`. That is NASM's
-- comment character, not GAS's: on x86 GAS the line comment character is `#`
-- and `;` is a *statement separator*, so `gcc`/`gc` was emitting lines that
-- silently changed the meaning of the code instead of commenting it out.
-- GAS also accepts `//` and `/* */`, hence the 'comments' value.
--
-- This must live in after/ftplugin, NOT in a FileType autocmd. Neovim's native
-- commenting (runtime/lua/vim/_comment.lua) ignores the buffer-local
-- 'commentstring' whenever a treesitter parser is attached to the buffer, and
-- instead resolves vim.filetype.get_option(<ft>, 'commentstring') -- which
-- evaluates the option in a scratch buffer, i.e. off the ftplugin chain. A
-- `vim.bo.commentstring = ...` autocmd sets a value that `gc` never reads.
--
-- Known side effect: _comment.lua asks that question per *treesitter language*,
-- and both `asm` and `nasm` filetypes map to the `asm` parser, so a .asm/.nasm
-- buffer now also comments with `#`. There is no configuration that gives the
-- two filetypes different strings while they share a parser (the loop in
-- _comment.lua never advances res_level, so the last non-empty filetype wins
-- for every buffer). GAS is what pwn.college uses, so GAS wins.
vim.bo.commentstring = "# %s"
vim.bo.comments = ":#,://,s1:/*,mb:*,ex:*/"

vim.b.undo_ftplugin = (vim.b.undo_ftplugin or "") .. " | setl commentstring< comments<"
