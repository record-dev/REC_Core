
---@type REC_Library.Server.API
local svApi = require "@REC_Library.server.sv_api"

---@type REC_Core.Shared.Config, REC_Core.Server.Config
local shCfg, svCfg = require "@REC_Core.config.sh_config", require "@REC_Core.config.sv_config"

---@type REC_Core.Server.Utils
local utils = require "@REC_Core.server.sv_utils"

---@type REC_Core.Shared.Events
local events = require "@REC_Core.shared.sh_event"

---@type REC_Core.Server.Manager.EntityManager
local entityManager = require "@REC_Core.server.manager.sv_entityManager"

---@type REC_Core.Server.Manager.OwnershipManager
local ownershipManager = require "@REC_Core.server.manager.sv_ownershipManager"

---@type REC_Core.Server.Manager.PlayerManager
local playerManager = require "@REC_Core.server.manager.sv_playerManager"

---@type REC_Core.Server.Manager.ZoneManager
local zoneManager = require "@REC_Core.server.manager.sv_zoneManager"

---@class REC_Core.Server.Manager.ServerManagerConfigBuilder: REC_Library.Server.Class.Manager.ServerManagerConfigBuilder
---@field metaDatas table<string, REC_Core.Server.Manager.ServerManagerConfigBuilder.MetaData>
---@field playerIdToCitizenId table<string, string>
local serverManagerConfigBuilder = svApi.Class.Manager.ServerManagerConfigBuilder:new()
    :setOnInit(function (self)
        ---@cast self REC_Core.Server.Manager.ServerManager
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

---@class REC_Core.Server.Manager.ServerManager: REC_Library.Server.Class.Manager.ServerManager]
---@field info REC_Core.Server.Manager.ServerManagerConfigBuilder
local serverManager = svApi.Class.Manager.ServerManager:new(serverManagerConfigBuilder)

---@class REC_Core.Server.Manager.ServerManagerConfigBuilder.MetaData
---@field uid string
---@

return serverManager