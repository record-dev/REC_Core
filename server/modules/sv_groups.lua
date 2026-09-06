
---@type REC_Core.Shared.Config
local shCfg = require "@REC_Core.config.sh_config"

---@type REC_Core.Shared.Enum
local shEnums = require "@REC_Core.shared.sh_enum"
local groupTypes = shEnums.groupTypes

---@type REC_Core.Shared.Functions
local functions = require "@REC_Core.shared.sh_functions"

---@type REC_Core.Shared.Events
local events = require "@REC_Core.shared.sh_event"

---@type REC_Core.Shared.Groups
local shGroups = require "@REC_Core.shared.sh_groups"

---@type REC_Core.Locales
local locales = require ("@REC_Core.locales.".. shCfg.language)

---@type REC_Core.Server.Utils
local utils = require "@REC_Core.server.sv_utils"

---@type REC_Core.Server.Handler
local handler = require "@REC_Core.handler.sv_handler"

---@type REC_Core.Server.Repository
local repository = require "@REC_Core.server.sv_repository"

---@type REC_Core.Server.Manager.ServerManager
local serverManager = require "@REC_Core.server.manager.sv_serverManager"

---@type REC_Core.Server.Modules.Players
local players = require "@REC_Core.server.modules.sv_players"

---[[
---     Jobs and gangs of loaded characters
---]]
---@class REC_Core.Server.Modules.Groups
local groups = {}

---[[
---     Announce a group change to the client, the handler and the server
---]]
---@param groupType REC_Core.Shared.Enum.GroupTypes
---@param character REC_Core.Server.Class.Character
---@param group REC_Core.Shared.Character.Group
---@param oldGroup REC_Core.Shared.Character.Group
local function announce(groupType, character, group, oldGroup)
    local info = character.info
    local playerId = info.playerId

    if groupType == groupTypes.job then

        ---@type REC_Core.Server.Main.JobUpdate.Payload
        local payload = {
            citizenId = info.citizenId,
            job = functions:deepCopy(group),
            oldJob = oldGroup,
        }

        TriggerClientEvent(events.client.updateJob, playerId, payload)

        -- extension point
        handler:onJobUpdate(playerId, payload)

        TriggerEvent(events.server.onJobUpdate, playerId, payload)

        utils:notify(playerId, "info", locales.notify.title, (locales.notify.jobUpdated):format(group.label, group.grade.name))
        return
    end

    ---@type REC_Core.Server.Main.GangUpdate.Payload
    local payload = {
        citizenId = info.citizenId,
        gang = functions:deepCopy(group),
        oldGang = oldGroup,
    }

    TriggerClientEvent(events.client.updateGang, playerId, payload)

    -- extension point
    handler:onGangUpdate(playerId, payload)

    TriggerEvent(events.server.onGangUpdate, playerId, payload)

    utils:notify(playerId, "info", locales.notify.title, (locales.notify.gangUpdated):format(group.label, group.grade.name))
end

---@param groupType REC_Core.Shared.Enum.GroupTypes
---@param playerId integer
---@return REC_Core.Shared.Character.Group|nil
function groups:get(groupType, playerId)

    local character = serverManager:getCharacterByPlayerId(playerId)
    if character == nil then
        return nil
    end

    return functions:deepCopy(character.info[groupType])
end

---[[
---     Give a loaded character a job or gang
---]]
---@param groupType REC_Core.Shared.Enum.GroupTypes
---@param playerId integer
---@param name string
---@param grade? integer defaults to 0
---@return boolean
function groups:set(groupType, playerId, name, grade)

    local character = serverManager:getCharacterByPlayerId(playerId)
    if character == nil then
        utils:debugPrint(("^3character is not loaded... playerId: %s^0"):format(tostring(playerId)))
        return false
    end

    local group = shGroups:resolve(groupType, name, grade)
    if group == nil then
        utils:debugPrint(("^3unknown %s or grade... name: %s, grade: %s^0"):format(groupType, tostring(name), tostring(grade)))
        return false
    end

    local oldGroup = character.info[groupType]

    character:setGroup(groupType, group)

    announce(groupType, character, group, oldGroup)

    players:saveIfImmediate(character.info.citizenId)

    return true
end

---[[
---     Clock a loaded character in or out
---]]
---@param playerId integer
---@param onDuty boolean
---@return boolean
function groups:setDuty(playerId, onDuty)

    local character = serverManager:getCharacterByPlayerId(playerId)
    if character == nil then
        utils:debugPrint(("^3character is not loaded... playerId: %s^0"):format(tostring(playerId)))
        return false
    end

    if type(onDuty) ~= "boolean" then
        return false
    end

    local info = character.info

    if info.job.onDuty == onDuty then
        return true
    end

    local oldJob = functions:deepCopy(info.job)

    local job = functions:deepCopy(info.job)
    job.onDuty = onDuty

    character:setGroup(groupTypes.job, job)

    ---@type REC_Core.Server.Main.JobUpdate.Payload
    local jobPayload = {
        citizenId = info.citizenId,
        job = functions:deepCopy(job),
        oldJob = oldJob,
    }

    TriggerClientEvent(events.client.updateJob, playerId, jobPayload)

    ---@type REC_Core.Server.Main.DutyChange.Payload
    local payload = {
        citizenId = info.citizenId,
        onDuty = onDuty,
        job = functions:deepCopy(job),
    }

    -- extension point
    handler:onDutyChange(playerId, payload)

    TriggerEvent(events.server.onDutyChange, playerId, payload)

    utils:notify(playerId, "info", locales.notify.title, onDuty == true and locales.notify.dutyOn or locales.notify.dutyOff)

    players:saveIfImmediate(info.citizenId)

    return true
end

---[[
---     Whether a loaded character holds one of the groups
---]]
---@param groupType REC_Core.Shared.Enum.GroupTypes
---@param playerId integer
---@param names string|string[]
---@param grades? table<integer, true>|integer[]
---@param onDutyOnly? boolean
---@return boolean
function groups:has(groupType, playerId, names, grades, onDutyOnly)

    local character = serverManager:getCharacterByPlayerId(playerId)
    if character == nil then
        return false
    end

    return shGroups:matches(character.info[groupType], names, grades, onDutyOnly)
end

---[[
---     How many loaded characters hold one of the groups
---]]
---@param groupType REC_Core.Shared.Enum.GroupTypes
---@param names string|string[]
---@param grades? table<integer, true>|integer[]
---@param onDutyOnly? boolean
---@return integer
function groups:count(groupType, names, grades, onDutyOnly)

    ---@type integer
    local count = 0

    for _, character in pairs(serverManager.info.characters) do
        if shGroups:matches(character.info[groupType], names, grades, onDutyOnly) == true then
            count += 1
        end
    end

    return count
end

---[[
---     Give a character that is not loaded a job or gang, straight to the DB
---]]
---@param groupType REC_Core.Shared.Enum.GroupTypes
---@param citizenId string
---@param name string
---@param grade? integer
---@return boolean
function groups:setOffline(groupType, citizenId, name, grade)

    if serverManager:getCharacter(citizenId) ~= nil then
        utils:debugPrint(("^3character is loaded, use the online export instead... citizenId: %s^0"):format(citizenId))
        return false
    end

    local group = shGroups:resolve(groupType, name, grade)
    if group == nil then
        utils:debugPrint(("^3unknown %s or grade... name: %s, grade: %s^0"):format(groupType, tostring(name), tostring(grade)))
        return false
    end

    local record = repository:getCharacter(citizenId)
    if record == nil then
        utils:debugPrint(("^3character is not founded... citizenId: %s^0"):format(citizenId))
        return false
    end

    return repository:updateCharacter(citizenId, { [groupType] = shGroups:toStored(group), })
end

return groups
