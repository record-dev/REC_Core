
---@type REC_Core.Server.Utils
local utils = require "@REC_Core.server.sv_utils"

---[[
---     DO NOT TOUCH
---     Table names, shared with sv_repository
---]]
---@class REC_Core.Server.Schema.Tables
local tables = {
    characters = "rec_core_characters",
    data = "rec_core_data",
}

---[[
---     The DDL that owns the tables above
---     Applied by hand (or by REC_SQLRunner), so nothing here ever creates a table.
---]]
---@type string
local SQL_FILE = "rec_core.sql"

---@class REC_Core.Server.Schema
local schema = {

    ---@type REC_Core.Server.Schema.Tables
    tables = tables,
}

---[[
---     The tables that are not on the database yet
---]]
---@return string[]
local function findMissingTables()

    ---@type string[]
    local missing = {}

    for _, name in pairs(tables) do

        local found = MySQL.scalar.await("SELECT 1 FROM `information_schema`.`TABLES` WHERE `TABLE_SCHEMA` = DATABASE() AND `TABLE_NAME` = ? LIMIT 1", { name, })
        if found == nil then
            missing[#missing+1] = name
        end
    end

    table.sort(missing)

    return missing
end

---[[
---     Check the tables are there
---     Called once at start, before the first character can be loaded.
---]]
---@return boolean
function schema:check()

    local isSuccessful, result = pcall(findMissingTables)
    if isSuccessful == false then
        utils:log(("^1failed to read the schema: %s^0"):format(tostring(result)))
        return false
    end

    ---@cast result string[]
    if #result > 0 then
        utils:log(("^1missing table(s): %s^0"):format(table.concat(result, ", ")))
        utils:log(("^3run %s on your database and restart the resource. Until then no character can be created or loaded.^0"):format(SQL_FILE))
        return false
    end

    return true
end

return schema
