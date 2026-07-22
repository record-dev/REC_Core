
---@type REC_Library.Client.API
local clApi = require "@REC_Library.client.cl_api"

---@type REC_Core.Client.Utils
local utils = require "@REC_Core.client.cl_utils"

---@type REC_Core.Shared.Events
local events = require "@REC_Core.shared.sh_event"

---@class REC_Core.Client.Manager.ZoneManagerConfigBuilder: REC_Library.Client.Class.Manager.ZoneManagerConfigBuilder
local zoneManagerConfigBuilder = clApi.Class.Manager.ZoneManagerConfigBuilder:new()

---@class REC_Core.Client.Manager.ZoneManager: REC_Library.Client.Class.Manager.ZoneManager
local zoneManager = clApi.Class.Manager.ZoneManager:new(zoneManagerConfigBuilder)

return zoneManager