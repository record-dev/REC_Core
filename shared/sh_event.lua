
---@type REC_Library.Shared.API
local shApi = require "@REC_Library.shared.sh_api"

---@type string
local prefix = GetCurrentResourceName()

---@class REC_Core.Shared.Events
local events = {

    client = {


    },

    server = {

        

        callbacks = {

            
        },
    },
}

shApi.Functions:generateEventsName(prefix, events)

return events