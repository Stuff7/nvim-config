-- Complete LSP JSON-RPC Transport Logger
-- Hooks at the deepest level to capture ALL messages

return {
  setup = function(log_file)
    -- Function to truncate only arrays, preserve all object fields
    local function truncate_arrays(obj, max_items)
      max_items = max_items or 3

      local function process(item, depth)
        if depth and depth > 20 then
          return "... (max depth)"
        end
        depth = (depth or 0) + 1

        if type(item) == "table" then
          if vim.islist(item) and #item > max_items then
            local result = {}
            for i = 1, max_items do
              result[i] = process(item[i], depth)
            end
            result[max_items + 1] = string.format("... (%d more items)", #item - max_items)
            return result
          else
            local result = {}
            for k, v in pairs(item) do
              result[k] = process(v, depth)
            end
            return result
          end
        end
        return item
      end

      return process(obj)
    end

    -- Pretty printer for JSON-like output
    local function pretty_print(obj, indent)
      indent = indent or 0
      local spaces = string.rep("  ", indent)

      if type(obj) == "table" then
        if next(obj) == nil then
          return "{}"
        end

        local lines = { "{" }
        for k, v in pairs(obj) do
          local key = type(k) == "string" and string.format('"%s"', k) or tostring(k)
          local value = pretty_print(v, indent + 1)
          table.insert(lines, string.format("%s  %s: %s,", spaces, key, value))
        end
        -- Remove trailing comma from last line
        if #lines > 1 then
          lines[#lines] = lines[#lines]:sub(1, -2)
        end
        table.insert(lines, spaces .. "}")
        return table.concat(lines, "\n")
      elseif type(obj) == "string" then
        return string.format('"%s"', obj:gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '\\r'):gsub('\t', '\\t'))
      elseif obj == vim.NIL then
        return "null"
      elseif type(obj) == "boolean" then
        return obj and "true" or "false"
      else
        return tostring(obj)
      end
    end

    -- Write to log file
    local function log_message(content)
      local file = io.open(log_file, "a")
      if file then
        file:write(content .. "\n")
        file:close()
      end
    end

    -- Get timestamp
    local function timestamp()
      return os.date("%Y-%m-%d %H:%M:%S")
    end

    -- Initialize log
    log_message(string.format("=== LSP JSON-RPC Transport Logging Started at %s ===\n", timestamp()))

    -- Hook into the deepest level - the actual RPC transport
    local original_rpc_start = vim.lsp.rpc.start

    vim.lsp.rpc.start = function(cmd, cmd_args, dispatchers, extra_spawnopts)
      local client_name = cmd and cmd[1] or (cmd_args and cmd_args[1]) or "unknown"

      -- Create new dispatchers that log everything
      local logging_dispatchers = {}

      if dispatchers then
        -- Copy existing dispatchers
        for k, v in pairs(dispatchers) do
          logging_dispatchers[k] = v
        end

        -- Override notification dispatcher
        if dispatchers.notification then
          logging_dispatchers.notification = function(method, params)
            local message = {
              jsonrpc = "2.0",
              method = method,
              params = params
            }

            log_message(string.format(
              "[%s] <<< INCOMING NOTIFICATION (%s)\n%s\n%s",
              timestamp(),
              client_name,
              pretty_print(truncate_arrays(message)),
              string.rep("=", 80)
            ))

            return dispatchers.notification(method, params)
          end
        end

        -- Override server_request dispatcher
        if dispatchers.server_request then
          logging_dispatchers.server_request = function(method, params)
            local message = {
              jsonrpc = "2.0",
              method = method,
              params = params,
              id = "server_request"
            }

            log_message(string.format(
              "[%s] <<< INCOMING SERVER REQUEST (%s)\n%s\n%s",
              timestamp(),
              client_name,
              pretty_print(truncate_arrays(message)),
              string.rep("=", 80)
            ))

            return dispatchers.server_request(method, params)
          end
        end
      end

      return original_rpc_start(cmd, cmd_args, logging_dispatchers, extra_spawnopts)
    end

    -- Hook vim.lsp.rpc.request for outgoing requests
    local original_request = vim.lsp.rpc.request
    vim.lsp.rpc.request = function(method, params, callback, notify_reply_callback)
      -- Generate a request ID
      local request_id = math.random(1000000, 9999999)

      local request_message = {
        jsonrpc = "2.0",
        id = request_id,
        method = method,
        params = params
      }

      log_message(string.format(
        "[%s] >>> OUTGOING REQUEST\n%s\n%s",
        timestamp(),
        pretty_print(truncate_arrays(request_message)),
        string.rep("=", 80)
      ))

      -- Wrap callback to log response
      local wrapped_callback = callback and function(err, result)
        local response_message = {
          jsonrpc = "2.0",
          id = request_id
        }

        if err then
          response_message.error = err
        else
          response_message.result = result
        end

        log_message(string.format(
          "[%s] <<< INCOMING RESPONSE\n%s\n%s",
          timestamp(),
          pretty_print(truncate_arrays(response_message)),
          string.rep("=", 80)
        ))

        return callback(err, result)
      end or nil

      return original_request(method, params, wrapped_callback, notify_reply_callback)
    end

    -- Hook vim.lsp.rpc.notify for outgoing notifications
    local original_notify = vim.lsp.rpc.notify
    vim.lsp.rpc.notify = function(method, params)
      local notification_message = {
        jsonrpc = "2.0",
        method = method,
        params = params
      }

      log_message(string.format(
        "[%s] >>> OUTGOING NOTIFICATION\n%s\n%s",
        timestamp(),
        pretty_print(truncate_arrays(notification_message)),
        string.rep("=", 80)
      ))

      return original_notify(method, params)
    end

    -- Also hook into the lower-level request_with_cancel in case it's used
    if vim.lsp.rpc.request_with_cancel then
      local original_request_with_cancel = vim.lsp.rpc.request_with_cancel
      vim.lsp.rpc.request_with_cancel = function(method, params, callback, notify_reply_callback)
        local request_id = math.random(1000000, 9999999)

        local request_message = {
          jsonrpc = "2.0",
          id = request_id,
          method = method,
          params = params
        }

        log_message(string.format(
          "[%s] >>> OUTGOING REQUEST (with cancel)\n%s\n%s",
          timestamp(),
          pretty_print(truncate_arrays(request_message)),
          string.rep("=", 80)
        ))

        local wrapped_callback = callback and function(err, result)
          local response_message = {
            jsonrpc = "2.0",
            id = request_id
          }

          if err then
            response_message.error = err
          else
            response_message.result = result
          end

          log_message(string.format(
            "[%s] <<< INCOMING RESPONSE (with cancel)\n%s\n%s",
            timestamp(),
            pretty_print(truncate_arrays(response_message)),
            string.rep("=", 80)
          ))

          return callback(err, result)
        end or nil

        return original_request_with_cancel(method, params, wrapped_callback, notify_reply_callback)
      end
    end

    -- Hook individual client request methods as backup
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then return end

        log_message(string.format(
          "[%s] LSP CLIENT ATTACHED: %s (ID: %d) - Buffer: %d",
          timestamp(), client.name, client.id, args.buf
        ))

        -- Hook the client's request method as a backup
        if client.request then
          local original_client_request = client.request
          client.request = function(self, method, params, callback, bufnr)
            local request_id = math.random(1000000, 9999999)

            local request_message = {
              jsonrpc = "2.0",
              id = request_id,
              method = method,
              params = params
            }

            log_message(string.format(
              "[%s] >>> CLIENT REQUEST (%s)\n%s\n%s",
              timestamp(),
              client.name,
              pretty_print(truncate_arrays(request_message)),
              string.rep("=", 80)
            ))

            local wrapped_callback = callback and function(err, result, context, config)
              local response_message = {
                jsonrpc = "2.0",
                id = request_id
              }

              if err then
                response_message.error = err
              else
                response_message.result = result
              end

              log_message(string.format(
                "[%s] <<< CLIENT RESPONSE (%s)\n%s\n%s",
                timestamp(),
                client.name,
                pretty_print(truncate_arrays(response_message)),
                string.rep("=", 80)
              ))

              return callback(err, result, context, config)
            end or nil

            return original_client_request(self, method, params, wrapped_callback, bufnr)
          end
        end
      end
    })

    -- Log function calls for debugging
    local function wrap_buf_function(name)
      local original = vim.lsp.buf[name]
      if original then
        vim.lsp.buf[name] = function(...)
          log_message(string.format("[%s] FUNCTION CALL: vim.lsp.buf.%s()", timestamp(), name))
          return original(...)
        end
      end
    end

    local functions = { "hover", "definition", "references", "signature_help", "code_action" }
    for _, name in ipairs(functions) do
      wrap_buf_function(name)
    end

    vim.notify("Deep LSP JSON-RPC logging enabled: " .. log_file, vim.log.levels.INFO)
  end
}
