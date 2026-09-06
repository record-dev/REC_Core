
---@type REC_Core.Shared.Config, REC_Core.Server.Config
local shCfg, svCfg = require "@REC_Core.config.sh_config", require "@REC_Core.config.sv_config"

---@type REC_Core.Shared.Enum
local shEnums = require "@REC_Core.shared.sh_enum"
local moneyActions = shEnums.moneyActions

---@type REC_Core.Shared.Functions
local functions = require "@REC_Core.shared.sh_functions"

---@type REC_Core.Shared.Events
local events = require "@REC_Core.shared.sh_event"

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
---     Money
---     Every balance change goes through apply, so every change is validated,
---     synced, announced and saved the same way.
---]]
---@class REC_Core.Server.Modules.Money
local money = {}

---[[
---     Accounts as configured, as a copy
---]]
---@return table<string, REC_Core.Config.Account>
function money:getAccounts()
    return functions:deepCopy(shCfg.accounts)
end

---@param account any
---@return boolean
function money:isAccount(account)
    return type(account) == "string" and shCfg.accounts[account] ~= nil
end

---[[
---     A reason that is never empty
---     A missing one is tagged with the resource that called, so an economy tracker
---     can tell which script forgot to say why.
---]]
---@param reason any
---@param resource string
---@return string
local function normalizeReason(reason, resource)

    if utils:isValidString(reason) == true then
        return reason
    end

    return ("@%s"):format(resource)
end

---[[
---     The balance a change would leave, nil when the account does not allow it
---]]
---@param account string
---@param action REC_Core.Shared.Enum.MoneyActions
---@param current integer
---@param amount integer
---@return integer|nil
local function nextBalance(account, action, current, amount)

    ---@type integer
    local balance = (function ()
        if action == moneyActions.add then
            return current + amount
        end

        if action == moneyActions.remove then
            return current - amount
        end

        return amount
    end)()

    if balance < 0 and shCfg.accounts[account].allowNegative ~= true then
        return nil
    end

    return balance
end

---[[
---     Tell the player
---]]
---@param playerId integer
---@param action REC_Core.Shared.Enum.MoneyActions
---@param account string
---@param delta integer
---@param balance integer
local function notifyChange(playerId, action, account, delta, balance)

    if svCfg.money.notify == false or delta == 0 then
        return
    end

    local label = shCfg.accounts[account].label

    if action == moneyActions.set then
        utils:notify(playerId, "info", locales.notify.title, (locales.notify.moneySet):format(label, functions:formatNumber(balance)))
        return
    end

    if delta > 0 then
        utils:notify(playerId, "success", locales.notify.title, (locales.notify.moneyAdded):format(functions:formatNumber(delta), label))
        return
    end

    utils:notify(playerId, "error", locales.notify.title, (locales.notify.moneyRemoved):format(functions:formatNumber(-delta), label))
end

---[[
---     One balance change of a loaded character
---]]
---@param character REC_Core.Server.Class.Character
---@param action REC_Core.Shared.Enum.MoneyActions
---@param account string
---@param amount integer the new balance for set, the delta otherwise
---@param reason string
---@param silent? boolean skip the player notification
---@return boolean
local function apply(character, action, account, amount, reason, silent)
    local info = character.info
    local playerId = info.playerId

    local current = character:getMoney(account)

    local balance = nextBalance(account, action, current, amount)
    if balance == nil then
        utils:debugPrint(("^3not enough money... citizenId: %s, account: %s, current: %d, amount: %d^0"):format(info.citizenId, account, current, amount))
        return false
    end

    -- extension point
    if handler:canChangeMoney(playerId, account, action, amount, reason) == false then
        utils:debugPrint(("^3money change is rejected by handler... citizenId: %s, account: %s^0"):format(info.citizenId, account))
        return false
    end

    character:setMoney(account, balance)

    ---@type REC_Core.Server.Main.MoneyChange.Payload
    local payload = {
        citizenId = info.citizenId,
        account = account,
        action = action,
        amount = amount,
        delta = balance - current,
        balance = balance,
        reason = reason,
        resource = utils:getInvokingResource(),
    }

    TriggerClientEvent(events.client.updateMoney, playerId, payload)

    -- extension point
    handler:onMoneyChange(playerId, payload)

    TriggerEvent(events.server.onMoneyChange, playerId, payload)

    if silent ~= true then
        notifyChange(playerId, action, account, payload.delta, balance)
    end

    players:saveIfImmediate(info.citizenId)

    utils:debugPrint(("^2money changed... citizenId: %s, account: %s, action: %s, delta: %d, balance: %d, reason: %s^0"):format(info.citizenId, account, action, payload.delta, balance, reason))

    return true
end



---[[
---     Online phase
---]]

---@param playerId integer
---@param account string
---@return integer|nil
function money:get(playerId, account)

    if self:isAccount(account) == false then
        utils:debugPrint(("^3unknown account... account: %s^0"):format(tostring(account)))
        return nil
    end

    local character = serverManager:getCharacterByPlayerId(playerId)
    if character == nil then
        return nil
    end

    return character:getMoney(account)
end

---@param playerId integer
---@return table<string, integer>|nil
function money:getAll(playerId)

    local character = serverManager:getCharacterByPlayerId(playerId)
    if character == nil then
        return nil
    end

    return functions:deepCopy(character.info.money)
end

---[[
---     Shared checks of add / remove / set
---]]
---@param playerId integer
---@param account string
---@return REC_Core.Server.Class.Character|nil
local function getTarget(playerId, account)

    if money:isAccount(account) == false then
        utils:debugPrint(("^3unknown account... account: %s^0"):format(tostring(account)))
        return nil
    end

    local character = serverManager:getCharacterByPlayerId(playerId)
    if character == nil then
        utils:debugPrint(("^3character is not loaded... playerId: %s^0"):format(tostring(playerId)))
        return nil
    end

    return character
end

---@param playerId integer
---@param account string
---@param amount integer
---@param reason? string
---@param silent? boolean
---@return boolean
function money:add(playerId, account, amount, reason, silent)

    local character = getTarget(playerId, account)
    if character == nil then
        return false
    end

    local normalized = utils:normalizeAmount(amount)
    if normalized == nil then
        utils:debugPrint(("^3amount must be a positive whole number... amount: %s^0"):format(tostring(amount)))
        return false
    end

    return apply(character, moneyActions.add, account, normalized, normalizeReason(reason, utils:getInvokingResource()), silent)
end

---@param playerId integer
---@param account string
---@param amount integer
---@param reason? string
---@param silent? boolean
---@return boolean
function money:remove(playerId, account, amount, reason, silent)

    local character = getTarget(playerId, account)
    if character == nil then
        return false
    end

    local normalized = utils:normalizeAmount(amount)
    if normalized == nil then
        utils:debugPrint(("^3amount must be a positive whole number... amount: %s^0"):format(tostring(amount)))
        return false
    end

    return apply(character, moneyActions.remove, account, normalized, normalizeReason(reason, utils:getInvokingResource()), silent)
end

---@param playerId integer
---@param account string
---@param amount integer the new balance
---@param reason? string
---@param silent? boolean
---@return boolean
function money:set(playerId, account, amount, reason, silent)

    local character = getTarget(playerId, account)
    if character == nil then
        return false
    end

    local normalized = utils:normalizeBalance(amount)
    if normalized == nil then
        utils:debugPrint(("^3balance must be a whole number... amount: %s^0"):format(tostring(amount)))
        return false
    end

    return apply(character, moneyActions.set, account, normalized, normalizeReason(reason, utils:getInvokingResource()), silent)
end



---[[
---     Offline phase
---     Straight to the DB. A loaded character has to go through the online path,
---     or the cache and the DB would disagree.
---]]

---@param citizenId string
---@param action REC_Core.Shared.Enum.MoneyActions
---@param account string
---@param amount integer
---@param reason? string
---@return boolean
local function applyOffline(citizenId, action, account, amount, reason)

    if money:isAccount(account) == false then
        utils:debugPrint(("^3unknown account... account: %s^0"):format(tostring(account)))
        return false
    end

    if serverManager:getCharacter(citizenId) ~= nil then
        utils:debugPrint(("^3character is loaded, use the online export instead... citizenId: %s^0"):format(citizenId))
        return false
    end

    local record = repository:getCharacter(citizenId)
    if record == nil then
        utils:debugPrint(("^3character is not founded... citizenId: %s^0"):format(citizenId))
        return false
    end

    local balances = players:fillMoney(record.money)
    local current = balances[account] or 0

    local balance = nextBalance(account, action, current, amount)
    if balance == nil then
        utils:debugPrint(("^3not enough money... citizenId: %s, account: %s^0"):format(citizenId, account))
        return false
    end

    balances[account] = balance

    if repository:updateCharacter(citizenId, { money = balances, }) == false then
        return false
    end

    ---@type REC_Core.Server.Main.OfflineMoneyChange.Payload
    local payload = {
        citizenId = citizenId,
        account = account,
        action = action,
        amount = amount,
        delta = balance - current,
        balance = balance,
        reason = normalizeReason(reason, utils:getInvokingResource()),
        resource = utils:getInvokingResource(),
    }

    TriggerEvent(events.server.onOfflineMoneyChange, payload)

    return true
end

---@param citizenId string
---@param account string
---@param amount integer
---@param reason? string
---@return boolean
function money:addOffline(citizenId, account, amount, reason)

    local normalized = utils:normalizeAmount(amount)
    if normalized == nil then
        return false
    end

    return applyOffline(citizenId, moneyActions.add, account, normalized, reason)
end

---@param citizenId string
---@param account string
---@param amount integer
---@param reason? string
---@return boolean
function money:removeOffline(citizenId, account, amount, reason)

    local normalized = utils:normalizeAmount(amount)
    if normalized == nil then
        return false
    end

    return applyOffline(citizenId, moneyActions.remove, account, normalized, reason)
end

return money
