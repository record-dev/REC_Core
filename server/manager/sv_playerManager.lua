
---@type REC_Library.Server.API
local svApi = require "@REC_Library.server.sv_api"

---@type REC_Core.Server.Utils
local utils = require "@REC_Core.server.sv_utils"

---@type REC_Core.Shared.Events
local events = require "@REC_Core.shared.sh_event"

---@class REC_Core.Server.Manager.PlayerManagerConfigBuilder: REC_Library.Server.Class.Manager.PlayerManagerConfigBuilder
local playerManagerConfigBuilder = svApi.Class.Manager.PlayerManagerConfigBuilder:new()
    :setOnStart(function (self)
        ---@cast self REC_Core.Server.Manager.PlayerManager

        utils:debugPrint("^2[PlayerManager]: onStart !!!!")
    end)
    :setOnStop(function (self)
        ---@cast self REC_Core.Server.Manager.PlayerManager

        utils:debugPrint("^2[PlayerManager]: onStop !!!!")
    end)
    :setOnRegistered(function (self, player)
        ---@cast self REC_Core.Server.Manager.PlayerManager

        utils:debugPrint("^2[PlayerManager]: registered !!!!", player.info.src)
    end)
    :setOnUnregistered(function (self, player)
        ---@cast self REC_Core.Server.Manager.PlayerManager

        utils:debugPrint("^2[PlayerManager]: unregistered !!!!", player.info.src)
    end)
    :setOnUpdate(function (self, player)
        ---@cast self REC_Core.Server.Manager.PlayerManager

        -- utils:debugPrint("^2[PlayerManager]: onUpdate !!!!", player.info.src)
    end)
    :setOnRoutingBucketChanged(function (self, player, oldBucket, newBucket)
        ---@cast self REC_Core.Server.Manager.PlayerManager

        utils:debugPrint(("[PlayerManager]: player %s changed routing bucket from %d to %d !!!!"):format(player.info.src, oldBucket, newBucket))

        local src = tonumber(player.info.src)
        local citizenId = exports.REC_PlayerManager:getCitizenIdByPlayerId(src)
        if citizenId == nil then
            utils:debugPrint(("^3failed to get citizenId... playerId: %d^0"):format(src))
            return
        end

    end)
    :setOnPlayerJoined(function (self, playerSrc, ...)
        ---@cast self REC_Core.Server.Manager.PlayerManager

        utils:debugPrint("^2[PlayerManager]: joining !!!")
    end)
    :setOnPlayerDropped(function (self, playerSrc, ...)
        ---@cast self REC_Core.Server.Manager.PlayerManager

        utils:debugPrint("^2[PlayerManager]: lefting!!!")
        local info = self.info

        if self:unregister(playerSrc) == false then
            print("^1Failed to unregister player: " .. playerSrc .. "^0")
        end
    end)
    :setCustomProperties({})

---@class REC_Core.Server.Manager.PlayerManager: REC_Library.Server.Class.Manager.PlayerManager
---@field info REC_Core.Server.Manager.PlayerManagerConfigBuilder
local playerManager = svApi.Class.Manager.PlayerManager:new(playerManagerConfigBuilder)

return playerManager