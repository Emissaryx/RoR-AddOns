-- ============================================================================
-- ActionBarColor
-- Simple visual feedback for action bar and morale buttons
-- ============================================================================

ActionBarColor = ActionBarColor or {}

local oldActionButtonUpdateEnabledState
local oldMoraleButtonUpdate

-- ----------------------------------------------------------------------------
-- Tint helper
-- ----------------------------------------------------------------------------
local function TintIcon(button, iconIndex, r, g, b)
    local windows = button.m_Windows
    if not windows then return end

    local icon = windows[iconIndex]
    if icon and icon.SetTintColor then
        icon:SetTintColor(r, g, b)
    end
end

-- ----------------------------------------------------------------------------
-- Initialization / hooks
-- ----------------------------------------------------------------------------
function ActionBarColor.Initialize()
    if ActionBarColor.__hooked then
        return
    end

    --------------------------------------------------------------------------
    -- Action buttons
    --------------------------------------------------------------------------
    oldActionButtonUpdateEnabledState = ActionButton.UpdateEnabledState
    ActionButton.UpdateEnabledState = function(self, ...)
        -- Let the engine do all real logic first
        oldActionButtonUpdateEnabledState(self, ...)

        -- Icon index is template-dependent
        local ICON_INDEX = 0

        if self.m_IsEnabled and self.m_IsTargetValid then
            -- Usable, valid target
            TintIcon(self, ICON_INDEX, 255, 255, 255)
        elseif self.m_IsEnabled then
            -- Usable, invalid target
            TintIcon(self, ICON_INDEX, 200, 0, 0)
        else
            -- Disabled
            TintIcon(self, ICON_INDEX, 125, 125, 125)
        end
    end

    --------------------------------------------------------------------------
    -- Morale buttons
    --------------------------------------------------------------------------
    oldMoraleButtonUpdate = MoraleButton.Update
    MoraleButton.Update = function(self, ...)
        oldMoraleButtonUpdate(self, ...)

        -- Morale buttons use a different icon index
        local ICON_INDEX = 2

        if self.m_AbilityId and self.m_AbilityId > 0 then
            if self.m_IsTargetValid then
                TintIcon(self, ICON_INDEX, 255, 255, 255)
            else
                TintIcon(self, ICON_INDEX, 255, 0, 0)
            end
        end
    end

    ActionBarColor.__hooked = true
end
