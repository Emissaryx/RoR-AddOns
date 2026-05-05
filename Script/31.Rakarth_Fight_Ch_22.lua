--[[
-- Initialization of variables and states
local RakarthProtoId = 1000351
local NewRakarthProtoId = 2100001

-- Function to transform Rakarth
local function TransformRakarth(creature)
    local x, y, z, o = creature:GetLocation()
    local healthPercent = creature.HealthPercent

    creature:SendLocalizeString("Rakarth is transforming!", SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)

    -- Summon the new Rakarth at the same location with the same health percentage
    local newRakarth = creature:SummonCreature(NewRakarthProtoId, x, y, z, o, 0, 0)
    if newRakarth then
        newRakarth:SetHealthPercent(healthPercent)
    end

    -- Destroy the old Rakarth
    creature:Destroy()
end

-- Function called when the creature enters combat
local function RakarthOnEnterCombat(creature, attacker)
    creature:SetState("STAGE", 0)
    creature:SetState("NEXT_TRANSFORM_PERCENT", 90) -- Initial transform threshold
end

-- Function called when the creature receives damage
local function RakarthOnReceiveDamage(creature, attacker, damage)
    local currentStage = creature:GetState("STAGE")
    local healthPercent = creature.HealthPercent
    local nextTransformPercent = creature:GetState("NEXT_TRANSFORM_PERCENT")

    -- Debug message to check health
    creature:SendLocalizeString("Current Health: " .. healthPercent .. "%", SystemData.ChatLogFilters.CHATLOGFILTERS_C_WHITE_1, Localized_text.CHAT_TAG_DEFAULT)

    -- Transform Rakarth at exactly 90% health
    if currentStage == 0 and healthPercent <= 90 and healthPercent > 89 then
        creature:SetState("STAGE", 1) -- Ensure transformation happens only once
        TransformRakarth(creature)
    end
end

-- Function to reset the creature and cleanup when it leaves combat or dies
local function RakarthReset(creature)
    -- Add any necessary cleanup logic here
end

-- Function called when the creature dies
local function RakarthOnDie(creature, killer)
    RakarthReset(creature)
end

-- Register the creature's scripts for different events for Rakarth
RegisterCreatureScript(RakarthProtoId, CreatureScript.OnEnterCombat, RakarthOnEnterCombat)
RegisterCreatureScript(RakarthProtoId, CreatureScript.OnReceiveDamage, RakarthOnReceiveDamage)
RegisterCreatureScript(RakarthProtoId, CreatureScript.OnLeaveCombat, RakarthReset)
RegisterCreatureScript(RakarthProtoId, CreatureScript.OnDie, RakarthOnDie)
]]
