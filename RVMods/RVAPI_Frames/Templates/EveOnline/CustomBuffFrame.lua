CustomBuffFrame = setmetatable ({}, BuffFrame)
CustomBuffFrame.__index       = CustomBuffFrame

function CustomBuffFrame:Create( windowName, windowTemplate, parentWindow, buffSlot, buffTargetType, showTimerLabels )

    self.m_Template = windowTemplate

    local buffFrame = self:CreateFromTemplate( windowName, parentWindow )

    if ( buffFrame ~= nil )
    then
        buffFrame.m_buffSlot            = buffSlot          -- Window slot number
        buffFrame.m_buffData            = nil               -- Buff data
        buffFrame.m_buffTargetType      = buffTargetType
        buffFrame.m_lastDurationUpdate  = 0
        buffFrame.m_IsFading            = false

        buffFrame:ShowBuffTimerLabel( showTimerLabels )
    end

    return buffFrame
end

CustomBuffTracker = setmetatable ({}, BuffTracker)
CustomBuffTracker.__index       = CustomBuffTracker

function CustomBuffTracker:Create( windowName, windowTemplate, parentName, initialAnchor, buffTargetType, maxBuffCount, buffRowStride, showTimerLabels )
    local newTracker =
    {
        m_buffData      = {},               -- Contains buff/effect data. Indexed by server effect id.
        m_buffMapping   = {},               -- Contains window id -> buff id mapping.
        m_targetType    = buffTargetType,   -- How this tracker knows which unit to query for buff/effects information...
        m_maxBuffs      = maxBuffCount,     -- How many windows this bufftracker creates...
        m_buffFrames    = {},
        m_buffRowStride = buffRowStride,    -- Number of buffs per row
    }

    local currentAnchor = initialAnchor

    for buffSlot = 1, maxBuffCount
    do
        local buffFrameName = windowName..buffSlot
        local buffFrame     = CustomBuffFrame:Create( buffFrameName, windowTemplate, parentName, buffSlot, buffTargetType, showTimerLabels )

        if ( buffFrame ~= nil )
        then
            newTracker.m_buffFrames[ buffSlot ] = buffFrame

            buffFrame:SetAnchor( currentAnchor )

            local nextSlot  = buffSlot + 1
            local remainder = math.fmod( nextSlot, buffRowStride )

            if ( remainder == 1 )
            then
                currentAnchor.Point             = "bottomleft"
                currentAnchor.RelativePoint     = "topleft"
                currentAnchor.RelativeTo        = windowName..( nextSlot - buffRowStride )
                currentAnchor.XOffset           = 0
                currentAnchor.YOffset           = 24 -- vertical buff spacing between rows...parameterize?
            else
                currentAnchor.Point             = "right"
                currentAnchor.RelativePoint     = "left"
                currentAnchor.RelativeTo        = windowName..buffSlot
                currentAnchor.XOffset           = 2 -- horizontal buff spacing between columns...parameterize?
                currentAnchor.YOffset           = 0
            end
        end
    end

    newTracker = setmetatable( newTracker, self )
    newTracker.__index = self

    -- Load all buffs now.
    -- TODO: commented ou as it currently defective and does not work
--    newTracker:Refresh()

    return newTracker
end