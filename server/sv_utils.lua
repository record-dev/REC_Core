
---@type REC_Core.Shared.Config, REC_Core.Server.Config
local shCfg, svCfg = require "@REC_Core.config.sh_config", require "@REC_Core.config.sv_config"

---@type REC_Core.Shared.Events
local events = require "@REC_Core.shared.sh_event"

---@type REC_Core.Locales
local locales = require ("@REC_Core.locales.".. shCfg.language)

---@type string
local resourceName = GetCurrentResourceName()

---@class REC_Core.Server.Utils
local utils = {}

---[[
---     Notify
---]]
---@param playerId integer
---@param notifyType "info" | "success" | "warning" | "error"
---@param title string
---@param description string
---@param duration? integer
function utils:notify(playerId, notifyType, title, description, duration)

    ---@type REC_Core.Client.Main.Notify.Payload
    local payload = {
        type = notifyType,
        title = title,
        description = description,
        duration = duration or 4000,
    }

    TriggerClientEvent(events.client.notify, playerId, payload)
end

---[[
---     Answer whoever ran a command, the console included
---]]
---@param src integer 0 is the console
---@param notifyType "info" | "success" | "warning" | "error"
---@param message string
function utils:reply(src, notifyType, message)

    if src == 0 then
        print(("[%s] %s"):format(resourceName, message))
        return
    end

    self:notify(src, notifyType, locales.notify.title, message)
end

---[[
---     Identifier a character is tied to
---     The first type in config.identifiers the player has.
---]]
---@param playerId integer
---@return string|nil
function utils:getIdentifier(playerId)

    for _, identifierType in ipairs(svCfg.identifiers) do

        local identifier = GetPlayerIdentifierByType(playerId, identifierType)
        if identifier ~= nil and identifier ~= "" then
            return identifier
        end
    end

    return nil
end

---[[
---     Resource that called the export, this one when called from inside
---]]
---@return string
function utils:getInvokingResource()
    return GetInvokingResource() or resourceName
end

---[[
---     ACE check
---]]
---@param playerId integer
---@param permission string e.g. "group.admin"
---@return boolean
function utils:hasPermission(playerId, permission)

    if type(permission) ~= "string" or permission == "" then
        return false
    end

    -- the console is allowed everything
    if playerId == 0 then
        return true
    end

    local allowed = IsPlayerAceAllowed(playerId, permission)

    return allowed == true or allowed == 1
end

---@param playerId any
---@return boolean
function utils:isValidPlayerId(playerId)
    return math.type(playerId) == "integer" and playerId > 0
end

---@param value any
---@return boolean
function utils:isValidString(value)
    return type(value) == "string" and value ~= ""
end

---[[
---     Amount of a money change: a positive whole number
---     10.0 passes as 10, 10.5 and 0 do not.
---]]
---@param amount any
---@return integer|nil
function utils:normalizeAmount(amount)

    local balance = self:normalizeBalance(amount)
    if balance == nil or balance <= 0 then
        return nil
    end

    return balance
end

---[[
---     A balance: any whole number
---]]
---@param amount any
---@return integer|nil
function utils:normalizeBalance(amount)

    if type(amount) ~= "number" then
        return nil
    end

    if amount ~= amount or amount == math.huge or amount == -math.huge then
        return nil
    end

    if amount ~= math.floor(amount) then
        return nil
    end

    return math.tointeger(amount)
end

---[[
---     ABC12345 shaped id, uniqueness is checked by the caller
---]]
---@return string
function utils:generateCitizenId()

    local shape = shCfg.characters.citizenId

    ---@type string
    local citizenId = ""

    for _ = 1, shape.letters do
        citizenId = citizenId .. string.char(math.random(65, 90))
    end

    for _ = 1, shape.digits do
        citizenId = citizenId .. tostring(math.random(0, 9))
    end

    return citizenId
end

---[[
---     Where the player's ped is right now
---]]
---@param playerId integer|nil
---@return REC_Core.Shared.Position|nil
function utils:getPlayerPosition(playerId)

    if playerId == nil then
        return nil
    end

    local ped = GetPlayerPed(playerId)
    if ped == nil or ped == 0 then
        return nil
    end

    if DoesEntityExist(ped) == false then
        return nil
    end

    local coords = GetEntityCoords(ped)

    ---@type REC_Core.Shared.Position
    return {
        x = coords.x,
        y = coords.y,
        z = coords.z,
        w = GetEntityHeading(ped),
    }
end

---[[
---     Whether a player is still connected
---]]
---@param playerId integer
---@return boolean
function utils:isConnected(playerId)

    local exists = DoesPlayerExist(tostring(playerId))

    return exists == true or exists == 1
end

---[[
---     Timestamp the DB accepts
---]]
---@return string
function utils:now()
    return os.date("%Y-%m-%d %H:%M:%S") --[[@as string]]
end

---[[
---     Always printed, for problems the owner has to see
---]]
---@param message string
function utils:log(message)
    print(("[%s] %s"):format(resourceName, message))
end

---[[
---     Debug output
---]]
---@param ... any
function utils:debugPrint(...)
    if svCfg.debugMode == true then
        print(...)
    end
end

return utils
