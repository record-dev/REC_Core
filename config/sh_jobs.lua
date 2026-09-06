
---[[
---     Jobs
---     The key is the job name, keep it lower case. Grades start at 0.
---     payment is what one paycheck pays, isBoss marks the grades a boss menu opens for,
---     defaultDuty is the duty state a character gets when it is given the job.
---]]
---@type table<string, REC_Core.Config.Job>
return {

    ["unemployed"] = {
        label = "Civilian",
        defaultDuty = true,
        grades = {
            [0] = { name = "Freelancer", payment = 10, },
        },
    },

    ["police"] = {
        label = "LSPD",
        type = "leo",
        defaultDuty = true,
        grades = {
            [0] = { name = "Recruit", payment = 50, },
            [1] = { name = "Officer", payment = 75, },
            [2] = { name = "Sergeant", payment = 100, },
            [3] = { name = "Lieutenant", payment = 125, },
            [4] = { name = "Chief", payment = 150, isBoss = true, },
        },
    },

    ["ambulance"] = {
        label = "EMS",
        type = "ems",
        defaultDuty = true,
        grades = {
            [0] = { name = "Recruit", payment = 50, },
            [1] = { name = "Paramedic", payment = 75, },
            [2] = { name = "Doctor", payment = 100, },
            [3] = { name = "Surgeon", payment = 125, },
            [4] = { name = "Chief", payment = 150, isBoss = true, },
        },
    },

    ["mechanic"] = {
        label = "Mechanic",
        defaultDuty = true,
        grades = {
            [0] = { name = "Recruit", payment = 50, },
            [1] = { name = "Mechanic", payment = 75, },
            [2] = { name = "Manager", payment = 100, isBoss = true, },
        },
    },

    ["taxi"] = {
        label = "Taxi",
        defaultDuty = true,
        grades = {
            [0] = { name = "Driver", payment = 50, },
            [1] = { name = "Manager", payment = 75, isBoss = true, },
        },
    },
}
