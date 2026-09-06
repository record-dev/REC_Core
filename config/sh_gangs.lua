
---[[
---     Gangs
---     The key is the gang name, keep it lower case. Grades start at 0.
---     isBoss marks the grades a boss menu opens for.
---]]
---@type table<string, REC_Core.Config.Gang>
return {

    ["none"] = {
        label = "No gang",
        grades = {
            [0] = { name = "Member", },
        },
    },

    ["ballas"] = {
        label = "Ballas",
        grades = {
            [0] = { name = "Recruit", },
            [1] = { name = "Enforcer", },
            [2] = { name = "Shot Caller", },
            [3] = { name = "Boss", isBoss = true, },
        },
    },

    ["vagos"] = {
        label = "Vagos",
        grades = {
            [0] = { name = "Recruit", },
            [1] = { name = "Enforcer", },
            [2] = { name = "Shot Caller", },
            [3] = { name = "Boss", isBoss = true, },
        },
    },

    ["families"] = {
        label = "Families",
        grades = {
            [0] = { name = "Recruit", },
            [1] = { name = "Enforcer", },
            [2] = { name = "Shot Caller", },
            [3] = { name = "Boss", isBoss = true, },
        },
    },
}
