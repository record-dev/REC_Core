
---@type REC_Core.Server.Utils
local utils = require "@REC_Core.server.sv_utils"

---@type REC_Core.Server.Schema
local schema = require "@REC_Core.server.sv_schema"
local tables = schema.tables

---[[
---     Columns of the character table other code may write
---]]
---@type table<string, true>
local writableColumns = {
    charinfo = true,
    job = true,
    gang = true,
    money = true,
    metadata = true,
    position = true,
    lastLoggedOutAt = true,
}

---[[
---     Everything that talks to the DB
---     Rows go in and out as plain tables, the JSON columns are decoded here.
---]]
---@class REC_Core.Server.Repository
local repository = {}



---[[
---     JSON phase
---]]

---[[
---     Lua value -> string the DB can store
---]]
---@param value any
---@return string|nil
function repository:encode(value)

    local isSuccessful, encoded = pcall(json.encode, value)
    if isSuccessful == false or type(encoded) ~= "string" then
        return nil
    end

    return encoded
end

---[[
---     string stored in the DB -> Lua value
---]]
---@param encoded any
---@return any
function repository:decode(encoded)

    if type(encoded) ~= "string" or encoded == "" then
        return nil
    end

    local isSuccessful, decoded = pcall(json.decode, encoded)
    if isSuccessful == false then
        utils:debugPrint(("^1failed to decode value... value: %s^0"):format(encoded))
        return nil
    end

    return decoded
end

---[[
---     Encode the table values of a column set, skipping what cannot be encoded
---]]
---@param columns table<string, any>
---@return table<string, any>
function repository:encodeColumns(columns)

    ---@type table<string, any>
    local encoded = {}

    for column, value in pairs(columns) do

        if writableColumns[column] ~= true then
            utils:debugPrint(("^3column is not writable... column: %s^0"):format(column))
            goto continue
        end

        if type(value) == "table" then

            local encodedValue = self:encode(value)
            if encodedValue == nil then
                utils:log(("^1failed to encode column, it will not be saved... column: %s^0"):format(column))
                goto continue
            end

            encoded[column] = encodedValue
        else
            encoded[column] = value
        end

        ::continue::
    end

    return encoded
end



---[[
---     Character phase
---]]

---[[
---     DB row -> record with the JSON columns decoded
---]]
---@param row table
---@return REC_Core.Server.Repository.CharacterRecord
function repository:toRecord(row)

    ---@type REC_Core.Server.Repository.CharacterRecord
    return {
        citizenId = row.citizenId,
        license = row.license,
        slot = row.slot,
        charinfo = self:decode(row.charinfo) or {},
        job = self:decode(row.job),
        gang = self:decode(row.gang),
        money = self:decode(row.money) or {},
        metadata = self:decode(row.metadata) or {},
        position = self:decode(row.position),
        lastLoggedOutAt = row.lastLoggedOutAt,
        createdAt = row.createdAt,
    }
end

---[[
---     Every character of one license, ordered by slot
---]]
---@param license string
---@return REC_Core.Server.Repository.CharacterRecord[]|nil nil when the query failed
function repository:getCharactersByLicense(license)

    local query = ("SELECT * FROM `%s` WHERE `license` = ? ORDER BY `slot` ASC"):format(tables.characters)

    local isSuccessful, rows = pcall(MySQL.query.await, query, { license, })
    if isSuccessful == false then
        utils:log(("^1failed to query characters... error: %s^0"):format(tostring(rows)))
        return nil
    end

    ---@type REC_Core.Server.Repository.CharacterRecord[]
    local records = {}

    for _, row in ipairs(rows or {}) do
        records[#records+1] = self:toRecord(row)
    end

    return records
end

---[[
---     One character
---]]
---@param citizenId string
---@return REC_Core.Server.Repository.CharacterRecord|nil
function repository:getCharacter(citizenId)

    local query = ("SELECT * FROM `%s` WHERE `citizenId` = ? LIMIT 1"):format(tables.characters)

    local isSuccessful, row = pcall(MySQL.single.await, query, { citizenId, })
    if isSuccessful == false then
        utils:log(("^1failed to query character... error: %s^0"):format(tostring(row)))
        return nil
    end

    if row == nil then
        return nil
    end

    return self:toRecord(row)
end

---@param citizenId string
---@return boolean|nil nil when the query failed
function repository:doesCitizenIdExist(citizenId)

    local query = ("SELECT 1 FROM `%s` WHERE `citizenId` = ? LIMIT 1"):format(tables.characters)

    local isSuccessful, found = pcall(MySQL.scalar.await, query, { citizenId, })
    if isSuccessful == false then
        utils:log(("^1failed to check citizenId... error: %s^0"):format(tostring(found)))
        return nil
    end

    return found ~= nil
end

---[[
---     Insert a new character
---     position starts as NULL, the first save fills it in.
---]]
---@param record REC_Core.Server.Repository.CharacterRecord
---@return boolean
function repository:insertCharacter(record)

    local columns = self:encodeColumns({
        charinfo = record.charinfo,
        job = record.job,
        gang = record.gang,
        money = record.money,
        metadata = record.metadata,
    })

    for _, column in ipairs({ "charinfo", "job", "gang", "money", "metadata", }) do
        if columns[column] == nil then
            return false
        end
    end

    local query = ("INSERT INTO `%s` (`citizenId`, `license`, `slot`, `charinfo`, `job`, `gang`, `money`, `metadata`) VALUES (?, ?, ?, ?, ?, ?, ?, ?)"):format(tables.characters)

    local isSuccessful, response = pcall(MySQL.insert.await, query, {
        record.citizenId,
        record.license,
        record.slot,
        columns.charinfo,
        columns.job,
        columns.gang,
        columns.money,
        columns.metadata,
    })

    if isSuccessful == false or response == nil then
        utils:log(("^1failed to insert character... citizenId: %s, error: %s^0"):format(record.citizenId, tostring(response)))
        return false
    end

    utils:debugPrint(("^2successful to insert character... citizenId: %s^0"):format(record.citizenId))

    return true
end

---[[
---     UPDATE for a set of columns, nil when nothing is writable
---]]
---@param citizenId string
---@param columns table<string, any>
---@return REC_Core.Server.Repository.Query|nil
function repository:buildCharacterQuery(citizenId, columns)

    local encoded = self:encodeColumns(columns)

    ---@type string[], any[]
    local sets, values = {}, {}

    for column, value in pairs(encoded) do
        sets[#sets+1] = ("`%s` = ?"):format(column)
        values[#values+1] = value
    end

    if #sets == 0 then
        return nil
    end

    values[#values+1] = citizenId

    ---@type REC_Core.Server.Repository.Query
    return {
        query = ("UPDATE `%s` SET %s WHERE `citizenId` = ?"):format(tables.characters, table.concat(sets, ", ")),
        values = values,
    }
end

---[[
---     Write a set of columns right now
---]]
---@param citizenId string
---@param columns table<string, any>
---@return boolean
function repository:updateCharacter(citizenId, columns)

    local built = self:buildCharacterQuery(citizenId, columns)
    if built == nil then
        return false
    end

    local isSuccessful, response = pcall(MySQL.update.await, built.query, built.values)
    if isSuccessful == false or response == nil then
        utils:log(("^1failed to update character... citizenId: %s, error: %s^0"):format(citizenId, tostring(response)))
        return false
    end

    return true
end

---[[
---     Delete a character and every value stored for it
---]]
---@param citizenId string
---@return boolean
function repository:deleteCharacter(citizenId)

    ---@type REC_Core.Server.Repository.Query[]
    local queries = {
        {
            query = ("DELETE FROM `%s` WHERE `citizenId` = ?"):format(tables.data),
            values = { citizenId, },
        },
        {
            query = ("DELETE FROM `%s` WHERE `citizenId` = ?"):format(tables.characters),
            values = { citizenId, },
        },
    }

    if self:transaction(queries) == false then
        utils:log(("^1failed to delete character... citizenId: %s^0"):format(citizenId))
        return false
    end

    utils:debugPrint(("^2successful to delete character... citizenId: %s^0"):format(citizenId))

    return true
end



---[[
---     Value store phase
---]]

---[[
---     Every value of one character, keyed by namespace
---]]
---@param citizenId string
---@return table<string, table<string, any>>|nil nil when the query failed
function repository:getData(citizenId)

    local query = ("SELECT `namespace`, `dataKey`, `value` FROM `%s` WHERE `citizenId` = ?"):format(tables.data)

    local isSuccessful, rows = pcall(MySQL.query.await, query, { citizenId, })
    if isSuccessful == false then
        utils:log(("^1failed to query values... error: %s^0"):format(tostring(rows)))
        return nil
    end

    ---@type table<string, table<string, any>>
    local data = {}

    for _, row in ipairs(rows or {}) do

        if row.namespace == nil or row.dataKey == nil then
            goto continue
        end

        if data[row.namespace] == nil then
            data[row.namespace] = {}
        end

        data[row.namespace][row.dataKey] = self:decode(row.value)

        ::continue::
    end

    return data
end

---[[
---     Upsert or delete for one value, nil deletes the row
---]]
---@param citizenId string
---@param namespace string
---@param dataKey string
---@param value any
---@return REC_Core.Server.Repository.Query|nil nil when the value cannot be encoded
function repository:buildDataQuery(citizenId, namespace, dataKey, value)

    if value == nil then

        ---@type REC_Core.Server.Repository.Query
        return {
            query = ("DELETE FROM `%s` WHERE `citizenId` = ? AND `namespace` = ? AND `dataKey` = ?"):format(tables.data),
            values = { citizenId, namespace, dataKey, },
        }
    end

    local encoded = self:encode(value)
    if encoded == nil then
        utils:log(("^1failed to encode value, it will not be saved... citizenId: %s, namespace: %s, dataKey: %s^0"):format(citizenId, namespace, dataKey))
        return nil
    end

    ---@type REC_Core.Server.Repository.Query
    return {
        query = ("INSERT INTO `%s` (`citizenId`, `namespace`, `dataKey`, `value`) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE `value` = VALUES(`value`)"):format(tables.data),
        values = { citizenId, namespace, dataKey, encoded, },
    }
end

---[[
---     Write one value right now, for offline characters
---]]
---@param citizenId string
---@param namespace string
---@param dataKey string
---@param value any
---@return boolean
function repository:upsertData(citizenId, namespace, dataKey, value)

    local built = self:buildDataQuery(citizenId, namespace, dataKey, value)
    if built == nil then
        return false
    end

    local isSuccessful, response = pcall(MySQL.update.await, built.query, built.values)
    if isSuccessful == false or response == nil then
        utils:log(("^1failed to write value... citizenId: %s, namespace: %s, dataKey: %s, error: %s^0"):format(citizenId, namespace, dataKey, tostring(response)))
        return false
    end

    return true
end



---[[
---     Transaction phase
---]]

---[[
---     Run queries as one transaction and wait for it
---]]
---@param queries REC_Core.Server.Repository.Query[]
---@return boolean
function repository:transaction(queries)

    if #queries == 0 then
        return true
    end

    local isSuccessful, response = pcall(MySQL.transaction.await, queries)
    if isSuccessful == false or response ~= true then
        utils:log(("^1transaction failed... queries: %d, error: %s^0"):format(#queries, tostring(response)))
        return false
    end

    return true
end

---[[
---     Run queries as one transaction without waiting
---     await never returns while the resource is stopping, so this is what the stop uses.
---]]
---@param queries REC_Core.Server.Repository.Query[]
function repository:fireTransaction(queries)

    if #queries == 0 then
        return
    end

    MySQL.transaction(queries)
end

return repository

---@class REC_Core.Server.Repository.Query
---@field query string
---@field values any[]

---@class REC_Core.Server.Repository.CharacterRecord
---@field citizenId string
---@field license string
---@field slot integer
---@field charinfo REC_Core.Shared.Character.Charinfo
---@field job REC_Core.Shared.Character.StoredGroup|nil
---@field gang REC_Core.Shared.Character.StoredGroup|nil
---@field money table<string, integer>
---@field metadata table<string, any>
---@field position REC_Core.Shared.Position|nil
---@field lastLoggedOutAt? string|integer
---@field createdAt? string|integer
