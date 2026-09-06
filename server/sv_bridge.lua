
---[[
---     REC_Library lib boundary (server)
---     Every lib call the server side makes goes through here, so swapping the
---     library later touches this file only.
---]]

---@class REC_Core.Server.Bridge
local bridge = {}

---[[
---     Register a callback the client awaits
---]]
---@param name string
---@param handler fun(source: integer, ...: any): ...
function bridge:registerCallback(name, handler)
    lib.callback.register(name, handler)
end

---[[
---     Register a chat command
---]]
---@param name string
---@param properties REC_Core.Server.Bridge.CommandProperties
---@param handler fun(source: integer, args: table<string, any>, raw: string)
function bridge:addCommand(name, properties, handler)
    lib.addCommand(name, properties, handler)
end

return bridge

---@class REC_Core.Server.Bridge.CommandProperties
---@field help? string
---@field params? REC_Core.Server.Bridge.CommandParam[]
---@field restricted? boolean|string|string[]

---@class REC_Core.Server.Bridge.CommandParam
---@field name string
---@field type? "number" | "playerId" | "string" | "longString"
---@field help? string
---@field optional? boolean
