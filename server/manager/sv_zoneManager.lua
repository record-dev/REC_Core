
---@type REC_Library.Server.API
local svApi = require "@REC_Library.server.sv_api"

---@type REC_ScriptTemplate.Server.Utils
local utils = require "@REC_ScriptTemplate.server.sv_utils"

---@type REC_ScriptTemplate.Shared.Events
local events = require "@REC_ScriptTemplate.shared.sh_event"

---@class REC_ScriptTemplate.Server.Manager.ZoneManagerConfigBuilder: REC_Library.Server.Class.Manager.ZoneManagerConfigBuilder
local zoneManagerConfigBuilder = svApi.Class.Manager.ZoneManagerConfigBuilder:new()

---@class REC_ScriptTemplate.Server.Manager.ZoneManager: REC_Library.Server.Class.Manager.ZoneManager
local zoneManager = svApi.Class.Manager.ZoneManager:new(zoneManagerConfigBuilder)

return zoneManager