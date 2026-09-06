
---@type REC_Core.Shared.Config
local shCfg = require "@REC_Core.config.sh_config"

---@type REC_Core.Locales
local locales = require ("@REC_Core.locales.".. shCfg.language)

---@type REC_Core.Client.Bridge
local bridge = require "@REC_Core.client.cl_bridge"

---@class REC_Core.Client.Utils
local utils = {}

---[[
---     Notify
---]]
---@param notifyType "info" | "success" | "warning" | "error"
---@param title string
---@param description string
---@param duration? integer
function utils:notify(notifyType, title, description, duration)

    ---@type REC_Core.Client.Main.Notify.Payload
    local payload = {
        type = notifyType,
        title = title,
        description = description,
        duration = duration or 4000,
    }

    bridge:notify(payload)
end

---[[
---     Message for an error code the server sent back
---]]
---@param code any
---@return string
function utils:errorMessage(code)

    if type(code) == "string" and locales.error[code] ~= nil then
        return locales.error[code]
    end

    return locales.error.generic
end

---@param code any
function utils:notifyError(code)
    self:notify("error", locales.notify.title, self:errorMessage(code))
end

---[[
---     Timestamp from the DB -> something a player can read
---     oxmysql hands timestamps over as milliseconds or as a string depending on its settings.
---]]
---@param timestamp any
---@return string
function utils:formatTimestamp(timestamp)

    if type(timestamp) == "number" then

        local seconds = timestamp > 100000000000 and math.floor(timestamp / 1000) or math.floor(timestamp)

        local isSuccessful, formatted = pcall(os.date, "%Y-%m-%d %H:%M", seconds)
        if isSuccessful == true and type(formatted) == "string" then
            return formatted
        end
    end

    if type(timestamp) == "string" and timestamp ~= "" then
        return timestamp:sub(1, 16)
    end

    return locales.menu.lastPlayed_never
end

---[[
---     Debug output
---]]
---@param ... any
function utils:debugPrint(...)
    if shCfg.debugMode == true then
        print(...)
    end
end

return utils
