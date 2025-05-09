local M = {}

---maps the table|string of keys to the action
---@param keys table
---@param action function|string
function M.nmap(bufnr, keys, action)
  for _, lhs in ipairs(keys) do
    vim.keymap.set('n', lhs, action, { silent = true, noremap = true, buffer = bufnr })
  end
end

--- @param  f function
--- @param  delay number
--- @return function
function M.debounce(f, delay)
  local timer = vim.loop.new_timer()

  return function(...)
    local args = { ... }

    timer:start(
      delay,
      0,
      vim.schedule_wrap(function()
        timer:stop()
        f(unpack(args))
      end)
    )
  end
end

function M.flash_highlight(winnr, lnum, durationMs, hl_group)
  if durationMs == false then
    return
  end
  hl_group = hl_group or 'Visual'
  if durationMs == true or durationMs == 1 then
    durationMs = 400
  end
  local bufnr = vim.api.nvim_win_get_buf(winnr)
  local ns
  if _G._outline_nvim_has[11] then
    ns = vim.api.nvim_create_namespace('_outline_nvim_flash')
    vim.hl.range(bufnr, ns, hl_group, { lnum - 1, 0 }, { lnum - 1, -1 })
  else
    ---@diagnostic disable-next-line:deprecated
    ns = vim.api.nvim_buf_add_highlight(bufnr, 0, hl_group, lnum - 1, 0, -1)
  end
  local remove_highlight = function()
    pcall(vim.api.nvim_buf_clear_namespace, bufnr, ns, 0, -1)
  end
  vim.defer_fn(remove_highlight, durationMs)
end

---@param module string   Used as message if second param omitted
---@param message string?
function M.echo(module, message)
  if not message then
    message = module
    module = ''
  end
  local prefix = 'outline'
  if module ~= '' then
    prefix = prefix .. '.' .. module
  end
  local prefix_chunk = { '(' .. prefix .. ') ', 'WarningMsg' }
  -- For now we don't echo much, so add all to history
  vim.api.nvim_echo({ prefix_chunk, { message } }, true, {})
end

---@param t table?
function M.table_has_content(t)
  return t and next(t) ~= nil
end

---@param t table|string?
function M.str_or_nonempty_table(t)
  return type(t) == 'string' or M.table_has_content(t)
end

function M.table_to_str(t)
  local ret = ''
  for _, value in ipairs(t) do
    ret = ret .. tostring(value)
  end
  return ret
end

function M.str_to_table(str)
  local t = {}
  for i = 1, #str do
    t[i] = str:sub(i, i)
  end
  return t
end

--- Copies an array and returns it because lua usually does references
---@generic T
---@param t T[]
---@return T[]
function M.array_copy(t)
  local ret = {}
  for _, value in ipairs(t) do
    table.insert(ret, value)
  end
  return ret
end

--- Deep copy a table, deeply excluding certain keys
function M.deepcopy_excluding(t, keys)
  local res = {}

  for key, value in pairs(t) do
    if not vim.tbl_contains(keys, key) then
      if type(value) == 'table' then
        res[key] = M.deepcopy_excluding(value, keys)
      else
        res[key] = value
      end
    end
  end

  return res
end

--- Get option value of given buffer.
--- @param bufnr integer
--- @param name string
--- @return any
function M.buf_get_option(bufnr, name)
  if _G._outline_nvim_has[10] then
    return vim.api.nvim_get_option_value(name, { buf = bufnr })
  else
    ---@diagnostic disable-next-line:deprecated
    return vim.api.nvim_buf_get_option(bufnr, name)
  end
end

--- Set option value of given buffer.
--- @param bufnr integer
--- @param name string
function M.buf_set_option(bufnr, name, value)
  if _G._outline_nvim_has[10] then
    return vim.api.nvim_set_option_value(name, value, { buf = bufnr })
  else
    ---@diagnostic disable-next-line:deprecated
    return vim.api.nvim_buf_set_option(bufnr, name, value)
  end
end

--- Get option value of given window.
--- @param winnr integer
--- @param name string
--- @return any
function M.win_get_option(winnr, name)
  if _G._outline_nvim_has[10] then
    return vim.api.nvim_get_option_value(name, { win = winnr })
  else
    ---@diagnostic disable-next-line:deprecated
    return vim.api.nvim_buf_get_option(winnr, name)
  end
end

--- Set option value of given window.
--- @param winnr integer
--- @param name string
function M.win_set_option(winnr, name, value)
  if _G._outline_nvim_has[10] then
    return vim.api.nvim_set_option_value(name, value, { win = winnr })
  else
    ---@diagnostic disable-next-line:deprecated
    return vim.api.nvim_win_set_option(winnr, name, value)
  end
end

return M
