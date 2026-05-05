local function OnServerCommand(caster, target, parameter)

    local randomResult = math.random(14);

    if randomResult <= 1
    then
        caster:SendLocalizeString("The Creepy Doll whispers: Try \'n tickle me again and I\'ll bite yer finger.", SystemData.ChatLogFilters.CHATLOGFILTERS_EMOTE, Localized_text.CHAT_TAG_DEFAULT)
    elseif randomResult <= 2
    then
        caster:SendLocalizeString("The Creepy Doll whispers: Lemme outta yer pocket!", SystemData.ChatLogFilters.CHATLOGFILTERS_EMOTE, Localized_text.CHAT_TAG_DEFAULT)
    elseif randomResult <= 3
    then
        caster:SendLocalizeString("The Creepy Doll whispers: Give in to Da Green…", SystemData.ChatLogFilters.CHATLOGFILTERS_EMOTE, Localized_text.CHAT_TAG_DEFAULT)
    elseif randomResult <= 4
    then
        caster:SendLocalizeString("The Creepy Doll whispers: Quit runnin\' from da fight maggot!", SystemData.ChatLogFilters.CHATLOGFILTERS_EMOTE, Localized_text.CHAT_TAG_DEFAULT)
    elseif randomResult <= 5
    then
        caster:SendLocalizeString("The Creepy Doll whispers: Wait'll I tell everyone wut ya just sed!", SystemData.ChatLogFilters.CHATLOGFILTERS_EMOTE, Localized_text.CHAT_TAG_DEFAULT)
    elseif randomResult <= 6
    then
        caster:SendLocalizeString("The Creepy Doll whispers: I can \'ear yer thoughts… ain\'t much goin\' on in dere!", SystemData.ChatLogFilters.CHATLOGFILTERS_EMOTE, Localized_text.CHAT_TAG_DEFAULT)
    elseif randomResult <= 7
    then
        caster:SendLocalizeString("The Creepy Doll whispers: I\'s gunna lauf wen dey pummel ya into mush", SystemData.ChatLogFilters.CHATLOGFILTERS_EMOTE, Localized_text.CHAT_TAG_DEFAULT)
    elseif randomResult <= 8
    then
        caster:SendLocalizeString("The Creepy Doll whispers: It\'s WAAAGH! not waaah waaah waaah.", SystemData.ChatLogFilters.CHATLOGFILTERS_EMOTE, Localized_text.CHAT_TAG_DEFAULT)
    elseif randomResult <= 9
    then
        caster:SendLocalizeString("The Creepy Doll whispers: Gimme a stick, I\'z betta at stabbin\' den youse!", SystemData.ChatLogFilters.CHATLOGFILTERS_EMOTE, Localized_text.CHAT_TAG_DEFAULT)
    elseif randomResult <= 10
    then
        caster:SendLocalizeString("The Creepy Doll whispers: Tell me again who\'z da runt in dis relationship… go on…", SystemData.ChatLogFilters.CHATLOGFILTERS_EMOTE, Localized_text.CHAT_TAG_DEFAULT)
    elseif randomResult <= 11
    then
        caster:SendLocalizeString("The Creepy Doll whispers: Youse da \'un playin\' wif a doll!", SystemData.ChatLogFilters.CHATLOGFILTERS_EMOTE, Localized_text.CHAT_TAG_DEFAULT)
    elseif randomResult <= 12
    then
        caster:SendLocalizeString("The Creepy Doll whispers: I dun\'t care bout yer problems!", SystemData.ChatLogFilters.CHATLOGFILTERS_EMOTE, Localized_text.CHAT_TAG_DEFAULT)
    elseif randomResult <= 13
    then
        caster:SendLocalizeString("The Creepy Doll whispers: Wutcha fink da udda\'s will say wen dey see ya wif a doll?", SystemData.ChatLogFilters.CHATLOGFILTERS_EMOTE, Localized_text.CHAT_TAG_DEFAULT)
    elseif randomResult <= 14
    then
        caster:SendLocalizeString("The Creepy Doll whispers: Sleep well… heh heh heh… I\'ll keep an eye on ya.", SystemData.ChatLogFilters.CHATLOGFILTERS_EMOTE, Localized_text.CHAT_TAG_DEFAULT)
    end
end

RegisterServerCommandScript(36, 43265, ServerCommandTrigger.Start, OnServerCommand)