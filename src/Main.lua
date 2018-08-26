-- -----------------------------------------------------------------------------
-- Full Moon
-- Author:  g4rr3t
-- Created: Aug 23, 2018
--
-- Main.lua
-- -----------------------------------------------------------------------------
MOON            = {}
MOON.name       = "FullMoon"
MOON.version    = "1.0.1"
MOON.dbVersion  = 1
MOON.slash      = "/moon"
MOON.prefix     = "[moon] "
MOON.HUDHidden  = false
MOON.ForceShow  = false
MOON.onCooldown = false
MOON.onProc     = false
MOON.isInCombat = false

-- -----------------------------------------------------------------------------
-- Level of debug output
-- 1: Low    - Basic debug info, show core functionality
-- 2: Medium - More information about skills and addon details
-- 3: High   - Everything
MOON.debugMode = 0
-- -----------------------------------------------------------------------------

function MOON:Trace(debugLevel, ...)
    if debugLevel <= MOON.debugMode then
        d(MOON.prefix .. ...)
    end
end

-- -----------------------------------------------------------------------------
-- Startup
-- -----------------------------------------------------------------------------

function MOON.Initialize(event, addonName)
    if addonName ~= MOON.name then return end

    MOON:Trace(1, "Full Moon Loaded")
    EVENT_MANAGER:UnregisterForEvent(MOON.name, EVENT_ADD_ON_LOADED)

    MOON.preferences = ZO_SavedVars:NewAccountWide("FullMoonVariables", MOON.dbVersion, nil, MOON:GetDefaults())

    -- Use saved debugMode value if the above value has not been changed
    if MOON.debugMode == 0 then
        MOON.debugMode = MOON.preferences.debugMode
        MOON:Trace(1, "Setting debug value to saved: " .. MOON.preferences.debugMode)
    end

    SLASH_COMMANDS[MOON.slash] = MOON.SlashCommand

    MOON:InitSettings()
    MOON.DrawUI()
    MOON.ToggleHUD()
    MOON.RegisterEvents()

    MOON:Trace(2, "Finished Initialize()")
end

-- -----------------------------------------------------------------------------
-- Event Hooks
-- -----------------------------------------------------------------------------

EVENT_MANAGER:RegisterForEvent(MOON.name, EVENT_ADD_ON_LOADED, function(...) MOON.Initialize(...) end)

