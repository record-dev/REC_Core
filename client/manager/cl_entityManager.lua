
---@type REC_Library.Client.API
local clApi = require "@REC_Library.client.cl_api"

---@type REC_Core.Client.Utils
local utils = require "@REC_Core.client.cl_utils"

---@type REC_Core.Shared.Events
local events = require "@REC_Core.shared.sh_event"

---@class REC_Core.Client.Manager.EntityManagerConfigBuilder: REC_Library.Client.Class.Manager.EntityManagerConfigBuilder
local entityManagerConfigBuilder = clApi.Class.Manager.EntityManagerConfigBuilder:new()

---@class REC_Core.Client.Manager.EntityManager: REC_Library.Client.Class.Manager.EntityManager
local entityManager = clApi.Class.Manager.EntityManager:new(entityManagerConfigBuilder)

return entityManager