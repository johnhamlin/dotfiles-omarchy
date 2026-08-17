-- Rust dev niceties on top of LazyVim's lang.rust + lang.toml extras.
return {
  -- rust-analyzer: run clippy (not plain `cargo check`) for on-save
  -- diagnostics, so the good lints show up inline while editing.
  -- --no-deps keeps it to this workspace instead of linting every
  -- dependency's source (faster, no noise you can't act on).
  {
    "mrcjkb/rustaceanvim",
    opts = {
      server = {
        default_settings = {
          ["rust-analyzer"] = {
            check = {
              command = "clippy",
              extraArgs = { "--no-deps" },
            },
          },
        },
      },
    },
  },

  -- taplo (Cargo.toml / TOML LSP). Its default schema catalog fetch was
  -- failing on every open ("failed to fetch catalog ... data did not match
  -- any variant of untagged enum SchemaCatalog"). Drop the remote catalog
  -- and associate Cargo.toml with the cargo schema directly, so Cargo.toml
  -- still gets completion/validation without the broken catalog round-trip.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        taplo = {
          settings = {
            evenBetterToml = {
              schema = {
                enabled = true,
                catalogs = {}, -- was hitting a catalog endpoint taplo can't parse
                associations = {
                  ["(?:^|/)Cargo\\.toml$"] = "https://json.schemastore.org/cargo.json",
                },
              },
            },
          },
        },
      },
    },
  },
}
