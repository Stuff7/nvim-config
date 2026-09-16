-- LSP JSON-RPC Transport Logger
--
-- Uses vim.lsp.log.set_format_func, the documented formatting hook for
-- Nvim's own LSP debug log. The handle receives (level, event, payload)
-- as real Lua values, exactly what log.debug('rpc.send', payload) passed
-- internally, so no text re-parsing is needed. This never touches
-- Client:request, Client:notify, self.rpc, or any dispatcher, so it cannot
-- change LSP client behavior.
--
-- Output defaults to compact (arrays truncated to 3 items).
-- Set LSP_LOG_FULL=1 to log every item in full.

local function truncate_arrays(obj, max_items, depth)
  max_items = max_items or 3
  depth = depth or 0
  if depth > 20 then return "... (max depth)" end
  if type(obj) ~= "table" then return obj end

  local is_list = vim.islist(obj)
  if is_list and #obj > max_items then
    local result = {}
    for i = 1, max_items do
      result[i] = truncate_arrays(obj[i], max_items, depth + 1)
    end
    result[max_items + 1] = string.format("... (%d more items)", #obj - max_items)
    return result
  end

  local result = {}
  for k, v in pairs(obj) do
    result[k] = truncate_arrays(v, max_items, depth + 1)
  end
  return result
end

local function identity(obj)
  return obj
end

local function pretty_print(obj, indent)
  indent = indent or 0
  local spaces = string.rep("  ", indent)

  if type(obj) == "table" then
    if next(obj) == nil then return "{}" end

    if vim.islist(obj) then
      local lines = { "[" }
      for _, v in ipairs(obj) do
        table.insert(lines, string.format("%s  %s,", spaces, pretty_print(v, indent + 1)))
      end
      lines[#lines] = lines[#lines]:sub(1, -2)
      table.insert(lines, spaces .. "]")
      return table.concat(lines, "\n")
    end

    local lines = { "{" }
    for k, v in pairs(obj) do
      local key = string.format('"%s"', tostring(k):gsub('"', '\\"'))
      table.insert(lines, string.format("%s  %s: %s,", spaces, key, pretty_print(v, indent + 1)))
    end
    lines[#lines] = lines[#lines]:sub(1, -2)
    table.insert(lines, spaces .. "}")
    return table.concat(lines, "\n")
  elseif type(obj) == "string" then
    local escaped = obj:gsub("\\", "\\\\"):gsub('"', '\\"'):gsub("\n", "\\n"):gsub("\r", "\\r"):gsub("\t", "\\t")
    return string.format('"%s"', escaped)
  elseif obj == vim.NIL or obj == nil then
    return "null"
  elseif type(obj) == "boolean" then
    return obj and "true" or "false"
  else
    return tostring(obj)
  end
end

local function timestamp()
  return os.date("%Y-%m-%d %H:%M:%S")
end

local DIRECTION_BY_EVENT = {
  ["rpc.send"] = ">>> OUTGOING",
  ["rpc.receive"] = "<<< INCOMING",
  ["notification"] = "<<< INCOMING NOTIFICATION",
  ["server_request"] = "<<< INCOMING SERVER REQUEST",
  ["client_exit"] = "--- CLIENT EXIT",
}

local function write_outgoing_json(path, messages)
  local outfile, open_err = io.open(path, "w")
  if not outfile then
    vim.notify("Failed to open outgoing JSON file: " .. tostring(open_err), vim.log.levels.ERROR)
    return
  end
  outfile:write(vim.json.encode(messages))
  outfile:close()
end

local active = nil

return {
  setup = function(log_file, outgoing_file)
    local output_path = log_file and vim.fn.fnamemodify(log_file, ":p") or nil
    local outgoing_path = outgoing_file and vim.fn.fnamemodify(outgoing_file, ":p") or nil

    if not output_path and not outgoing_path then
      return
    end

    local session_key = output_path or ("outgoing:" .. (outgoing_path or ""))

    if active then
      if active.key == session_key then
        return
      end
      if active.outfile then
        active.outfile:close()
      end
      active = nil
    end

    local outfile = nil
    if output_path then
      vim.fn.mkdir(vim.fn.fnamemodify(output_path, ":h"), "p")

      local open_err
      outfile, open_err = io.open(output_path, "w")
      if not outfile then
        vim.notify("Failed to open LSP log file: " .. tostring(open_err), vim.log.levels.ERROR)
        return
      end

      outfile:write(string.format("=== LSP JSON-RPC Transport Logging Started at %s ===\n\n", timestamp()))
      outfile:flush()
    end

    if outgoing_path then
      vim.fn.mkdir(vim.fn.fnamemodify(outgoing_path, ":h"), "p")
    end

    local full = vim.env.LSP_LOG_FULL == "1"
    local process_arrays = full and identity or truncate_arrays
    local outgoing_messages = {}

    active = { key = session_key, outfile = outfile }

    vim.lsp.log.set_level("debug")

    vim.lsp.log.set_format_func(function(level, event, payload)
      if level ~= "DEBUG" or type(event) ~= "string" then
        return nil
      end
      if not active or active.key ~= session_key then
        return nil
      end

      if outfile then
        local direction = DIRECTION_BY_EVENT[event] or ("--- " .. event:upper())
        local rendered = payload ~= nil and pretty_print(process_arrays(payload)) or "{}"

        outfile:write(string.format(
          "[%s] %s\n%s\n%s\n",
          timestamp(), direction,
          rendered,
          string.rep("=", 80)
        ))
        outfile:flush()
      end

      if outgoing_path and event == "rpc.send" and payload ~= nil then
        table.insert(outgoing_messages, payload)
        write_outgoing_json(outgoing_path, outgoing_messages)
      end

      return nil
    end)

    vim.api.nvim_create_autocmd("VimLeavePre", {
      callback = function()
        vim.schedule(function()
          if active and active.key == session_key then
            if outfile then
              outfile:close()
            end
            active = nil
          end
        end)
      end,
    })

    vim.notify(
      string.format(
        "LSP logging enabled: %s%s (%s)",
        output_path or "(outgoing only)",
        outgoing_path and (", " .. outgoing_path) or "",
        full and "full" or "compact"
      ),
      vim.log.levels.INFO
    )
  end,
}
