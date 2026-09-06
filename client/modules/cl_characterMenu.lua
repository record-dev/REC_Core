
---@type REC_Core.Shared.Config
local shCfg = require "@REC_Core.config.sh_config"
local nameCfg = shCfg.characters.name

---@type REC_Core.Shared.Enum
local shEnums = require "@REC_Core.shared.sh_enum"
local genders, errors = shEnums.genders, shEnums.errors

---@type REC_Core.Shared.Functions
local functions = require "@REC_Core.shared.sh_functions"

---@type REC_Core.Shared.Events
local events = require "@REC_Core.shared.sh_event"
local callbacks = events.server.callbacks

---@type REC_Core.Locales
local locales = require ("@REC_Core.locales.".. shCfg.language)

---@type REC_Core.Client.Bridge
local bridge = require "@REC_Core.client.cl_bridge"

---@type REC_Core.Client.Utils
local utils = require "@REC_Core.client.cl_utils"

---@type table<string, string>
local menuIds = {
    main = GetCurrentResourceName() .. ":characters",
    character = GetCurrentResourceName() .. ":character",
}

---[[
---     The character menu
---     Runs until a character is loaded on the server, nothing here spawns the ped.
---]]
---@class REC_Core.Client.Modules.CharacterMenu
local characterMenu = {

    ---@type REC_Core.Client.Modules.CharacterMenu.Info
    info = {
        selection = nil,
        isRunning = false,
    },
}

---@param character REC_Core.Server.Callbacks.GetCharacters.Character
---@return string
local function characterTitle(character)
    return ("%s %s"):format(character.charinfo.firstname, character.charinfo.lastname)
end

---[[
---     Menu callbacks run on the NUI thread, so the work that yields gets its own
---]]
---@param fn fun()
---@return fun()
local function async(fn)
    return function ()
        CreateThread(fn)
    end
end



---[[
---     Server phase
---]]

---[[
---     The list, retried until the server answers
---]]
---@return REC_Core.Server.Callbacks.GetCharacters.Return
function characterMenu:fetch()

    while true do

        local result = bridge:callback(callbacks.getCharacters)
        if type(result) == "table" and result.ok == true then
            return result
        end

        utils:notifyError(type(result) == "table" and result.error or nil)

        Wait(5000)
    end
end

---[[
---     Load a character, the menu ends when this succeeds
---]]
---@param citizenId string
function characterMenu:select(citizenId)

    local result = bridge:callback(callbacks.selectCharacter, citizenId)
    if type(result) ~= "table" or result.ok ~= true then
        utils:notifyError(type(result) == "table" and result.error or nil)
        self:show()
        return
    end

    self.info.selection = result
end

---[[
---     Ask for the details and create
---]]
function characterMenu:create()

    bridge:hideMenu()

    local input = bridge:inputDialog(locales.create.title, {
        {
            type = "input",
            label = locales.create.firstName,
            required = true,
            min = nameCfg.minLength,
            max = nameCfg.maxLength,
        },
        {
            type = "input",
            label = locales.create.lastName,
            required = true,
            min = nameCfg.minLength,
            max = nameCfg.maxLength,
        },
        {
            type = "date",
            label = locales.create.birthdate,
            required = true,
            format = "YYYY-MM-DD",
            returnString = true,
        },
        {
            type = "select",
            label = locales.create.gender,
            required = true,
            default = genders.male,
            options = {
                { value = genders.male, label = locales.create.gender_male, },
                { value = genders.female, label = locales.create.gender_female, },
            },
        },
        {
            type = "input",
            label = locales.create.nationality,
            default = shCfg.characters.defaultNationality,
            max = 50,
        },
    }, { allowCancel = true, })

    if input == nil then
        self:show()
        return
    end

    ---@type REC_Core.Server.Callbacks.CreateCharacter.Input
    local payload = {
        firstname = functions:trim(input[1]) or "",
        lastname = functions:trim(input[2]) or "",
        birthdate = input[3],
        gender = input[4],
        nationality = functions:trim(input[5]),
    }

    -- the same checks the server makes, to spare the round trip
    if functions:isValidName(payload.firstname, nameCfg.minLength, nameCfg.maxLength) == false
        or functions:isValidName(payload.lastname, nameCfg.minLength, nameCfg.maxLength) == false
        or functions:isValidBirthdate(payload.birthdate) == false
    then
        utils:notifyError(errors.invalidInput)
        self:show()
        return
    end

    local result = bridge:callback(callbacks.createCharacter, payload)
    if type(result) ~= "table" or result.ok ~= true then
        utils:notifyError(type(result) == "table" and result.error or nil)
        self:show()
        return
    end

    utils:notify("success", locales.notify.title, (locales.notify.characterCreated):format(payload.firstname, payload.lastname))

    self:select(result.citizenId)
end

---[[
---     Confirm and delete
---]]
---@param character REC_Core.Server.Callbacks.GetCharacters.Character
function characterMenu:delete(character)

    bridge:hideMenu()

    local answer = bridge:alertDialog({
        header = locales.delete.header,
        content = (locales.delete.content):format(character.charinfo.firstname, character.charinfo.lastname),
        centered = true,
        cancel = true,
        labels = {
            confirm = locales.delete.confirm,
            cancel = locales.delete.cancel,
        },
    })

    if answer ~= "confirm" then
        self:show()
        return
    end

    local result = bridge:callback(callbacks.deleteCharacter, character.citizenId)
    if type(result) ~= "table" or result.ok ~= true then
        utils:notifyError(type(result) == "table" and result.error or nil)
    else
        utils:notify("success", locales.notify.title, locales.notify.characterDeleted)
    end

    self:show()
end



---[[
---     Menu phase
---]]

---[[
---     Play / delete for one character
---]]
---@param character REC_Core.Server.Callbacks.GetCharacters.Character
---@param allowDelete boolean
function characterMenu:showCharacter(character, allowDelete)

    ---@type REC_Core.Client.Bridge.MenuOption[]
    local options = {
        {
            title = locales.menu.play,
            description = locales.menu.play_description,
            icon = "play",
            onSelect = async(function ()
                self:select(character.citizenId)
            end),
        },
    }

    if allowDelete == true then
        options[#options+1] = {
            title = locales.menu.delete,
            description = locales.menu.delete_description,
            icon = "trash",
            onSelect = async(function ()
                self:delete(character)
            end),
        }
    end

    options[#options+1] = {
        title = locales.menu.back,
        icon = "arrow-left",
        onSelect = async(function ()
            self:show()
        end),
    }

    bridge:showMenu({
        id = menuIds.character,
        title = characterTitle(character),
        canClose = false,
        options = options,
    })
end

---[[
---     The list of characters
---]]
function characterMenu:show()

    local result = self:fetch()

    ---@type REC_Core.Client.Bridge.MenuOption[]
    local options = {}

    for _, character in ipairs(result.characters) do
        options[#options+1] = {
            title = characterTitle(character),
            description = (locales.menu.character_description):format(character.job.label, utils:formatTimestamp(character.lastLoggedOutAt)),
            icon = "user",
            arrow = true,
            onSelect = async(function ()
                self:showCharacter(character, result.allowDelete)
            end),
        }
    end

    if #result.characters < result.maxSlots then
        options[#options+1] = {
            title = locales.menu.newCharacter,
            description = (locales.menu.newCharacter_description):format(#result.characters, result.maxSlots),
            icon = "plus",
            onSelect = async(function ()
                self:create()
            end),
        }
    end

    bridge:showMenu({
        id = menuIds.main,
        title = locales.menu.title,
        canClose = false,
        options = options,
    })
end

---[[
---     Block until a character is loaded on the server
---]]
---@return REC_Core.Server.Callbacks.SelectCharacter.Return
function characterMenu:run()
    local info = self.info

    info.selection = nil
    info.isRunning = true

    self:show()

    while info.selection == nil do
        Wait(100)
    end

    info.isRunning = false

    bridge:hideMenu()

    return info.selection --[[@as REC_Core.Server.Callbacks.SelectCharacter.Return]]
end

return characterMenu

---@class REC_Core.Client.Modules.CharacterMenu.Info
---@field selection REC_Core.Server.Callbacks.SelectCharacter.Return|nil
---@field isRunning boolean
