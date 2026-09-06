
---@type REC_Core.Shared.Functions
local functions = require "@REC_Core.shared.sh_functions"

---@type string
local prefix = GetCurrentResourceName()

---@class REC_Core.Shared.Events
local events = {

    client = {

        -- full character snapshot, sent to one player when their character loads
        syncPlayerData = "",

        -- one account balance changed
        updateMoney = "",

        -- the job changed (grade and duty included)
        updateJob = "",

        -- the gang changed
        updateGang = "",

        -- charinfo changed
        updateCharinfo = "",

        -- one metadata key changed
        updateMetadata = "",

        -- one value of the value store changed
        updateValue = "",

        -- drop the client side character (logout / resource stop)
        reset = "",

        -- show a notification
        notify = "",

        ---[[
        ---     Local events other client resources listen to (never sent over the network)
        ---]]
        onPlayerLoaded = "",
        onPlayerUnloaded = "",
        onMoneyChange = "",
        onJobUpdate = "",
        onGangUpdate = "",
        onCharinfoChange = "",
        onMetadataChange = "",
        onValueChange = "",
    },

    server = {

        ---[[
        ---     Server side events other resources listen to (never sent over the network)
        ---]]
        onPlayerLoaded = "",
        onPlayerUnloaded = "",
        onCharacterCreated = "",
        onCharacterDeleted = "",
        onMoneyChange = "",
        onOfflineMoneyChange = "",
        onJobUpdate = "",
        onGangUpdate = "",
        onDutyChange = "",
        onCharinfoChange = "",
        onMetadataChange = "",
        onValueChange = "",

        callbacks = {

            -- whether the core is active and whether the caller already has a character loaded
            getStatus = "",

            -- the caller's characters for the menu
            getCharacters = "",

            -- create a character in a free slot
            createCharacter = "",

            -- delete one of the caller's characters
            deleteCharacter = "",

            -- load one of the caller's characters
            selectCharacter = "",

            -- unload the current character and go back to the menu
            logout = "",
        },
    },
}

functions:generateEventsName(prefix, events)

return events
