-- pwn/CTF working layer, shared by this desktop and the pwn.college dojo.
--
-- All bindings live under <leader>k -- the one leader prefix LazyVim leaves
-- entirely unclaimed (<leader>p yanky, <leader>t neotest, <leader>r rest,
-- <leader>c the LSP "code" group). hover.nvim's <leader>kh (promote float)
-- joins the same group.
--
-- This file is chezmoi-managed on the desktop AND rsynced verbatim to the
-- dojo by ~/.local/bin/pwn-nvim-sync (it lives in lua/plugins/, which the
-- sync mirrors). Everything here must therefore stay portable: no assumption
-- about which tools exist -- guard on vim.fn.executable and degrade with a
-- notify. Dojo-only pieces (asm-lsp, asm filetype detection) stay in the
-- dojo's zz-pwn.lua override; anything shared belongs here.

-- Compile flags for <leader>kb. Override per-buffer/session with e.g.
--   :lua vim.g.pwn_cflags = { "-m32", "-g", "-no-pie", "-fno-stack-protector" }
vim.g.pwn_cflags = vim.g.pwn_cflags
  or { "-g", "-O0", "-no-pie", "-fno-stack-protector", "-z", "execstack", "-Wno-implicit-function-declaration" }

-- ---------------------------------------------------------------------------
-- Hex viewing. The classic xxd round-trip, keyed off binary *content* (ELF
-- magic or a NUL in the first 4 KiB) so it fires on challenge binaries and
-- flag blobs regardless of name. `binary` must be set in BufReadPre (before
-- the read) or nvim mangles trailing bytes / line endings; the
-- BufWritePre/Post pair keeps an edited dump writable without corruption.
-- ---------------------------------------------------------------------------
local function looks_binary(path)
  local fd = vim.uv.fs_open(path, "r", 438)
  if not fd then
    return false
  end
  local chunk = vim.uv.fs_read(fd, 4096, 0)
  vim.uv.fs_close(fd)
  if not chunk or #chunk == 0 then
    return false
  end
  return chunk:sub(1, 4) == "\127ELF" or chunk:find("\0", 1, true) ~= nil
end

local hex_group = vim.api.nvim_create_augroup("pwn_hex", { clear = true })

vim.api.nvim_create_autocmd("BufReadPre", {
  group = hex_group,
  callback = function(ev)
    if ev.file ~= "" and vim.fn.filereadable(ev.file) == 1 and looks_binary(ev.file) then
      vim.bo[ev.buf].binary = true
      vim.b[ev.buf].pwn_hex = true
    end
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = hex_group,
  callback = function(ev)
    if vim.b[ev.buf].pwn_hex then
      vim.cmd("silent %!xxd")
      vim.bo[ev.buf].modified = false
      vim.bo[ev.buf].filetype = "xxd"
    end
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = hex_group,
  callback = function(ev)
    if vim.b[ev.buf].pwn_hex then
      vim.cmd("silent %!xxd -r")
    end
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  group = hex_group,
  callback = function(ev)
    if vim.b[ev.buf].pwn_hex then
      vim.cmd("silent %!xxd")
      vim.bo[ev.buf].modified = false
    end
  end,
})

local function hex_toggle()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].pwn_hex then
    vim.cmd("silent %!xxd -r")
    vim.bo[buf].binary = false
    vim.b[buf].pwn_hex = false
    vim.cmd("filetype detect")
    vim.notify("hex view off", vim.log.levels.INFO)
  else
    vim.bo[buf].binary = true
    vim.cmd("silent %!xxd")
    vim.bo[buf].filetype = "xxd"
    vim.b[buf].pwn_hex = true
    vim.notify("hex view on", vim.log.levels.INFO)
  end
end

-- ---------------------------------------------------------------------------
-- Build / run / inspect.
-- ---------------------------------------------------------------------------
local function term(cmd, opts)
  opts = vim.tbl_extend("force", { cwd = vim.fn.expand("%:p:h"), interactive = true }, opts or {})
  if Snacks and Snacks.terminal then
    Snacks.terminal.open(cmd, opts)
  else
    vim.cmd("botright split | terminal " .. cmd)
  end
end

-- Returns the output path on success, nil on failure. Synchronous so that
-- "build then run" is actually sequenced.
local function build_c(notify_ok)
  local src = vim.fn.expand("%:p")
  local out = vim.fn.expand("%:p:r")
  if src == "" then
    vim.notify("no file in this buffer", vim.log.levels.ERROR)
    return nil
  end
  local cmd = vim.list_extend({ "gcc" }, vim.deepcopy(vim.g.pwn_cflags))
  vim.list_extend(cmd, { "-o", out, src })

  local res = vim.system(cmd, { text = true }):wait()
  if res.code ~= 0 then
    vim.notify((res.stderr or "") .. (res.stdout or ""), vim.log.levels.ERROR, { title = "gcc failed" })
    return nil
  end
  if notify_ok ~= false then
    vim.notify(table.concat(cmd, " "), vim.log.levels.INFO, { title = "built " .. vim.fn.fnamemodify(out, ":t") })
  end
  return out
end

local function run_current()
  local ft = vim.bo.filetype
  local file = vim.fn.shellescape(vim.fn.expand("%:p"))
  if ft == "python" then
    term("python3 " .. file)
  elseif ft == "c" or ft == "cpp" then
    local out = build_c(false)
    if out then
      term(vim.fn.shellescape(out))
    end
  elseif ft == "sh" or ft == "bash" then
    term("bash " .. file)
  elseif ft == "asm" or ft == "nasm" then
    vim.notify("no run recipe for asm -- assemble it into a C harness first", vim.log.levels.WARN)
  else
    vim.notify("no run recipe for filetype '" .. ft .. "'", vim.log.levels.WARN)
  end
end

-- Syscall lookup: pwn work lives in man section 2; fall back to 3 for libc,
-- then to an unqualified lookup.
local function man_lookup()
  local word = vim.fn.expand("<cword>")
  if word == "" then
    return
  end
  for _, section in ipairs({ "2", "3", "" }) do
    local ok = pcall(vim.cmd, "Man " .. section .. " " .. word)
    if ok then
      return
    end
  end
  vim.notify("no man page for '" .. word .. "'", vim.log.levels.WARN)
end

local function checksec()
  if vim.fn.executable("checksec") == 0 then
    vim.notify("checksec not installed (pacman -S checksec)", vim.log.levels.WARN)
    return
  end
  local target = vim.fn.expand("%:p")
  -- On a C source buffer, inspect the compiled artifact rather than the source.
  if vim.bo.filetype == "c" or vim.bo.filetype == "cpp" then
    target = vim.fn.expand("%:p:r")
  end
  if vim.fn.filereadable(target) == 0 then
    vim.notify("nothing to inspect at " .. target, vim.log.levels.WARN)
    return
  end
  term("checksec --file=" .. vim.fn.shellescape(target) .. " ; echo ; read -n1 -p 'enter to close'")
end

local function debug_current()
  local target = vim.fn.expand("%:p")
  if vim.bo.filetype == "c" or vim.bo.filetype == "cpp" then
    target = build_c(false) or vim.fn.expand("%:p:r")
  end
  -- Standalone pwndbg where present (this desktop); the dojo has no such
  -- command and its gdb already loads pwndbg via ~/.gdbinit, so fall to gdb.
  local dbg = vim.fn.executable("pwndbg") == 1 and "pwndbg" or "gdb"
  term(dbg .. " " .. vim.fn.shellescape(target))
end

return {
  -- -------------------------------------------------------------------
  -- pwntools snippets (LuaSnip, python ft). A separate spec extending the
  -- same plugin merges with the desktop's luasnip.lua -- both opts
  -- functions run.
  -- -------------------------------------------------------------------
  {
    "L3MON4D3/LuaSnip",
    opts = function(_, opts)
      local ls = require("luasnip")
      local s, t, i, c = ls.snippet, ls.text_node, ls.insert_node, ls.choice_node
      local fmt = require("luasnip.extras.fmt").fmta

      ls.add_snippets("python", {
        -- Full exploit skeleton with a local/remote switch.
        s(
          "pwn",
          fmt(
            [[
from pwn import *

exe = context.binary = ELF(<binary>)
context.terminal = ["tmux", "splitw", "-h"]

HOST, PORT = <host>, <port>


def start():
    if args.REMOTE:
        return remote(HOST, PORT)
    if args.GDB:
        return gdb.debug([exe.path], gdbscript=GDBSCRIPT)
    return process([exe.path])


GDBSCRIPT = """
b *main
continue
"""

io = start()

<body>

io.interactive()
]],
            {
              binary = i(1, '"./challenge"'),
              host = i(2, '"localhost"'),
              port = i(3, "1337"),
              body = i(0),
            }
          )
        ),

        -- Minimal header when you just want a REPL-ish script.
        s("pwnh", fmt([[
from pwn import *

context.update(arch=<arch>, os="linux", log_level=<level>)
io = process(<target>)
<body>
]], {
          arch = c(1, { t('"amd64"'), t('"i386"'), t('"aarch64"') }),
          level = c(2, { t('"info"'), t('"debug"') }),
          target = i(3, '["./challenge"]'),
          body = i(0),
        })),

        s("ru", fmt([[io.recvuntil(<d>)<f>]], { d = i(1, 'b"> "'), f = i(0) })),
        s("sla", fmt([[io.sendlineafter(<d>, <p>)<f>]], { d = i(1, 'b"> "'), p = i(2, "payload"), f = i(0) })),
        s("sl", fmt([[io.sendline(<p>)<f>]], { p = i(1, "payload"), f = i(0) })),
        s("p64", fmt([[p64(<v>)<f>]], { v = i(1, "0xdeadbeef"), f = i(0) })),
        s("u64", fmt([[u64(io.recv(6).ljust(8, b"\0"))<f>]], { f = i(0) })),
        s("cyc", fmt([[cyclic(<n>)<f>]], { n = i(1, "128"), f = i(0) })),
        s("cycf", fmt([[cyclic_find(<v>)<f>]], { v = i(1, "0x6161616a"), f = i(0) })),

        -- ROP chain scaffold.
        s("rop", fmt([[
rop = ROP(exe)
rop.raw(rop.find_gadget(["ret"])[0])
rop.call(<func>, [<arg>])
payload = flat({<off>: rop.chain()})
]], {
          func = i(1, 'exe.sym["system"]'),
          arg = i(2, 'next(exe.search(b"/bin/sh\\0"))'),
          off = i(3, "72"),
        })),

        -- Attach a debugger to an already-running process.
        s("gdba", fmt([[
gdb.attach(io, gdbscript="""
b *<addr>
continue
""")
pause()
]], { addr = i(1, "main+42") })),

        s("fmt", fmt([[payload = fmtstr_payload(<off>, {<what>: <val>})<f>]], {
          off = i(1, "6"),
          what = i(2, "exe.got['exit']"),
          val = i(3, "exe.sym['win']"),
          f = i(0),
        })),
      })

      return opts
    end,
  },

  -- -------------------------------------------------------------------
  -- Bindings + which-key group.
  -- -------------------------------------------------------------------
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        { "<leader>k", group = "pwn", icon = "" },
      },
    },
  },
  {
    "LazyVim/LazyVim",
    keys = {
      { "<leader>kb", function() build_c() end, desc = "Build C (pwn flags)" },
      { "<leader>kr", run_current, desc = "Run current file" },
      { "<leader>km", man_lookup, desc = "Man page for word (syscall)" },
      { "<leader>kx", hex_toggle, desc = "Toggle hex (xxd) view" },
      { "<leader>kc", checksec, desc = "checksec on binary" },
      { "<leader>kg", debug_current, desc = "gdb/pwndbg on binary" },
    },
  },
}
