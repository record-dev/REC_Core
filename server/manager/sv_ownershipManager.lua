
---@type REC_Library.Server.API
local svApi = require "@REC_Library.server.sv_api"

---@type REC_Core.Server.Utils
local utils = require "@REC_Core.server.sv_utils"

---@type REC_Core.Shared.Events
local events = require "@REC_Core.shared.sh_event"

---@class REC_Core.Server.Manager.OwnershipManagerConfigBuilder: REC_Library.Server.Class.Manager.OwnershipManagerConfigBuilder
local ownershipManagerConfigBuilder = svApi.Class.Manager.OwnershipManagerConfigBuilder:new()
    :setOnRegister(function (self, netId)
        utils:debugPrint(("%d was registered"):format(netId))
    end)
    :setOnUnregister(function (self, netId)
        utils:debugPrint(("%d was unregistered"):format(netId))
    end)
    :setOnStart(function (self, ...)
        utils:debugPrint("onStart!!!")
    end)
    :setOnStop(function (self, ...)
        utils:debugPrint("onStop!!!")
    end)
    :setOnCheckOwnership(function (self, handle, netId, oldOwner, newOwner)
        -- utils:debugPrint("onCheckOwnership", handle, netId, oldOwner, newOwner)
    end)
    :setOnUpdateOwnership(function (self, handle, netId, oldOwner, newOwner, reason)
        utils:debugPrint("^6onUpdateOwnership^0", handle, netId, oldOwner, newOwner, reason)
    end)

---@class REC_Core.Server.Manager.OwnershipManager: REC_Library.Server.Class.Manager.OwnershipManager
local ownershipManager = svApi.Class.Manager.OwnershipManager:new(ownershipManagerConfigBuilder)

return ownershipManager