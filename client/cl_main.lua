
---@type REC_Library.Client.API, REC_Library.Shared.API
local clApi, shApi = require "@REC_Library.client.cl_api", require "@REC_Library.shared.sh_api"
local apiShCfg = shApi.Config
local apiShEnums = shApi.Enums

---@type REC_Utils.Client.Api
local clUtilsApi = require "@REC_Utils.client.cl_api"

---@type REC_Core.Shared.Config
local shCfg = require "@REC_Core.config.sh_config"

---@type REC_Core.Shared.Enum
local shEnums = require "@REC_Core.shared.sh_enum"

---@type REC_Core.Client.Utils
local utils = require "@REC_Core.client.cl_utils"

---@type REC_Core.Shared.Events
local events = require "@REC_Core.shared.sh_event"

---@type REC_Core.Locales
local locales = require ("@REC_Core.locales.".. apiShCfg.language)

---@type REC_Core.Client.Manager.SessionManager
local sessionManager = require "@REC_Core.client.manager.cl_sessionManager"

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
