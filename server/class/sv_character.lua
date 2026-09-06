
---@type REC_Core.Shared.Functions
local functions = require "@REC_Core.shared.sh_functions"

---[[
---     One loaded character
---     Holds the in memory state and remembers what changed since the last save.
---     Each mark carries a revision so a save that yielded only clears the marks it
---     actually wrote, and a change made while it was awaiting stays dirty.
---]]
---@class REC_Core.Server.Class.Character
---@field info REC_Core.Server.Class.Character.Info
local Character = {}
Character.__index = Character

---instantiation
---@param payload REC_Core.Server.Class.Character.Payload
---@return self
function Character:new(payload)
    local instance = setmetatable({}, self)

    ---@type REC_Core.Server.Class.Character.Info
    instance.info = {
        playerId = payload.playerId,
        license = payload.license,
        citizenId = payload.citizenId,
        slot = payload.slot,
        charinfo = payload.charinfo,
        job = payload.job,
        gang = payload.gang,
        money = payload.money,
        metadata = payload.metadata,
        position = payload.position,
        data = payload.data,
        loadedAt = os.time(),
        revision = 0,
        dirty = {
            columns = {},
            data = {},
        },
    }

    return instance
end



---[[
---     Snapshot phase
---]]

---[[
---     Copy other resources read, nothing here points into the live state
---]]
---@return REC_Core.Server.Character
function Character:snapshot()
    local info = self.info

    ---@type REC_Core.Server.Character
    return {
        playerId = info.playerId,
        license = info.license,
        citizenId = info.citizenId,
        slot = info.slot,
        charinfo = functions:deepCopy(info.charinfo),
        job = functions:deepCopy(info.job),
        gang = functions:deepCopy(info.gang),
        money = functions:deepCopy(info.money),
        metadata = functions:deepCopy(info.metadata),
        position = functions:deepCopy(info.position),
        loadedAt = info.loadedAt,
    }
end

---[[
---     The same without what the client has no business seeing
---]]
---@return REC_Core.Shared.Character
function Character:toClientSnapshot()

    local snapshot = self:snapshot()
    snapshot.license = nil
    snapshot.playerId = nil
    snapshot.loadedAt = nil

    return snapshot
end



---[[
---     Dirty phase
---]]

---@param column string
function Character:markColumn(column)
    local info = self.info

    info.revision += 1
    info.dirty.columns[column] = info.revision
end

---@param namespace string
---@param dataKey string
function Character:markData(namespace, dataKey)
    local info = self.info

    info.revision += 1

    if info.dirty.data[namespace] == nil then
        info.dirty.data[namespace] = {}
    end

    info.dirty.data[namespace][dataKey] = info.revision
end

---@return boolean
function Character:hasDirty()
    local dirty = self.info.dirty

    return next(dirty.columns) ~= nil or next(dirty.data) ~= nil
end

---[[
---     Copy of the marks a save is about to write
---]]
---@return REC_Core.Server.Class.Character.Dirty
function Character:takeTargets()
    return functions:deepCopy(self.info.dirty)
end

---[[
---     Clear the marks a save wrote, keeping the ones that moved on since
---]]
---@param targets REC_Core.Server.Class.Character.Dirty
function Character:clearTargets(targets)
    local dirty = self.info.dirty

    for column, revision in pairs(targets.columns) do
        if dirty.columns[column] == revision then
            dirty.columns[column] = nil
        end
    end

    for namespace, dataKeys in pairs(targets.data) do

        local current = dirty.data[namespace]
        if current == nil then
            goto continue
        end

        for dataKey, revision in pairs(dataKeys) do
            if current[dataKey] == revision then
                current[dataKey] = nil
            end
        end

        if next(current) == nil then
            dirty.data[namespace] = nil
        end

        ::continue::
    end
end



---[[
---     Money phase
---]]

---@param account string
---@return integer
function Character:getMoney(account)
    return self.info.money[account] or 0
end

---@param account string
---@param balance integer
function Character:setMoney(account, balance)
    self.info.money[account] = balance
    self:markColumn("money")
end



---[[
---     Group phase
---]]

---@param groupType REC_Core.Shared.Enum.GroupTypes
---@param group REC_Core.Shared.Character.Group
function Character:setGroup(groupType, group)
    self.info[groupType] = group
    self:markColumn(groupType)
end



---[[
---     Charinfo phase
---]]

---@param key string
---@param value any
function Character:setCharinfo(key, value)
    self.info.charinfo[key] = value
    self:markColumn("charinfo")
end



---[[
---     Metadata phase
---]]

---@param key string
---@return any
function Character:getMetadata(key)
    return self.info.metadata[key]
end

---@param key string
---@param value any
function Character:setMetadata(key, value)
    self.info.metadata[key] = value
    self:markColumn("metadata")
end



---[[
---     Value store phase
---]]

---@param namespace string
---@param dataKey string
---@return any
function Character:getValue(namespace, dataKey)

    local namespaceData = self.info.data[namespace]
    if namespaceData == nil then
        return nil
    end

    return namespaceData[dataKey]
end

---[[
---     Every value of a namespace, as a copy
---]]
---@param namespace string
---@return table<string, any>|nil
function Character:getValues(namespace)

    local namespaceData = self.info.data[namespace]
    if namespaceData == nil then
        return nil
    end

    return functions:deepCopy(namespaceData)
end

---[[
---     nil deletes the value
---]]
---@param namespace string
---@param dataKey string
---@param value any
function Character:setValue(namespace, dataKey, value)
    local info = self.info

    if info.data[namespace] == nil then
        info.data[namespace] = {}
    end

    info.data[namespace][dataKey] = value

    self:markData(namespace, dataKey)

    -- drop the namespace once it is empty
    if value == nil and next(info.data[namespace]) == nil then
        info.data[namespace] = nil
    end
end



---[[
---     Position phase
---]]

---[[
---     Not marked, the save reads the live ped anyway
---]]
---@param position REC_Core.Shared.Position
function Character:setPosition(position)
    self.info.position = position
end

return Character

---@class REC_Core.Server.Class.Character.Payload
---@field playerId integer
---@field license string
---@field citizenId string
---@field slot integer
---@field charinfo REC_Core.Shared.Character.Charinfo
---@field job REC_Core.Shared.Character.Group
---@field gang REC_Core.Shared.Character.Group
---@field money table<string, integer>
---@field metadata table<string, any>
---@field position REC_Core.Shared.Position|nil
---@field data table<string, table<string, any>>

---@class REC_Core.Server.Class.Character.Info: REC_Core.Server.Class.Character.Payload
---@field loadedAt integer
---@field revision integer
---@field dirty REC_Core.Server.Class.Character.Dirty

---@class REC_Core.Server.Class.Character.Dirty
---@field columns table<string, integer> column -> revision
---@field data table<string, table<string, integer>> namespace -> dataKey -> revision
