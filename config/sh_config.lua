
---[[
---     REC_Core shared config
---     What each setting does, and why the defaults are what they are:
---     https://docs.re-cord.dev/en/common-dependencies/rec_core
---]]

---@class REC_Core.Shared.Config
local config = {}

---[[
---    Debug mode
---]]
---@type boolean
config.debugMode = true

---[[
---     Language of everything a player reads
---     'en' or 'ja' or 'custom' (locales/custom.lua is yours to fill in)
---]]
---@type "en" | "ja" | "custom"
config.language = "ja"

---[[
---     Money accounts
---     The key is the account name other resources pass to addMoney / removeMoney.
---     default is the balance a new character starts with, allowNegative lets
---     removeMoney overdraw the account.
---]]
---@type table<string, REC_Core.Config.Account>
config.accounts = {

    ["cash"] = {
        label = "Cash",
        default = 500,
        allowNegative = false,
    },

    ["bank"] = {
        label = "Bank",
        default = 5000,
        allowNegative = false,
    },

    ["crypto"] = {
        label = "Crypto",
        default = 0,
        allowNegative = false,
    },

    -- ["black_money"] = {
    --     label = "Dirty money",
    --     default = 0,
    --     allowNegative = false,
    -- },
}

---[[
---     Characters
---]]
config.characters = {

    ---@type integer
    maxSlots = 5,

    ---@type boolean
    allowDelete = true,

    ---[[
    ---     Length limits of the first and last name, counted in characters
    ---]]
    name = {

        ---@type integer
        minLength = 2,

        ---@type integer
        maxLength = 20,
    },

    ---@type string
    defaultNationality = "Japan",

    ---[[
    ---     Metadata every new character starts with
    ---]]
    ---@type table<string, any>
    defaultMetadata = {},

    ---[[
    ---     Shape of a citizenId, e.g. ABC12345
    ---]]
    citizenId = {

        ---@type integer
        letters = 3,

        ---@type integer
        digits = 5,
    },
}

---[[
---     Groups
---     The job and gang a new character starts with, and the fallback when a stored
---     one is no longer in config/sh_jobs.lua or config/sh_gangs.lua.
---]]
config.groups = {

    ---@type string
    defaultJob = "unemployed",

    ---@type string
    defaultGang = "none",
}

---[[
---     Spawn
---]]
config.spawn = {

    ---[[
    ---     Where a character spawns when it has no saved position
    ---]]
    ---@type vector4
    default = vector4(-1037.75, -2737.97, 20.17, 328.0),

    ---@type boolean
    useLastPosition = true,

    ---[[
    ---     Swap the ped to the freemode model of the character's gender before spawning
    ---     Turn it off when an appearance resource sets the model itself.
    ---]]
    ---@type boolean
    applyDefaultModel = true,

    ---@type table<REC_Core.Shared.Enum.Genders, string>
    models = {
        male = "mp_m_freemode_01",
        female = "mp_f_freemode_01",
    },

    ---@type integer
    fadeDuration = 800, -- millisecond
}

---[[
---     Character menu
---     The player is parked invisible at pedCoords so the world streams in around the camera.
---]]
config.characterMenu = {

    ---@type vector4
    pedCoords = vector4(969.25, 72.61, 116.18, 280.5),

    camera = {

        ---@type boolean
        enabled = true,

        ---@type vector3
        coords = vector3(978.6, 76.55, 118.27),

        ---@type vector3
        rotation = vector3(-5.0, 0.0, 91.27),

        ---@type number
        fov = 50.0,
    },
}

return config
