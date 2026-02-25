-- Override LazyVim octo extra: enable local FS for LSP in review diffs
return {
  "pwntester/octo.nvim",
  opts = {
    use_local_fs = true,
  },
}
