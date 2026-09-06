
---@class REC_Core.Shared.Enum
local enum = {}

---@enum REC_Core.Shared.Enum.GroupTypes
enum.groupTypes = {
    job = "job",
    gang = "gang",
}

---@enum REC_Core.Shared.Enum.Genders
enum.genders = {
    male = "male",
    female = "female",
}

---@enum REC_Core.Shared.Enum.MoneyActions
enum.moneyActions = {
    add = "add",
    remove = "remove",
    set = "set",
}

---@enum REC_Core.Shared.Enum.UnloadReasons
enum.unloadReasons = {
    dropped = "dropped",
    logout = "logout",
    switch = "switch",
    stop = "stop",
}

---@enum REC_Core.Shared.Enum.Errors
enum.errors = {
    notActive = "notActive",
    databaseNotReady = "databaseNotReady",
    invalidInput = "invalidInput",
    slotsFull = "slotsFull",
    notFound = "notFound",
    alreadyLoaded = "alreadyLoaded",
    notAllowed = "notAllowed",
    busy = "busy",
    generic = "generic",
}

return enum
