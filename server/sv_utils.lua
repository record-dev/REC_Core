
---@type REC_Library.Server.API, REC_Library.Shared.API
local svApi, shApi = require "@REC_Library.server.sv_api", require "@REC_Library.shared.sh_api"

---@type REC_Utils.Server.Api
local svUtilsApi = require "@REC_Utils.server.sv_api"

---@type REC_Core.Shared.Config, REC_Core.Server.Config
local shCfg, svCfg = require "@REC_Core.config.sh_config", require "@REC_Core.config.sv_config"

---[[
---     DO NOT TOUCH
---]]
---@type string
local tableName = "rec_core"

---@class REC_Core.Server.Utils
local utils = {}

---[[
---     Batch registration process
---]]
---@param serverManager REC_Core.Server.Manager.ServerManager
---@param uid string
---@return boolean
function utils:register(serverManager, uid)

    -- Existence check
    if self:doesMetaDataExist(serverManager, uid) == true then
        self:debugPrint(("^3metaData is already exist... uid: %d^0"):format(uid))
        return false
    end

    ---[[
    ---     DB information verification phase
    ---]]
    local existRecord = self:getRecord(uid)
    if existRecord == nil then
        self:debugPrint(("^3failed to get record... uid: %d^0"):format(uid))

        -- Create record
        if self:createRecord(
            uid,
            {}
        ) == false then
            self:debugPrint(("^3failed to create record... uid: %d^0"):format(uid))
            return false
        end

        ---@type REC_Core.Server.Utils.GetRecord.Return
        existRecord = {
            -- ...
        }
    else
        self:debugPrint(("^2record is founded... playerId: %d^0"):format(uid))

        existRecord = existRecord[1]
    end

    ---[[
    ---     metadata fase
    ---]]
    local metaData = self:createMetaData(
        uid,
        {}
    )

    -- Register
    if self:registerMetaData(serverManager, metaData) == false then
        self:debugPrint(("^3failed to get register metaData... playerId: %d^0"):format(playerId))
        return false
    end

    return true
end

---[[
---     Batch unregistration process
---]]
---@param serverManager REC_Core.Server.Manager.ServerManager
---@param uid string
---@return boolean
function utils:unregister(serverManager, uid)
    local serverManagerInfo = serverManager.info

    ---[[
    ---     Metadata phase
    ---]]

    -- Unregister metadata
    if self:unregisterMetaData(serverManager, uid) == false then
        self:debugPrint(("^3failed to unregister metaData... uid: %s^0"):format(uid))
        return false
    end

    return true
end

---[[
---     Create metadata
---]]
---@param uid string
---@param payload REC_Core.Server.Utils.CreateMetaData.Payload
---@return REC_Core.Server.Manager.ServerManagerConfigBuilder.MetaData
function utils:createMetaData(uid, payload)

    ---@type REC_Core.Server.Manager.ServerManagerConfigBuilder.MetaData
    return {
        uid = uid,
        -- ...
    }
end

---[[
---     Get metadata
---]]
---@param serverManager REC_Core.Server.Manager.ServerManager
---@param uid string
---@return REC_Core.Server.Manager.ServerManagerConfigBuilder.MetaData|nil
function utils:getMetaData(serverManager, uid)
    local serverManagerInfo = serverManager.info

    -- Existence check
    if self:doesMetaDataExist(serverManager, uid) == false then
        return nil
    end

    return serverManagerInfo.metaDatas[uid]
end

---[[
---     Register metadata
---]]
---@param serverManager REC_Core.Server.Manager.ServerManager
---@param metaData REC_Core.Server.Manager.ServerManagerConfigBuilder.MetaData
---@return boolean
function utils:registerMetaData(serverManager, metaData)
    local serverManagerInfo = serverManager.info

    -- Existence check
    if self:doesMetaDataExist(serverManager, metaData.uid) == true then
        self:debugPrint(("^3metaData is already exist... uid: %d^0"):format(metaData.uid))
        return false
    end

    -- Store
    serverManagerInfo.metaDatas[metaData.uid] = metaData

    return true
end

---[[
---     Unregister metadata
---]]
---@param serverManager REC_Core.Server.Manager.ServerManager
---@param uid string
---@return boolean
function utils:unregisterMetaData(serverManager, uid)
    local serverManagerInfo = serverManager.info

    -- Existence check
    if self:doesMetaDataExist(serverManager, uid) == false then
        self:debugPrint(("^3metaData is not exist... uid: %d^0"):format(uid))
        return false
    end

    -- Remove from list
    serverManagerInfo.metaDatas[uid] = nil

    return true
end

---[[
---     Check metadata existence
---]]
---@param serverManager REC_Core.Server.Manager.ServerManager
---@param uid string
---@return boolean
function utils:doesMetaDataExist(serverManager, uid)
    return serverManager.info.metaDatas[uid] ~= nil
end

---[[
---     Create record
---]]
---@param uid string
---@param payload REC_Core.Server.Utils.CreateRecord.Payload
---@return boolean
function utils:createRecord(uid, payload)

    local query = "INSERT INTO `%s` (`------`) VALUES (?)"

    -- Execute query
    local response = MySQL.insert.await((query):format(tableName), { uid })
    if response == nil then
        self:debugPrint(("^1failed to create record with uid: %s^0"):format(uid))
        return false
    end

    self:debugPrint(("^2successful to create record with uid: %s^0"):format(uid))

    return true
end

---[[
---     Update record
---]]
---@param serverManager REC_Core.Server.Manager.ServerManager
---@param uid string
---@param payload REC_Core.Server.Utils.UpdateMetaData.Payload
---@return boolean
function utils:updateMetaData(serverManager, uid, payload)

    -- Get metadata
    local metaData = self:getMetaData(serverManager, uid)
    if metaData == nil then
        self:debugPrint(("^1metaData is no founded with uid: %s^0"):format(uid))
        return false
    end

    -- Execute update process
    for k, v in pairs(payload) do
        if metaData[k] ~= nil then
            metaData[k] = v

            -- Debug output
            self:debugPrint(("^2updated metaData key: %s, value: %s^0"):format(k, tostring(v)))
        end
    end

    self:debugPrint(("^2successful to update metaData... uid: %s^0"):format(uid))

    return true
end

---[|
---     Get record
---     Also supports multiple searches
---]]
---@param targetUid string|string[]
---@return table<integer, REC_Core.Server.Utils.GetRecord.Return>|nil
function utils:getRecord(targetUid)

    -- Argument check
    if targetUid == nil or (type(targetUid) ~= "string" and type(targetUid) ~= "table") then
        self:debugPrint("^3invalid params.^0")
        return nil
    end

    -- Convert to table if singular
    if type(targetUid) ~= "table" then
        targetUid = { targetUid }
    end

    -- Organize query
    local query = "SELECT * FROM `%s` WHERE `------` IN (?)"

    -- Execute query
    ---@type table<integer, REC_Core.Server.Utils.GetRecord.Return>
    local response = MySQL.query.await((query):format(tableName), { targetUid })
    if response == nil or #response == 0 then
        self:debugPrint("^1failed to get record...^0")
        return nil
    end

    -- Conversion process
    for _, record in ipairs(response) do
        for k, v in pairs(record) do

            -- ...

            -- Convert to boolean type that is easy to handle in Lua
            if type(v) == "boolean" then
                if v == 1 then
                    v = true
                else
                    v = false
                end
            end
        end
    end

    return response
end

---[[
---     Update record
---]]
---@param uid string
---@param payload REC_Core.Server.Utils.UpdateRecord.Payload
---@return boolean
function utils:updateRecord(uid, payload)

    local query = "UPDATE `%s` SET `something` = ? WHERE `------` = ?"

    local response = MySQL.update.await((query):format(tableName), {
        uid
        -- ...
    })

    if response == nil then
        self:debugPrint(("^1failed to update record with uid: %s^0"):format(uid))
        return false
    end

    self:debugPrint(("^2successful to update record with uid: %s^0"):format(uid))

    return true
end

---[[
---     Notify
---]]
---@param playerId integer
---@param notifyType "info" | "success" | "warning" | "error" 
---@param title string
---@param description string
---@param duration? integer
---@param showDuration? boolean
function utils:notify(playerId, notifyType, title, description, duration, showDuration)
    duration = duration or 4000
    showDuration = showDuration or false

    svUtilsApi.Notify:trigger(
        playerId,
        notifyType,
        title,
        description,
        duration,
        true
    )
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

---@class REC_Core.Server.Utils.CreateMetaData.Payload
---@

---@class REC_Core.Server.Utils.UpdateMetaData.Payload
---@

---@class REC_Core.Server.Utils.GetRecord.Return
---@field id? integer
---@
---@
---@
---@field updatedAt? integer
---@field createdAt? integer

---@class REC_Core.Server.Utils.CreateRecord.Payload
---@

---@class REC_Core.Server.Utils.UpdateRecord.Payload
---@


return utils