
---@type REC_Core.Locales
return {

    connect = {

        noIdentifier = "\n\nYour identifier could not be read.\nPlease restart FiveM and try again.",
    },

    menu = {

        title = "Characters",

        -- %s is the job label, %s the last time it was played
        character_description = "%s | last played: %s",

        lastPlayed_never = "never",

        newCharacter = "New character",

        -- %d slots used, %d slots in total
        newCharacter_description = "%d / %d slots used",

        play = "Play",
        play_description = "Spawn with this character",

        delete = "Delete",
        delete_description = "Remove this character for good",

        back = "Back",
    },

    create = {

        title = "New character",

        firstName = "First name",
        lastName = "Last name",
        birthdate = "Birthdate",
        gender = "Gender",
        gender_male = "Male",
        gender_female = "Female",
        nationality = "Nationality",
    },

    delete = {

        header = "Delete character",

        -- %s %s is the character's first and last name
        content = "Delete %s %s? This cannot be undone.",

        confirm = "Delete",
        cancel = "Cancel",
    },

    notify = {

        title = "RE:CORD",

        -- %s %s is the character's first and last name
        characterCreated = "Welcome, %s %s!",

        characterDeleted = "The character was deleted.",

        -- %s is the amount, %s the account label
        moneyAdded = "+$%s (%s)",
        moneyRemoved = "-$%s (%s)",

        -- %s is the account label, %s the new balance
        moneySet = "%s: $%s",

        -- %s is the job label, %s the grade name
        jobUpdated = "Job: %s / %s",

        -- %s is the gang label, %s the grade name
        gangUpdated = "Gang: %s / %s",

        dutyOn = "You are now on duty.",
        dutyOff = "You are now off duty.",

        -- %s is the amount
        paycheck = "Paycheck: $%s",
    },

    error = {

        notActive = "The core is not active on this server.",
        databaseNotReady = "The database is not ready. Please tell the staff.",
        invalidInput = "The input is not valid.",
        slotsFull = "Every character slot is used.",
        notFound = "The character was not found.",
        alreadyLoaded = "That character is already in use.",
        notAllowed = "You cannot do that.",
        busy = "Please wait a moment.",
        generic = "Something went wrong. Please try again.",
    },

    command = {

        noCharacter = "That player has no character loaded.",
        unknownJob = "Unknown job or grade.",
        unknownGang = "Unknown gang or grade.",
        unknownAccount = "Unknown account.",
        invalidAmount = "The amount must be a whole number.",
        failed = "The command failed.",

        -- %s is the character name, %s the job, %d the grade
        jobSet = "Set the job of %s to %s (%d).",

        -- %s is the character name, %s the gang, %d the grade
        gangSet = "Set the gang of %s to %s (%d).",

        -- %s is the amount, %s the account, %s the character name
        moneyAdded = "Added $%s to the %s account of %s.",
        moneyRemoved = "Removed $%s from the %s account of %s.",

        -- %s is the account, %s the character name, %s the balance
        moneySet = "Set the %s account of %s to $%s.",
    },
}
