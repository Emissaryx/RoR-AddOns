-- vim:ts=4:sw=4:sts=4:et:
local tinsert = table.insert
local tremove = table.remove

TOLSkill = {}
TOLSkill.__index = TOLSkill

function TOLSkill.new(name, isUrgent, speakChance)
    local newSkill = {}
    setmetatable(newSkill, TOLSkill)
    if "string" == type(name) then
        name = StringToWString(name)
    end
    newSkill.name = name
    newSkill.isUrgent = isUrgent or false
    newSkill.speakChance = speakChance
    newSkill.phrases = {}
    newSkill.tagSets = {}
    for ch,chtxt in pairs(ThinkOutLoud.CHANNELS) do
        newSkill.tagSets[chtxt] = TOLSet.new()
    end
    -- special set to Intersect against for SAYSELF checking.
    newSkill.tagSets["SAYSELF"] = TOLSet.new()
    return newSkill
end


-- return the TOLSkill as a simple table that matches the format
-- as used in the config file (for storing in the SavedVariables file)
function TOLSkill:save()
    local ret = {}
    ret.name = self.name
    ret.isUrgent = self.isUrgent
    ret.speakChance = self.speakChance
    ret.phrases = {}
    for _,p in pairs(self.phrases) do
        tinsert(ret.phrases, p)
    end
    return ret
end


function TOLSkill:insertPhrase(phrase, pos)
    -- TODO sanity checking. Unless we do it elsewhere.
    tinsert(self.phrases, phrase)
    local pos = #self.phrases
    local ch = ThinkOutLoud.CHANNELS[phrase.channel]
    self.tagSets[ch]:add(pos)
    -- default sayself to true. This was poorly thought out.
    if phrase.sayself == nil then phrase.sayself = true end
    if phrase.sayself then
        self.tagSets["SAYSELF"]:add(pos)
    end
end


function TOLSkill:removePhrase(pos)
    if nil == pos then pos = #self.phrases end
    tremove(self.phrases, pos)
    for _,tagset in pairs(self.tagSets) do
        tagset:remove(pos)
    end
end


function TOLSkill:randomPhrase(tags, isTargettingSelf)
    -- first grab phrases for all valid channels.
    local validPhrases = TOLSet.new()
    for tag in pairs(tags) do
        validPhrases = validPhrases:union(self.tagSets[tag])
    end

    -- now intersect against sayself
    if isTargettingSelf then
        validPhrases = validPhrases:intersection(self.tagSets["SAYSELF"])
    end

    validPhrases = validPhrases:toList()
    -- and pick a random phrase from the resultant set.
    if 0 == #validPhrases then return end
    local randIndex = math.ceil(math.random() * #validPhrases)
    randIndex = validPhrases[randIndex]
    return self.phrases[randIndex]
end
