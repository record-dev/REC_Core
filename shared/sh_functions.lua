
---@class REC_Core.Shared.Functions
local functions = {}

---[[
---     Prefix every leaf with the resource name
---     { client = { syncPlayerData = "" } } -> "REC_Core:client:syncPlayerData"
---]]
---@param prefix string
---@param tbl table
function functions:generateEventsName(prefix, tbl)

    for key, value in pairs(tbl) do
        if type(value) == "string" then
            tbl[key] = prefix .. ":" .. key
        else
            self:generateEventsName(prefix .. ":" .. key, value)
        end
    end
end

---[[
---     Copy a value so the caller cannot mutate the original
---]]
---@generic T
---@param value T
---@return T
function functions:deepCopy(value)

    if type(value) ~= "table" then
        return value
    end

    local copy = {}
    for k, v in pairs(value) do
        copy[k] = self:deepCopy(v)
    end

    return copy
end

---[[
---     Whether a value can be stored in the DB as JSON
---]]
---@param value any
---@return boolean
function functions:isStorable(value)

    local valueType = type(value)

    return valueType == "nil"
        or valueType == "string"
        or valueType == "number"
        or valueType == "boolean"
        or valueType == "table"
end

---[[
---     Number of entries in a table, arrays and maps alike
---]]
---@param tbl table
---@return integer
function functions:count(tbl)

    ---@type integer
    local count = 0

    for _ in pairs(tbl) do
        count += 1
    end

    return count
end

---@param str any
---@return string|nil
function functions:trim(str)

    if type(str) ~= "string" then
        return nil
    end

    return str:match("^%s*(.-)%s*$")
end

---[[
---     Whether a string can be a first or last name
---     Counted in characters, so a Japanese name is not cut short by its byte length.
---]]
---@param str any
---@param minLength integer
---@param maxLength integer
---@return boolean
function functions:isValidName(str, minLength, maxLength)

    if type(str) ~= "string" then
        return false
    end

    local length = utf8.len(str)
    if length == nil or length < minLength or length > maxLength then
        return false
    end

    -- control characters, digits and markup have no place in a name
    if str:find("[%c%d%[%]{}<>\\/|@#$%%^&*+=~`\"_;:,?!]") ~= nil then
        return false
    end

    return true
end

---[[
---     Whether a string is a real date in YYYY-MM-DD
---]]
---@param str any
---@return boolean
function functions:isValidBirthdate(str)

    if type(str) ~= "string" then
        return false
    end

    local year, month, day = str:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)$")
    if year == nil then
        return false
    end

    year, month, day = tonumber(year), tonumber(month), tonumber(day)

    if year < 1900 or year > 2100 or month < 1 or month > 12 or day < 1 or day > 31 then
        return false
    end

    -- the round trip catches days that do not exist, e.g. 02-30
    if os == nil or os.time == nil then
        return true
    end

    local isSuccessful, timestamp = pcall(os.time, { year = year, month = month, day = day, hour = 12, })
    if isSuccessful == false or timestamp == nil then
        return false
    end

    local back = os.date("*t", timestamp)

    return back.year == year and back.month == month and back.day == day
end

---[[
---     1234567 -> "1,234,567"
---]]
---@param amount number
---@return string
function functions:formatNumber(amount)

    local sign = amount < 0 and "-" or ""
    local str = tostring(math.floor(math.abs(amount)))

    while true do
        local replaced, count = str:gsub("^(%d+)(%d%d%d)", "%1,%2")
        str = replaced

        if count == 0 then
            break
        end
    end

    return sign .. str
end

---[[
---     { x, y, z, w } -> vector4, tolerant of a vector already
---]]
---@param position any
---@return vector4|nil
function functions:toVector4(position)

    if type(position) == "vector4" then
        return position
    end

    if type(position) == "vector3" then
        return vector4(position.x, position.y, position.z, 0.0)
    end

    if type(position) ~= "table" then
        return nil
    end

    if type(position.x) ~= "number" or type(position.y) ~= "number" or type(position.z) ~= "number" then
        return nil
    end

    return vector4(position.x + 0.0, position.y + 0.0, position.z + 0.0, (position.w or 0.0) + 0.0)
end

---[[
---     vector4 -> { x, y, z, w } for JSON
---]]
---@param position vector4|vector3|table|nil
---@return REC_Core.Shared.Position|nil
function functions:toPositionTable(position)

    local vector = self:toVector4(position)
    if vector == nil then
        return nil
    end

    ---@type REC_Core.Shared.Position
    return {
        x = vector.x,
        y = vector.y,
        z = vector.z,
        w = vector.w,
    }
end

return functions
