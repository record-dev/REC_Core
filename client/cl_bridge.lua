
---[[
---     REC_Library lib boundary (client)
---     Every lib call the client side makes goes through here, so swapping the
---     library later touches this file only.
---]]

---@class REC_Core.Client.Bridge
local bridge = {}

---@type table<string, string>
local notifyTypes = {
    info = "inform",
    success = "success",
    warning = "warning",
    error = "error",
}

---[[
---     Ask the server and wait for the answer
---]]
---@param name string
---@param ... any
---@return any ...
function bridge:callback(name, ...)
    return lib.callback.await(name, false, ...)
end

---[[
---     Show a context menu
---]]
---@param menu REC_Core.Client.Bridge.Menu
function bridge:showMenu(menu)
    lib.registerContext(menu)
    lib.showContext(menu.id)
end

function bridge:hideMenu()
    lib.hideContext()
end

---[[
---     Form dialog, nil when cancelled
---]]
---@param heading string
---@param rows REC_Core.Client.Bridge.InputRow[]
---@param options? { allowCancel?: boolean }
---@return any[]|nil
function bridge:inputDialog(heading, rows, options)
    return lib.inputDialog(heading, rows, options)
end

---[[
---     Confirm dialog
---]]
---@param options REC_Core.Client.Bridge.AlertOptions
---@return "confirm" | "cancel"
function bridge:alertDialog(options)
    return lib.alertDialog(options)
end

---@param payload REC_Core.Client.Main.Notify.Payload
function bridge:notify(payload)
    lib.notify({
        title = payload.title,
        description = payload.description,
        type = notifyTypes[payload.type] or notifyTypes.info,
        duration = payload.duration,
    })
end

return bridge

---@class REC_Core.Client.Bridge.Menu
---@field id string
---@field title string
---@field canClose? boolean
---@field options REC_Core.Client.Bridge.MenuOption[]

---@class REC_Core.Client.Bridge.MenuOption
---@field title string
---@field description? string
---@field icon? string
---@field arrow? boolean
---@field disabled? boolean
---@field onSelect? fun()

---@class REC_Core.Client.Bridge.InputRow
---@field type "input" | "number" | "checkbox" | "select" | "date"
---@field label string
---@field description? string
---@field placeholder? string
---@field required? boolean
---@field default? any
---@field min? number
---@field max? number
---@field format? string date only
---@field returnString? boolean date only
---@field options? { value: string, label: string }[] select only

---@class REC_Core.Client.Bridge.AlertOptions
---@field header string
---@field content string
---@field centered? boolean
---@field cancel? boolean
---@field labels? { confirm?: string, cancel?: string }
