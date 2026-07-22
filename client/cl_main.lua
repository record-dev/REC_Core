
---@type REC_Library.Client.API, REC_Library.Shared.API
local clApi, shApi = require "@REC_Library.client.cl_api", require "@REC_Library.shared.sh_api"
local apiShCfg = shApi.Config
local apiShEnums = shApi.Enums

---@type REC_Utils.Client.Api
local clUtilsApi = require "@REC_Utils.client.cl_api"

---@type REC_ScriptTemplate.Shared.Config
local shCfg = require "@REC_ScriptTemplate.config.sh_config"

---@type REC_ScriptTemplate.Shared.Enum
local shEnums = require "@REC_ScriptTemplate.shared.sh_enum"

---@type REC_ScriptTemplate.Client.Utils
local utils = require "@REC_ScriptTemplate.client.cl_utils"

---@type REC_ScriptTemplate.Shared.Events
local events = require "@REC_ScriptTemplate.shared.sh_event"

---@type REC_ScriptTemplate.Locales
local locales = require ("@REC_ScriptTemplate.locales.".. apiShCfg.language)

---@type REC_ScriptTemplate.Client.Manager.SessionManager
local sessionManager = require "@REC_ScriptTemplate.client.manager.cl_sessionManager"

---[[
---     Initialization
---]]
if sessionManager:init() == false then
    print("^1failed to init sessionManager^0")
    return
end

local sessionManagerInfo = sessionManager.info



---[[
---     Handler
---]]
clApi.Class.Handler.HandlerBuilder:new()
    :setOnPlayerLoaded(function (...)



    end)
    :setOnPlayerLoggedOut(function (...)



    end)
    :setOnResourceStart(function (resourceName, ...)

        -- Resource check
        if resourceName ~= GetCurrentResourceName() then
            return
        end


    end)
    :setOnResourceStop(function (resourceName, ...)

        -- Resource check
        if resourceName ~= GetCurrentResourceName() then
            return
        end


    end)

---[[
---     Monitor vehicle entry/exit events
---]]
lib.onCache('vehicle', function(entity, _)

    -- Cancel if it's an exit event
    if entity == false then
        return
    end


end)
