
---@type REC_Library.Client.API
local clApi = require "@REC_Library.client.cl_api"

---@type REC_ScriptTemplate.Client.Utils
local utils = require "@REC_ScriptTemplate.client.cl_utils"

---@type REC_ScriptTemplate.Shared.Events
local events = require "@REC_ScriptTemplate.shared.sh_event"

---@class REC_ScriptTemplate.Client.Manager.EntityManagerConfigBuilder: REC_Library.Client.Class.Manager.EntityManagerConfigBuilder
local entityManagerConfigBuilder = clApi.Class.Manager.EntityManagerConfigBuilder:new()

---@class REC_ScriptTemplate.Client.Manager.EntityManager: REC_Library.Client.Class.Manager.EntityManager
local entityManager = clApi.Class.Manager.EntityManager:new(entityManagerConfigBuilder)

return entityManager