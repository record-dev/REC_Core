
---@type REC_Core.Shared.Config
local shCfg = require "@REC_Core.config.sh_config"

---@type REC_Core.Shared.Enum
local shEnums = require "@REC_Core.shared.sh_enum"
local groupTypes = shEnums.groupTypes

---@type REC_Core.Shared.Functions
local functions = require "@REC_Core.shared.sh_functions"

---@type table<string, REC_Core.Config.Job>, table<string, REC_Core.Config.Gang>
local jobs, gangs = require "@REC_Core.config.sh_jobs", require "@REC_Core.config.sh_gangs"

---[[
---     Job and gang definitions
---     Reads config/sh_jobs.lua and config/sh_gangs.lua and turns a stored
---     { name, grade } into the snapshot other resources read.
---]]
---@class REC_Core.Shared.Groups
local groups = {}

---@param groupType REC_Core.Shared.Enum.GroupTypes
---@return table<string, REC_Core.Config.Group>
function groups:getDefinitions(groupType)

    if groupType == groupTypes.gang then
        return gangs
    end

    return jobs
end

---@param groupType REC_Core.Shared.Enum.GroupTypes
---@return string
function groups:getDefaultName(groupType)

    if groupType == groupTypes.gang then
        return shCfg.groups.defaultGang
    end

    return shCfg.groups.defaultJob
end

---@param groupType REC_Core.Shared.Enum.GroupTypes
---@param name any
---@return REC_Core.Config.Group|nil
function groups:get(groupType, name)

    if type(name) ~= "string" then
        return nil
    end

    return self:getDefinitions(groupType)[name]
end

---[[
---     Build the snapshot other resources read
---]]
---@param groupType REC_Core.Shared.Enum.GroupTypes
---@param name any
---@param grade any
---@param onDuty? boolean job only, nil takes the job's defaultDuty
---@return REC_Core.Shared.Character.Group|nil nil when the name or the grade is unknown
function groups:resolve(groupType, name, grade, onDuty)

    local definition = self:get(groupType, name)
    if definition == nil then
        return nil
    end

    if grade == nil then
        grade = 0
    end

    -- 2.0 from a command or a JSON column is still grade 2
    if type(grade) == "number" then
        grade = math.tointeger(grade)
    end

    if math.type(grade) ~= "integer" then
        return nil
    end

    local gradeDefinition = definition.grades[grade]
    if gradeDefinition == nil then
        return nil
    end

    ---@type REC_Core.Shared.Character.Group
    local group = {
        name = name,
        label = definition.label,
        type = definition.type,
        grade = {
            level = grade,
            name = gradeDefinition.name,
            isBoss = gradeDefinition.isBoss == true,
            payment = gradeDefinition.payment or 0,
        },
    }

    if groupType == groupTypes.job then

        if onDuty == nil then
            onDuty = definition.defaultDuty == true
        end

        group.onDuty = onDuty
    end

    return group
end

---[[
---     Resolve what the DB stored
---     Falls back to the default group when the stored one is no longer in the config.
---]]
---@param groupType REC_Core.Shared.Enum.GroupTypes
---@param stored REC_Core.Shared.Character.StoredGroup|nil
---@return REC_Core.Shared.Character.Group
function groups:resolveStored(groupType, stored)

    if type(stored) == "table" then
        local group = self:resolve(groupType, stored.name, stored.grade, stored.onDuty)
        if group ~= nil then
            return group
        end
    end

    -- validate() made sure the default resolves
    return self:resolve(groupType, self:getDefaultName(groupType), 0) --[[@as REC_Core.Shared.Character.Group]]
end

---[[
---     What goes into the DB
---]]
---@param group REC_Core.Shared.Character.Group
---@return REC_Core.Shared.Character.StoredGroup
function groups:toStored(group)

    ---@type REC_Core.Shared.Character.StoredGroup
    return {
        name = group.name,
        grade = group.grade.level,
        onDuty = group.onDuty,
    }
end

---[[
---     Whether a group satisfies a job check
---]]
---@param group REC_Core.Shared.Character.Group
---@param names string|string[]
---@param grades? table<integer, true>|integer[] set or list of allowed grade levels, nil allows all
---@param onDutyOnly? boolean
---@return boolean
function groups:matches(group, names, grades, onDutyOnly)

    if group == nil then
        return false
    end

    -- name
    local nameMatched = (function ()
        if type(names) == "string" then
            return group.name == names
        end

        if type(names) ~= "table" then
            return false
        end

        for _, name in ipairs(names) do
            if group.name == name then
                return true
            end
        end

        return false
    end)()

    if nameMatched == false then
        return false
    end

    -- grade
    if type(grades) == "table" and next(grades) ~= nil then

        local gradeMatched = grades[group.grade.level] == true

        if gradeMatched == false then
            for _, level in ipairs(grades) do
                if level == group.grade.level then
                    gradeMatched = true
                    break
                end
            end
        end

        if gradeMatched == false then
            return false
        end
    end

    -- duty
    if onDutyOnly == true and group.onDuty ~= true then
        return false
    end

    return true
end

---[[
---     Labels of every group, for menus and other resources
---]]
---@param groupType REC_Core.Shared.Enum.GroupTypes
---@return table<string, REC_Core.Shared.Groups.Label>
function groups:getLabels(groupType)

    ---@type table<string, REC_Core.Shared.Groups.Label>
    local labels = {}

    for name, definition in pairs(self:getDefinitions(groupType)) do
        labels[name] = {
            label = definition.label,
            type = definition.type,
            grades = functions:deepCopy(definition.grades),
        }
    end

    return labels
end

---[[
---     Check the config once at start
---]]
---@return boolean
---@return string|nil reason
function groups:validate()

    for _, groupType in pairs(groupTypes) do

        local definitions = self:getDefinitions(groupType)

        for name, definition in pairs(definitions) do

            if type(name) ~= "string" or name == "" then
                return false, ("%s has a name that is not a string"):format(groupType)
            end

            if type(definition.label) ~= "string" then
                return false, ("%s %s has no label"):format(groupType, name)
            end

            if type(definition.grades) ~= "table" or definition.grades[0] == nil then
                return false, ("%s %s has no grade 0"):format(groupType, name)
            end

            for level, grade in pairs(definition.grades) do

                if math.type(level) ~= "integer" or level < 0 then
                    return false, ("%s %s has a grade key that is not an integer >= 0"):format(groupType, name)
                end

                if type(grade.name) ~= "string" then
                    return false, ("%s %s grade %d has no name"):format(groupType, name, level)
                end
            end
        end

        local defaultName = self:getDefaultName(groupType)
        if definitions[defaultName] == nil then
            return false, ("default %s %s is not defined"):format(groupType, tostring(defaultName))
        end
    end

    return true
end

return groups

---@class REC_Core.Shared.Groups.Label
---@field label string
---@field type? string
---@field grades table<integer, REC_Core.Config.Group.Grade>
