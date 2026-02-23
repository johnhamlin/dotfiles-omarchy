-- Keep noisy LSPs in their lanes + only enable Angular when it's actually an Angular repo
return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local util = require("lspconfig.util")
      opts.servers = opts.servers or {}

      -- 1) Restrict Ember to real Ember projects (no more attaching in plain TS/JS)
      opts.servers.ember = {
        filetypes = { "handlebars", "typescript.glimmer", "javascript.glimmer" },
        root_dir = util.root_pattern("ember-cli-build.js"), -- remove ".git"
      }

      -- 2) Prevent angularls from starting outside Angular workspaces
      opts.servers.angularls = {
        root_dir = util.root_pattern("angular.json", "nx.json"),
        single_file_support = false,
      }

      -- 3) Only inject the Angular TS plugin into vtsls when an Angular root exists
      opts.servers.vtsls = opts.servers.vtsls or {}
      local old_on_new_config = opts.servers.vtsls.on_new_config
      opts.servers.vtsls.on_new_config = function(config, root_dir)
        if old_on_new_config then
          old_on_new_config(config, root_dir)
        end
        local is_angular = util.root_pattern("angular.json", "nx.json")(root_dir) ~= nil

        -- Start from any existing plugins but strip stray Angular entries
        local plugins = (((config.settings or {}).vtsls or {}).tsserver or {}).globalPlugins or {}
        local filtered = {}
        for _, p in ipairs(plugins) do
          if p.name ~= "@angular/language-server" then
            table.insert(filtered, p)
          end
        end

        if is_angular then
          local mason_ok, registry = pcall(require, "mason-registry")
          local angular_path = nil
          if mason_ok then
            local pkg = registry.get_package("angular-language-server")
            if pkg and pkg:is_installed() then
              angular_path = pkg:get_install_path() .. "/node_modules/@angular/language-server"
            end
          end
          table.insert(filtered, {
            name = "@angular/language-server",
            location = angular_path, -- ok if nil; Node will resolve from workspace
            enableForWorkspaceTypeScriptVersions = false,
          })
        end

        config.settings = vim.tbl_deep_extend("force", config.settings or {}, {
          vtsls = { tsserver = { globalPlugins = filtered } },
        })
      end
    end,
  },
}
