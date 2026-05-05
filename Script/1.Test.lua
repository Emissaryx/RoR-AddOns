local function OnInteract (creature, player)
    creature:Say('Stand back! Or I\'ll have you arrested!!! ' .. player.Name .. '!')
end

RegisterCreatureScript(843, CreatureScript.OnInteract, OnInteract)