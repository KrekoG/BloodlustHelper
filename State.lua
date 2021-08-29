
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
			if not(spell == "Bloodlust") then
				spellID = spellID + 1
				spell = GetSpellName(spellID, type)
			else

				local start, duration, hasCooldown = GetSpellCooldown(spellID, type)
				if (hasCooldown == 1 and start > 0 and duration > 2) then
							insert("S", start, 180, GetSpellTexture(spellID, type))
				end

				spell = nil
			end
		end
	end
end

local function onEvent()
	this:Show()
	if (event == "SPELL_UPDATE_COOLDOWN") then
		this.Class[1] = true
	end
end

local function onUpdate()
	this:Hide()

	BloodlustHelperStateUpdate()
end


local Slave = CreateFrame("Frame", nil, WorldFrame)
Slave:RegisterEvent("SPELL_UPDATE_COOLDOWN")
Slave:SetScript("OnEvent", onEvent)
Slave:SetScript("OnUpdate", onUpdate)
Slave:Hide()

Slave.Class = { }

function BloodlustHelperStateRemove(tbl, texture)
	remove(tbl[1], tbl[2], tbl[3])
end


function BloodlustHelperStateUpdate()
	Slave.Class[1] = Slave.Class[1] and stateSpells()

	table.sort(BloodlustHelperState, sort)
end
