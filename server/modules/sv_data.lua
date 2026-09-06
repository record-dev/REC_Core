
---@type REC_Core.Shared.Config, REC_Core.Server.Config
local shCfg, svCfg = require "@REC_Core.config.sh_config", require "@REC_Core.config.sv_config"

---@type REC_Core.Shared.Functions
local functions = require "@REC_Core.shared.sh_functions"

---@type REC_Core.Shared.Events
local events = require "@REC_Core.shared.sh_event"

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
---     Charinfo, metadata and the value store
---     charinfo and metadata are fields of the character row. The value store is
---     one row per (namespace, key) so a resource keeps its own values apart.
---]]
---@class REC_Core.Server.Modules.Data
local data = {}

---[[
---     Whether a namespace may be synced to the client
---]]
---@param namespace string
---@return boolean
local function isSyncable(namespace)
    return svCfg.sync.blockedNamespaces[namespace] == nil
end



---[[
---     Charinfo phase
---]]

---@param playerId integer
---@return REC_Core.Shared.Character.Charinfo|nil
function data:getCharinfo(playerId)

    local character = serverManager:getCharacterByPlayerId(playerId)
    if character == nil then
        return nil
    end

    return functions:deepCopy(character.info.charinfo)
end

---@param playerId integer
---@param key string
---@param value string|number|boolean|table|nil
---@return boolean
function data:setCharinfo(playerId, key, value)

    if utils:isValidString(key) == false or functions:isStorable(value) == false then
        return false
    end

    local character = serverManager:getCharacterByPlayerId(playerId)
    if character == nil then
        utils:debugPrint(("^3character is not loaded... playerId: %s^0"):format(tostring(playerId)))
        return false
    end

    local info = character.info
    local oldValue = info.charinfo[key]

    character:setCharinfo(key, value)

    ---@type REC_Core.Server.Main.CharinfoChange.Payload
    local payload = {
        citizenId = info.citizenId,
        key = key,
        oldValue = oldValue,
        newValue = value,
        charinfo = functions:deepCopy(info.charinfo),
    }

    TriggerClientEvent(events.client.updateCharinfo, playerId, payload)

    -- extension point
    handler:onCharinfoChange(playerId, payload)

    TriggerEvent(events.server.onCharinfoChange, playerId, payload)

    players:saveIfImmediate(info.citizenId)

    return true
end



---[[
---     Metadata phase
---]]

---@param playerId integer
---@param key string
---@return any
function data:getMetadata(playerId, key)

    local character = serverManager:getCharacterByPlayerId(playerId)
    if character == nil then
        return nil
    end

    return functions:deepCopy(character:getMetadata(key))
end

---@param playerId integer
---@return table<string, any>|nil
function data:getAllMetadata(playerId)

    local character = serverManager:getCharacterByPlayerId(playerId)
    if character == nil then
        return nil
    end

    return functions:deepCopy(character.info.metadata)
end

---[[
---     nil deletes the key
---]]
---@param playerId integer
---@param key string
---@param value any
---@return boolean
function data:setMetadata(playerId, key, value)

    if utils:isValidString(key) == false or functions:isStorable(value) == false then
        return false
    end

    local character = serverManager:getCharacterByPlayerId(playerId)
    if character == nil then
        utils:debugPrint(("^3character is not loaded... playerId: %s^0"):format(tostring(playerId)))
        return false
    end

    local info = character.info
    local oldValue = character:getMetadata(key)

    character:setMetadata(key, value)

    ---@type REC_Core.Server.Main.MetadataChange.Payload
    local payload = {
        citizenId = info.citizenId,
        key = key,
        oldValue = oldValue,
        newValue = value,
    }

    TriggerClientEvent(events.client.updateMetadata, playerId, payload)

    -- extension point
    handler:onMetadataChange(playerId, payload)

    TriggerEvent(events.server.onMetadataChange, playerId, payload)

    players:saveIfImmediate(info.citizenId)

    return true
end



---[[
---     Value store phase
---]]

---@param playerId integer
---@param namespace string
---@param dataKey string
---@return any
function data:getValue(playerId, namespace, dataKey)

    local character = serverManager:getCharacterByPlayerId(playerId)
    if character == nil then
        return nil
    end

    return functions:deepCopy(character:getValue(namespace, dataKey))
end

---@param playerId integer
---@param namespace string
---@return table<string, any>|nil
function data:getValues(playerId, namespace)

    local character = serverManager:getCharacterByPlayerId(playerId)
    if character == nil then
        return nil
    end

    return character:getValues(namespace)
end

---[[
---     Write one value, nil deletes it
---]]
---@param playerId integer
---@param namespace string
---@param dataKey string
---@param value any
---@param shouldDeferSave? boolean true skips the immediate write during a bulk operation
---@return boolean
function data:setValue(playerId, namespace, dataKey, value, shouldDeferSave)

    if functions:isStorable(value) == false then
        utils:debugPrint(("^3value must be a string, number, boolean or table... type: %s^0"):format(type(value)))
        return false
    end

    local character = serverManager:getCharacterByPlayerId(playerId)
    if character == nil then
        utils:debugPrint(("^3character is not loaded... playerId: %s^0"):format(tostring(playerId)))
        return false
    end

    local info = character.info

    -- extension point
    if handler:canSetValue(info.citizenId, namespace, dataKey, value) == false then
        utils:debugPrint(("^3setValue is rejected by handler... citizenId: %s, namespace: %s, dataKey: %s^0"):format(info.citizenId, namespace, dataKey))
        return false
    end

    local oldValue = character:getValue(namespace, dataKey)

    character:setValue(namespace, dataKey, value)

    ---@type REC_Core.Server.Main.ValueChange.Payload
    local payload = {
        citizenId = info.citizenId,
        namespace = namespace,
        dataKey = dataKey,
        oldValue = oldValue,
        newValue = value,
    }

    if isSyncable(namespace) == true then

        ---@type REC_Core.Client.Main.UpdateValue.Payload
        local clientPayload = {
            namespace = namespace,
            dataKey = dataKey,
            value = value,
        }

        TriggerClientEvent(events.client.updateValue, playerId, clientPayload)
    end

    -- extension point
    handler:onValueChange(playerId, payload)

    TriggerEvent(events.server.onValueChange, playerId, payload)

    if shouldDeferSave ~= true then
        players:saveIfImmediate(info.citizenId)
    end

    return true
end

---[[
---     Write every value of a namespace at once
---]]
---@param playerId integer
---@param namespace string
---@param values table<string, any>
---@return boolean
function data:setValues(playerId, namespace, values)

    local character = serverManager:getCharacterByPlayerId(playerId)
    if character == nil then
        utils:debugPrint(("^3character is not loaded... playerId: %s^0"):format(tostring(playerId)))
        return false
    end

    ---@type integer
    local successfulCount = 0

    for dataKey, value in pairs(values) do

        if utils:isValidString(dataKey) == false then
            utils:debugPrint(("^3dataKey must be a string... dataKey: %s^0"):format(tostring(dataKey)))
            goto continue
        end

        if self:setValue(playerId, namespace, dataKey, value, true) == true then
            successfulCount += 1
        end

        ::continue::
    end

    if successfulCount == 0 then
        return false
    end

    players:saveIfImmediate(character.info.citizenId)

    return true
end

---@param playerId integer
---@param namespace string
---@param dataKey string
---@return boolean
function data:removeValue(playerId, namespace, dataKey)
    return self:setValue(playerId, namespace, dataKey, nil)
end

---@param playerId integer
---@param namespace string
---@return boolean
function data:removeNamespace(playerId, namespace)

    local character = serverManager:getCharacterByPlayerId(playerId)
    if character == nil then
        utils:debugPrint(("^3character is not loaded... playerId: %s^0"):format(tostring(playerId)))
        return false
    end

    local values = character:getValues(namespace)
    if values == nil then
        return true
    end

    -- values is a copy, so deleting while iterating is fine
    for dataKey in pairs(values) do
        self:setValue(playerId, namespace, dataKey, nil, true)
    end

    players:saveIfImmediate(character.info.citizenId)

    return true
end



---[[
---     Offline phase
---     Straight to the DB, the loaded characters keep going through the cache.
---]]

---@param citizenId string
---@param namespace string
---@param dataKey? string omit it to get the whole namespace
---@return any
function data:getOfflineValue(citizenId, namespace, dataKey)

    local stored = repository:getData(citizenId)
    if stored == nil then
        return nil
    end

    local namespaceData = stored[namespace]
    if namespaceData == nil then
        return nil
    end

    if dataKey == nil then
        return namespaceData
    end

    return namespaceData[dataKey]
end

---@param citizenId string
---@param namespace string
---@param dataKey string
---@param value any nil deletes it
---@return boolean
function data:setOfflineValue(citizenId, namespace, dataKey, value)

    if functions:isStorable(value) == false then
        return false
    end

    if serverManager:getCharacter(citizenId) ~= nil then
        utils:debugPrint(("^3character is loaded, use setValue instead... citizenId: %s^0"):format(citizenId))
        return false
    end

    return repository:upsertData(citizenId, namespace, dataKey, value)
end

return data
