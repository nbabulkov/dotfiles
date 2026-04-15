-- Fix for nvim-treesitter's set-lang-from-info-string! directive crashing on
-- Neovim 0.12, where quantified captures in iter_matches can return a table of
-- nodes instead of a single node. The upstream query_predicates.lua nil-checks
-- the node but not whether it's a table, so node:range() fails inside
-- vim.treesitter.get_node_text.
--
-- To check if this is still needed: look at query_predicates.lua in nvim-treesitter
-- and see if set-lang-from-info-string! handles `type(node) == "table"`.
-- If it does, delete this file.
if vim.fn.has("nvim-0.12") ~= 1 then
  return
end

local qp_path = vim.api.nvim_get_runtime_file("lua/nvim-treesitter/query_predicates.lua", false)[1]
if qp_path then
  local src = io.open(qp_path):read("*a")
  if src:find('type(node) == "table"', 1, true) then
    vim.notify(
      "[treesitter_nvim12_fix] nvim-treesitter has fixed the quantified captures bug.\n"
      .. "You can delete: " .. vim.fn.stdpath("config") .. "/after/plugin/treesitter_nvim12_fix.lua",
      vim.log.levels.WARN
    )
    return
  end
end

local non_filetype_aliases = {
  ex = "elixir", pl = "perl", sh = "bash", uxn = "uxntal", ts = "typescript",
}

local function resolve_lang(alias)
  return vim.filetype.match({ filename = "a." .. alias })
    or non_filetype_aliases[alias]
    or alias
end

vim.treesitter.query.add_directive(
  "set-lang-from-info-string!",
  function(match, _, bufnr, pred, metadata)
    local node = match[pred[2]]
    if not node then return end
    -- Neovim 0.12: quantified captures return a list of nodes
    if type(node) == "table" then node = node[1] end
    if not node then return end
    local text = vim.treesitter.get_node_text(node, bufnr)
    if text then
      metadata["injection.language"] = resolve_lang(text:lower())
    end
  end,
  { force = true, all = false }
)
