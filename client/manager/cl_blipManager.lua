
---@type REC_Library.Client.API
local clApi = require "@REC_Library.client.cl_api"

---@type REC_ScriptTemplate.Client.Utils
local utils = require "@REC_ScriptTemplate.client.cl_utils"

---@type REC_ScriptTemplate.Shared.Events
local events = require "@REC_ScriptTemplate.shared.sh_event"

---@class REC_ScriptTemplate.Client.Main.BlipManaerConfigBuilder: REC_Library.Client.Class.Manager.BlipManagerConfigBuilder
local blipManagerConfigBuilder = clApi.Class.Manager.BlipManagerConfigBuilder:new()

---For state management on client
---@class REC_ScriptTemplate.Client.Manager.BlipManager: REC_Library.Client.Class.Manager.BlipManager
---@field info REC_ScriptTemplate.Client.Main.BlipManaerConfigBuilder
local blipManager = clApi.Class.Manager.BlipManager:new(blipManagerConfigBuilder)

return blipManager