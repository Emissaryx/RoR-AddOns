-- player_proxy.lua

---@class PlayerProxy : UnitProxy
---@field Money number
local PlayerProxy = {}

--- Adds money to the player.
---@param money number
function PlayerProxy:AddMoney(money) end

--- Removes money from the player.
---@param money number
---@return boolean
function PlayerProxy:RemoveMoney(money) end

--- Adds an item to the player's inventory.
---@param itemId number
---@param count number
---@return boolean
function PlayerProxy:AddItem(itemId, count) end

--- Removes an item from the player's inventory.
---@param itemId number
---@param count number
---@return boolean
function PlayerProxy:RemoveItem(itemId, count) end

--- Checks if the player has a certain amount of an item in their inventory.
---@param itemId number
---@param count number
---@return boolean
function PlayerProxy:HasItem(itemId, count) end

--- Sends a localized string to the player's chat.
---@param message string
---@param filter ChatLogFilters
---@param localizeEntry LocalizedText
function PlayerProxy:SendLocalizeString(message, filter, localizeEntry) end

--- Teleports the player to a specified location.
---@param zoneId number
---@param x number
---@param y number
---@param z number
---@param o number
function PlayerProxy:Teleport(zoneId, x, y, z, o) end

--- Triggers a quest objective for the player.
---@param questId number
---@param questObjectiveId number
---@return boolean
function PlayerProxy:TriggerQuestObjective(questId, questObjectiveId) end

return PlayerProxy
