---@meta

---[[
---     Exports
---]]

exports.REC_Core = {}

---[[
---     Lifecycle (server)
---]]

---**`SERVER`**
---
---Whether the core is running (false while dormant next to another framework)
---@return boolean
function exports.REC_Core:isActive() end

---**`SERVER`**
---
---Whether a player has a character loaded
---@param playerId integer
---@return boolean
function exports.REC_Core:isLoaded(playerId) end

---**`SERVER`**
---
---Server ids of every player with a character loaded
---@return integer[]
function exports.REC_Core:getPlayerIds() end

---**`SERVER`**
---
---Every loaded character, as copies
---@return REC_Core.Server.Character[]
function exports.REC_Core:getPlayers() end

---**`SERVER`**
---
---The loaded character of a player, as a copy
---@param playerId integer
---@return REC_Core.Server.Character|nil
function exports.REC_Core:getPlayerData(playerId) end

---**`SERVER`**
---
---@param playerId integer
---@return string|nil
function exports.REC_Core:getCitizenIdByPlayerId(playerId) end

---**`SERVER`**
---
---@param citizenId string
---@return integer|nil
function exports.REC_Core:getPlayerIdByCitizenId(citizenId) end

---**`SERVER`**
---
---The identifier characters are tied to (config.identifiers), e.g. license2:...
---@param playerId integer
---@return string|nil
function exports.REC_Core:getIdentifier(playerId) end

---**`SERVER`**
---
---Every character of one identifier, from the DB
---@param license string
---@return REC_Core.Server.Character[]|nil
function exports.REC_Core:getCharactersByLicense(license) end

---**`SERVER`**
---
---A character from the DB, loaded or not
---Queries the DB directly, do not call it often
---@param citizenId string
---@return REC_Core.Server.Character|nil
function exports.REC_Core:getOfflineCharacter(citizenId) end

---**`SERVER`**
---
---Delete a character that is not loaded, with every value stored for it
---@param citizenId string
---@return boolean
function exports.REC_Core:deleteCharacter(citizenId) end

---**`SERVER`**
---
---Save the character and send the player back to the character menu
---@param playerId integer
---@return boolean
function exports.REC_Core:logout(playerId) end

---**`SERVER`**
---
---Write the unsaved changes of a player right now
---Normally autosave and the player leaving already write, so you rarely need this
---@param playerId integer
---@return boolean
function exports.REC_Core:save(playerId) end

---**`SERVER`**
---
---Write the unsaved changes of everyone right now
---@return integer number of characters whose save failed
function exports.REC_Core:saveAll() end

---**`SERVER`**
---
---ACE check, the console (0) passes everything
---@param playerId integer
---@param permission string e.g. "group.admin"
---@return boolean
function exports.REC_Core:hasPermission(playerId, permission) end

---[[
---     Money (server)
---]]

---**`SERVER`**
---
---The accounts as configured
---@return table<string, REC_Core.Config.Account>
function exports.REC_Core:getAccounts() end

---**`SERVER`**
---
---@param playerId integer
---@param account string
---@return integer|nil
function exports.REC_Core:getMoney(playerId, account) end

---**`SERVER`**
---
---@param playerId integer
---@return table<string, integer>|nil
function exports.REC_Core:getMoneys(playerId) end

---**`SERVER`**
---
---Add to an account
---A missing reason is recorded as "@<your resource>", so give one
---@param playerId integer
---@param account string
---@param amount integer positive whole number
---@param reason? string
---@return boolean
function exports.REC_Core:addMoney(playerId, account, amount, reason) end

---**`SERVER`**
---
---Take from an account, fails when the balance would go below 0 unless the account allows it
---@param playerId integer
---@param account string
---@param amount integer positive whole number
---@param reason? string
---@return boolean
function exports.REC_Core:removeMoney(playerId, account, amount, reason) end

---**`SERVER`**
---
---Set the balance of an account
---@param playerId integer
---@param account string
---@param amount integer the new balance
---@param reason? string
---@return boolean
function exports.REC_Core:setMoney(playerId, account, amount, reason) end

---**`SERVER`**
---
---Add to an account of a character that is not loaded, straight to the DB
---Fails for loaded characters, use addMoney for those
---@param citizenId string
---@param account string
---@param amount integer
---@param reason? string
---@return boolean
function exports.REC_Core:addOfflineMoney(citizenId, account, amount, reason) end

---**`SERVER`**
---
---@param citizenId string
---@param account string
---@param amount integer
---@param reason? string
---@return boolean
function exports.REC_Core:removeOfflineMoney(citizenId, account, amount, reason) end

---[[
---     Jobs and gangs (server)
---]]

---**`SERVER`**
---
---Every job as configured
---@return table<string, REC_Core.Shared.Groups.Label>
function exports.REC_Core:getJobs() end

---**`SERVER`**
---
---Every gang as configured
---@return table<string, REC_Core.Shared.Groups.Label>
function exports.REC_Core:getGangs() end

---**`SERVER`**
---
---@param playerId integer
---@return REC_Core.Shared.Character.Group|nil
function exports.REC_Core:getJob(playerId) end

---**`SERVER`**
---
---@param playerId integer
---@return REC_Core.Shared.Character.Group|nil
function exports.REC_Core:getGang(playerId) end

---**`SERVER`**
---
---@param playerId integer
---@param name string job name
---@param grade? integer defaults to 0
---@return boolean
function exports.REC_Core:setJob(playerId, name, grade) end

---**`SERVER`**
---
---@param playerId integer
---@param name string gang name
---@param grade? integer defaults to 0
---@return boolean
function exports.REC_Core:setGang(playerId, name, grade) end

---**`SERVER`**
---
---@param playerId integer
---@param onDuty boolean
---@return boolean
function exports.REC_Core:setDuty(playerId, onDuty) end

---**`SERVER`**
---
---@param playerId integer
---@param job string|string[]
---@param grades? table<integer, true>|integer[] allowed grade levels, nil allows all
---@param onDutyOnly? boolean
---@return boolean
function exports.REC_Core:hasJob(playerId, job, grades, onDutyOnly) end

---**`SERVER`**
---
---@param playerId integer
---@param gang string|string[]
---@param grades? table<integer, true>|integer[]
---@return boolean
function exports.REC_Core:hasGang(playerId, gang, grades) end

---**`SERVER`**
---
---How many loaded characters hold one of the jobs
---@param job string|string[]
---@param grades? table<integer, true>|integer[]
---@param onDutyOnly? boolean
---@return integer
function exports.REC_Core:countPlayersByJob(job, grades, onDutyOnly) end

---**`SERVER`**
---
---@param gang string|string[]
---@param grades? table<integer, true>|integer[]
---@return integer
function exports.REC_Core:countPlayersByGang(gang, grades) end

---**`SERVER`**
---
---Give a character that is not loaded a job, straight to the DB
---@param citizenId string
---@param name string
---@param grade? integer
---@return boolean
function exports.REC_Core:setOfflineJob(citizenId, name, grade) end

---**`SERVER`**
---
---@param citizenId string
---@param name string
---@param grade? integer
---@return boolean
function exports.REC_Core:setOfflineGang(citizenId, name, grade) end

---[[
---     Charinfo and metadata (server)
---]]

---**`SERVER`**
---
---@param playerId integer
---@return REC_Core.Shared.Character.Charinfo|nil
function exports.REC_Core:getCharinfo(playerId) end

---**`SERVER`**
---
---@param playerId integer
---@param key string
---@param value string|number|boolean|table|nil
---@return boolean
function exports.REC_Core:setCharinfo(playerId, key, value) end

---**`SERVER`**
---
---@param playerId integer
---@param key string
---@return any
function exports.REC_Core:getMetadata(playerId, key) end

---**`SERVER`**
---
---@param playerId integer
---@return table<string, any>|nil
function exports.REC_Core:getAllMetadata(playerId) end

---**`SERVER`**
---
---Passing nil as value deletes the key
---@param playerId integer
---@param key string
---@param value any string | number | boolean | table only
---@return boolean
function exports.REC_Core:setMetadata(playerId, key, value) end

---[[
---     Value store (server)
---     One row per (namespace, key), use your resource name as the namespace
---]]

---**`SERVER`**
---
---@param playerId integer
---@param namespace string usually your own resource name
---@param dataKey string
---@return any
function exports.REC_Core:getValue(playerId, namespace, dataKey) end

---**`SERVER`**
---
---Every value in a namespace at once, as a copy
---@param playerId integer
---@param namespace string
---@return table<string, any>|nil
function exports.REC_Core:getValues(playerId, namespace) end

---**`SERVER`**
---
---Passing nil as value deletes it
---@param playerId integer
---@param namespace string usually your own resource name
---@param dataKey string
---@param value any string | number | boolean | table only
---@return boolean
function exports.REC_Core:setValue(playerId, namespace, dataKey, value) end

---**`SERVER`**
---
---Write every value in a namespace at once
---@param playerId integer
---@param namespace string
---@param values table<string, any>
---@return boolean
function exports.REC_Core:setValues(playerId, namespace, values) end

---**`SERVER`**
---
---@param playerId integer
---@param namespace string
---@param dataKey string
---@return boolean
function exports.REC_Core:removeValue(playerId, namespace, dataKey) end

---**`SERVER`**
---
---Delete a whole namespace
---@param playerId integer
---@param namespace string
---@return boolean
function exports.REC_Core:removeNamespace(playerId, namespace) end

---**`SERVER`**
---
---A value of a character that is not loaded
---Queries the DB directly, do not call it often
---@param citizenId string
---@param namespace string
---@param dataKey? string omit it to get the whole namespace
---@return any
function exports.REC_Core:getOfflineValue(citizenId, namespace, dataKey) end

---**`SERVER`**
---
---Write a value of a character that is not loaded
---Fails for loaded characters, use setValue for those
---@param citizenId string
---@param namespace string
---@param dataKey string
---@param value any
---@return boolean
function exports.REC_Core:setOfflineValue(citizenId, namespace, dataKey, value) end

---**`SERVER`**
---
---The shared config, as a copy
---@return REC_Core.Shared.Config
function exports.REC_Core:getConfig() end

---[[
---     Client
---]]

---**`CLIENT`**
---
---Whether our character is loaded
---@return boolean
function exports.REC_Core:isLoaded() end

---**`CLIENT`**
---
---Our character, as a copy
---@return REC_Core.Shared.Character|nil
function exports.REC_Core:getPlayerData() end

---**`CLIENT`**
---
---@return string|nil
function exports.REC_Core:getCitizenId() end

---**`CLIENT`**
---
---@return REC_Core.Shared.Character.Charinfo|nil
function exports.REC_Core:getCharinfo() end

---**`CLIENT`**
---
---@return REC_Core.Shared.Character.Group|nil
function exports.REC_Core:getJob() end

---**`CLIENT`**
---
---@return REC_Core.Shared.Character.Group|nil
function exports.REC_Core:getGang() end

---**`CLIENT`**
---
---@param account string
---@return integer|nil
function exports.REC_Core:getMoney(account) end

---**`CLIENT`**
---
---@return table<string, integer>|nil
function exports.REC_Core:getMoneys() end

---**`CLIENT`**
---
---@param key string
---@return any
function exports.REC_Core:getMetadata(key) end

---**`CLIENT`**
---
---One of our own values
---Namespaces listed in sync.blockedNamespaces in sv_config.lua are never sent, so they read as nil
---@param namespace string
---@param dataKey string
---@return any
function exports.REC_Core:getValue(namespace, dataKey) end

---**`CLIENT`**
---
---All our own values in a namespace, as a copy
---@param namespace string
---@return table<string, any>|nil
function exports.REC_Core:getValues(namespace) end

---**`CLIENT`**
---
---@param job string|string[]
---@param grades? table<integer, true>|integer[]
---@param onDutyOnly? boolean
---@return boolean
function exports.REC_Core:hasJob(job, grades, onDutyOnly) end

---**`CLIENT`**
---
---@param gang string|string[]
---@param grades? table<integer, true>|integer[]
---@return boolean
function exports.REC_Core:hasGang(gang, grades) end

---**`CLIENT`**
---
---Back to the character menu
---@return boolean
function exports.REC_Core:logout() end

---[[
---     Exports End
---]]

---[[
---     Events
---
---     server (TriggerEvent, listen with AddEventHandler)
---         REC_Core:server:onPlayerLoaded        (playerId, REC_Core.Server.Main.PlayerLoaded.Payload)
---         REC_Core:server:onPlayerUnloaded      (playerId, REC_Core.Server.Main.PlayerUnloaded.Payload)
---         REC_Core:server:onCharacterCreated    (playerId, REC_Core.Server.Main.CharacterCreated.Payload)
---         REC_Core:server:onCharacterDeleted    (playerId, REC_Core.Server.Main.CharacterDeleted.Payload)
---         REC_Core:server:onMoneyChange         (playerId, REC_Core.Server.Main.MoneyChange.Payload)
---         REC_Core:server:onOfflineMoneyChange  (REC_Core.Server.Main.OfflineMoneyChange.Payload)
---         REC_Core:server:onJobUpdate           (playerId, REC_Core.Server.Main.JobUpdate.Payload)
---         REC_Core:server:onGangUpdate          (playerId, REC_Core.Server.Main.GangUpdate.Payload)
---         REC_Core:server:onDutyChange          (playerId, REC_Core.Server.Main.DutyChange.Payload)
---         REC_Core:server:onCharinfoChange      (playerId, REC_Core.Server.Main.CharinfoChange.Payload)
---         REC_Core:server:onMetadataChange      (playerId, REC_Core.Server.Main.MetadataChange.Payload)
---         REC_Core:server:onValueChange         (playerId, REC_Core.Server.Main.ValueChange.Payload)
---
---     client (local TriggerEvent, listen with AddEventHandler)
---         REC_Core:client:onPlayerLoaded        (REC_Core.Client.Main.PlayerLoaded.Payload)
---         REC_Core:client:onPlayerUnloaded      (REC_Core.Client.Main.PlayerUnloaded.Payload)
---         REC_Core:client:onMoneyChange         (REC_Core.Server.Main.MoneyChange.Payload)
---         REC_Core:client:onJobUpdate           (REC_Core.Server.Main.JobUpdate.Payload)
---         REC_Core:client:onGangUpdate          (REC_Core.Server.Main.GangUpdate.Payload)
---         REC_Core:client:onCharinfoChange      (REC_Core.Server.Main.CharinfoChange.Payload)
---         REC_Core:client:onMetadataChange      (REC_Core.Server.Main.MetadataChange.Payload)
---         REC_Core:client:onValueChange         (REC_Core.Client.Main.UpdateValue.Payload)
---
---     state bag
---         Player(playerId).state.citizenId       while a character is loaded
---]]

---[[
---     Character
---]]

---The character as the client sees it
---@class REC_Core.Shared.Character
---@field citizenId string
---@field slot integer
---@field charinfo REC_Core.Shared.Character.Charinfo
---@field job REC_Core.Shared.Character.Group
---@field gang REC_Core.Shared.Character.Group
---@field money table<string, integer> account -> balance
---@field metadata table<string, any>
---@field position REC_Core.Shared.Position|nil where the last save left it
---@field lastLoggedOutAt? string|integer

---The character as the server sees it
---@class REC_Core.Server.Character: REC_Core.Shared.Character
---@field playerId integer|nil nil when read from the DB while offline
---@field license string
---@field loadedAt? integer os.time() of the load

---@class REC_Core.Shared.Character.Charinfo
---@field firstname string
---@field lastname string
---@field birthdate string YYYY-MM-DD
---@field gender REC_Core.Shared.Enum.Genders
---@field nationality string
---@field [string] any anything setCharinfo added

---@class REC_Core.Shared.Character.Group
---@field name string
---@field label string
---@field type? string
---@field grade REC_Core.Shared.Character.Group.Grade
---@field onDuty? boolean job only

---@class REC_Core.Shared.Character.Group.Grade
---@field level integer
---@field name string
---@field isBoss boolean
---@field payment integer

---What the DB keeps of a group
---@class REC_Core.Shared.Character.StoredGroup
---@field name string
---@field grade integer
---@field onDuty? boolean

---@class REC_Core.Shared.Position
---@field x number
---@field y number
---@field z number
---@field w number heading

---[[
---     Config
---]]

---@class REC_Core.Config.Account
---@field label string
---@field default integer balance a new character starts with
---@field allowNegative? boolean

---@class REC_Core.Config.Group
---@field label string
---@field type? string
---@field defaultDuty? boolean job only
---@field grades table<integer, REC_Core.Config.Group.Grade>

---@class REC_Core.Config.Group.Grade
---@field name string
---@field payment? integer
---@field isBoss? boolean

---@class REC_Core.Config.Job: REC_Core.Config.Group
---@field defaultDuty? boolean

---@class REC_Core.Config.Gang: REC_Core.Config.Group

---[[
---     Server event payloads
---]]

---@class REC_Core.Server.Main.PlayerLoaded.Payload
---@field citizenId string
---@field character REC_Core.Server.Character

---@class REC_Core.Server.Main.PlayerUnloaded.Payload
---@field citizenId string
---@field reason REC_Core.Shared.Enum.UnloadReasons

---@class REC_Core.Server.Main.CharacterCreated.Payload
---@field citizenId string
---@field character REC_Core.Server.Character

---@class REC_Core.Server.Main.CharacterDeleted.Payload
---@field citizenId string

---@class REC_Core.Server.Main.MoneyChange.Payload
---@field citizenId string
---@field account string
---@field action REC_Core.Shared.Enum.MoneyActions
---@field amount integer the argument of the call: the delta for add / remove, the new balance for set
---@field delta integer balance after minus balance before, negative for a removal
---@field balance integer balance after
---@field reason string never empty, "@<resource>" when the caller gave none
---@field resource string resource that made the change

---@class REC_Core.Server.Main.OfflineMoneyChange.Payload: REC_Core.Server.Main.MoneyChange.Payload

---@class REC_Core.Server.Main.JobUpdate.Payload
---@field citizenId string
---@field job REC_Core.Shared.Character.Group
---@field oldJob REC_Core.Shared.Character.Group

---@class REC_Core.Server.Main.GangUpdate.Payload
---@field citizenId string
---@field gang REC_Core.Shared.Character.Group
---@field oldGang REC_Core.Shared.Character.Group

---@class REC_Core.Server.Main.DutyChange.Payload
---@field citizenId string
---@field onDuty boolean
---@field job REC_Core.Shared.Character.Group

---@class REC_Core.Server.Main.CharinfoChange.Payload
---@field citizenId string
---@field key string
---@field oldValue any
---@field newValue any
---@field charinfo REC_Core.Shared.Character.Charinfo the whole charinfo after the change

---@class REC_Core.Server.Main.MetadataChange.Payload
---@field citizenId string
---@field key string
---@field oldValue any
---@field newValue any

---@class REC_Core.Server.Main.ValueChange.Payload
---@field citizenId string
---@field namespace string
---@field dataKey string
---@field oldValue any
---@field newValue any

---[[
---     Client event payloads
---]]

---@class REC_Core.Client.Main.PlayerLoaded.Payload
---@field character REC_Core.Shared.Character

---@class REC_Core.Client.Main.PlayerUnloaded.Payload
---@field reason REC_Core.Shared.Enum.UnloadReasons

---@class REC_Core.Client.Main.SyncPlayerData.Payload
---@field character REC_Core.Shared.Character
---@field data table<string, table<string, any>> namespace -> dataKey -> value, blocked namespaces left out

---@class REC_Core.Client.Main.UpdateValue.Payload
---@field namespace string
---@field dataKey string
---@field value any

---@class REC_Core.Client.Main.Reset.Payload
---@field reason REC_Core.Shared.Enum.UnloadReasons

---@class REC_Core.Client.Main.Notify.Payload
---@field type "info" | "success" | "warning" | "error"
---@field title string
---@field description string
---@field duration? integer

---[[
---     Callback payloads
---]]

---@class REC_Core.Server.Callbacks.GetStatus.Return
---@field active boolean
---@field databaseReady boolean
---@field character? REC_Core.Shared.Character set when the server already has one loaded
---@field data? table<string, table<string, any>>

---@class REC_Core.Server.Callbacks.GetCharacters.Return
---@field ok boolean
---@field error? REC_Core.Shared.Enum.Errors
---@field characters? REC_Core.Server.Callbacks.GetCharacters.Character[]
---@field maxSlots? integer
---@field allowDelete? boolean

---@class REC_Core.Server.Callbacks.GetCharacters.Character
---@field citizenId string
---@field slot integer
---@field charinfo REC_Core.Shared.Character.Charinfo
---@field job REC_Core.Shared.Character.Group
---@field gang REC_Core.Shared.Character.Group
---@field lastLoggedOutAt? string|integer

---@class REC_Core.Server.Callbacks.CreateCharacter.Input
---@field firstname string
---@field lastname string
---@field birthdate string YYYY-MM-DD
---@field gender REC_Core.Shared.Enum.Genders
---@field nationality? string

---@class REC_Core.Server.Callbacks.CreateCharacter.Return
---@field ok boolean
---@field error? REC_Core.Shared.Enum.Errors
---@field citizenId? string

---@class REC_Core.Server.Callbacks.DeleteCharacter.Return
---@field ok boolean
---@field error? REC_Core.Shared.Enum.Errors

---@class REC_Core.Server.Callbacks.SelectCharacter.Return
---@field ok boolean
---@field error? REC_Core.Shared.Enum.Errors
---@field character? REC_Core.Shared.Character
---@field data? table<string, table<string, any>>
---@field spawn? vector4

---[[
---     Locales
---]]

---@class REC_Core.Locales
---@field connect REC_Core.Locales.Connect
---@field menu REC_Core.Locales.Menu
---@field create REC_Core.Locales.Create
---@field delete REC_Core.Locales.Delete
---@field notify REC_Core.Locales.Notify
---@field error REC_Core.Locales.Error
---@field command REC_Core.Locales.Command

---@class REC_Core.Locales.Connect
---@field noIdentifier string

---@class REC_Core.Locales.Menu
---@field title string
---@field character_description string %s job label, %s last played
---@field lastPlayed_never string
---@field newCharacter string
---@field newCharacter_description string %d used, %d total
---@field play string
---@field play_description string
---@field delete string
---@field delete_description string
---@field back string

---@class REC_Core.Locales.Create
---@field title string
---@field firstName string
---@field lastName string
---@field birthdate string
---@field gender string
---@field gender_male string
---@field gender_female string
---@field nationality string

---@class REC_Core.Locales.Delete
---@field header string
---@field content string %s %s first and last name
---@field confirm string
---@field cancel string

---@class REC_Core.Locales.Notify
---@field title string
---@field characterCreated string %s %s first and last name
---@field characterDeleted string
---@field moneyAdded string %s amount, %s account label
---@field moneyRemoved string %s amount, %s account label
---@field moneySet string %s account label, %s balance
---@field jobUpdated string %s job label, %s grade name
---@field gangUpdated string %s gang label, %s grade name
---@field dutyOn string
---@field dutyOff string
---@field paycheck string %s amount

---@class REC_Core.Locales.Error
---@field notActive string
---@field databaseNotReady string
---@field invalidInput string
---@field slotsFull string
---@field notFound string
---@field alreadyLoaded string
---@field notAllowed string
---@field busy string
---@field generic string
---@field [string] string

---@class REC_Core.Locales.Command
---@field noCharacter string
---@field unknownJob string
---@field unknownGang string
---@field unknownAccount string
---@field invalidAmount string
---@field failed string
---@field jobSet string %s name, %s job, %d grade
---@field gangSet string %s name, %s gang, %d grade
---@field moneyAdded string %s amount, %s account, %s name
---@field moneyRemoved string %s amount, %s account, %s name
---@field moneySet string %s account, %s name, %s balance
