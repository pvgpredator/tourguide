

local TourGuide = TourGuide
local ww = WidgetWarlock
WidgetWarlock = nil


local NUMROWS, GAP, ROWHEIGHT = 20, 4, 20
local offset, rows = 0, {}


local frame = CreateFrame("Frame", nil, UIParent)
TourGuide.guidespanel = frame
frame.name = "Guides"
frame.parent = "Tour Guide"
frame:Hide()
frame:SetScript("OnShow", function()
	local function HideTooltip() GameTooltip:Hide() end
	local function ShowTooltip(f)
		if TourGuide.db.char.completion[f.guide] ~= 1 then return end

		GameTooltip:SetOwner(f, "ANCHOR_RIGHT")
		GameTooltip:SetText("This guide has been completed.  Shift-click to reset it.", nil, nil, nil, nil, true)
	end
	local function OnClick(self)
		if IsShiftKeyDown() then
			TourGuide.db.char.completion[self.guide] = nil
			TourGuide.db.char.turnins[self.guide] = {}
			TourGuide:UpdateGuidesPanel()
			GameTooltip:Hide()
		else
			local text = self.guide
			if not text then self:SetChecked(false)
			else
				TourGuide:LoadGuide(text)
				TourGuide:UpdateStatusFrame()
				TourGuide:UpdateGuidesPanel()
			end
		end
	end


	rows = {}
	for i=1,NUMROWS do
		local anchor, point = rows[i-1], "BOTTOMLEFT"
		if i == 1 then anchor, point = frame, "TOPLEFT" end

		local row = CreateFrame("CheckButton", nil, frame)
		if i == 1 then row:SetPoint("TOP", frame, 0, -GAP)
		else row:SetPoint("TOP", rows[i-1], "BOTTOM") end
		row:SetPoint("LEFT", frame, GAP, 0)
		row:SetPoint("RIGHT", frame, -GAP, 0)
		row:SetHeight(ROWHEIGHT)

		local highlight = ww.SummonTexture(row, nil, nil, nil, "Interface\\HelpFrame\\HelpFrameButton-Highlight")
		highlight:SetTexCoord(0, 1, 0, 0.578125)
		highlight:SetAllPoints()
		row:SetHighlightTexture(highlight)
		row:SetCheckedTexture(highlight)

		local text = ww.SummonFontString(row, nil, "GameFontWhite", nil, "LEFT", GAP, 0)

		row:SetScript("OnClick", OnClick)
		row:SetScript("OnEnter", ShowTooltip)
		row:SetScript("OnLeave", HideTooltip)

		row.text = text
		rows[i] = row
	end

	frame:EnableMouseWheel()
	frame:SetScript("OnMouseWheel", function(f, val)
		offset = offset - val
		if offset == (#TourGuide.guidelist - NUMROWS) then offset = offset - 1 end
		if offset < 0 then offset = 0 end
		TourGuide:UpdateGuidesPanel()
	end)


	local function OnShow(self)
		TourGuide:UpdateGuidesPanel()

		self:SetAlpha(0)
		self:SetScript("OnUpdate", ww.FadeIn)
	end

	frame:SetScript("OnShow", OnShow)
	ww.SetFadeTime(frame, 0.5)
	OnShow(frame)
end)


function TourGuide:UpdateGuidesPanel()
	if not frame or not frame:IsVisible() then return end
	for i,row in ipairs(rows) do
		row.i = i + offset + 1

		local name = self.guidelist[i + offset + 1]
		local complete = self.db.char.currentguide == name and (self.current-1)/#self.actions or self.db.char.completion[name]
		row.guide = name

		local r,g,b = self.ColorGradient(complete or 0)
		local text = complete and complete ~= 0 and string.format("%s |cff%02x%02x%02x[%d%%]", name, r*255, g*255, b*255, complete*100) or name
		row.text:SetText(text)
		row:SetChecked(self.db.char.currentguide == name)
	end
end

InterfaceOptions_AddCategory(frame)
