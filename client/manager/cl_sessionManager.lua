
---@type REC_Library.Client.API, REC_Library.Shared.API
local clApi, shApi = require "@REC_Library.client.cl_api", require "@REC_Library.shared.sh_api"

---@type REC_Core.Shared.Config
local shCfg = require "@REC_Core.config.sh_config"

---@type REC_Core.Client.Utils
local utils = require "@REC_Core.client.cl_utils"

---@type REC_Core.Shared.Events
local events = require "@REC_Core.shared.sh_event"

---@type REC_Core.Client.Manager.EntityManager
local entityManager = require "@REC_Core.client.manager.cl_entityManager"

---@type REC_Core.Client.Manager.ZoneManager
local zoneManager   = require "@REC_Core.client.manager.cl_zoneManager"

---@type REC_Core.Client.Manager.BlipManager
local blipManager   = require "@REC_Core.client.manager.cl_blipManager"

---@class REC_Core.Client.Manager.SessionConfigBuilder: REC_Library.Client.Class.Manager.SessionManagerConfigBuilder
local sessionConfigBuilder = clApi.Class.Manager.SessionManagerConfigBuilder:new()
    :setOnInit(function (self)
        ---@cast self REC_Core.Client.Manager.SessionManager
        local info = self.info

        

        return true
    end)
    :setEntityManager(entityManager)
    :setZoneManager(zoneManager)
    :setBlipManager(blipManager)
    :setCustomProperties({})

---For state management on client
---@class REC_Core.Client.Manager.SessionManager: REC_Library.Client.Class.Manager.SessionManager
---@field info REC_Core.Client.Manager.SessionConfigBuilder
local sessionManager = clApi.Class.Manager.SessionManager:new(sessionConfigBuilder)

return sessionManager