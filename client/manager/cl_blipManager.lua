
---@type REC_Library.Client.API
local clApi = require "@REC_Library.client.cl_api"

---@type REC_Core.Client.Utils
local utils = require "@REC_Core.client.cl_utils"

---@type REC_Core.Shared.Events
local events = require "@REC_Core.shared.sh_event"

---@class REC_Core.Client.Main.BlipManaerConfigBuilder: REC_Library.Client.Class.Manager.BlipManagerConfigBuilder
local blipManagerConfigBuilder = clApi.Class.Manager.BlipManagerConfigBuilder:new()

---For state management on client
---@class REC_Core.Client.Manager.BlipManager: REC_Library.Client.Class.Manager.BlipManager
---@field info REC_Core.Client.Main.BlipManaerConfigBuilder
local blipManager = clApi.Class.Manager.BlipManager:new(blipManagerConfigBuilder)

return blipManager