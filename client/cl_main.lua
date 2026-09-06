
---@type REC_Core.Shared.Config
local shCfg = require "@REC_Core.config.sh_config"

---@type REC_Core.Shared.Enum
local shEnums = require "@REC_Core.shared.sh_enum"
local groupTypes, errors, unloadReasons = shEnums.groupTypes, shEnums.errors, shEnums.unloadReasons

---@type REC_Core.Shared.Functions
local functions = require "@REC_Core.shared.sh_functions"

---@type REC_Core.Shared.Events
local events = require "@REC_Core.shared.sh_event"

---@type REC_Core.Shared.Groups
local shGroups = require "@REC_Core.shared.sh_groups"

---@type REC_Core.Client.Bridge
local bridge = require "@REC_Core.client.cl_bridge"

---@type REC_Core.Client.Utils
local utils = require "@REC_Core.client.cl_utils"

---@type REC_Core.Client.Handler
local handler = require "@REC_Core.handler.cl_handler"

---@type REC_Core.Client.Manager.SessionManager
local sessionManager = require "@REC_Core.client.manager.cl_sessionManager"

---@type REC_Core.Client.Modules.Spawn
local spawn = require "@REC_Core.client.modules.cl_spawn"

---@type REC_Core.Client.Modules.CharacterMenu
local characterMenu = require "@REC_Core.client.modules.cl_characterMenu"

---[[
---     Initialization
---]]
if sessionManager:init() == false then
    print("^1failed to init sessionManager^0")
    return
end

local sessionManagerInfo = sessionManager.info



---[[
---     Character flow
---]]

---[[
---     Take a character the server loaded for us
---]]
---@param character REC_Core.Shared.Character
---@param data table<string, table<string, any>>|nil
local function applyCharacter(character, data)

    sessionManager:load(character, data)

    -- extension point
    handler:onPlayerLoaded(character)

    ---@type REC_Core.Client.Main.PlayerLoaded.Payload
    local payload = {
        character = functions:deepCopy(character),
    }

    TriggerEvent(events.client.onPlayerLoaded, payload)

    utils:debugPrint(("^2character is loaded... citizenId: %s^0"):format(character.citizenId))
end

---[[
---     Ask the server until it answers
---]]
---@return REC_Core.Server.Callbacks.GetStatus.Return
local function waitForStatus()

    while true do

        local status = bridge:callback(events.server.callbacks.getStatus)
        if type(status) == "table" then
            return status
        end

        Wait(1000)
    end
end

---[[
---     Menu -> load -> spawn, once per session and again after a logout
---]]
local function runCharacterFlow()

    if sessionManagerInfo.isFlowRunning == true then
        return
    end

    sessionManagerInfo.isFlowRunning = true

    local status = waitForStatus()

    -- another core owns the player
    if status.active == false then
        utils:debugPrint("^3core is not active on the server...^0")
        sessionManagerInfo.isFlowRunning = false
        return
    end

    -- the server still has our character, nothing to choose
    if status.character ~= nil then
        applyCharacter(status.character, status.data)
        sessionManagerInfo.isFlowRunning = false
        return
    end

    spawn:prepare()

    -- the menu cannot work without the DB, keep asking until it is there
    while status.databaseReady == false do
        utils:notifyError(errors.databaseNotReady)
        Wait(10000)
        status = waitForStatus()
    end

    local selection = characterMenu:run()

    spawn:spawn(selection.character, selection.spawn)

    applyCharacter(selection.character, selection.data)

    sessionManagerInfo.isFlowRunning = false
end

---[[
---     Drop the character on the client
---]]
---@param reason REC_Core.Shared.Enum.UnloadReasons
local function dropCharacter(reason)

    if sessionManagerInfo.isLoaded == false then
        return
    end

    sessionManager:clear()

    -- extension point
    handler:onPlayerUnloaded(reason)

    ---@type REC_Core.Client.Main.PlayerUnloaded.Payload
    local payload = {
        reason = reason,
    }

    TriggerEvent(events.client.onPlayerUnloaded, payload)

    utils:debugPrint(("^3character is dropped... reason: %s^0"):format(reason))
end

---[[
---     Start once the session is up
---     Runs on join and again when the resource restarts.
---]]
CreateThread(function ()

    while NetworkIsSessionStarted() == false do
        Wait(100)
    end

    runCharacterFlow()
end)



---[[
---     Sync from the server
---]]

---@param payload REC_Core.Client.Main.SyncPlayerData.Payload
RegisterNetEvent(events.client.syncPlayerData, function (payload)

    if type(payload) ~= "table" or type(payload.character) ~= "table" then
        utils:debugPrint("^1invalid payload...^0")
        return
    end

    applyCharacter(payload.character, payload.data)
end)

---@param payload REC_Core.Server.Main.MoneyChange.Payload
RegisterNetEvent(events.client.updateMoney, function (payload)

    local character = sessionManagerInfo.character
    if character == nil or type(payload) ~= "table" or type(payload.account) ~= "string" then
        return
    end

    character.money[payload.account] = payload.balance

    -- extension point
    handler:onMoneyChange(payload)

    TriggerEvent(events.client.onMoneyChange, payload)
end)

---@param payload REC_Core.Server.Main.JobUpdate.Payload
RegisterNetEvent(events.client.updateJob, function (payload)

    local character = sessionManagerInfo.character
    if character == nil or type(payload) ~= "table" or type(payload.job) ~= "table" then
        return
    end

    character.job = payload.job

    -- extension point
    handler:onJobUpdate(payload)

    TriggerEvent(events.client.onJobUpdate, payload)
end)

---@param payload REC_Core.Server.Main.GangUpdate.Payload
RegisterNetEvent(events.client.updateGang, function (payload)

    local character = sessionManagerInfo.character
    if character == nil or type(payload) ~= "table" or type(payload.gang) ~= "table" then
        return
    end

    character.gang = payload.gang

    -- extension point
    handler:onGangUpdate(payload)

    TriggerEvent(events.client.onGangUpdate, payload)
end)

---@param payload REC_Core.Server.Main.CharinfoChange.Payload
RegisterNetEvent(events.client.updateCharinfo, function (payload)

    local character = sessionManagerInfo.character
    if character == nil or type(payload) ~= "table" or type(payload.charinfo) ~= "table" then
        return
    end

    character.charinfo = payload.charinfo

    -- extension point
    handler:onCharinfoChange(payload)

    TriggerEvent(events.client.onCharinfoChange, payload)
end)

---@param payload REC_Core.Server.Main.MetadataChange.Payload
RegisterNetEvent(events.client.updateMetadata, function (payload)

    local character = sessionManagerInfo.character
    if character == nil or type(payload) ~= "table" or type(payload.key) ~= "string" then
        return
    end

    character.metadata[payload.key] = payload.newValue

    -- extension point
    handler:onMetadataChange(payload)

    TriggerEvent(events.client.onMetadataChange, payload)
end)

---@param payload REC_Core.Client.Main.UpdateValue.Payload
RegisterNetEvent(events.client.updateValue, function (payload)

    if sessionManagerInfo.isLoaded == false or type(payload) ~= "table" or type(payload.namespace) ~= "string" or type(payload.dataKey) ~= "string" then
        return
    end

    local data = sessionManagerInfo.data

    if data[payload.namespace] == nil then
        data[payload.namespace] = {}
    end

    data[payload.namespace][payload.dataKey] = payload.value

    -- drop the namespace once it is empty (to match the server)
    if payload.value == nil and next(data[payload.namespace]) == nil then
        data[payload.namespace] = nil
    end

    -- extension point
    handler:onValueChange(payload)

    TriggerEvent(events.client.onValueChange, payload)
end)

---@param payload REC_Core.Client.Main.Reset.Payload
RegisterNetEvent(events.client.reset, function (payload)

    local reason = type(payload) == "table" and payload.reason or unloadReasons.stop

    dropCharacter(reason)

    -- a logout goes back to the menu, a stop leaves the player where they are
    if reason == unloadReasons.logout then
        CreateThread(runCharacterFlow)
    end
end)

---@param payload REC_Core.Client.Main.Notify.Payload
RegisterNetEvent(events.client.notify, function (payload)

    if type(payload) ~= "table" then
        return
    end

    bridge:notify(payload)
end)

---[[
---     Never leave the player parked when this resource stops
---]]
AddEventHandler("onResourceStop", function (resource)

    if resource ~= GetCurrentResourceName() then
        return
    end

    bridge:hideMenu()
    spawn:release()
end)



---[[
---     Exports
---]]

---[[
---     whether our character is loaded
---]]
---@return boolean
exports("isLoaded", function ()
    return sessionManagerInfo.isLoaded
end)

---[[
---     our character, as a copy
---]]
---@return REC_Core.Shared.Character|nil
exports("getPlayerData", function ()
    return functions:deepCopy(sessionManagerInfo.character)
end)

---@return string|nil
exports("getCitizenId", function ()
    return sessionManagerInfo.character?.citizenId
end)

---@return REC_Core.Shared.Character.Charinfo|nil
exports("getCharinfo", function ()
    return functions:deepCopy(sessionManagerInfo.character?.charinfo)
end)

---@return REC_Core.Shared.Character.Group|nil
exports("getJob", function ()
    return functions:deepCopy(sessionManagerInfo.character?.job)
end)

---@return REC_Core.Shared.Character.Group|nil
exports("getGang", function ()
    return functions:deepCopy(sessionManagerInfo.character?.gang)
end)

---@param account string
---@return integer|nil
exports("getMoney", function (account)

    local character = sessionManagerInfo.character
    if character == nil or type(account) ~= "string" then
        return nil
    end

    return character.money[account]
end)

---@return table<string, integer>|nil
exports("getMoneys", function ()
    return functions:deepCopy(sessionManagerInfo.character?.money)
end)

---@param key string
---@return any
exports("getMetadata", function (key)

    local character = sessionManagerInfo.character
    if character == nil or type(key) ~= "string" then
        return nil
    end

    return functions:deepCopy(character.metadata[key])
end)

---[[
---     one of our own values, nil for the namespaces the server keeps back
---]]
---@param namespace string
---@param dataKey string
---@return any
exports("getValue", function (namespace, dataKey)

    if type(namespace) ~= "string" or type(dataKey) ~= "string" then
        return nil
    end

    local namespaceData = sessionManagerInfo.data[namespace]
    if namespaceData == nil then
        return nil
    end

    return functions:deepCopy(namespaceData[dataKey])
end)

---@param namespace string
---@return table<string, any>|nil
exports("getValues", function (namespace)

    if type(namespace) ~= "string" then
        return nil
    end

    return functions:deepCopy(sessionManagerInfo.data[namespace])
end)

---@param job string|string[]
---@param grades? table<integer, true>|integer[]
---@param onDutyOnly? boolean
---@return boolean
exports("hasJob", function (job, grades, onDutyOnly)

    local character = sessionManagerInfo.character
    if character == nil then
        return false
    end

    return shGroups:matches(character.job, job, grades, onDutyOnly)
end)

---@param gang string|string[]
---@param grades? table<integer, true>|integer[]
---@return boolean
exports("hasGang", function (gang, grades)

    local character = sessionManagerInfo.character
    if character == nil then
        return false
    end

    return shGroups:matches(character.gang, gang, grades)
end)

---[[
---     back to the character menu
---]]
---@return boolean
exports("logout", function ()

    if sessionManagerInfo.isLoaded == false then
        return false
    end

    return bridge:callback(events.server.callbacks.logout) == true
end)

---[[
---     Exports End
---]]
