local EVENT_MANAGER = EVENT_MANAGER
local GetAbilityIcon = GetAbilityIcon
local GetActiveWeaponPairInfo = GetActiveWeaponPairInfo
local GetSlotBoundId = GetSlotBoundId
local GetSpecificSkillAbilityKeysByAbilityId = GetSpecificSkillAbilityKeysByAbilityId
local IsMounted = IsMounted
local SlotSkillAbilityInSlot = SlotSkillAbilityInSlot
local SOUNDS = SOUNDS

local x = {
    __index = _G
}

KeyInv = setmetatable(x, x)
KeyInv.KeyInv = KeyInv
setfenv(1, KeyInv)

local name = 'KeyInv'
local settings_version = 1

local saved = {
    debug = false
}

local function emptyfunc()
    return ''
end

local dbg = emptyfunc
local dformat = emptyfunc

local function inventory(name)
	-- get the character bag size
	local n = GetBagSize(BAG_BACKPACK)
	
	-- iterate through backpack bag to find all matching items, and add their counts to the total
	for i = 0, n do
		local iname = GetItemName(BAG_BACKPACK, i)
                if name == iname then
                    local success = CallSecureProtected("UseItem", BAG_BACKPACK, i)
                    df("%s success: %s", iname, tostring(success))
                    return i
                end
	end
        df("|c00ffffInventory item \"%s\" not found", name)
end

function Key(n)
    if saved.key[n] then
        inventory(saved.key[n])
    end
end

local function assign(n, iname)
    saved.key[n] = iname
    df('|c00ff11Assigned key %d to "%s"', n, iname)
end

local function addmenu(iname)
    local entries = {}
    for i = 1, 5 do
        entries[i] = {label = string.format('Key %d', i), callback = function() assign(i, iname) end}
    end
    AddCustomSubMenuItem("Assign to shortcut key", entries)
    ShowMenu(control)
end

local function rightclick(control)
    local _, n = ZO_Inventory_GetBagAndIndex(control)
    local iname = GetItemName(BAG_BACKPACK, n)
    zo_callLater(function () addmenu(iname) end, 0)
end

local function onloaded(_, addon_name)
    if addon_name ~= name then
	return
    end
    EVENT_MANAGER:UnregisterForEvent(addon_name, EVENT_ADD_ON_LOADED)
    dbg = emptyfunc
    saved = ZO_SavedVars:NewAccountWide(name .. 'Saved', settings_version, nil, saved)
    KeyInv_Saved = saved
    if saved.debug then
        dbg = df
        dformat = string.format
    else
        dbg = emptyfunc
        dbg = emptyfunc
    end
    saved.key = saved.key or {}

    SLASH_COMMANDS['/kidebug'] = function(n)
	if not n or n == '' then
	    -- nothing to do
	elseif n == 'true' or n == 'on' then
	    dbg = df
            dformat = string.format
            saved.debug = true
	else
	    dbg = emptyfunc
            dformat = emptyfunc
            saved.debug = false
	end
	d("KeyInv debugging: " .. tostring(dbg == df))
    end
    SLASH_COMMANDS['/kidump'] = function(n)
        for i = 1, 5 do
            if saved.key[i] then
                df("key %d: %s", i, saved.key[i])
            end
        end
    end

    ZO_PreHook('ZO_InventorySlot_ShowContextMenu', rightclick)
    ZO_CreateStringId('SI_BINDING_NAME_KEYINV_HOTKEY1', 'Inventory shortcut key 1')
    ZO_CreateStringId('SI_BINDING_NAME_KEYINV_HOTKEY2', 'Inventory shortcut key 2')
    ZO_CreateStringId('SI_BINDING_NAME_KEYINV_HOTKEY3', 'Inventory shortcut key 3')
    ZO_CreateStringId('SI_BINDING_NAME_KEYINV_HOTKEY4', 'Inventory shortcut key 4')
    ZO_CreateStringId('SI_BINDING_NAME_KEYINV_HOTKEY5', 'Inventory shortcut key 5')
end

EVENT_MANAGER:RegisterForEvent(name, EVENT_ADD_ON_LOADED, onloaded)
