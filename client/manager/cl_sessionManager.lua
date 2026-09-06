
---[[
---     Client side state
---     Our own character and the values the server let us see.
---]]
---@class REC_Core.Client.Manager.SessionManager
local sessionManager = {

    ---@type REC_Core.Client.Manager.SessionManager.Info
    info = {
        isLoaded = false,
        isFlowRunning = false,
        character = nil,
        data = {},
    },
}

---@return boolean
function sessionManager:init()
    local info = self.info

    info.isLoaded = false
    info.isFlowRunning = false
    info.character = nil
    info.data = {}

    return true
end

---@param character REC_Core.Shared.Character
---@param data table<string, table<string, any>>|nil
function sessionManager:load(character, data)
    local info = self.info

    info.character = character
    info.data = data or {}
    info.isLoaded = true
end

function sessionManager:clear()
    local info = self.info

    info.character = nil
    info.data = {}
    info.isLoaded = false
end

return sessionManager

---@class REC_Core.Client.Manager.SessionManager.Info
---@field isLoaded boolean whether a character is loaded
---@field isFlowRunning boolean whether the character menu flow is in progress
---@field character REC_Core.Shared.Character|nil
---@field data table<string, table<string, any>> namespace -> dataKey -> value
