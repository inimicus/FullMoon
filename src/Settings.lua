-- -----------------------------------------------------------------------------
-- Full Moon
-- Author:  g4rr3t
-- Created: Aug 23, 2018
--
-- Settings.lua
-- -----------------------------------------------------------------------------

local LAM = LibStub("LibAddonMenu-2.0")

local panelData = {
    type        = "panel",
    name        = "Full Moon",
    displayName = "Full Moon",
    author      = "g4rr3t",
    version     = MOON.version,
    registerForRefresh  = true,
}

local optionsTable = {
    [1] = {
        type = "header",
        name = "Positioning",
        width = "full",
    },
    [2] = {
        type = "button",
        name = function() if MOON.preferences.unlocked then return "Lock" else return "Unlock" end end,
        tooltip = "Toggle lock/unlock state of counter display for repositioning.",
        func = function(control) ToggleLocked(control) end,
        width = "half",
    },
    [3] = {
        type = "button",
        name = function() if MOON.ForceShow then return "Hide" else return "Show" end end,
        tooltip = "Force show for position or previewing display settings.",
        func = function(control) ForceShow(control) end,
        width = "half",
    },
    [4] = {
        type = "header",
        name = "Display",
        width = "full",
    },
    [5] = {
        type = "slider",
        name = "Size",
        tooltip = "Display size of counter.",
        min = 32,
        max = 512,
        step = 5,
        getFunc = function() return GetSize() end,
        setFunc = function(value) SetSize(value) end,
        width = "full",
        default = 40,
    },
    [6] = {
        type = "checkbox",
        name = "Hide Out of Combat",
        tooltip = "Only show display while in combat, otherwise hide display",
        getFunc = function() return GetHideOutOfCombat() end,
        setFunc = function(value) SetHideOutOfCombat(value) end,
        width = "full",
    },
}

-- -----------------------------------------------------------------------------
-- Helper functions to set/get settings
-- -----------------------------------------------------------------------------

-- Locked State
function ToggleLocked(control)
    MOON.preferences.unlocked = not MOON.preferences.unlocked
    MOON.Container:SetMovable(MOON.preferences.unlocked)
    if MOON.preferences.unlocked then
        control:SetText("Lock")
    else
        control:SetText("Unlock")
    end
end

-- Force Showing
function ForceShow(control)
    MOON.ForceShow = not MOON.ForceShow
    if MOON.ForceShow then
        control:SetText("Hide")
        MOON.HUDHidden = false
        MOON.Container:SetHidden(false)
        MOON.UpdateStacks(5)
    else
        control:SetText("Show")
        MOON.HUDHidden = true
        MOON.Container:SetHidden(true)
        MOON.UpdateStacks(0)
    end
end

-- Sizing
function SetSize(value)
    MOON.preferences.size = value
    MOON.Container:SetDimensions(value, value)
    MOON.Texture:SetDimensions(value, value)
    MOON.SetFontSize(value)
end

function GetSize()
    return MOON.preferences.size
end

-- Show In Combat
function SetHideOutOfCombat(value)
    MOON.preferences.hideOOC = value

    if value then
        MOON.RegisterCombatEvent()
    else
        MOON.UnregisterCombatEvent()
    end

end

function GetHideOutOfCombat()
    return MOON.preferences.hideOOC
end

-- -----------------------------------------------------------------------------
-- Initialize Settings
-- -----------------------------------------------------------------------------

function MOON:InitSettings()
    LAM:RegisterAddonPanel(MOON.name, panelData)
    LAM:RegisterOptionControls(MOON.name, optionsTable)

    MOON:Trace(2, "Finished InitSettings()")
end

