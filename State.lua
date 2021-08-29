
BloodlustHelperState = { }

local function insert(type, start, duration, texture)
	for _, tbl in ipairs(BloodlustHelperState) do
		if (tbl[1] == type and tbl[2] == start and tbl[3] == duration) then
			tbl[4][texture] = true
			return
		end
	end

	local tbl = { type, start, duration, { [texture] = true } }
	table.insert(BloodlustHelperState, tbl)
end

local function remove(type, start, duration)
	for idx, tbl in ipairs(BloodlustHelperState) do
		if (tbl[1] == type and tbl[2] == start and tbl[3] == duration) then
			table.remove(BloodlustHelperState, idx)
		end
	end
end

local function sort(left, right)
	local now = GetTime()
	return (left[3] - (now - left[2])) < (right[3] - (now - right[2]))
end


local bookTypes = { BOOKTYPE_SPELL, BOOKTYPE_PET }
local function stateSpells()
	for _, type in bookTypes do
		local spellID = 1
		local spell = GetSpellName(spellID, type)

		while (spell) do
			local start, duration, hasCooldown = GetSpellCooldown(spellID, type)
			if (hasCooldown == 1) then
				if (start > 0) then
					local min = BloodlustHelperOptions.minSpellDuration
					local max = BloodlustHelperOptions.maxSpellDuration
					if (duration > min and duration < max) then
						insert("S", start, duration, GetSpellTexture(spellID, type))
					end
				end
			end

			spellID = spellID + 1
			spell = GetSpellName(spellID, type)
		end
	end
end

local function stateInventory()
	for i=0, 1 do
		local slotID = GetInventorySlotInfo("Trinket"..i.."Slot")
		local start, duration, hasCooldown = GetInventoryItemCooldown("player", slotID)
		if (hasCooldown == 1) then
			if (start > 0) then
				if (duration > BloodlustHelperOptions.minItemDuration) then
					insert("I", start, duration, GetInventoryItemTexture("player", slotID))
				end
			end
		end
	end
end

local function stateContainers()
	for bagIndex=0, 4 do
		for invIndex=1, GetContainerNumSlots(bagIndex) do
			local link = GetContainerItemLink(bagIndex, invIndex)
			if (link) then
				local start, duration, hasCooldown = GetContainerItemCooldown(bagIndex, invIndex)
	    		if (start > 0) then
	    			local _, _, itemID = string.find(link, "item:(%d+):")
					local _, _, _, _, type = GetItemInfo(itemID)
					if (type == "Consumable") then
						if (duration > BloodlustHelperOptions.minItemDuration) then
							local texture = BloodlustHelperItems[tonumber(itemID)] or (GetContainerItemInfo(bagIndex, invIndex))
							insert("C", start, duration, texture)
						end
					end
				end
			end
		end
	end
end


local function onEvent()
	this:Show()

	if (event == "PLAYER_ENTERING_WORLD") then
		BloodlustHelperState = { }
		this.Class[1] = true
		this.Class[2] = true
		this.Class[3] = true
	elseif (event == "UPDATE_SHAPESHIFT_FORMS") then
		this.Class[1] = true
	elseif (event == "SPELLS_CHANGED") then
		this.Class[1] = true
	elseif (event == "SPELL_UPDATE_COOLDOWN") then
		this.Class[1] = true
		this.Class[2] = true
	elseif (event == "CURRENT_SPELL_CAST_CHANGED") then
		this.Class[1] = true
	elseif (event == "BAG_UPDATE_COOLDOWN") then
		this.Class[3] = true
	elseif (event == "UNIT_INVENTORY_CHANGED") then
		for idx, tbl in ipairs(BloodlustHelperState) do
			if (tbl[1] == "I") then
				table.remove(BloodlustHelperState, idx)
			end
		end
		this.Class[2] = true
	end
end

local function onUpdate()
	this:Hide()

	BloodlustHelperStateUpdate()
end


local Slave = CreateFrame("Frame", nil, WorldFrame)
Slave:RegisterEvent("PLAYER_ENTERING_WORLD")
Slave:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
Slave:RegisterEvent("SPELLS_CHANGED")
Slave:RegisterEvent("SPELL_UPDATE_COOLDOWN")
Slave:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")
Slave:RegisterEvent("BAG_UPDATE_COOLDOWN")
Slave:RegisterEvent("UNIT_INVENTORY_CHANGED")
Slave:SetScript("OnEvent", onEvent)
Slave:SetScript("OnUpdate", onUpdate)
Slave:Hide()

Slave.Class = { }

function BloodlustHelperStateRemove(tbl, texture)
	remove(tbl[1], tbl[2], tbl[3])
end


function BloodlustHelperStateUpdate()
	Slave.Class[1] = Slave.Class[1] and stateSpells()
	Slave.Class[2] = Slave.Class[2] and stateInventory()
	Slave.Class[3] = Slave.Class[3] and stateContainers()

	table.sort(BloodlustHelperState, sort)
end
