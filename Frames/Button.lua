
local FactoryInterface = { }
IFrameFactory("1.0"):Register("BloodlustHelper", "Button", FactoryInterface)

local function time(left)
	local min = math.floor(left / 60)
	local sec = math.floor(math.mod(left, 60))

	if (this.min == min and this.sec == sec) then
		return nil
	end

	this.min = min
	this.sec = sec

	return string.format("%02d:%02s", min, sec)
end

local function onUpdate()
	if (not this:IsVisible()) then
		return
	end

	this.targetName:SetText(this.tbl[5]);

	local left = this.tbl[3] - ( GetTime() - this.tbl[2] )
	if (left > 0) then
		local label = time(left)
		if (label) then
			this.label:SetText(label)
		end
		this.bar:SetValue(left)
	else
		BloodlustHelperStateRemove(this.tbl)
		BloodlustHelper:onUpdate()
	end
end

function FactoryInterface:Create(name)
	local frame = CreateFrame("Frame", name, UIParent)
	frame:SetWidth(80)
	frame:SetHeight(32)

	local backdropTable = {
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 12,
		edgeSize = 12,
		insets = {
			left = 2,
			right = 2,
			top = 2,
			bottom = 2
		}
	}

	local backdropColor = BloodlustHelperOptions.backdropColor
	local barColor = BloodlustHelperOptions.barColor
	local textColor = BloodlustHelperOptions.textColor

	frame:SetBackdrop(backdropTable)
	frame:SetBackdropBorderColor(backdropColor.r, backdropColor.g, backdropColor.b, backdropColor.a)
	frame:SetBackdropColor(backdropColor.r, backdropColor.g, backdropColor.b, backdropColor.a)

	frame.bar = CreateFrame("StatusBar", nil, frame)
	frame.bar:SetPoint("Center", frame)
	frame.bar:SetWidth(70)
	frame.bar:SetHeight(22)
	frame.bar:SetStatusBarTexture("Interface\\AddOns\\BloodlustHelper\\Textures\\Smooth")
	frame.bar:SetStatusBarColor(barColor.r, barColor.g, barColor.b, barColor.a)

	frame.targetName = frame.bar:CreateFontString(nil, "OVERLAY")
	frame.targetName:SetFontObject(BloodlustHelperFont)
	frame.targetName:SetPoint("LEFT", frame, "RIGHT", 30, -1)
	frame.targetName:SetJustifyH("CENTER")
	frame.targetName:SetTextColor(textColor.r, textColor.g, textColor.b, textColor.a)

	frame.label = frame.bar:CreateFontString(nil, "OVERLAY")
	frame.label:SetFontObject(BloodlustHelperFont)
	frame.label:SetPoint("CENTER", frame, "CENTER", 0, -1)
	frame.label:SetJustifyH("CENTER")
	frame.label:SetTextColor(textColor.r, textColor.g, textColor.b, textColor.a)
	frame:SetScript("OnUpdate", onUpdate)

	return frame
end

function FactoryInterface:Destroy(frame)
	return frame
end
