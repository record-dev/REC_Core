
---@type REC_Library.Server.API
local svApi = require "@REC_Library.server.sv_api"

---@type REC_ScriptTemplate.Server.Utils
local utils = require "@REC_ScriptTemplate.server.sv_utils"

---@type REC_ScriptTemplate.Shared.Events
local events = require "@REC_ScriptTemplate.shared.sh_event"

---@class REC_ScriptTemplate.Server.Manager.EntityManagerConfigBuilder: REC_Library.Server.Class.Manager.EntityManagerConfigBuilder
---@
local entityManagerConfigBuilder = svApi.Class.Manager.EntityManagerConfigBuilder:new()

---@class REC_ScriptTemplate.Server.Manager.EntityManager: REC_Library.Server.Class.Manager.EntityManager
---@
local entityManager = svApi.Class.Manager.EntityManager:new(entityManagerConfigBuilder)

return entityManager