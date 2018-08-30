-- -----------------------------------------------------------------------------
-- Full Moon
-- Author:  g4rr3t
-- Created: Aug 23, 2018
--
-- Tracking.lua
-- -----------------------------------------------------------------------------

local BLOOD_SCENT_ID = 111387
local FRENZIED_ID = 111386
local updateIntervalMs = 100

MOON.timeOfProc = 0
MOON.procDurationMs = 5000
MOON.cooldownDurationMs = 18000

function MOON.RegisterEvents()

    -- Blood Scent
    EVENT_MANAGER:RegisterForEvent(MOON.name .. "BLOOD_SCENT", EVENT_EFFECT_CHANGED, function(...) MOON.OnEffectChanged(...) end)
    EVENT_MANAGER:AddFilterForEvent(MOON.name .. "BLOOD_SCENT", EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_ABILITY_ID, BLOOD_SCENT_ID,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    -- Frenzied
    EVENT_MANAGER:RegisterForEvent(MOON.name .. "FRENZIED", EVENT_EFFECT_CHANGED, function(...) MOON.OnEffectChanged(...) end)
    EVENT_MANAGER:AddFilterForEvent(MOON.name .. "FRENZIED", EVENT_EFFECT_CHANGED,
        REGISTER_FILTER_ABILITY_ID, FRENZIED_ID,
        REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, COMBAT_UNIT_TYPE_PLAYER)

    -- Combat State
    if MOON.preferences.hideOOC then
        MOON.RegisterCombatEvent()
    end

end

function MOON.UnregisterEvents()
    EVENT_MANAGER:UnregisterForEvent(MOON.name .. "BLOOD_SCENT", EVENT_EFFECT_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(MOON.name .. "FRENZIED", EVENT_EFFECT_CHANGED)

    if MOON.preferences.showOOC then
        MOON.UnregisterCombatEvent()
    end
end

function MOON.RegisterCombatEvent()
    EVENT_MANAGER:RegisterForEvent(name, EVENT_PLAYER_COMBAT_STATE, function(...) MOON.IsInCombat(...) end)
end

function MOON.UnregisterCombatEvent()
    EVENT_MANAGER:UnregisterForEvent(MOON.name, EVENT_PLAYER_COMBAT_STATE)
end

function MOON.IsInCombat(_, inCombat)
    MOON.isInCombat = inCombat

    if inCombat then
        MOON:Trace(2, "Entered Combat")
        MOON.HUDHidden = false
        MOON.Container:SetHidden(false)
    else
        MOON:Trace(2, "Left Combat")
        MOON.HUDHidden = true
        MOON.Container:SetHidden(true)
    end

end

function MOON.OnEffectChanged(_, changeType, _, effectName, unitTag, _, _,
        stackCount, _, _, _, _, _, _, _, effectAbilityId)

    MOON:Trace(3, effectName .. " (" .. effectAbilityId .. ")")

    -- If Blood Scent Stack
    if effectAbilityId == BLOOD_SCENT_ID then

        MOON:Trace(2, zo_strformat("Stack #<<1>> for Ability ID: <<2>>", stackCount, effectAbilityId))

        -- Set to zero if stacks faded
        if changeType == EFFECT_RESULT_FADED then
            MOON.UpdateStacks(0)
        else
            MOON.UpdateStacks(stackCount)
        end

    end

    -- If Frenzied
    if effectAbilityId == FRENZIED_ID then
        if changeType == EFFECT_RESULT_GAINED then
            MOON:Trace(2, "Frenzied!")
            MOON.timeOfProc = GetGameTimeMilliseconds()
            MOON.onCooldown = true
            MOON.Frenzied(true)
            MOON.Update() -- Manually call first update
            EVENT_MANAGER:RegisterForUpdate(MOON.name .. "FRENZIED", updateIntervalMs, MOON.Update)
            return
        end

        if changeType == EFFECT_RESULT_FADED then
            MOON:Trace(2, "No longer Frenzied!")
            MOON.Frenzied(false)
            MOON.Update() -- Manually call update to keep sync
            return
        end
    end

end
