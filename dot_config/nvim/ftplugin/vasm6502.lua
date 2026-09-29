-- A distinct filetype prevents the x86 asm parser/comment settings leaking in.
vim.bo.commentstring = "; %s"
vim.bo.comments = ":;"
vim.bo.expandtab = true
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.b.autoformat = false
-- Check the saved file without overwriting a ROM. Run in its directory so
-- relative includes work, even when Neovim was launched somewhere else.
vim.bo.makeprg =
  [[sh -c 'cd "$1" && (echo "VASM_DIRECTORY:$PWD"; vasm6502_oldstyle -Fbin -dotdir -o /dev/null "$2")' sh %:p:h:S %:p:S]]
vim.bo.errorformat = table.concat({
  "%-DVASM_DIRECTORY:%f",
  '%Efatal error %n in line %l of "%f": %m',
  "%Efatal error %n: %m",
  '%Eerror %n in line %l of "%f": %m',
  '%Wwarning %n in line %l of "%f": %m',
  "%Eerror %n: %m",
  "%Wwarning %n: %m",
  "%-G%.%#",
}, ",")
vim.b.undo_ftplugin = "setlocal commentstring< comments< expandtab< shiftwidth< softtabstop< makeprg< errorformat<"
  .. " | unlet! b:autoformat"
