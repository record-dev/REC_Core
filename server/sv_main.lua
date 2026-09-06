
---@type REC_Core.Shared.Config, REC_Core.Server.Config
local shCfg, svCfg = require "@REC_Core.config.sh_config", require "@REC_Core.config.sv_config"

---@type REC_Core.Shared.Enum
local shEnums = require "@REC_Core.shared.sh_enum"
local unloadReasons = shEnums.unloadReasons

---@type REC_Core.Shared.Functions
local functions = require "@REC_Core.shared.sh_functions"

---@type REC_Core.Shared.Events
local events = require "@REC_Core.shared.sh_event"

---@type REC_Core.Locales
local locales = require ("@REC_Core.locales.".. shCfg.language)

---@type REC_Core.Server.Bridge
local bridge = require "@REC_Core.server.sv_bridge"

---@type REC_Core.Server.Utils
local utils = require "@REC_Core.server.sv_utils"

---@type REC_Core.Server.Handler
local handler = require "@REC_Core.handler.sv_handler"

---@type REC_Core.Server.Schema
local schema = require "@REC_Core.server.sv_schema"

---@type REC_Core.Server.Manager.ServerManager
local serverManager = require "@REC_Core.server.manager.sv_serverManager"

---@type REC_Core.Server.Modules.Players
local players = require "@REC_Core.server.modules.sv_players"

---@type REC_Core.Server.Modules.Money
local money = require "@REC_Core.server.modules.sv_money"

---[[
---     Initialization
---]]
if serverManager:init() == false then
    print("^1failed to init serverManager....^0")
    return
end

local serverManagerInfo = serverManager.info

---[[
---     The one callback that answers even while dormant
---     The client asks this first and stays out of the way when the core is off.
---]]
bridge:registerCallback(events.server.callbacks.getStatus, function (src)
    return players:getStatus(src)
end)

---[[
---     Another core on this server
---]]
local otherFramework = utils:detectOtherFramework()
if otherFramework ~= nil and svCfg.framework.allowOtherFramework == false then
    utils:log(("^3%s is running, so REC_Core stays dormant. Set config.framework.allowOtherFramework to true in config/sv_config.lua to run both.^0"):format(otherFramework))
    return
end

if otherFramework ~= nil then
    utils:log(("^3%s is running next to REC_Core, both will try to own the player^0"):format(otherFramework))
end

serverManagerInfo.isActive = true

---[[
---     Schema check
---     On its own thread: the query yields, and a resource that depends on this one
---     starts as soon as this file stops running.
---]]
CreateThread(function ()
    serverManagerInfo.isDatabaseReady = schema:check()
end)



---[[
---     Connection lifecycle
---]]

---[[
---     A player without the identifier cannot have characters
---]]
AddEventHandler("playerConnecting", function (playerName, setKickReason, deferrals)
    local src = source --[[@as integer]]

    deferrals.defer()

    -- deferrals ignore a done() that lands in the same tick as defer()
    Wait(0)

    local identifier = utils:getIdentifier(src)
    if identifier == nil then
        utils:debugPrint(("^3refused a connection without an identifier... name: %s^0"):format(tostring(playerName)))
        deferrals.done(locales.connect.noIdentifier)
        return
    end

    deferrals.done()
end)

---[[
---     Save and dispose when a player leaves
---]]
AddEventHandler("playerDropped", function (reason)
    local src = source --[[@as integer]]

    utils:debugPrint(("^5player %d dropped... reason: %s^0"):format(src, tostring(reason)))

    players:unload(src, unloadReasons.dropped)
end)



---[[
---     Callbacks the character menu uses
---]]

bridge:registerCallback(events.server.callbacks.getCharacters, function (src)
    return players:getCharacters(src)
end)

---@param input REC_Core.Server.Callbacks.CreateCharacter.Input
bridge:registerCallback(events.server.callbacks.createCharacter, function (src, input)
    return players:createCharacter(src, input)
end)

---@param citizenId string
bridge:registerCallback(events.server.callbacks.deleteCharacter, function (src, citizenId)
    return players:deleteCharacter(src, citizenId)
end)

---@param citizenId string
bridge:registerCallback(events.server.callbacks.selectCharacter, function (src, citizenId)
    return players:selectCharacter(src, citizenId)
end)

bridge:registerCallback(events.server.callbacks.logout, function (src)
    return players:logout(src)
end)



---[[
---     Threads
---]]

---[[
---     autosave thread
---]]
CreateThread(function ()

    if svCfg.database.autoSave.enabled == false then
        return
    end

    serverManagerInfo.shouldRunThread = true

    utils:debugPrint("^6start autoSave thread!!^0")

    ---@type integer
    local interval = svCfg.database.autoSave.interval * 60000

    while serverManagerInfo.shouldRunThread == true do
        Wait(interval)

        -- stopped while waiting
        if serverManagerInfo.shouldRunThread == false then
            break
        end

        local failedCount = players:saveAll()
        if failedCount > 0 then
            utils:log(("^1failed to save %d character(s) during autosave^0"):format(failedCount))
        end
    end

    utils:debugPrint("^6stop autoSave thread!!^0")
end)

---[[
---     paycheck thread
---]]
CreateThread(function ()

    if svCfg.paycheck.enabled == false then
        return
    end

    serverManagerInfo.shouldRunThread = true

    utils:debugPrint("^6start paycheck thread!!^0")

    ---@type integer
    local interval = svCfg.paycheck.interval * 60000

    while serverManagerInfo.shouldRunThread == true do
        Wait(interval)

        if serverManagerInfo.shouldRunThread == false then
            break
        end

        for _, citizenId in ipairs(serverManager:getCitizenIds()) do

            local character = serverManager:getCharacter(citizenId)
            if character == nil then
                goto continue
            end

            local info = character.info

            if svCfg.paycheck.onDutyOnly == true and info.job.onDuty ~= true then
                goto continue
            end

            -- extension point
            local amount = handler:getPaycheck(info.playerId, character:snapshot(), info.job.grade.payment)

            if utils:normalizeAmount(amount) == nil then
                goto continue
            end

            if money:add(info.playerId, svCfg.paycheck.account, amount, svCfg.paycheck.reason, true) == true then
                utils:notify(info.playerId, "success", locales.notify.title, (locales.notify.paycheck):format(functions:formatNumber(amount)))
            end

            ::continue::
        end
    end

    utils:debugPrint("^6stop paycheck thread!!^0")
end)

---[[
---     Resource stop
---     await never returns during shutdown, so the queries are fired without waiting.
---]]
AddEventHandler("onResourceStop", function (resource)

    if resource ~= GetCurrentResourceName() then
        return
    end

    utils:debugPrint("^3detected resource stopping...^0")

    serverManagerInfo.shouldRunThread = false
    serverManagerInfo.isActive = false

    local queryCount = players:flushOnStop()
    if queryCount > 0 then
        utils:log(("^3flushed %d queries on stopping...^0"):format(queryCount))
    end

    ---@type REC_Core.Client.Main.Reset.Payload
    local payload = {
        reason = unloadReasons.stop,
    }

    TriggerClientEvent(events.client.reset, -1, payload)
end)
