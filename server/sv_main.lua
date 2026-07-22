
---@type REC_Library.Server.API, REC_Library.Shared.API
local svApi, shApi = require "@REC_Library.server.sv_api", require "@REC_Library.shared.sh_api"
local apiShCfg = shApi.Config

---@type REC_ScriptTemplate.Shared.Config, REC_ScriptTemplate.Server.Config
local shCfg, svCfg = require "@REC_ScriptTemplate.config.sh_config", require "@REC_ScriptTemplate.config.sv_config"

---@type REC_ScriptTemplate.Server.Utils
local utils = require "@REC_ScriptTemplate.server.sv_utils"

---@type REC_ScriptTemplate.Shared.Events
local events = require "@REC_ScriptTemplate.shared.sh_event"

---@type REC_ScriptTemplate.Locales
local locales = require ("@REC_ScriptTemplate.locales.".. apiShCfg.language)

---@type REC_ScriptTemplate.Server.Manager.ServerManager
local serverManager = require "@REC_ScriptTemplate.server.manager.sv_serverManager"

---[[
---     Initialization
---]]
if serverManager:init() == false then
    print("^1failed to init serverManager....^0")
    return
end

local serverManagerInfo = serverManager.info



---[[
---     Detect player spawn event
---]]
---@param src integer
---@param payload REC_PlayerManager.Server.Main.PlayerLoaded.Payload
AddEventHandler('REC_PlayerManager:server:onPlayerLoaded', function(src, payload)

    utils:debugPrint(("^5player %d is loaded... \ntrying to initialize....^0"):format(src))

    -- -- Register metadata
    -- if utils:register(serverManager, src) == false then
    --     utils:debugPrint(("^3failed to register player.... playerId: %d^0"):format(src))
    -- end

    -- -- Get metadata
    -- local metaData = utils:getMetaData(serverManager, payload.citizenId)
    -- if metaData == nil then
    --     utils:debugPrint(("^1failed to get metaData by citizenId: %s ^0"):format(payload.citizenId))
    --     return
    -- end


end)

-- ---[[
-- ---     Detect routing bucket change
-- ---]]
-- ---@param src integer
-- ---@param payload REC_PlayerManager.Server.Main.PlayerRoutingBucketChange.Payload
-- AddEventHandler("REC_PlayerManager:server:onPlayerRoutingBucketChange", function(src, payload)

--     -- -- Get metadata
--     -- local metaData = utils:getMetaData(serverManager, payload.citizenId)
--     -- if metaData == nil then
--     --     utils:debugPrint(("^1failed to get metaData by citizenId: %s ^0"):format(payload.citizenId))
--     --     return
--     -- end
-- end)

---[[
---     Detect player exit event
---]]
---@param src integer
---@param payload REC_PlayerManager.Server.Main.PlayerLeft.Payload
AddEventHandler("REC_PlayerManager:server:onPlayerLeft", function (src, payload)

    utils:debugPrint(("^5player %s is left... \ntrying to unregister....^0"):format(src))

    -- -- Unregister metadata
    -- if utils:unregister(serverManager, payload.citizenId) == false then
    --     utils:debugPrint(("^3failed to unregister player.... playerId: %s^0"):format(src))
    --     return
    -- end
end)

AddEventHandler('onResourceStop', function(resource)
   if resource ~= GetCurrentResourceName() then return end

    print("リソース停止処理を検知...")
end)

---[[
---     Function to check if process is ongoing from other resources
---]]
-- exports('isActive', function()
--     return 
-- end)