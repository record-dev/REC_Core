
---@type REC_Core.Shared.Config, REC_Core.Server.Config
local shCfg, svCfg = require "@REC_Core.config.sh_config", require "@REC_Core.config.sv_config"
local commandsCfg = svCfg.commands

---@type REC_Core.Shared.Enum
local shEnums = require "@REC_Core.shared.sh_enum"
local groupTypes = shEnums.groupTypes

---@type REC_Core.Shared.Functions
local functions = require "@REC_Core.shared.sh_functions"

---@type REC_Core.Locales
local locales = require ("@REC_Core.locales.".. shCfg.language)

---@type REC_Core.Server.Bridge
local bridge = require "@REC_Core.server.sv_bridge"

---@type REC_Core.Server.Utils
local utils = require "@REC_Core.server.sv_utils"

---@type REC_Core.Server.Manager.ServerManager
local serverManager = require "@REC_Core.server.manager.sv_serverManager"

---@type REC_Core.Server.Modules.Players
local players = require "@REC_Core.server.modules.sv_players"

---@type REC_Core.Server.Modules.Money
local money = require "@REC_Core.server.modules.sv_money"

---@type REC_Core.Server.Modules.Groups
local groups = require "@REC_Core.server.modules.sv_groups"

if commandsCfg.enabled == false then
    return
end



---[[
---     Player commands
---]]

if commandsCfg.player.logout == true then

    bridge:addCommand("logout", {
        help = "Go back to the character menu",
    }, function (src)

        if src == 0 then
            return
        end

        players:logout(src)
    end)
end

if commandsCfg.player.duty == true then

    bridge:addCommand("duty", {
        help = "Clock in or out of your job",
    }, function (src)

        if src == 0 then
            return
        end

        local job = groups:get(groupTypes.job, src)
        if job == nil then
            return
        end

        groups:setDuty(src, job.onDuty ~= true)
    end)
end



---[[
---     Admin commands
---]]

---[[
---     Name of the character for the reply
---]]
---@param playerId integer
---@return string|nil
local function characterName(playerId)

    local character = serverManager:getCharacterByPlayerId(playerId)
    if character == nil then
        return nil
    end

    local charinfo = character.info.charinfo

    return ("%s %s"):format(charinfo.firstname, charinfo.lastname)
end

bridge:addCommand("setjob", {
    help = "Give a player a job",
    restricted = commandsCfg.restricted,
    params = {
        { name = "target", type = "playerId", help = "server id", },
        { name = "job", type = "string", help = "job name", },
        { name = "grade", type = "number", help = "grade, defaults to 0", optional = true, },
    },
}, function (src, args)

    local name = characterName(args.target)
    if name == nil then
        utils:reply(src, "error", locales.command.noCharacter)
        return
    end

    local grade = args.grade ~= nil and math.tointeger(args.grade) or 0

    if groups:set(groupTypes.job, args.target, args.job, grade) == false then
        utils:reply(src, "error", locales.command.unknownJob)
        return
    end

    utils:reply(src, "success", (locales.command.jobSet):format(name, args.job, grade))
end)

bridge:addCommand("setgang", {
    help = "Give a player a gang",
    restricted = commandsCfg.restricted,
    params = {
        { name = "target", type = "playerId", help = "server id", },
        { name = "gang", type = "string", help = "gang name", },
        { name = "grade", type = "number", help = "grade, defaults to 0", optional = true, },
    },
}, function (src, args)

    local name = characterName(args.target)
    if name == nil then
        utils:reply(src, "error", locales.command.noCharacter)
        return
    end

    local grade = args.grade ~= nil and math.tointeger(args.grade) or 0

    if groups:set(groupTypes.gang, args.target, args.gang, grade) == false then
        utils:reply(src, "error", locales.command.unknownGang)
        return
    end

    utils:reply(src, "success", (locales.command.gangSet):format(name, args.gang, grade))
end)

---[[
---     Shared body of the three money commands
---]]
---@param src integer
---@param args table<string, any>
---@param action REC_Core.Shared.Enum.MoneyActions
local function moneyCommand(src, args, action)

    local name = characterName(args.target)
    if name == nil then
        utils:reply(src, "error", locales.command.noCharacter)
        return
    end

    if money:isAccount(args.account) == false then
        utils:reply(src, "error", locales.command.unknownAccount)
        return
    end

    local amount = (function ()
        if action == shEnums.moneyActions.set then
            return utils:normalizeBalance(args.amount)
        end
        return utils:normalizeAmount(args.amount)
    end)()

    if amount == nil then
        utils:reply(src, "error", locales.command.invalidAmount)
        return
    end

    local reason = ("admin-%s"):format(action)

    local isSuccessful = (function ()
        if action == shEnums.moneyActions.add then
            return money:add(args.target, args.account, amount, reason)
        end

        if action == shEnums.moneyActions.remove then
            return money:remove(args.target, args.account, amount, reason)
        end

        return money:set(args.target, args.account, amount, reason)
    end)()

    if isSuccessful == false then
        utils:reply(src, "error", locales.command.failed)
        return
    end

    local formatted = functions:formatNumber(amount)

    if action == shEnums.moneyActions.add then
        utils:reply(src, "success", (locales.command.moneyAdded):format(formatted, args.account, name))
        return
    end

    if action == shEnums.moneyActions.remove then
        utils:reply(src, "success", (locales.command.moneyRemoved):format(formatted, args.account, name))
        return
    end

    utils:reply(src, "success", (locales.command.moneySet):format(args.account, name, formatted))
end

---@type REC_Core.Server.Bridge.CommandParam[]
local moneyParams = {
    { name = "target", type = "playerId", help = "server id", },
    { name = "account", type = "string", help = "account name, e.g. cash / bank", },
    { name = "amount", type = "number", help = "amount", },
}

bridge:addCommand("addmoney", {
    help = "Add money to a player's account",
    restricted = commandsCfg.restricted,
    params = moneyParams,
}, function (src, args)
    moneyCommand(src, args, shEnums.moneyActions.add)
end)

bridge:addCommand("removemoney", {
    help = "Remove money from a player's account",
    restricted = commandsCfg.restricted,
    params = moneyParams,
}, function (src, args)
    moneyCommand(src, args, shEnums.moneyActions.remove)
end)

bridge:addCommand("setmoney", {
    help = "Set the balance of a player's account",
    restricted = commandsCfg.restricted,
    params = moneyParams,
}, function (src, args)
    moneyCommand(src, args, shEnums.moneyActions.set)
end)
