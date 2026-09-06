
---[[
---     REC_Core server config
---     What each setting does, and why the defaults are what they are:
---     https://docs.re-cord.dev/en/common-dependencies/rec_core
---]]

---@class REC_Core.Server.Config
local config = {}

---[[
---    Debug mode
---]]
---@type boolean
config.debugMode = true

---[[
---     Another framework on the same server
---     Two cores fighting over the character menu breaks both, so REC_Core stays
---     dormant when one of these resources is running. Set allowOtherFramework to
---     true only while testing REC_Core next to another core.
---]]
config.framework = {

    ---@type boolean
    allowOtherFramework = false,

    ---@type string[]
    others = {
        "qbx_core",
        "qb-core",
        "es_extended",
        "ox_core",
    },
}

---[[
---     Identifier a character is tied to
---     The first type that the player has is used, in this order.
---]]
---@type string[]
config.identifiers = {
    "license2",
    "license",
}

---[[
---     Database
---     The tables come from rec_core.sql and are only checked for at start.
---]]
config.database = {

    ---[[
    ---     Autosave
    ---     Writes only what changed, batched every interval. With false a change is
    ---     written the moment it happens, which costs a round trip per change.
    ---]]
    autoSave = {

        ---@type boolean
        enabled = true,

        ---@type integer
        interval = 5, -- minute
    },
}

---[[
---     Client sync
---     Only the player's own character is synced, other players' data is never sent.
---]]
config.sync = {

    ---[[
    ---     Namespaces of the value store that are never sent to the client
    ---     List the resources holding values a cheater must not read.
    ---]]
    ---@type table<string, true>
    blockedNamespaces = {

        -- ["REC_Economy"] = true,
    },
}

---[[
---     Money
---]]
config.money = {

    ---[[
    ---     Tell the player about every change to their balance
    ---]]
    ---@type boolean
    notify = true,
}

---[[
---     Paycheck
---     Pays the payment of the character's job grade into the account below.
---]]
config.paycheck = {

    ---@type boolean
    enabled = true,

    ---@type integer
    interval = 30, -- minute

    ---@type string
    account = "bank",

    ---@type boolean
    onDutyOnly = false,

    ---@type string
    reason = "paycheck",
}

---[[
---     Commands
---     restricted is the ACE the admin commands need, e.g. add_ace group.admin group.admin allow
---]]
config.commands = {

    ---@type boolean
    enabled = true,

    ---@type string
    restricted = "group.admin",

    player = {

        ---@type boolean
        logout = true,

        ---@type boolean
        duty = true,
    },
}

return config
