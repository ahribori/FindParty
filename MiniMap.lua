-- FindParty Minimap Button
-- Based on the Hit Assist minimap button

FP_Minimap_Save = {
	ButtonRadius = 78,
	ButtonShown = true,
	ButtonPosition = 336,
	Angle = 0}     -- table, SavedVariable, can't be local

CreateFrame("Button", "FP_Minimap_Button", Minimap)

FP_Minimap_Button:EnableMouse(true)
FP_Minimap_Button:SetMovable(false)
FP_Minimap_Button:SetFrameStrata("LOW")
FP_Minimap_Button:SetWidth(33)
FP_Minimap_Button:SetHeight(33)
FP_Minimap_Button:SetPoint("TOPLEFT", Minimap, "LEFT", 2, 0)
FP_Minimap_Button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

FP_Minimap_Button:CreateTexture("FP_Minimap_ButtonIcon", "BORDER")
FP_Minimap_ButtonIcon:SetWidth(20)
FP_Minimap_ButtonIcon:SetHeight(20)
FP_Minimap_ButtonIcon:SetPoint("CENTER", -2, 1)
FP_Minimap_ButtonIcon:SetTexture("Interface\\AddOns\\FindParty\\SIM-Icon") --INV_Misc_Bag_10_Blue

FP_Minimap_Button:CreateTexture("FP_Minimap_ButtonBorder", "OVERLAY")
FP_Minimap_ButtonBorder:SetWidth(52)
FP_Minimap_ButtonBorder:SetHeight(52)
FP_Minimap_ButtonBorder:SetPoint("TOPLEFT")
FP_Minimap_ButtonBorder:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

function FP_Minimap_Button_Init()
	
	FP_Minimap_Save.ButtonRadius = FP_Minimap_Save.ButtonRadius or 78
	FP_Minimap_Save.ButtonPosition = FP_Minimap_Save.ButtonPosition or 345
	FP_Minimap_Button_UpdatePosition()
end

function FP_Minimap_Button_UpdatePosition()
	FP_Minimap_Button:SetPoint(
		"TOPLEFT",
		"Minimap",
		"TOPLEFT",
		54 - (FP_Minimap_Save.ButtonRadius * cos(FP_Minimap_Save.ButtonPosition)),
		(FP_Minimap_Save.ButtonRadius * sin(FP_Minimap_Save.ButtonPosition)) - 55
	)
end

-- Thanks to Yatlas for this code
function FP_Minimap_Button_BeingDragged()
	-- Thanks to Gello for this code
	local xpos,ypos = GetCursorPosition()
	local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom()

	xpos = xmin-xpos/UIParent:GetScale()+70
	ypos = ypos/UIParent:GetScale()-ymin-70

	local v = math.deg(math.atan2(ypos, xpos))
	if v < 0 then
		v = v + 360
	end
	FP_Minimap_Save.ButtonPosition = v
	FP_Minimap_Button_UpdatePosition()

end

FP_Minimap_Button:RegisterEvent("VARIABLES_LOADED")
FP_Minimap_Button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
FP_Minimap_Button:RegisterForDrag("LeftButton")
FP_Minimap_Button:SetScript("OnDragStart", function(self)
	self:SetScript("OnUpdate", FP_Minimap_Button_BeingDragged)
end)
FP_Minimap_Button:SetScript("OnDragStop", function(self)
	self:SetScript("OnUpdate", nil)
end)
FP_Minimap_Button:SetScript("OnClick", function(self, button)
	FP_IconClicked(self, button);
end)
FP_Minimap_Button:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	local msg = "|cff00ff00왼쪽 클릭: |r파티찾기 도우미 열기";
	msg = msg.."\n|cff00ff00오른쪽 클릭: |r옵션";
	msg = msg.."\n|cff00ff00왼쪽 누르고 드래그 : |r아이콘이동";
	msg = msg.."\n|cff00ff00Alt + 왼쪽 클릭: |r아이콘 고정/해제";
	msg = msg.."\n|cff00ff00Ctrl + 왼쪽 클릭: |r광고 시작/정지";
	msg = msg.."\n|cff00ff00Shift + 왼쪽 클릭: |r기능 정지/작동";
	msg = msg.."\n ";
	msg = msg.."\n현재:";
	if (FP_IsActivated()) then
		msg = msg.." 작동중";
	else
		msg = msg.." 작동정지";
	end
	if (FP_IsAnnoucing()) then
		msg = msg.." 광고중 "
	end
	if (FP_Options.iconLocked) then
		msg = msg.." 아이콘고정"
	end
	GameTooltip:AddLine(msg);
	GameTooltip:Show();
end)
FP_Minimap_Button:SetScript("OnLeave", function(self)
	GameTooltip:Hide();
end)
FP_Minimap_Button:SetScript("OnEvent", FP_Minimap_Button_Init)