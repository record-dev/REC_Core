
---@type REC_Core.Server.Utils
local utils = require "@REC_Core.server.sv_utils"

---@type REC_Core.Shared.Events
local events = require "@REC_Core.shared.sh_event"

---[[
---     Server side extension points
---     Every function here is called by the core at the moment its name says.
---     The ones that return a value decide something, the others only observe.
---]]
---@class REC_Core.Server.Handler
local handler = {}

---[[
---     Called right after a character is loaded
---]]
---@param playerId integer
---@param character REC_Core.Server.Character
function handler:onPlayerLoaded(playerId, character)

    utils:debugPrint(("^5onPlayerLoaded... playerId: %d, citizenId: %s^0"):format(playerId, character.citizenId))
end

---[[
---     Called right before a character is disposed
---     It runs before the save, so values written here still reach the DB.
---]]
---@param playerId integer
---@param citizenId string
---@param reason REC_Core.Shared.Enum.UnloadReasons
function handler:onPlayerUnloaded(playerId, citizenId, reason)

    utils:debugPrint(("^5onPlayerUnloaded... playerId: %d, citizenId: %s, reason: %s^0"):format(playerId, citizenId, reason))
end

---[[
---     Called right after a character is created
---     Seed anything a new character needs here, e.g. a starter item.
---]]
---@param playerId integer
---@param character REC_Core.Server.Character
function handler:onCharacterCreated(playerId, character)

    utils:debugPrint(("^5onCharacterCreated... playerId: %d, citizenId: %s^0"):format(playerId, character.citizenId))
end

---[[
---     Called right after a character is deleted from the DB
---     Clean up what other tables hold for this citizenId here.
---]]
---@param playerId integer
---@param citizenId string
function handler:onCharacterDeleted(playerId, citizenId)

    utils:debugPrint(("^5onCharacterDeleted... playerId: %d, citizenId: %s^0"):format(playerId, citizenId))
end

---[[
---     Decides where a character spawns
---     Return a vector4 to override, nil keeps the saved position or config.spawn.default.
---]]
---@param playerId integer
---@param character REC_Core.Server.Character
---@return vector4|nil
function handler:getSpawnPosition(playerId, character)

    return nil
end

---[[
---     Decides whether a money change is allowed
---     Returning false rejects the change.
---]]
---@param playerId integer
---@param account string
---@param action REC_Core.Shared.Enum.MoneyActions
---@param amount integer
---@param reason string
---@return boolean
function handler:canChangeMoney(playerId, account, action, amount, reason)

    return true
end

---[[
---     Called right after a balance changed
---]]
---@param playerId integer
---@param payload REC_Core.Server.Main.MoneyChange.Payload
function handler:onMoneyChange(playerId, payload)

    utils:debugPrint(("^6onMoneyChange... playerId: %d, account: %s, action: %s, delta: %d, reason: %s^0"):format(playerId, payload.account, payload.action, payload.delta, payload.reason))
end

---[[
---     Decides how much a paycheck pays
---     amount is the payment of the job grade, return 0 to skip this player.
---]]
---@param playerId integer
---@param character REC_Core.Server.Character
---@param amount integer
---@return integer
function handler:getPaycheck(playerId, character, amount)

    return amount
end

---[[
---     Called right after the job changed
---]]
---@param playerId integer
---@param payload REC_Core.Server.Main.JobUpdate.Payload
function handler:onJobUpdate(playerId, payload)

    utils:debugPrint(("^6onJobUpdate... playerId: %d, job: %s, grade: %d^0"):format(playerId, payload.job.name, payload.job.grade.level))
end

---[[
---     Called right after the gang changed
---]]
---@param playerId integer
---@param payload REC_Core.Server.Main.GangUpdate.Payload
function handler:onGangUpdate(playerId, payload)

    utils:debugPrint(("^6onGangUpdate... playerId: %d, gang: %s, grade: %d^0"):format(playerId, payload.gang.name, payload.gang.grade.level))
end

---[[
---     Called right after the duty state changed
---]]
---@param playerId integer
---@param payload REC_Core.Server.Main.DutyChange.Payload
function handler:onDutyChange(playerId, payload)

    utils:debugPrint(("^6onDutyChange... playerId: %d, onDuty: %s^0"):format(playerId, tostring(payload.onDuty)))
end

---[[
---     Called right after a charinfo field changed
---]]
---@param playerId integer
---@param payload REC_Core.Server.Main.CharinfoChange.Payload
function handler:onCharinfoChange(playerId, payload)

    utils:debugPrint(("^6onCharinfoChange... playerId: %d, key: %s^0"):format(playerId, payload.key))
end

---[[
---     Called right after a metadata key changed
---]]
---@param playerId integer
---@param payload REC_Core.Server.Main.MetadataChange.Payload
function handler:onMetadataChange(playerId, payload)

    utils:debugPrint(("^6onMetadataChange... playerId: %d, key: %s^0"):format(playerId, payload.key))
end

---[[
---     Decides whether a write to the value store is allowed
---     Returning false rejects the write.
---]]
---@param citizenId string
---@param namespace string resource name the write came from
---@param dataKey string
---@param value any
---@return boolean
function handler:canSetValue(citizenId, namespace, dataKey, value)

    return true
end

---[[
---     Called right after a value of the value store changed
---]]
---@param playerId integer
---@param payload REC_Core.Server.Main.ValueChange.Payload
function handler:onValueChange(playerId, payload)

    utils:debugPrint(("^6onValueChange... playerId: %d, namespace: %s, dataKey: %s^0"):format(playerId, payload.namespace, payload.dataKey))
end

return handler
