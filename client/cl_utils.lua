
---@type REC_Utils.Client.Api
local clUtilsApi = require "@REC_Utils.client.cl_api"

---@type REC_Core.Server.Config
local shCfg = require "@REC_Core.config.sh_config"

---@class REC_Core.Client.Utils
local utils = {}

---[[
---     Notify
---]]
---@param notifyType "info" | "success" | "warning" | "error" 
---@param title string
---@param description string
---@param duration? integer
---@param showDuration? boolean
function utils:notify(notifyType, title, description, duration, showDuration)
    duration = duration or 4000
    showDuration = showDuration or false

    clUtilsApi.Notify:trigger(
        notifyType,
        title,
        description,
        duration,
        true
    )
end

---[[
---     Debug output
---]]
---@param ... string
function utils:debugPrint(...)
    if shCfg.debugMode == true then
        print(...)
    end
end

return utils