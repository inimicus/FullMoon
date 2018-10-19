-- -----------------------------------------------------------------------------
-- Full Moon
-- Author:  g4rr3t
-- Created: Oct 19, 2018
--
-- Equipped.lua
-- -----------------------------------------------------------------------------

MOON.Equipped = {}
Callback = nil
local filterBySetName = nil
local items = {}
local sets = {}

local ITEM_SLOTS = {
    EQUIP_SLOT_HEAD,
    EQUIP_SLOT_NECK,
    EQUIP_SLOT_CHEST,
    EQUIP_SLOT_SHOULDERS,
    EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_WAIST,
    EQUIP_SLOT_LEGS,
    EQUIP_SLOT_FEET,
    EQUIP_SLOT_RING1,
    EQUIP_SLOT_RING2,
    EQUIP_SLOT_HAND,
    EQUIP_SLOT_BACKUP_MAIN,
    EQUIP_SLOT_BACKUP_OFF,
}


local function GetNumSetBonuses(itemLink)
    -- 2H weapons, staves, bows count as two set pieces
    if GetItemLinkWeaponType(itemLink) == WEAPONTYPE_BOW
        or GetItemLinkWeaponType(itemLink) == WEAPONTYPE_FIRE_STAFF
        or GetItemLinkWeaponType(itemLink) == WEAPONTYPE_FROST_STAFF
        or GetItemLinkWeaponType(itemLink) == WEAPONTYPE_HEALING_STAFF
        or GetItemLinkWeaponType(itemLink) == WEAPONTYPE_LIGHTNING_STAFF
        or GetItemLinkWeaponType(itemLink) == WEAPONTYPE_TWO_HANDED_AXE
        or GetItemLinkWeaponType(itemLink) == WEAPONTYPE_TWO_HANDED_HAMMER
        or GetItemLinkWeaponType(itemLink) == WEAPONTYPE_TWO_HANDED_SWORD
    then
        return 2
    else
        return 1
    end
end

local function AddSetBonus(slot, itemLink)
    local hasSet, setName, _, _, maxEquipped = GetItemLinkSetInfo(itemLink, true)

    if hasSet and setName == filterBySetName then
        -- Initialize first time encountering a set
        if sets[setName] == nil then
            sets[setName] = {}
            sets[setName].maxBonus = maxEquipped
            sets[setName].bonuses = {}
        end

        -- Update bonuses
        sets[setName].bonuses[slot] = GetNumSetBonuses(itemLink)
    end
end

local function RemoveSetBonus(slot, itemLink)
    local hasSet, setName, _, _, _ = GetItemLinkSetInfo(itemLink, true)

    if hasSet and setName == filterBySetName then
        -- Don't remove bonus if bonus wasn't added to begin with
        if sets[setName] ~= nil and sets[setName].bonuses[slot] ~=nil then
            sets[setName].bonuses[slot] = 0
        end
    end
end

local function UpdateEnabledSets()
    for key, set in pairs(sets) do
        if set ~= nil then

            local totalBonus = 0
            for slot, bonus in pairs(set.bonuses) do
                totalBonus = totalBonus + bonus
            end

            if totalBonus >= set.maxBonus then
                if not set.equippedMax then
                    set.equippedMax = true
                    Callback(key, true)
                end
            else
                if set.equippedMax then
                    set.equippedMax = false
                    Callback(key, false)
                end
            end

        end
    end
end

local function UpdateSingleSlot(slotId, itemLink)
    local previousLink = items[slotId]

    -- Update equipped item
    items[slotId] = itemLink

    -- Item did not change
    if itemLink == previousLink then
        MOON:Trace(1, zo_strformat("Same item equipped: <<1>>", itemLink))
        return

    -- Item Removed (slot empty)
    elseif itemLink == '' then
        MOON:Trace(1, zo_strformat("Item unequipped: <<1>>", previousLink))
        RemoveSetBonus(slotId, previousLink)

    -- Item Changed
    else
        MOON:Trace(1, zo_strformat("New item equipped: <<1>>", itemLink))
        RemoveSetBonus(slotId, previousLink)
        AddSetBonus(slotId, itemLink)
    end

    UpdateEnabledSets()
end

local function WornSlotUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason)
    -- Ignore costume updates
    if slotId == EQUIP_SLOT_COSTUME then return end

    local itemLink = GetItemLink(bagId, slotId)
    UpdateSingleSlot(slotId, itemLink)
end

local function UpdateAllSlots()
    for index, slot in pairs(ITEM_SLOTS) do
        local itemLink = GetItemLink(BAG_WORN, slot)

        if itemLink ~= "" then
            items[slot] = itemLink
            AddSetBonus(slot, itemLink)
        end
    end

    UpdateEnabledSets()
end

function MOON.Equipped:FilterBySetName(setName)
    filterBySetName = setName
end

function MOON.Equipped:Register(callback)
    if callback == nil then
        -- Error
        d('[EquipmentBonus] Callback function required!')
        return
    end

    EVENT_MANAGER:RegisterForEvent(MOON.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, WornSlotUpdate)
    EVENT_MANAGER:AddFilterForEvent(MOON.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        REGISTER_FILTER_BAG_ID, BAG_WORN,
        REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)

    Callback = function(...) callback(...) end

    UpdateAllSlots()
end

