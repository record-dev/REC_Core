
---@type REC_Core.Shared.Config, REC_Core.Server.Config
local shCfg, svCfg = require "@REC_Core.config.sh_config", require "@REC_Core.config.sv_config"

---@type REC_Core.Server.Utils
local utils = require "@REC_Core.server.sv_utils"

---@type REC_Core.Shared.Groups
local shGroups = require "@REC_Core.shared.sh_groups"

---[[
---     Server side state
---     Who is loaded, and the flags the rest of the server reads.
---]]
---@class REC_Core.Server.Manager.ServerManager
local serverManager = {

    ---@type REC_Core.Server.Manager.ServerManager.Info
    info = {
        isActive = false,
        isDatabaseReady = false,
        characters = {},
        playerIdToCitizenId = {},
        loading = {},
        shouldRunThread = false,
    },
}

---[[
---     Check the config once, refuse to start on a config that cannot work
---]]
---@return boolean
function serverManager:init()
    local info = self.info

    info.characters = {}
    info.playerIdToCitizenId = {}
    info.loading = {}
    info.shouldRunThread = false

    -- accounts
    if type(shCfg.accounts) ~= "table" or next(shCfg.accounts) == nil then
        utils:log("^1config.accounts must have at least one account... please check config/sh_config.lua^0")
        return false
    end

    for name, account in pairs(shCfg.accounts) do

        if type(name) ~= "string" or name == "" then
            utils:log("^1config.accounts has a key that is not a string... please check config/sh_config.lua^0")
            return false
        end

        if type(account.label) ~= "string" or utils:normalizeBalance(account.default) == nil then
            utils:log(("^1config.accounts.%s needs a label and a whole number default... please check config/sh_config.lua^0"):format(name))
            return false
        end
    end

    -- groups
    local isValid, reason = shGroups:validate()
    if isValid == false then
        utils:log(("^1invalid job / gang config: %s... please check config/sh_jobs.lua and config/sh_gangs.lua^0"):format(tostring(reason)))
        return false
    end

    -- characters
    if math.type(shCfg.characters.maxSlots) ~= "integer" or shCfg.characters.maxSlots < 1 then
        utils:log("^1config.characters.maxSlots must be an integer >= 1... please check config/sh_config.lua^0")
        return false
    end

    -- spawn
    if type(shCfg.spawn.default) ~= "vector4" then
        utils:log("^1config.spawn.default must be a vector4... please check config/sh_config.lua^0")
        return false
    end

    -- autosave
    if svCfg.database.autoSave.enabled == true and svCfg.database.autoSave.interval <= 0 then
        utils:log("^1config.database.autoSave.interval must be greater than 0... please check config/sv_config.lua^0")
        return false
    end

    -- paycheck
    if svCfg.paycheck.enabled == true then

        if shCfg.accounts[svCfg.paycheck.account] == nil then
            utils:log(("^1config.paycheck.account %s is not in config.accounts... please check config/sv_config.lua^0"):format(tostring(svCfg.paycheck.account)))
            return false
        end

        if svCfg.paycheck.interval <= 0 then
            utils:log("^1config.paycheck.interval must be greater than 0... please check config/sv_config.lua^0")
            return false
        end
    end

    return true
end

---@param citizenId string
---@return REC_Core.Server.Class.Character|nil
function serverManager:getCharacter(citizenId)
    return self.info.characters[citizenId]
end

---@param playerId integer
---@return REC_Core.Server.Class.Character|nil
function serverManager:getCharacterByPlayerId(playerId)

    local citizenId = self.info.playerIdToCitizenId[tostring(playerId)]
    if citizenId == nil then
        return nil
    end

    return self:getCharacter(citizenId)
end

---@param character REC_Core.Server.Class.Character
---@return boolean
function serverManager:register(character)
    local info = self.info
    local characterInfo = character.info

    if info.characters[characterInfo.citizenId] ~= nil then
        utils:debugPrint(("^3character is already registered... citizenId: %s^0"):format(characterInfo.citizenId))
        return false
    end

    info.characters[characterInfo.citizenId] = character
    info.playerIdToCitizenId[tostring(characterInfo.playerId)] = characterInfo.citizenId

    return true
end

---@param citizenId string
---@return boolean
function serverManager:unregister(citizenId)
    local info = self.info

    local character = info.characters[citizenId]
    if character == nil then
        return false
    end

    info.characters[citizenId] = nil

    local playerKey = tostring(character.info.playerId)
    if info.playerIdToCitizenId[playerKey] == citizenId then
        info.playerIdToCitizenId[playerKey] = nil
    end

    return true
end

---[[
---     Snapshot of the loaded citizenIds, safe to iterate across yields
---]]
---@return string[]
function serverManager:getCitizenIds()

    ---@type string[]
    local citizenIds = {}

    for citizenId in pairs(self.info.characters) do
        citizenIds[#citizenIds+1] = citizenId
    end

    return citizenIds
end

---@param playerId integer
---@return boolean
function serverManager:isLoading(playerId)
    return self.info.loading[tostring(playerId)] == true
end

---@param playerId integer
---@param isLoading boolean
function serverManager:setLoading(playerId, isLoading)
    self.info.loading[tostring(playerId)] = isLoading == true and true or nil
end

return serverManager

---@class REC_Core.Server.Manager.ServerManager.Info
---@field isActive boolean
---@field isDatabaseReady boolean
---@field characters table<string, REC_Core.Server.Class.Character> citizenId -> character
---@field playerIdToCitizenId table<string, string>
---@field loading table<string, true> players in the middle of selectCharacter
---@field shouldRunThread boolean
