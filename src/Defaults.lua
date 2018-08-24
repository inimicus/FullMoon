-- -----------------------------------------------------------------------------
-- Full Moon
-- Author:  g4rr3t
-- Created: Aug 23, 2018
--
-- Defaults.lua
-- -----------------------------------------------------------------------------

local defaults = {
    debugMode = 0,
    showEmptyStacks = false,
    positionLeft = 800,
    positionTop = 600,
    size = 100,
    unlocked = true,
}

function MOON:GetDefaults()
    return defaults
end
