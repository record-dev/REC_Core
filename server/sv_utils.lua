
---@type REC_Library.Server.API, REC_Library.Shared.API
local svApi, shApi = require "@REC_Library.server.sv_api", require "@REC_Library.shared.sh_api"

---@type REC_Utils.Server.Api
local svUtilsApi = require "@REC_Utils.server.sv_api"

---@type REC_Core.Shared.Config, REC_Core.Server.Config
local shCfg, svCfg = require "@REC_Core.config.sh_config", require "@REC_Core.config.sv_config"

---[[
---     DO NOT TOUCH
---]]
---@type string
local tableName = "rec_core"

---@class REC_Core.Server.Utils
local utils = {}

---[[
---     Notify
---]]
---@param playerId integer
---@param notifyType "info" | "success" | "warning" | "error" 
---@param title string
---@param description string
---@param duration? integer
---@param showDuration? boolean
function utils:notify(playerId, notifyType, title, description, duration, showDuration)
    duration = duration or 4000
    showDuration = showDuration or false

    svUtilsApi.Notify:trigger(
        playerId,
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
---@param ... any
function utils:debugPrint(...)
    if svCfg.debugMode == true then
        print(...)
    end
end

---@class REC_Core.Server.Utils.CreateMetaData.Payload
---@

---@class REC_Core.Server.Utils.UpdateMetaData.Payload
---@

---@class REC_Core.Server.Utils.GetRecord.Return
---@field id? integer
---@
---@
---@
---@field updatedAt? integer
---@field createdAt? integer

---@class REC_Core.Server.Utils.CreateRecord.Payload
---@

---@class REC_Core.Server.Utils.UpdateRecord.Payload
---@


return utils