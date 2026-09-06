
---@type REC_Core.Shared.Config
local shCfg = require "@REC_Core.config.sh_config"

---@type REC_Core.Shared.Enum
local shEnums = require "@REC_Core.shared.sh_enum"
local groupTypes = shEnums.groupTypes

---@type REC_Core.Shared.Functions
local functions = require "@REC_Core.shared.sh_functions"

---@type REC_Core.Shared.Groups
local shGroups = require "@REC_Core.shared.sh_groups"

---@type REC_Core.Server.Utils
local utils = require "@REC_Core.server.sv_utils"

---@type REC_Core.Server.Manager.ServerManager
local serverManager = require "@REC_Core.server.manager.sv_serverManager"
local serverManagerInfo = serverManager.info

---@type REC_Core.Server.Modules.Players
local players = require "@REC_Core.server.modules.sv_players"

---@type REC_Core.Server.Modules.Money
local money = require "@REC_Core.server.modules.sv_money"

---@type REC_Core.Server.Modules.Groups
local groups = require "@REC_Core.server.modules.sv_groups"

---@type REC_Core.Server.Modules.Data
local data = require "@REC_Core.server.modules.sv_data"



---[[
---     Argument checks shared by the exports
---]]

---@param playerId any
---@return boolean
local function checkPlayerId(playerId)

    if utils:isValidPlayerId(playerId) == false then
        print(("^1[%s] playerId must be a positive integer... got: %s^0"):format(utils:getInvokingResource(), tostring(playerId)))
        return false
    end

    return true
end

---@param value any
---@param name string
---@return boolean
local function checkString(value, name)

    if utils:isValidString(value) == false then
        print(("^1[%s] %s must be a non empty string... got: %s^0"):format(utils:getInvokingResource(), name, tostring(value)))
        return false
    end

    return true
end



---[[
---     Lifecycle
---]]

---[[
---     whether the core finished booting
---]]
---@return boolean
exports("isActive", function ()
    return serverManagerInfo.isActive
end)

---[[
---     whether a player has a character loaded
---]]
---@param playerId integer
---@return boolean
exports("isLoaded", function (playerId)

    if checkPlayerId(playerId) == false then
        return false
    end

    return serverManager:getCharacterByPlayerId(playerId) ~= nil
end)

---[[
---     server ids of every player with a character loaded
---]]
---@return integer[]
exports("getPlayerIds", function ()

    ---@type integer[]
    local playerIds = {}

    for _, character in pairs(serverManagerInfo.characters) do
        playerIds[#playerIds+1] = character.info.playerId
    end

    return playerIds
end)

---[[
---     every loaded character
---]]
---@return REC_Core.Server.Character[]
exports("getPlayers", function ()

    ---@type REC_Core.Server.Character[]
    local characters = {}

    for _, character in pairs(serverManagerInfo.characters) do
        characters[#characters+1] = character:snapshot()
    end

    return characters
end)

---[[
---     the loaded character of a player, as a copy
---]]
---@param playerId integer
---@return REC_Core.Server.Character|nil
exports("getPlayerData", function (playerId)

    if checkPlayerId(playerId) == false then
        return nil
    end

    local character = serverManager:getCharacterByPlayerId(playerId)
    if character == nil then
        return nil
    end

    return character:snapshot()
end)

---@param playerId integer
---@return string|nil
exports("getCitizenIdByPlayerId", function (playerId)

    if checkPlayerId(playerId) == false then
        return nil
    end

    return serverManager:getCharacterByPlayerId(playerId)?.info.citizenId
end)

---@param citizenId string
---@return integer|nil
exports("getPlayerIdByCitizenId", function (citizenId)

    if checkString(citizenId, "citizenId") == false then
        return nil
    end

    return serverManager:getCharacter(citizenId)?.info.playerId
end)

---[[
---     the identifier characters are tied to (config.identifiers)
---]]
---@param playerId integer
---@return string|nil
exports("getIdentifier", function (playerId)

    if checkPlayerId(playerId) == false then
        return nil
    end

    return utils:getIdentifier(playerId)
end)

---[[
---     every character of one identifier, from the DB
---]]
---@param license string
---@return REC_Core.Server.Character[]|nil
exports("getCharactersByLicense", function (license)

    if checkString(license, "license") == false then
        return nil
    end

    return players:getCharactersByLicense(license)
end)

---[[
---     a character from the DB, loaded or not
---]]
---@param citizenId string
---@return REC_Core.Server.Character|nil
exports("getOfflineCharacter", function (citizenId)

    if checkString(citizenId, "citizenId") == false then
        return nil
    end

    return players:getOfflineCharacter(citizenId)
end)

---[[
---     delete a character that is not loaded
---]]
---@param citizenId string
---@return boolean
exports("deleteCharacter", function (citizenId)

    if checkString(citizenId, "citizenId") == false then
        return false
    end

    return players:deleteOffline(citizenId, 0)
end)

---[[
---     send a player back to the character menu
---]]
---@param playerId integer
---@return boolean
exports("logout", function (playerId)

    if checkPlayerId(playerId) == false then
        return false
    end

    return players:logout(playerId)
end)

---[[
---     write the unsaved changes of a player right now
---]]
---@param playerId integer
---@return boolean
exports("save", function (playerId)

    if checkPlayerId(playerId) == false then
        return false
    end

    local character = serverManager:getCharacterByPlayerId(playerId)
    if character == nil then
        return false
    end

    return players:save(character.info.citizenId)
end)

---[[
---     write the unsaved changes of everyone right now
---]]
---@return integer number of characters whose save failed
exports("saveAll", function ()
    return players:saveAll()
end)

---[[
---     ACE check, the console passes everything
---]]
---@param playerId integer
---@param permission string
---@return boolean
exports("hasPermission", function (playerId, permission)

    if math.type(playerId) ~= "integer" or playerId < 0 then
        return false
    end

    return utils:hasPermission(playerId, permission)
end)



---[[
---     Money
---]]

---@return table<string, REC_Core.Config.Account>
exports("getAccounts", function ()
    return money:getAccounts()
end)

---@param playerId integer
---@param account string
---@return integer|nil
exports("getMoney", function (playerId, account)

    if checkPlayerId(playerId) == false or checkString(account, "account") == false then
        return nil
    end

    return money:get(playerId, account)
end)

---@param playerId integer
---@return table<string, integer>|nil
exports("getMoneys", function (playerId)

    if checkPlayerId(playerId) == false then
        return nil
    end

    return money:getAll(playerId)
end)

---@param playerId integer
---@param account string
---@param amount integer
---@param reason? string
---@return boolean
exports("addMoney", function (playerId, account, amount, reason)

    if checkPlayerId(playerId) == false or checkString(account, "account") == false then
        return false
    end

    return money:add(playerId, account, amount, reason)
end)

---@param playerId integer
---@param account string
---@param amount integer
---@param reason? string
---@return boolean
exports("removeMoney", function (playerId, account, amount, reason)

    if checkPlayerId(playerId) == false or checkString(account, "account") == false then
        return false
    end

    return money:remove(playerId, account, amount, reason)
end)

---@param playerId integer
---@param account string
---@param amount integer the new balance
---@param reason? string
---@return boolean
exports("setMoney", function (playerId, account, amount, reason)

    if checkPlayerId(playerId) == false or checkString(account, "account") == false then
        return false
    end

    return money:set(playerId, account, amount, reason)
end)

---@param citizenId string
---@param account string
---@param amount integer
---@param reason? string
---@return boolean
exports("addOfflineMoney", function (citizenId, account, amount, reason)

    if checkString(citizenId, "citizenId") == false or checkString(account, "account") == false then
        return false
    end

    return money:addOffline(citizenId, account, amount, reason)
end)

---@param citizenId string
---@param account string
---@param amount integer
---@param reason? string
---@return boolean
exports("removeOfflineMoney", function (citizenId, account, amount, reason)

    if checkString(citizenId, "citizenId") == false or checkString(account, "account") == false then
        return false
    end

    return money:removeOffline(citizenId, account, amount, reason)
end)



---[[
---     Jobs and gangs
---]]

---@return table<string, REC_Core.Shared.Groups.Label>
exports("getJobs", function ()
    return shGroups:getLabels(groupTypes.job)
end)

---@return table<string, REC_Core.Shared.Groups.Label>
exports("getGangs", function ()
    return shGroups:getLabels(groupTypes.gang)
end)

---@param playerId integer
---@return REC_Core.Shared.Character.Group|nil
exports("getJob", function (playerId)

    if checkPlayerId(playerId) == false then
        return nil
    end

    return groups:get(groupTypes.job, playerId)
end)

---@param playerId integer
---@return REC_Core.Shared.Character.Group|nil
exports("getGang", function (playerId)

    if checkPlayerId(playerId) == false then
        return nil
    end

    return groups:get(groupTypes.gang, playerId)
end)

---@param playerId integer
---@param name string
---@param grade? integer
---@return boolean
exports("setJob", function (playerId, name, grade)

    if checkPlayerId(playerId) == false or checkString(name, "name") == false then
        return false
    end

    return groups:set(groupTypes.job, playerId, name, grade)
end)

---@param playerId integer
---@param name string
---@param grade? integer
---@return boolean
exports("setGang", function (playerId, name, grade)

    if checkPlayerId(playerId) == false or checkString(name, "name") == false then
        return false
    end

    return groups:set(groupTypes.gang, playerId, name, grade)
end)

---@param playerId integer
---@param onDuty boolean
---@return boolean
exports("setDuty", function (playerId, onDuty)

    if checkPlayerId(playerId) == false then
        return false
    end

    return groups:setDuty(playerId, onDuty)
end)

---@param playerId integer
---@param job string|string[]
---@param grades? table<integer, true>|integer[]
---@param onDutyOnly? boolean
---@return boolean
exports("hasJob", function (playerId, job, grades, onDutyOnly)

    if checkPlayerId(playerId) == false then
        return false
    end

    return groups:has(groupTypes.job, playerId, job, grades, onDutyOnly)
end)

---@param playerId integer
---@param gang string|string[]
---@param grades? table<integer, true>|integer[]
---@return boolean
exports("hasGang", function (playerId, gang, grades)

    if checkPlayerId(playerId) == false then
        return false
    end

    return groups:has(groupTypes.gang, playerId, gang, grades)
end)

---@param job string|string[]
---@param grades? table<integer, true>|integer[]
---@param onDutyOnly? boolean
---@return integer
exports("countPlayersByJob", function (job, grades, onDutyOnly)
    return groups:count(groupTypes.job, job, grades, onDutyOnly)
end)

---@param gang string|string[]
---@param grades? table<integer, true>|integer[]
---@return integer
exports("countPlayersByGang", function (gang, grades)
    return groups:count(groupTypes.gang, gang, grades)
end)

---@param citizenId string
---@param name string
---@param grade? integer
---@return boolean
exports("setOfflineJob", function (citizenId, name, grade)

    if checkString(citizenId, "citizenId") == false or checkString(name, "name") == false then
        return false
    end

    return groups:setOffline(groupTypes.job, citizenId, name, grade)
end)

---@param citizenId string
---@param name string
---@param grade? integer
---@return boolean
exports("setOfflineGang", function (citizenId, name, grade)

    if checkString(citizenId, "citizenId") == false or checkString(name, "name") == false then
        return false
    end

    return groups:setOffline(groupTypes.gang, citizenId, name, grade)
end)



---[[
---     Charinfo and metadata
---]]

---@param playerId integer
---@return REC_Core.Shared.Character.Charinfo|nil
exports("getCharinfo", function (playerId)

    if checkPlayerId(playerId) == false then
        return nil
    end

    return data:getCharinfo(playerId)
end)

---@param playerId integer
---@param key string
---@param value string|number|boolean|table|nil
---@return boolean
exports("setCharinfo", function (playerId, key, value)

    if checkPlayerId(playerId) == false or checkString(key, "key") == false then
        return false
    end

    return data:setCharinfo(playerId, key, value)
end)

---@param playerId integer
---@param key string
---@return any
exports("getMetadata", function (playerId, key)

    if checkPlayerId(playerId) == false or checkString(key, "key") == false then
        return nil
    end

    return data:getMetadata(playerId, key)
end)

---@param playerId integer
---@return table<string, any>|nil
exports("getAllMetadata", function (playerId)

    if checkPlayerId(playerId) == false then
        return nil
    end

    return data:getAllMetadata(playerId)
end)

---@param playerId integer
---@param key string
---@param value any nil deletes the key
---@return boolean
exports("setMetadata", function (playerId, key, value)

    if checkPlayerId(playerId) == false or checkString(key, "key") == false then
        return false
    end

    return data:setMetadata(playerId, key, value)
end)



---[[
---     Value store
---]]

---@param playerId integer
---@param namespace string
---@param dataKey string
---@return any
exports("getValue", function (playerId, namespace, dataKey)

    if checkPlayerId(playerId) == false or checkString(namespace, "namespace") == false or checkString(dataKey, "dataKey") == false then
        return nil
    end

    return data:getValue(playerId, namespace, dataKey)
end)

---@param playerId integer
---@param namespace string
---@return table<string, any>|nil
exports("getValues", function (playerId, namespace)

    if checkPlayerId(playerId) == false or checkString(namespace, "namespace") == false then
        return nil
    end

    return data:getValues(playerId, namespace)
end)

---@param playerId integer
---@param namespace string
---@param dataKey string
---@param value any nil deletes it
---@return boolean
exports("setValue", function (playerId, namespace, dataKey, value)

    if checkPlayerId(playerId) == false or checkString(namespace, "namespace") == false or checkString(dataKey, "dataKey") == false then
        return false
    end

    return data:setValue(playerId, namespace, dataKey, value)
end)

---@param playerId integer
---@param namespace string
---@param values table<string, any>
---@return boolean
exports("setValues", function (playerId, namespace, values)

    if checkPlayerId(playerId) == false or checkString(namespace, "namespace") == false then
        return false
    end

    if type(values) ~= "table" then
        print(("^1[%s] values must be a table^0"):format(utils:getInvokingResource()))
        return false
    end

    return data:setValues(playerId, namespace, values)
end)

---@param playerId integer
---@param namespace string
---@param dataKey string
---@return boolean
exports("removeValue", function (playerId, namespace, dataKey)

    if checkPlayerId(playerId) == false or checkString(namespace, "namespace") == false or checkString(dataKey, "dataKey") == false then
        return false
    end

    return data:removeValue(playerId, namespace, dataKey)
end)

---@param playerId integer
---@param namespace string
---@return boolean
exports("removeNamespace", function (playerId, namespace)

    if checkPlayerId(playerId) == false or checkString(namespace, "namespace") == false then
        return false
    end

    return data:removeNamespace(playerId, namespace)
end)

---@param citizenId string
---@param namespace string
---@param dataKey? string omit it to get the whole namespace
---@return any
exports("getOfflineValue", function (citizenId, namespace, dataKey)

    if checkString(citizenId, "citizenId") == false or checkString(namespace, "namespace") == false then
        return nil
    end

    if dataKey ~= nil and checkString(dataKey, "dataKey") == false then
        return nil
    end

    return data:getOfflineValue(citizenId, namespace, dataKey)
end)

---@param citizenId string
---@param namespace string
---@param dataKey string
---@param value any nil deletes it
---@return boolean
exports("setOfflineValue", function (citizenId, namespace, dataKey, value)

    if checkString(citizenId, "citizenId") == false or checkString(namespace, "namespace") == false or checkString(dataKey, "dataKey") == false then
        return false
    end

    return data:setOfflineValue(citizenId, namespace, dataKey, value)
end)



---[[
---     Config
---]]

---@return REC_Core.Shared.Config
exports("getConfig", function ()
    return functions:deepCopy(shCfg)
end)
