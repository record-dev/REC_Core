
---@type REC_Library.Server.API
local svApi = require "@REC_Library.server.sv_api"

---@type REC_Core.Shared.Config, REC_Core.Server.Config
local shCfg, svCfg = require "@REC_Core.config.sh_config", require "@REC_Core.config.sv_config"

---@type REC_Core.Server.Utils
local utils = require "@REC_Core.server.sv_utils"

---@type REC_Core.Shared.Events
local events = require "@REC_Core.shared.sh_event"

---@class REC_Core.Server.Manager.ServerManagerConfigBuilder: REC_Library.Server.Class.Manager.ServerManagerConfigBuilder
local serverManagerConfigBuilder = svApi.Class.Manager.ServerManagerConfigBuilder:new()
    :setOnInit(function (self)
        ---@cast self REC_Core.Server.Manager.ServerManager
        local info = self.info

        ---[[
        ---     Initialization
        ---]]


        return true
    end)
    :setCustomProperties({})

---@class REC_Core.Server.Manager.ServerManager: REC_Library.Server.Class.Manager.ServerManager]
---@field info REC_Core.Server.Manager.ServerManagerConfigBuilder
local serverManager = svApi.Class.Manager.ServerManager:new(serverManagerConfigBuilder)

return serverManager