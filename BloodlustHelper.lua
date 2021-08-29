
local IFrameFactory = IFrameFactory("1.0")

BloodlustHelperButton = { }

local frameDockTable = {
	["Top"] = { "BOTTOM", nil, "TOP", 0, -2 },
    ["Bottom"] = { "TOP", nil, "BOTTOM", 0, 2 },
    ["Left"] = { "RIGHT", nil, "LEFT", 1, 0 },
    ["Right"] = { "LEFT", nil, "RIGHT", -1, 0 },
}

BloodlustHelper = { }

local iface = IFrameManager:Interface()
function iface:getName(frame)
    return "BloodlustHelper"
end

function BloodlustHelper:onLoad()
    BloodlustHelperDock:RegisterEvent("VARIABLES_LOADED")
    BloodlustHelperDock:RegisterEvent("PLAYER_ENTERING_WORLD")
    BloodlustHelperDock:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
    BloodlustHelperDock:RegisterEvent("SPELLS_CHANGED")
    BloodlustHelperDock:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    BloodlustHelperDock:RegisterEvent("CURRENT_SPELL_CAST_CHANGED")
    BloodlustHelperDock:RegisterEvent("BAG_UPDATE_COOLDOWN")
    BloodlustHelperDock:RegisterEvent("UNIT_INVENTORY_CHANGED")

    BloodlustHelperDock:SetBackdropBorderColor(0, 0, 0, 1)
    BloodlustHelperDock:SetBackdropColor(0, 0, 0, 1)

    BloodlustHelperDock:Hide()

    IFrameManager:Register(BloodlustHelperDock, iface)
end

function BloodlustHelper:onEvent()
	BloodlustHelperDock:Show()
end

function BloodlustHelper:onUpdate()
	BloodlustHelperDock:Hide()

	IFrameFactory:Clear("BloodlustHelper", "Button")
	IFrameFactory:Clear("BloodlustHelper", "Icon")

	BloodlustHelperOptionsValidate()

	BloodlustHelperDock:SetScale(BloodlustHelperOptions.frameScale)

    local buttonDockInfo = frameDockTable[BloodlustHelperOptions.buttonDock]
    local iconDockInfo = frameDockTable[BloodlustHelperOptions.iconDock]
	local frameParent = BloodlustHelperDock
	for _, tbl in BloodlustHelperState do
		local buttonFrame = IFrameFactory:Create("BloodlustHelper", "Button")
		buttonFrame:SetScale(BloodlustHelperOptions.frameScale)

		buttonFrame.tbl = tbl
		buttonFrame.bar:SetMinMaxValues(0, tbl[3])
		buttonFrame:ClearAllPoints()
		buttonDockInfo[2] = frameParent
		if (frameParent == BloodlustHelperDock) then
			local relativeTo = buttonDockInfo[3]
			buttonDockInfo[3] = buttonDockInfo[1]
			buttonDockInfo[5], buttonDockInfo[4] = 0, 0
			buttonFrame:SetPoint(unpack(buttonDockInfo))
			buttonDockInfo[3] = relativeTo
		else
			buttonFrame:SetPoint(unpack(buttonDockInfo))
		end


		local iconParent = buttonFrame

		for iconIndex, spellInfo in tbl[4] do
			local iconFrame = IFrameFactory:Create("BloodlustHelper", "Icon")

			iconFrame:ClearAllPoints()
			iconDockInfo[2] = iconParent
			iconFrame:SetPoint(unpack(iconDockInfo))
			iconFrame.texture:SetTexture(iconIndex)
			iconFrame:SetParent(buttonFrame)

			iconParent = iconFrame
		end

		frameParent = buttonFrame
	end
end
