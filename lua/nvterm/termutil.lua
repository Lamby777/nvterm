local util = {}
local a = vim.api

util.calc_float_opts = function(opts)
  return {
    relative = "editor",
    width = math.ceil(opts.width * vim.o.columns),
    height = math.ceil(opts.height * vim.o.lines),
    row = math.floor(opts.row * vim.o.lines),
    col = math.floor(opts.col * vim.o.columns),
    border = opts.border,
  }
end

util.get_split_dims = function(type, ratio)
  local type_switch = type == "horizontal"
  local type_func = type_switch and a.nvim_win_get_height or a.nvim_win_get_width
  return math.floor(type_func(0) * ratio)
end

util.execute_type_cmd = function(type, terminals, override)
  local opts = terminals.type_opts[type]
  local dims = type ~= "float" and util.get_split_dims(type, opts.split_ratio) or util.calc_float_opts(opts)
  dims = override and "" or dims
  local type_cmds = {
    horizontal = function()
      vim.cmd(opts.location .. dims .. " split")
    end,
    vertical = function()
      vim.cmd(opts.location .. dims .. " vsplit")
    end,
    float = function()
      a.nvim_open_win(0, true, dims)
    end,
  }

  type_cmds[type]()
end

util.verify_terminals = function(terminals)
  for i, term in pairs(terminals.list) do
    local valid = vim.api.nvim_buf_is_valid(term.buf)

    if not valid then
      -- TODO filter out nils from list
      terminals.list[i] = nil
    end
  end

  terminals.list = vim.tbl_map(function(term)
    term.open = vim.api.nvim_win_is_valid(term.win)
    return term
  end, terminals.list)

  return terminals
end

return util
