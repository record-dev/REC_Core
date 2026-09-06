
---@type REC_Core.Client.Utils
local utils = require "@REC_Core.client.cl_utils"

---@type REC_Core.Shared.Events
local events = require "@REC_Core.shared.sh_event"

---[[
---     Client side extension points
---     Every function here is called by the core at the moment its name says.
---]]
---@class REC_Core.Client.Handler
local handler = {}

---[[
---     Called right after our character is loaded and spawned
---]]
---@param character REC_Core.Shared.Character
function handler:onPlayerLoaded(character)

    utils:debugPrint(("^5onPlayerLoaded... citizenId: %s^0"):format(character.citizenId))
end

---[[
---     Called right after our character is dropped (logout / resource stop)
---]]
---@param reason REC_Core.Shared.Enum.UnloadReasons
function handler:onPlayerUnloaded(reason)

    utils:debugPrint(("^5onPlayerUnloaded... reason: %s^0"):format(reason))
end

---[[
---     Decides who spawns the player
---     Return true when you placed the ped yourself (e.g. a spawn selector), the
---     core then skips its own spawn. The screen is faded out when this is called.
---]]
---@param character REC_Core.Shared.Character
---@param spawn vector4 where the server wants the character
---@return boolean
function handler:onSpawn(character, spawn)

    return false
end

---[[
---     Called right after one of our balances changed
---]]
---@param payload REC_Core.Server.Main.MoneyChange.Payload
function handler:onMoneyChange(payload)

    utils:debugPrint(("^6onMoneyChange... account: %s, delta: %d, balance: %d^0"):format(payload.account, payload.delta, payload.balance))
end

---[[
---     Called right after our job changed
---]]
---@param payload REC_Core.Server.Main.JobUpdate.Payload
function handler:onJobUpdate(payload)

    utils:debugPrint(("^6onJobUpdate... job: %s, grade: %d, onDuty: %s^0"):format(payload.job.name, payload.job.grade.level, tostring(payload.job.onDuty)))
end

---[[
---     Called right after our gang changed
---]]
---@param payload REC_Core.Server.Main.GangUpdate.Payload
function handler:onGangUpdate(payload)

    utils:debugPrint(("^6onGangUpdate... gang: %s, grade: %d^0"):format(payload.gang.name, payload.gang.grade.level))
end

---[[
---     Called right after our charinfo changed
---]]
---@param payload REC_Core.Server.Main.CharinfoChange.Payload
function handler:onCharinfoChange(payload)

    utils:debugPrint(("^6onCharinfoChange... key: %s^0"):format(payload.key))
end

---[[
---     Called right after one of our metadata keys changed
---]]
---@param payload REC_Core.Server.Main.MetadataChange.Payload
function handler:onMetadataChange(payload)

    utils:debugPrint(("^6onMetadataChange... key: %s^0"):format(payload.key))
end

---[[
---     Called right after one of our values changed
---]]
---@param payload REC_Core.Client.Main.UpdateValue.Payload
function handler:onValueChange(payload)

    utils:debugPrint(("^6onValueChange... namespace: %s, dataKey: %s^0"):format(payload.namespace, payload.dataKey))
end

return handler
