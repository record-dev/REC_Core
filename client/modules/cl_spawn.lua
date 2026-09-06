
---@type REC_Core.Shared.Config
local shCfg = require "@REC_Core.config.sh_config"
local spawnCfg, menuCfg = shCfg.spawn, shCfg.characterMenu

---@type REC_Core.Client.Utils
local utils = require "@REC_Core.client.cl_utils"

---@type REC_Core.Client.Handler
local handler = require "@REC_Core.handler.cl_handler"

---[[
---     Parking the player during the menu, and putting them into the world after
---]]
---@class REC_Core.Client.Modules.Spawn
local spawn = {

    ---@type REC_Core.Client.Modules.Spawn.Info
    info = {
        camera = nil,
        isPrepared = false,
    },
}

---[[
---     spawnmanager would drop the player into the world on its own
---]]
local function disableAutoSpawn()

    if GetResourceState("spawnmanager") ~= "started" then
        return
    end

    exports.spawnmanager:setAutoSpawn(false)
end

---[[
---     Keep the ped out of sight and out of harm
---]]
---@param ped integer
---@param isParked boolean
local function setParked(ped, isParked)

    FreezeEntityPosition(ped, isParked)
    SetEntityVisible(ped, isParked == false, false)
    SetEntityInvincible(ped, isParked)
    SetPlayerInvincible(PlayerId(), isParked)
end



---[[
---     Camera phase
---]]

function spawn:startCamera()
    local info = self.info

    if menuCfg.camera.enabled == false or info.camera ~= nil then
        return
    end

    local coords, rotation = menuCfg.camera.coords, menuCfg.camera.rotation

    local camera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", coords.x, coords.y, coords.z, rotation.x, rotation.y, rotation.z, menuCfg.camera.fov, false, 0)

    SetCamActive(camera, true)
    RenderScriptCams(true, false, 0, true, true)

    info.camera = camera
end

function spawn:stopCamera()
    local info = self.info

    if info.camera == nil then
        return
    end

    RenderScriptCams(false, false, 0, true, true)
    SetCamActive(info.camera, false)
    DestroyCam(info.camera, false)

    info.camera = nil
end



---[[
---     Spawn phase
---]]

---[[
---     Park the player out of the world while the menu is open
---]]
function spawn:prepare()
    local info = self.info

    disableAutoSpawn()

    DoScreenFadeOut(0)

    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()

    local parking = menuCfg.pedCoords

    -- on the first join the ped is not part of the session yet
    NetworkResurrectLocalPlayer(parking.x, parking.y, parking.z, parking.w, true, true, false)

    local ped = PlayerPedId()

    SetEntityCoordsNoOffset(ped, parking.x, parking.y, parking.z, false, false, false)
    SetEntityHeading(ped, parking.w)
    ClearPedTasksImmediately(ped)

    setParked(ped, true)

    -- let the world stream in around the camera
    Wait(500)

    self:startCamera()

    DoScreenFadeIn(spawnCfg.fadeDuration)

    info.isPrepared = true
end

---[[
---     Swap the ped to the freemode model of the gender
---]]
---@param gender string
function spawn:applyModel(gender)

    local modelName = spawnCfg.models[gender] or spawnCfg.models.male

    local model = joaat(modelName)

    if IsModelInCdimage(model) == false or IsModelValid(model) == false then
        utils:debugPrint(("^3model is not valid... model: %s^0"):format(modelName))
        return
    end

    RequestModel(model)

    local deadline = GetGameTimer() + 10000
    while HasModelLoaded(model) == false and GetGameTimer() < deadline do
        Wait(10)
    end

    if HasModelLoaded(model) == false then
        utils:debugPrint(("^3model did not load in time... model: %s^0"):format(modelName))
        return
    end

    SetPlayerModel(PlayerId(), model)
    SetPedDefaultComponentVariation(PlayerPedId())
    SetModelAsNoLongerNeeded(model)
end

---[[
---     Put the character into the world
---]]
---@param character REC_Core.Shared.Character
---@param position vector4
function spawn:spawn(character, position)
    local info = self.info

    DoScreenFadeOut(spawnCfg.fadeDuration)
    while IsScreenFadedOut() == false do
        Wait(0)
    end

    self:stopCamera()

    -- extension point, the owner may have a spawn selector of their own
    if handler:onSpawn(character, position) == true then
        info.isPrepared = false
        return
    end

    if spawnCfg.applyDefaultModel == true then
        self:applyModel(character.charinfo.gender)
    end

    NetworkResurrectLocalPlayer(position.x, position.y, position.z, position.w, true, true, false)

    local ped = PlayerPedId()

    SetEntityCoordsNoOffset(ped, position.x, position.y, position.z, false, false, false)
    SetEntityHeading(ped, position.w)

    -- wait for the ground so the ped does not fall through
    RequestCollisionAtCoord(position.x, position.y, position.z)

    local deadline = GetGameTimer() + 5000
    while HasCollisionLoadedAroundEntity(ped) == false and GetGameTimer() < deadline do
        Wait(0)
    end

    setParked(ped, false)
    ClearPedTasksImmediately(ped)

    DoScreenFadeIn(spawnCfg.fadeDuration)

    info.isPrepared = false
end

---[[
---     Give the player back their ped, for a resource stop while parked
---]]
function spawn:release()
    local info = self.info

    self:stopCamera()

    if info.isPrepared == false then
        return
    end

    setParked(PlayerPedId(), false)

    DoScreenFadeIn(0)

    info.isPrepared = false
end

return spawn

---@class REC_Core.Client.Modules.Spawn.Info
---@field camera integer|nil
---@field isPrepared boolean whether the player is parked for the menu
