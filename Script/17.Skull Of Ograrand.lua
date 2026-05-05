local function OnServerCommand(caster, target, parameter)
  local randomResult = math.random(12);

  if randomResult <= 1
  then
    caster:SendLocalizeString("The Skull of Ograrand Says: The Winds of Change will make it so.",
      SystemData.ChatLogFilters.SystemData.ChatLogFilters_EMOTE, Localized_text.CHAT_TAG_DEFAULT)
  elseif randomResult <= 2
  then
    caster:SendLocalizeString(
    "The Skull of Ograrand Says: There is a possibility the answer you seek is favorable to you.",
      SystemData.ChatLogFilters.SystemData.ChatLogFilters_EMOTE, Localized_text.CHAT_TAG_DEFAULT)
  elseif randomResult <= 3
  then
    caster:SendLocalizeString("The Skull of Ograrand Says: Lean into the whispers upon the winds to hear the answer.",
      SystemData.ChatLogFilters.SystemData.ChatLogFilters_EMOTE, Localized_text.CHAT_TAG_DEFAULT)
  elseif randomResult <= 4
  then
    caster:SendLocalizeString("The Skull of Ograrand Says: You will not be happy with the truth that is before you.",
      SystemData.ChatLogFilters.SystemData.ChatLogFilters_EMOTE, Localized_text.CHAT_TAG_DEFAULT)
  elseif randomResult <= 5
  then
    caster:SendLocalizeString("The Skull of Ograrand Says: Change is inevitable.",
      SystemData.ChatLogFilters.SystemData.ChatLogFilters_EMOTE, Localized_text.CHAT_TAG_DEFAULT)
  elseif randomResult <= 6
  then
    caster:SendLocalizeString("The Skull of Ograrand Says: There is no hope for the forlorn.",
      SystemData.ChatLogFilters.SystemData.ChatLogFilters_EMOTE, Localized_text.CHAT_TAG_DEFAULT)
  elseif randomResult <= 7
  then
    caster:SendLocalizeString("The Skull of Ograrand Says: Time reveals all.",
      SystemData.ChatLogFilters.SystemData.ChatLogFilters_EMOTE, Localized_text.CHAT_TAG_DEFAULT)
  elseif randomResult <= 8
  then
    caster:SendLocalizeString("The Skull of Ograrand Says: If you seek truth, stop living a lie.",
      SystemData.ChatLogFilters.SystemData.ChatLogFilters_EMOTE, Localized_text.CHAT_TAG_DEFAULT)
  elseif randomResult <= 9
  then
    caster:SendLocalizeString(
    "The Skull of Ograrand Says: The Architect of Fates has already set your path upon this course.",
      SystemData.ChatLogFilters.SystemData.ChatLogFilters_EMOTE, Localized_text.CHAT_TAG_DEFAULT)
  elseif randomResult <= 10
  then
    caster:SendLocalizeString("The Skull of Ograrand Says: The Lord of Change gifts such knowledge only to the worthy.",
      SystemData.ChatLogFilters.SystemData.ChatLogFilters_EMOTE, Localized_text.CHAT_TAG_DEFAULT)
  elseif randomResult <= 11
  then
    caster:SendLocalizeString("The Skull of Ograrand Says: The Raven God will answer you through his messengers.",
      SystemData.ChatLogFilters.SystemData.ChatLogFilters_EMOTE, Localized_text.CHAT_TAG_DEFAULT)
  elseif randomResult <= 12
  then
    caster:SendLocalizeString("The Skull of Ograrand Says: The Great Conspirator wills it to be thus.",
      SystemData.ChatLogFilters.SystemData.ChatLogFilters_EMOTE, Localized_text.CHAT_TAG_DEFAULT)
  end
end

RegisterServerCommandScript(36, 43264, ServerCommandTrigger.Start, OnServerCommand)
