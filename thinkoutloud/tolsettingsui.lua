-- vim:ts=4:sw=4:sts=4:et:
TOLSettingsUI = {}

-- errrmm. WTB better organisation.
local OUTER_WINDOW = "TOLSettingsMainWindow"
local MAIN_WINDOW = "TOLSettingsWindow"
local CB_EVENT = MAIN_WINDOW.."EventComboBox"
local CB_SKILL = MAIN_WINDOW.."SkillComboBox"
local CB_PHRASE = MAIN_WINDOW.."PhraseComboBox"
local EDIT_SKILL = MAIN_WINDOW.."SkillEditWindow"
local EDIT_SKILL_NAME_EDIT = EDIT_SKILL.."SkillNameEdit"
local EDIT_SKILL_SPEAK_COMBO = EDIT_SKILL.."SkillSpeakChanceComboBox"
local EDIT_SKILL_URGENT_COMBO = EDIT_SKILL.."SkillIsUrgentComboBox"
local EDIT_PHRASE = MAIN_WINDOW.."PhraseEditWindow"
local EDIT_PHRASE_TEXT_EDIT = EDIT_PHRASE.."PhraseTextEdit"
local EDIT_PHRASE_CHANNEL_COMBO = EDIT_PHRASE.."PhraseChannelComboBox"
local EDIT_PHRASE_SAYSELF_COMBO = EDIT_PHRASE.."PhraseSayselfComboBox"


-- ComboBoxGetSelectedText is broken (for anything beyond the 10th item)
-- so store ordered lists of the data.
-- TODO should probably make this more sane, and give comboboxes the ability
-- to store their text and separate data associated with each index.
-- But this is what I get when I code for ages and become slightly manic.
local CBDATA = {
    comboBoxes = {}
}

CBDATA.GetSelectedText = function(cb)
    local index = ComboBoxGetSelectedMenuItem(cb)
    return CBDATA.comboBoxes[cb][index]
end

CBDATA.AddMenuItem = function(cb, item)
    ComboBoxAddMenuItem(cb, item)
    if not CBDATA.comboBoxes[cb] then
        CBDATA.comboBoxes[cb] = {}
    end
    table.insert(CBDATA.comboBoxes[cb], item)
end

CBDATA.ClearMenuItems = function(cb)
    CBDATA.comboBoxes[cb] = {}
    ComboBoxClearMenuItems(cb)
end


local CBDATA_EVENT = {}
local CBDATA_SKILL = {}
local CBDATA_PHRASE = {}
local CBDATA_SKILL_SPEAK = {}
local CBDATA_SKILL_URGENT = {}
local CBDATA_PHRASE_CHANNEL = {}
local CBDATA_PHRASE_SAYSELF = {}


local function SetupEventEditWindow(index)
    WindowSetShowing(EDIT_SKILL, false)
    WindowSetShowing(EDIT_PHRASE, false)
end


local function PopulateSkillFields(skill)
    TextEditBoxSetText(EDIT_SKILL.."SkillNameEdit", skill.name)
    local speakChanceIndex
    if nil == skill.speakChance then
        speakChanceIndex = 1
    else
        -- this is kinda stupid.
        local sc = skill.speakChance * 100
        if sc <= 20 then
            speakChanceIndex = sc + 2
        else
            speakChanceIndex = math.modf( (sc - 20) / 5) + 22
        end
    end
    ComboBoxSetSelectedMenuItem(EDIT_SKILL_SPEAK_COMBO, speakChanceIndex)

    if not skill.isUrgent then
        ComboBoxSetSelectedMenuItem(EDIT_SKILL_URGENT_COMBO, 1)
    else
        ComboBoxSetSelectedMenuItem(EDIT_SKILL_URGENT_COMBO, 2)
    end
end


local function PopulatePhraseFields(phrase)
    TextEditBoxSetText(EDIT_PHRASE.."PhraseTextEdit", phrase.text)
    ComboBoxSetSelectedMenuItem(EDIT_PHRASE_CHANNEL_COMBO, phrase.channel)
    if not phrase.sayself then
        ComboBoxSetSelectedMenuItem(EDIT_PHRASE_SAYSELF_COMBO, 1)
    else
        ComboBoxSetSelectedMenuItem(EDIT_PHRASE_SAYSELF_COMBO, 2)
    end
end


local function SetupSkillEditWindow(index)
    WindowSetShowing(EDIT_SKILL, true)
    WindowSetShowing(EDIT_PHRASE, false)
    local skillName = CBDATA.GetSelectedText(CB_SKILL)
    local speakChanceIndex
    local skill

    if 1 == index then
        -- New skill
        LabelSetText(EDIT_SKILL.."TitleLabel", L"Add New Skill")
        WindowSetShowing(EDIT_SKILL.."EditPhrasesButton", false)
        WindowSetShowing(EDIT_SKILL.."DeleteButton", false)
        skill = TOLSkill.new(L"")
    else
        -- Editing existing skill
        LabelSetText(EDIT_SKILL.."TitleLabel", L"Edit Skill")
        WindowSetShowing(EDIT_SKILL.."EditPhrasesButton", true)
        WindowSetShowing(EDIT_SKILL.."DeleteButton", true)
        skill = ThinkOutLoud.Settings.skills[skillName]
    end
    PopulateSkillFields(skill)
end


local function SetupPhraseEditWindow(index)
    WindowSetShowing(EDIT_SKILL, false)
    WindowSetShowing(EDIT_PHRASE, true)
    local phrase, skill
    local skillName = CBDATA.GetSelectedText(CB_SKILL)
    skill = ThinkOutLoud.Settings.skills[skillName]
    if 1 == index then
        -- New phrase
        LabelSetText(EDIT_PHRASE.."TitleLabel", L"Add New Phrase")
        WindowSetShowing(EDIT_PHRASE.."DeleteButton", false)
        phrase = {text=L"", channel=ThinkOutLoud.CMD_SAY, sayself="true"}
    else
        -- Editing existing phrase
        LabelSetText(EDIT_PHRASE.."TitleLabel", L"Edit Phrase")
        WindowSetShowing(EDIT_PHRASE.."DeleteButton", true)
        phrase = skill.phrases[index-1]
    end
    PopulatePhraseFields(phrase)
end


function TOLSettingsUI.Initialize()
    CreateWindow(OUTER_WINDOW, false)
    --[[
    LayoutEditor.RegisterWindow(
        OUTER_WINDOW,
        L"ThinkOutLoud Settings",
        L"ThinkOutLoud Settings",
        false, false,
        true, nil
    )
    --]]

    LabelSetText(OUTER_WINDOW.."TitleBarText", L"ThinkOutLoud Config")

    -- set up skill edit window
    ButtonSetText(EDIT_SKILL.."EditPhrasesButton", L"Edit Phrases")
    ButtonSetText(EDIT_SKILL.."DeleteButton", L"Delete")
    ButtonSetText(EDIT_SKILL.."SaveButton", L"Save")
    LabelSetText(EDIT_SKILL.."SkillNameLabel", L"Skill Name")
    LabelSetText(EDIT_SKILL.."SkillSpeakChanceLabel",
                    L"Speak Chance")
    CBDATA.AddMenuItem(EDIT_SKILL_SPEAK_COMBO, L"USE DEFAULT")
    -- If you change this, also change PopulateSkillFields so it gets
    -- the correct index. Or just make the code non-stupid.
    for i=0,20,1 do
        CBDATA.AddMenuItem(EDIT_SKILL_SPEAK_COMBO, L""..i..L"%")
    end
    for i=25,100,5 do
        CBDATA.AddMenuItem(EDIT_SKILL_SPEAK_COMBO, L""..i..L"%")
    end
    ComboBoxSetSelectedMenuItem(EDIT_SKILL_SPEAK_COMBO, 1)
    LabelSetText(EDIT_SKILL.."SkillIsUrgentLabel", L"Is Urgent (ignore throttle)?")
    CBDATA.AddMenuItem(EDIT_SKILL_URGENT_COMBO, L"No")
    CBDATA.AddMenuItem(EDIT_SKILL_URGENT_COMBO, L"Yes")

    -- set up phrase edit window
    ButtonSetText(EDIT_PHRASE.."DeleteButton", L"Delete")
    ButtonSetText(EDIT_PHRASE.."SaveButton", L"Save")
    LabelSetText(EDIT_PHRASE.."PhraseTextLabel", L"Text to be spoken.")
    LabelSetText(EDIT_PHRASE.."PhraseChannelLabel",
            L"Chat Channel")
    LabelSetText(EDIT_PHRASE.."PhraseSayselfLabel",
            L"Speak if I am the friendly target?")
    for _, channel in ipairs(ThinkOutLoud.CHANNELS) do
        CBDATA.AddMenuItem(EDIT_PHRASE_CHANNEL_COMBO, towstring(channel))
    end
LabelSetText(EDIT_PHRASE.."PhraseInstructionLabel",
    L"%T - Hostile Target\n"
    .. L"%P - Hostile Target Class\n"
    .. L"%E - Hostile Target Class Icon\n"
    .. L"%F - Friendly Target\n"
    .. L"%C - Friendly Class\n"
    .. L"%I - Friendly Class Icon")

    CBDATA.AddMenuItem(EDIT_PHRASE_SAYSELF_COMBO, L"No")
    CBDATA.AddMenuItem(EDIT_PHRASE_SAYSELF_COMBO, L"Yes")

    -- set up starting state
    CBDATA.AddMenuItem(CB_EVENT, L"--SELECT EVENT--")
    for index, data in ipairs(ThinkOutLoud.USER_EVENTS) do
        CBDATA.AddMenuItem(CB_EVENT, data)
    end
    ComboBoxSetSelectedMenuItem(CB_EVENT, 1)
    -- doesn't seem to fire the event when called programmatically?
    TOLSettingsUI.OnEventSelChanged(1)
end


function TOLSettingsUI.Shutdown()
end


function TOLSettingsUI.SetShowing(show)
    WindowSetShowing(OUTER_WINDOW, show)
end


function TOLSettingsUI.ToggleShowing()
    WindowSetShowing(OUTER_WINDOW, WindowGetShowing(OUTER_WINDOW))
end


function TOLSettingsUI.OnEventSelChanged(index)
    if 0 == index then return end
    
    SetupEventEditWindow(index)
    if 1 == index then
        WindowSetShowing(CB_SKILL, false)
        WindowSetShowing(CB_PHRASE, false)
        return
    end
    CBDATA.ClearMenuItems(CB_SKILL)
    CBDATA_SKILL = {}
    CBDATA.AddMenuItem(CB_SKILL, L"--SELECT SKILL--")
    for skillName,v in pairs(ThinkOutLoud.Settings.skills) do
        CBDATA.AddMenuItem(CB_SKILL, skillName)
    end
    ComboBoxSetSelectedMenuItem(CB_SKILL, 1)
    TOLSettingsUI.OnSkillSelChanged(1)
    WindowSetShowing(CB_SKILL, true)
end


function TOLSettingsUI.OnSkillSelChanged(index)
    if 0 == index then return end

    WindowSetShowing(CB_PHRASE, false)
    SetupSkillEditWindow(index)
end


function TOLSettingsUI.OnPhraseSelChanged(index)
    if 0 == index then return end

    SetupPhraseEditWindow(index)
end


-- We've been editing a skill, and decided to start editing the phrases.
-- so show and set up the phrase combo box.
function TOLSettingsUI.BeginEditPhrases()
    CBDATA.ClearMenuItems(CB_PHRASE)
    CBDATA.AddMenuItem(CB_PHRASE, L"--SELECT PHRASE--")
    local name = TextEditBoxGetText(EDIT_SKILL_NAME_EDIT)
    local skill = ThinkOutLoud.Settings.skills[name]
    for k,v in pairs(skill.phrases) do
        CBDATA.AddMenuItem(CB_PHRASE, v.text)
    end
    ComboBoxSetSelectedMenuItem(CB_PHRASE, 1)
    TOLSettingsUI.OnPhraseSelChanged(1)
    WindowSetShowing(CB_PHRASE, true)
end


function TOLSettingsUI.SkillSaveLButtonUp()
    local name, isUrgent, speakChance, skill
    name = TextEditBoxGetText(EDIT_SKILL_NAME_EDIT)
    if 1 == ComboBoxGetSelectedMenuItem(EDIT_SKILL_URGENT_COMBO) then
        isUrgent = false
    else
        isUrgent = true
    end
    local sc = CBDATA.GetSelectedText(EDIT_SKILL_SPEAK_COMBO)
    if L"USE DEFAULT" == sc then
        speakChance = nil
    else
        speakChance = tonumber(sc:match(L"[0-9]+")) / 100
    end
    if ThinkOutLoud.Settings.skills[name] then
        skill = ThinkOutLoud.Settings.skills[name]
        skill.name = name
        skill.isUrgent = isUrgent
        skill.speakChance = speakChance
    else
        skill = TOLSkill.new(name, isUrgent, speakChance)
    end
    ThinkOutLoud.Settings.skills[name] = skill
    ThinkOutLoud.isDefault = false
    -- XXX repeated code - refresh skill selection
    TOLSettingsUI.OnEventSelChanged(ComboBoxGetSelectedMenuItem(CB_EVENT))
end


function TOLSettingsUI.SkillDeleteLButtonUp()
    local name = TextEditBoxGetText(EDIT_SKILL_NAME_EDIT)
    ThinkOutLoud.Settings.skills[name] = nil
    ThinkOutLoud.isDefault = false

    -- XXX repeated code
    TOLSettingsUI.OnEventSelChanged(ComboBoxGetSelectedMenuItem(CB_EVENT))
end


local function GetCurrentSkill()
    local skillName = CBDATA.GetSelectedText(CB_SKILL)
    return ThinkOutLoud.Settings.skills[skillName]
end


function TOLSettingsUI.PhraseSaveLButtonUp()
    local skill, phraseIndex, text, channel, sayself, phrase
    skill = GetCurrentSkill()
    phraseIndex = ComboBoxGetSelectedMenuItem(CB_PHRASE)
    text = TextEditBoxGetText(EDIT_PHRASE_TEXT_EDIT)
    channel = ComboBoxGetSelectedMenuItem(EDIT_PHRASE_CHANNEL_COMBO)
    sayself = ComboBoxGetSelectedMenuItem(EDIT_PHRASE_SAYSELF_COMBO)
    if 1 ~= phraseIndex then
        skill:removePhrase(phraseIndex - 1)
    end
    if 1 == sayself then
        sayself = false
    else
        sayself = true
    end
    local phrase = {
        text = text,
        channel = channel,
        sayself = sayself,
    }
    skill:insertPhrase(phrase)
    ThinkOutLoud.isDefault = false

    TOLSettingsUI.BeginEditPhrases()
end


function TOLSettingsUI.PhraseDeleteLButtonUp()
    local skill = GetCurrentSkill()
    local phraseIndex = ComboBoxGetSelectedMenuItem(CB_PHRASE) - 1
    skill.phrases[phraseIndex] = nil
    ThinkOutLoud.isDefault = false

    TOLSettingsUI.BeginEditPhrases()
end


function TOLSettingsUI.CloseLButtonUp()
    TOLSettingsUI.SetShowing(false)
end
