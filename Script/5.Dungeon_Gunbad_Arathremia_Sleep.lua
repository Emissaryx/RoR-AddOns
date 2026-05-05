local function OnServerCommand(caster, target, values)
  local sayString = "Sleep, |t."

  sayString = sayString:gsub("|t", target.Name)
  caster:Say(sayString, SystemData.ChatLogFilters.CHATLOGFILTERS_EMOTE, Localized_text.CHAT_TAG_DEFAULT)
end

RegisterServerCommandScript(34, 50814, ServerCommandTrigger.Start, OnServerCommand)
