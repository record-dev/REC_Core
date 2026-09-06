
---@type REC_Core.Shared.Config, REC_Core.Server.Config
local shCfg, svCfg = require "@REC_Core.config.sh_config", require "@REC_Core.config.sv_config"

---@type REC_Core.Shared.Enum
local shEnums = require "@REC_Core.shared.sh_enum"
local groupTypes, genders, errors, unloadReasons = shEnums.groupTypes, shEnums.genders, shEnums.errors, shEnums.unloadReasons

---@type REC_Core.Shared.Functions
local functions = require "@REC_Core.shared.sh_functions"

---@type REC_Core.Shared.Events
local events = require "@REC_Core.shared.sh_event"

---@type REC_Core.Shared.Groups
local shGroups = require "@REC_Core.shared.sh_groups"

---@type REC_Core.Server.Utils
local utils = require "@REC_Core.server.sv_utils"

---@type REC_Core.Server.Handler
local handler = require "@REC_Core.handler.sv_handler"

---@type REC_Core.Server.Repository
local repository = require "@REC_Core.server.sv_repository"

---@type REC_Core.Server.Class.Character
local Character = require "@REC_Core.server.class.sv_character"

---@type REC_Core.Server.Manager.ServerManager
local serverManager = require "@REC_Core.server.manager.sv_serverManager"
local serverManagerInfo = serverManager.info

---[[
---     Character lifecycle
---     Create, select, load, unload, delete and save.
---]]
---@class REC_Core.Server.Modules.Players
local players = {}



---[[
---     Snapshot phase
---]]

---[[
---     What the client is allowed to see of the value store
---]]
---@param data table<string, table<string, any>>
---@return table<string, table<string, any>>
function players:filterData(data)

    ---@type table<string, table<string, any>>
    local filtered = {}

    for namespace, namespaceData in pairs(data) do

        if svCfg.sync.blockedNamespaces[namespace] == true then
            goto continue
        end

        filtered[namespace] = functions:deepCopy(namespaceData)

        ::continue::
    end

    return filtered
end

---@param character REC_Core.Server.Class.Character
---@return REC_Core.Client.Main.SyncPlayerData.Payload
function players:getClientPayload(character)

    ---@type REC_Core.Client.Main.SyncPlayerData.Payload
    return {
        character = character:toClientSnapshot(),
        data = self:filterData(character.info.data),
    }
end

---[[
---     Record straight from the DB -> the snapshot other resources read
---]]
---@param record REC_Core.Server.Repository.CharacterRecord
---@return REC_Core.Server.Character
function players:recordToSnapshot(record)

    ---@type REC_Core.Server.Character
    return {
        playerId = serverManager:getCharacter(record.citizenId)?.info.playerId,
        license = record.license,
        citizenId = record.citizenId,
        slot = record.slot,
        charinfo = functions:deepCopy(record.charinfo),
        job = shGroups:resolveStored(groupTypes.job, record.job),
        gang = shGroups:resolveStored(groupTypes.gang, record.gang),
        money = self:fillMoney(record.money),
        metadata = functions:deepCopy(record.metadata),
        position = functions:deepCopy(record.position),
        lastLoggedOutAt = record.lastLoggedOutAt,
    }
end

---[[
---     Every configured account has a balance, an account added later starts at 0
---]]
---@param stored table<string, any>|nil
---@return table<string, integer>
function players:fillMoney(stored)

    ---@type table<string, integer>
    local money = {}

    for account in pairs(shCfg.accounts) do
        money[account] = 0
    end

    if type(stored) == "table" then
        for account, balance in pairs(stored) do
            local normalized = utils:normalizeBalance(balance)
            if normalized ~= nil then
                money[account] = normalized
            end
        end
    end

    return money
end

---[[
---     Where the character spawns
---]]
---@param playerId integer
---@param character REC_Core.Server.Class.Character
---@return vector4
function players:getSpawn(playerId, character)

    local override = functions:toVector4(handler:getSpawnPosition(playerId, character:snapshot()))
    if override ~= nil then
        return override
    end

    if shCfg.spawn.useLastPosition == true then
        local last = functions:toVector4(character.info.position)
        if last ~= nil then
            return last
        end
    end

    return shCfg.spawn.default
end



---[[
---     Callback phase
---]]

---[[
---     Whether the core is active, and the character when one is already loaded
---]]
---@param playerId integer
---@return REC_Core.Server.Callbacks.GetStatus.Return
function players:getStatus(playerId)

    ---@type REC_Core.Server.Callbacks.GetStatus.Return
    local status = {
        active = serverManagerInfo.isActive,
        databaseReady = serverManagerInfo.isDatabaseReady,
    }

    if serverManagerInfo.isActive == false then
        return status
    end

    local character = serverManager:getCharacterByPlayerId(playerId)
    if character ~= nil then
        local payload = self:getClientPayload(character)
        status.character = payload.character
        status.data = payload.data
    end

    return status
end

---[[
---     Refuses the callbacks that need the DB
---]]
---@return REC_Core.Shared.Enum.Errors|nil
local function getUnavailableReason()

    if serverManagerInfo.isActive == false then
        return errors.notActive
    end

    if serverManagerInfo.isDatabaseReady == false then
        return errors.databaseNotReady
    end

    return nil
end

---[[
---     The caller's characters, for the menu
---]]
---@param playerId integer
---@return REC_Core.Server.Callbacks.GetCharacters.Return
function players:getCharacters(playerId)

    local unavailable = getUnavailableReason()
    if unavailable ~= nil then
        return { ok = false, error = unavailable, }
    end

    local license = utils:getIdentifier(playerId)
    if license == nil then
        return { ok = false, error = errors.generic, }
    end

    local records = repository:getCharactersByLicense(license)
    if records == nil then
        return { ok = false, error = errors.generic, }
    end

    ---@type REC_Core.Server.Callbacks.GetCharacters.Character[]
    local characters = {}

    for _, record in ipairs(records) do
        characters[#characters+1] = {
            citizenId = record.citizenId,
            slot = record.slot,
            charinfo = record.charinfo,
            job = shGroups:resolveStored(groupTypes.job, record.job),
            gang = shGroups:resolveStored(groupTypes.gang, record.gang),
            lastLoggedOutAt = record.lastLoggedOutAt,
        }
    end

    return {
        ok = true,
        characters = characters,
        maxSlots = shCfg.characters.maxSlots,
        allowDelete = shCfg.characters.allowDelete,
    }
end

---[[
---     Turn what the menu sent into a charinfo, nil when anything is off
---]]
---@param input any
---@return REC_Core.Shared.Character.Charinfo|nil
local function validateCreateInput(input)

    if type(input) ~= "table" then
        return nil
    end

    local nameCfg = shCfg.characters.name

    local firstname = functions:trim(input.firstname)
    if functions:isValidName(firstname, nameCfg.minLength, nameCfg.maxLength) == false then
        return nil
    end

    local lastname = functions:trim(input.lastname)
    if functions:isValidName(lastname, nameCfg.minLength, nameCfg.maxLength) == false then
        return nil
    end

    if functions:isValidBirthdate(input.birthdate) == false then
        return nil
    end

    if input.gender ~= genders.male and input.gender ~= genders.female then
        return nil
    end

    local nationality = functions:trim(input.nationality)
    if nationality == nil or nationality == "" then
        nationality = shCfg.characters.defaultNationality
    end

    if utf8.len(nationality) == nil or utf8.len(nationality) > 50 then
        return nil
    end

    ---@type REC_Core.Shared.Character.Charinfo
    return {
        firstname = firstname --[[@as string]],
        lastname = lastname --[[@as string]],
        birthdate = input.birthdate,
        gender = input.gender,
        nationality = nationality,
    }
end

---[[
---     Create a character in the caller's lowest free slot
---]]
---@param playerId integer
---@param input any what the menu sent
---@return REC_Core.Server.Callbacks.CreateCharacter.Return
function players:createCharacter(playerId, input)

    local unavailable = getUnavailableReason()
    if unavailable ~= nil then
        return { ok = false, error = unavailable, }
    end

    if serverManager:getCharacterByPlayerId(playerId) ~= nil then
        return { ok = false, error = errors.alreadyLoaded, }
    end

    if serverManager:isLoading(playerId) == true then
        return { ok = false, error = errors.busy, }
    end

    local charinfo = validateCreateInput(input)
    if charinfo == nil then
        return { ok = false, error = errors.invalidInput, }
    end

    local license = utils:getIdentifier(playerId)
    if license == nil then
        return { ok = false, error = errors.generic, }
    end

    serverManager:setLoading(playerId, true)

    local result = (function ()

        local records = repository:getCharactersByLicense(license)
        if records == nil then
            return { ok = false, error = errors.generic, }
        end

        if #records >= shCfg.characters.maxSlots then
            return { ok = false, error = errors.slotsFull, }
        end

        -- lowest free slot
        ---@type table<integer, true>
        local usedSlots = {}
        for _, record in ipairs(records) do
            usedSlots[record.slot] = true
        end

        ---@type integer|nil
        local slot = nil
        for candidate = 1, shCfg.characters.maxSlots do
            if usedSlots[candidate] == nil then
                slot = candidate
                break
            end
        end

        if slot == nil then
            return { ok = false, error = errors.slotsFull, }
        end

        -- unique citizenId
        ---@type string|nil
        local citizenId = nil
        for _ = 1, 20 do

            local candidate = utils:generateCitizenId()

            local exists = repository:doesCitizenIdExist(candidate)
            if exists == nil then
                return { ok = false, error = errors.generic, }
            end

            if exists == false then
                citizenId = candidate
                break
            end
        end

        if citizenId == nil then
            utils:log("^1could not find a free citizenId, raise config.characters.citizenId.digits^0")
            return { ok = false, error = errors.generic, }
        end

        -- starting balances
        ---@type table<string, integer>
        local money = {}
        for account, accountCfg in pairs(shCfg.accounts) do
            money[account] = utils:normalizeBalance(accountCfg.default) or 0
        end

        ---@type REC_Core.Server.Repository.CharacterRecord
        local record = {
            citizenId = citizenId,
            license = license,
            slot = slot,
            charinfo = charinfo,
            job = shGroups:toStored(shGroups:resolveStored(groupTypes.job, nil)),
            gang = shGroups:toStored(shGroups:resolveStored(groupTypes.gang, nil)),
            money = money,
            metadata = functions:deepCopy(shCfg.characters.defaultMetadata),
            position = nil,
        }

        if repository:insertCharacter(record) == false then
            return { ok = false, error = errors.generic, }
        end

        local snapshot = self:recordToSnapshot(record)
        snapshot.playerId = playerId

        -- extension point
        handler:onCharacterCreated(playerId, snapshot)

        ---@type REC_Core.Server.Main.CharacterCreated.Payload
        local payload = {
            citizenId = citizenId,
            character = snapshot,
        }

        TriggerEvent(events.server.onCharacterCreated, playerId, payload)

        utils:debugPrint(("^2successful to create character... playerId: %d, citizenId: %s^0"):format(playerId, citizenId))

        return { ok = true, citizenId = citizenId, }
    end)()

    serverManager:setLoading(playerId, false)

    return result
end

---[[
---     Delete one of the caller's characters
---     Only an unloaded character can go, the menu is the only place that asks.
---]]
---@param playerId integer
---@param citizenId any
---@return REC_Core.Server.Callbacks.DeleteCharacter.Return
function players:deleteCharacter(playerId, citizenId)

    local unavailable = getUnavailableReason()
    if unavailable ~= nil then
        return { ok = false, error = unavailable, }
    end

    if shCfg.characters.allowDelete == false then
        return { ok = false, error = errors.notAllowed, }
    end

    if utils:isValidString(citizenId) == false then
        return { ok = false, error = errors.invalidInput, }
    end

    if serverManager:getCharacter(citizenId) ~= nil then
        return { ok = false, error = errors.notAllowed, }
    end

    local license = utils:getIdentifier(playerId)
    if license == nil then
        return { ok = false, error = errors.generic, }
    end

    local record = repository:getCharacter(citizenId)
    if record == nil then
        return { ok = false, error = errors.notFound, }
    end

    if record.license ~= license then
        utils:debugPrint(("^3player tried to delete a character that is not theirs... playerId: %d, citizenId: %s^0"):format(playerId, citizenId))
        return { ok = false, error = errors.notAllowed, }
    end

    if self:deleteOffline(citizenId, playerId) == false then
        return { ok = false, error = errors.generic, }
    end

    return { ok = true, }
end

---[[
---     Load one of the caller's characters
---]]
---@param playerId integer
---@param citizenId any
---@return REC_Core.Server.Callbacks.SelectCharacter.Return
function players:selectCharacter(playerId, citizenId)

    local unavailable = getUnavailableReason()
    if unavailable ~= nil then
        return { ok = false, error = unavailable, }
    end

    if utils:isValidString(citizenId) == false then
        return { ok = false, error = errors.invalidInput, }
    end

    if serverManager:isLoading(playerId) == true then
        return { ok = false, error = errors.busy, }
    end

    -- the same character again just gets its payload back
    local current = serverManager:getCharacterByPlayerId(playerId)
    if current ~= nil and current.info.citizenId == citizenId then

        local payload = self:getClientPayload(current)
        return { ok = true, character = payload.character, data = payload.data, spawn = self:getSpawn(playerId, current), }
    end

    -- someone else has it
    if serverManager:getCharacter(citizenId) ~= nil then
        return { ok = false, error = errors.alreadyLoaded, }
    end

    serverManager:setLoading(playerId, true)

    -- switching characters, the old one is saved and disposed first
    if current ~= nil then
        self:unload(playerId, unloadReasons.switch)
    end

    local character, failure = self:load(playerId, citizenId)

    serverManager:setLoading(playerId, false)

    if character == nil then
        return { ok = false, error = failure or errors.generic, }
    end

    local payload = self:getClientPayload(character)

    return {
        ok = true,
        character = payload.character,
        data = payload.data,
        spawn = self:getSpawn(playerId, character),
    }
end



---[[
---     Load phase
---]]

---[[
---     Read a character from the DB and register it
---]]
---@param playerId integer
---@param citizenId string
---@return REC_Core.Server.Class.Character|nil
---@return REC_Core.Shared.Enum.Errors|nil
function players:load(playerId, citizenId)

    local license = utils:getIdentifier(playerId)
    if license == nil then
        return nil, errors.generic
    end

    local record = repository:getCharacter(citizenId)
    if record == nil then
        return nil, errors.notFound
    end

    if record.license ~= license then
        utils:debugPrint(("^3player tried to load a character that is not theirs... playerId: %d, citizenId: %s^0"):format(playerId, citizenId))
        return nil, errors.notAllowed
    end

    -- a failed read must not look like an empty store, the next save would wipe it
    local data = repository:getData(citizenId)
    if data == nil then
        return nil, errors.generic
    end

    -- the player may have dropped while the DB was answering
    if utils:isConnected(playerId) == false then
        utils:debugPrint(("^3player dropped while loading... playerId: %d^0"):format(playerId))
        return nil, errors.generic
    end

    -- the same character may have been taken while awaiting
    if serverManager:getCharacter(citizenId) ~= nil then
        return nil, errors.alreadyLoaded
    end

    local character = Character:new({
        playerId = playerId,
        license = license,
        citizenId = citizenId,
        slot = record.slot,
        charinfo = record.charinfo,
        job = shGroups:resolveStored(groupTypes.job, record.job),
        gang = shGroups:resolveStored(groupTypes.gang, record.gang),
        money = self:fillMoney(record.money),
        metadata = record.metadata,
        position = record.position,
        data = data,
    })

    if serverManager:register(character) == false then
        return nil, errors.alreadyLoaded
    end

    Player(playerId).state:set("citizenId", citizenId, true)

    local snapshot = character:snapshot()

    -- extension point
    handler:onPlayerLoaded(playerId, snapshot)

    ---@type REC_Core.Server.Main.PlayerLoaded.Payload
    local payload = {
        citizenId = citizenId,
        character = snapshot,
    }

    TriggerEvent(events.server.onPlayerLoaded, playerId, payload)

    utils:debugPrint(("^2successful to load character... playerId: %d, citizenId: %s^0"):format(playerId, citizenId))

    return character
end

---[[
---     Save and dispose the character of a player
---]]
---@param playerId integer
---@param reason REC_Core.Shared.Enum.UnloadReasons
---@return boolean
function players:unload(playerId, reason)

    local character = serverManager:getCharacterByPlayerId(playerId)
    if character == nil then
        return false
    end

    local citizenId = character.info.citizenId

    -- extension point, before the save so its writes reach the DB
    handler:onPlayerUnloaded(playerId, citizenId, reason)

    if self:save(citizenId, { lastLoggedOut = true, }) == false then
        utils:log(("^1failed to save character before unload... citizenId: %s^0"):format(citizenId))
    end

    -- the same citizenId may have come back on another connection while saving
    local current = serverManager:getCharacter(citizenId)
    if current ~= nil and current.info.playerId ~= playerId then
        utils:debugPrint(("^3character was reloaded while saving... citizenId: %s^0"):format(citizenId))
        return true
    end

    ---@type REC_Core.Server.Main.PlayerUnloaded.Payload
    local payload = {
        citizenId = citizenId,
        reason = reason,
    }

    TriggerEvent(events.server.onPlayerUnloaded, playerId, payload)

    serverManager:unregister(citizenId)

    if utils:isConnected(playerId) == true then
        Player(playerId).state:set("citizenId", nil, true)
    end

    if reason == unloadReasons.logout then

        ---@type REC_Core.Client.Main.Reset.Payload
        local resetPayload = {
            reason = reason,
        }

        TriggerClientEvent(events.client.reset, playerId, resetPayload)
    end

    utils:debugPrint(("^2successful to unload character... playerId: %d, citizenId: %s, reason: %s^0"):format(playerId, citizenId, reason))

    return true
end

---[[
---     Back to the character menu
---]]
---@param playerId integer
---@return boolean
function players:logout(playerId)
    return self:unload(playerId, unloadReasons.logout)
end



---[[
---     Save phase
---]]

---[[
---     Value of a character column the way the DB stores it
---]]
---@param character REC_Core.Server.Class.Character
---@param column string
---@return any
local function columnValue(character, column)
    local info = character.info

    if column == "job" then
        return shGroups:toStored(info.job)
    end

    if column == "gang" then
        return shGroups:toStored(info.gang)
    end

    return info[column]
end

---[[
---     Queries for everything unsaved, plus the live position
---]]
---@param character REC_Core.Server.Class.Character
---@param options? REC_Core.Server.Modules.Players.SaveOptions
---@return REC_Core.Server.Repository.Query[] queries
---@return REC_Core.Server.Class.Character.Dirty targets marks the queries cover
local function buildSaveQueries(character, options)
    local info = character.info

    local targets = character:takeTargets()

    ---@type table<string, any>
    local columns = {}

    for column in pairs(targets.columns) do
        columns[column] = columnValue(character, column)
    end

    -- the live ped is the truth about where the character is
    local position = utils:getPlayerPosition(info.playerId)
    if position ~= nil then
        character:setPosition(position)
        columns.position = position
    end

    if options ~= nil and options.lastLoggedOut == true then
        columns.lastLoggedOutAt = utils:now()
    end

    ---@type REC_Core.Server.Repository.Query[]
    local queries = {}

    if next(columns) ~= nil then
        queries[#queries+1] = repository:buildCharacterQuery(info.citizenId, columns)
    end

    for namespace, dataKeys in pairs(targets.data) do
        for dataKey in pairs(dataKeys) do
            queries[#queries+1] = repository:buildDataQuery(info.citizenId, namespace, dataKey, character:getValue(namespace, dataKey))
        end
    end

    return queries, targets
end

---[[
---     Write the unsaved changes of one character
---]]
---@param citizenId string
---@param options? REC_Core.Server.Modules.Players.SaveOptions
---@return boolean
function players:save(citizenId, options)

    local character = serverManager:getCharacter(citizenId)
    if character == nil then
        utils:debugPrint(("^3character is not loaded... citizenId: %s^0"):format(citizenId))
        return false
    end

    local queries, targets = buildSaveQueries(character, options)

    if #queries == 0 then
        return true
    end

    if repository:transaction(queries) == false then
        utils:log(("^1failed to save character... citizenId: %s^0"):format(citizenId))
        return false
    end

    character:clearTargets(targets)

    utils:debugPrint(("^2successful to save character... citizenId: %s, queries: %d^0"):format(citizenId, #queries))

    return true
end

---[[
---     Write right away when autosave is off
---]]
---@param citizenId string
function players:saveIfImmediate(citizenId)

    if svCfg.database.autoSave.enabled == true then
        return
    end

    self:save(citizenId)
end

---[[
---     Write every loaded character
---]]
---@return integer number of characters whose save failed
function players:saveAll()

    ---@type integer
    local failedCount = 0

    for _, citizenId in ipairs(serverManager:getCitizenIds()) do

        -- the player may have left while waiting
        if serverManager:getCharacter(citizenId) == nil then
            goto continue
        end

        if self:save(citizenId) == false then
            failedCount += 1
        end

        ::continue::
    end

    return failedCount
end

---[[
---     Fire off every unsaved change on resource stop, without waiting
---]]
---@return integer number of queries fired
function players:flushOnStop()

    ---@type integer
    local queryCount = 0

    for _, character in pairs(serverManagerInfo.characters) do

        local queries = buildSaveQueries(character, { lastLoggedOut = true, })

        -- per character so one failure does not roll everyone back
        repository:fireTransaction(queries)

        queryCount += #queries
    end

    return queryCount
end



---[[
---     Offline phase
---]]

---[[
---     A character straight from the DB, loaded or not
---]]
---@param citizenId string
---@return REC_Core.Server.Character|nil
function players:getOfflineCharacter(citizenId)

    local record = repository:getCharacter(citizenId)
    if record == nil then
        return nil
    end

    return self:recordToSnapshot(record)
end

---[[
---     Every character of one license
---]]
---@param license string
---@return REC_Core.Server.Character[]|nil
function players:getCharactersByLicense(license)

    local records = repository:getCharactersByLicense(license)
    if records == nil then
        return nil
    end

    ---@type REC_Core.Server.Character[]
    local characters = {}

    for _, record in ipairs(records) do
        characters[#characters+1] = self:recordToSnapshot(record)
    end

    return characters
end

---[[
---     Delete a character that is not loaded
---]]
---@param citizenId string
---@param playerId? integer who asked, 0 when nobody in particular
---@return boolean
function players:deleteOffline(citizenId, playerId)
    playerId = playerId or 0

    if serverManager:getCharacter(citizenId) ~= nil then
        utils:debugPrint(("^3character is loaded, unload it first... citizenId: %s^0"):format(citizenId))
        return false
    end

    if repository:deleteCharacter(citizenId) == false then
        return false
    end

    -- extension point
    handler:onCharacterDeleted(playerId, citizenId)

    ---@type REC_Core.Server.Main.CharacterDeleted.Payload
    local payload = {
        citizenId = citizenId,
    }

    TriggerEvent(events.server.onCharacterDeleted, playerId, payload)

    return true
end

return players

---@class REC_Core.Server.Modules.Players.SaveOptions
---@field lastLoggedOut? boolean stamp lastLoggedOutAt as well
