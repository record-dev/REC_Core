
---@type REC_Library.Server.API
local svApi = require "@REC_Library.server.sv_api"

---@type REC_Core.Server.Utils
local utils = require "@REC_Core.server.sv_utils"

---@type REC_Core.Shared.Events
local events = require "@REC_Core.shared.sh_event"

---@class REC_Core.Server.Manager.ZoneManagerConfigBuilder: REC_Library.Server.Class.Manager.ZoneManagerConfigBuilder
local zoneManagerConfigBuilder = svApi.Class.Manager.ZoneManagerConfigBuilder:new()

---@class REC_Core.Server.Manager.ZoneManager: REC_Library.Server.Class.Manager.ZoneManager
local zoneManager = svApi.Class.Manager.ZoneManager:new(zoneManagerConfigBuilder)

return zoneManager