
---@type REC_Library.Server.API
local svApi = require "@REC_Library.server.sv_api"

---@type REC_ScriptTemplate.Shared.Config, REC_ScriptTemplate.Server.Config
local shCfg, svCfg = require "@REC_ScriptTemplate.config.sh_config", require "@REC_ScriptTemplate.config.sv_config"

---@type REC_ScriptTemplate.Server.Utils
local utils = require "@REC_ScriptTemplate.server.sv_utils"

---@type REC_ScriptTemplate.Shared.Events
local events = require "@REC_ScriptTemplate.shared.sh_event"

---@type REC_ScriptTemplate.Server.Manager.EntityManager
local entityManager = require "@REC_ScriptTemplate.server.manager.sv_entityManager"

---@type REC_ScriptTemplate.Server.Manager.OwnershipManager
local ownershipManager = require "@REC_ScriptTemplate.server.manager.sv_ownershipManager"

---@type REC_ScriptTemplate.Server.Manager.PlayerManager
local playerManager = require "@REC_ScriptTemplate.server.manager.sv_playerManager"

---@type REC_ScriptTemplate.Server.Manager.ZoneManager
local zoneManager = require "@REC_ScriptTemplate.server.manager.sv_zoneManager"

---@class REC_ScriptTemplate.Server.Manager.ServerManagerConfigBuilder: REC_Library.Server.Class.Manager.ServerManagerConfigBuilder
---@field metaDatas table<string, REC_ScriptTemplate.Server.Manager.ServerManagerConfigBuilder.MetaData>
---@field playerIdToCitizenId table<string, string>
local serverManagerConfigBuilder = svApi.Class.Manager.ServerManagerConfigBuilder:new()
    :setOnInit(function (self)
        ---@cast self REC_ScriptTemplate.Server.Manager.ServerManager
        local info = self.info

        ---[[
        ---     Initialization
        ---]]

        info.metaDatas = {}
        info.playerIdToCitizenId = {}

        return true
    end)
    :setPlayerManager(playerManager)
    :setEntityManager(entityManager)
    :setOwnershipManager(ownershipManager)
    :setZoneManager(zoneManager)
    :setCustomProperties({})

---@class REC_ScriptTemplate.Server.Manager.ServerManager: REC_Library.Server.Class.Manager.ServerManager]
---@field info REC_ScriptTemplate.Server.Manager.ServerManagerConfigBuilder
local serverManager = svApi.Class.Manager.ServerManager:new(serverManagerConfigBuilder)

---@class REC_ScriptTemplate.Server.Manager.ServerManagerConfigBuilder.MetaData
---@field uid string
---@

return serverManager