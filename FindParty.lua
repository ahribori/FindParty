-- 표시 버전은 TOC에서 직접 읽어옵니다. 버전업시 TOC에 Version을 변경하세요.
-- 업데이트 후 옵션 초기화 필요시 Revision 값을 증가시킨후 FP_Init을 변경하시기 바랍니다.
FP_DISPLAY_VERSION = GetAddOnMetadata("FindParty", "version")
FP_Revision = 16

----------------------
-- 기본 변수들 선언 --
----------------------
FP_Version = 1
FP_Options = nil
FP_Filter_Dungeon = {}
FP_UserDefinedWhMsg = nil
FP_UserDefinedAdMsg = nil
FP_UserDefineFilterMsg = ""

FP_Minimap_Save = {
	ButtonRadius = 78,
	ButtonShown = true,
	ButtonPosition = 336,
	Angle = 0
}

FP_Position_Save = {
	["point"] = nil,
	["relpoint"] = nil,
	["x"] = nil,
	["y"] = nil,
	["width"] = nil
}

local lastUpdatedTime = 0
local lastAnnouncedTime = 0
local isAnnouncing = false
local isDungeonFiltering = false
local shouterSelected = nil
local frameData = {}
local exceptionData = {}
local colName = {"time", "dungeon", "name", "msg"}
local colFrame = {"DungeonText", "NameText", "MsgText"}

local FP_UPDATE_INTERVAL = 2
local PHARSING_MSG_LENGTH = 100
local ASCD = true
local DESC = false
local INC = 1
local DEC = 2
local MAX = 3
local MIN = 4

local sortData = {
	["time"] = ASCD,
	["dungeon"] = ASCD,
	["name"] = ASCD,
	["msg"] = ASCD,
	["current_sort"] = "dungeon"
}

local FP_Option_Menu = {
	[1] = {
		name = FP_OPTIONS_CHANNEL,
		dbname = "channel",
		value = {},
	},
	[2] = {
		name = FP_OPTIONS_INTERVAL,
		dbname = "interval",
		value = {"10","15","20","25","30","45","60","90","120","300","600"},
	},
	[3] = {
		name = FP_OPTIONS_VALID,
		dbname = "valid",
		value = {"30","60","90","120","300","600"},
	},
	[4] = {
		name = "",
	},
	[5] = {
		name = FP_OPTIONS_FONTSIZE,
		dbname = "fontsize",
		value = {"12","13","14","15","16","17","18"},
	},
	[6] = {
		name = FP_OPTIONS_SCALE,
		dbname = "scale",
		value = {"2","1.9","1.8","1.7","1.6","1.5","1.4","1.3","1.2","1.1","1","0.9","0.8","0.7","0.6","0.5"},
	},
	[7] = {
		name = FP_OPTIONS_COLOR,
		dbname = "color",
	},
	[8] = {
		name = "",
	},
	[9] = {
		name = FP_OPTIONS_ICON,
		dbname = "icon",
		exec = function(self) FP_Minimap_ButtonToggle(self.checked) end,
	},
	[10] = {
		name = FP_OPTIONS_ESC,
		dbname = "esc",
		exec = function(self) FP_SetSpecialFrame(self.checked) end,
	},
	[11] = {
		name = FP_OPTIONS_RIGHTBUTTON,
		dbname = "rightButton",
		exec = function(self) FP_Options.rightButton = self.checked end,
	},
	[12] = {
		name = "",
	},
	[13] = {
		name = FP_OPTIONS_NORAID,
		dbname = "noraid",
		exec = function(self) FP_Options.noraid = self.checked end,
	},
	[14] = {
		name = FP_OPTIONS_NOPVP,
		dbname = "nopvp",
		exec = function(self) FP_Options.nopvp = self.checked end,
	},
	[15] = {
		name = "",
	},
	[16] = {
		name = FP_OPTIONS_RESET,
		dbname = "reset",
		value = {
			[1] = {
				name = FP_OPTIONS_RESETPOS,
				exec = function() FP_LoadDefaultWinPos() end,
			},
			[2] = {
				name = FP_OPTIONS_RESETSIZE,
				exec = function() FP_LoadDefaultWinSize() end,
			},
			[3] = {
				name = FP_OPTIONS_RESETALL,
				exec = function() FP_LoadDefaultOption() end,
			},
		},
	},
	[17] = {
		name = "",
	},
	[18] = {
		name = FP_TEXT_CLOSE,
		dbname = "close",
		exec = "",
	},
}

local FP_Default_Options= {
	["channel"] = { [FP_DEFAULT_PARTY_CHANNEL] = true },
	["color"] = { ["r"] = 0, ["g"] = 0, ["b"] = 0, ["opacity"] = 0.5, },
	["interval"] = 30,
	["valid"] = 60,
	["scale"] = 1,
	["fontsize"] = 13,
	["viewLines"] = 20,
	["titlebarVisible"] = true,
	["menubarVisible"] = true,
	["activated"] = true,
	["icon"] = true,
	["iconLocked"] = false,
	["activateBellnWindow"] = false,
	["useroffed"] = false,
	["rightButton"] = false,
	["esc"] = false,
	["noraid"] = true,
	["nopvp"] = true,
}

------------------------
-- 미니맵 아이콘 설정 --
------------------------
-- Based on the Hit Assist minimap button
CreateFrame("Button", "FP_Minimap_Button", Minimap)

FP_Minimap_Button:EnableMouse(true)
FP_Minimap_Button:SetMovable(false)
FP_Minimap_Button:SetFrameStrata("MEDIUM")
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
	FP_Minimap_Button:UnregisterEvent("VARIABLES_LOADED")
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
FP_Minimap_Button:SetScript("OnDragStart", function(self) self:SetScript("OnUpdate", FP_Minimap_Button_BeingDragged) end)
FP_Minimap_Button:SetScript("OnDragStop", function(self) self:SetScript("OnUpdate", nil) end)
FP_Minimap_Button:SetScript("OnClick", function(self, button) FP_IconClicked(self, button) end)
FP_Minimap_Button:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	local msg = ""
	for k,v in ipairs(FP_TOOLTIP_MINIMAP) do
		msg = msg..v
	end
	if FP_Options.activated then
		msg = msg..FP_TOOLTIP_MINIMAP_ON
	else
		msg = msg..FP_TOOLTIP_MINIMAP_OFF
	end
	if isAnnouncing then
		msg = msg..FP_TOOLTIP_MINIMAP_AD
	end
	if FP_Options.iconLocked then
		msg = msg..FP_TOOLTIP_MINIMAP_LOCK
	else
		msg = msg..FP_TOOLTIP_MINIMAP_NOLOCK
	end
	GameTooltip:AddLine(msg)
	GameTooltip:Show()
end)
FP_Minimap_Button:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
FP_Minimap_Button:SetScript("OnEvent", FP_Minimap_Button_Init)

-----------------
-- 툴팁 테이블 --
-----------------
FP_Tooltip = {
	["DEFAULT"] = function(msg, frame, anchor, pX, pY)
		GameTooltip:SetOwner(frame, anchor, pX or 0, pY or 0)
		GameTooltip:ClearLines()
		GameTooltip:AddLine(msg)
		GameTooltip:Show()
	end,
	["LIST"] = function(self)
		local text = _G[self:GetName().."MsgText"]:GetText()
		if text then
			FP_Tooltip.DEFAULT(text, _G[self:GetName().."Name"], "ANCHOR_TOPLEFT", 0, 0)
		end
	end,
	["SORTTIME"] = function(self)
		FP_Tooltip.DEFAULT(FP_TOOLTIP_SORT_TIME, self, "ANCHOR_TOPRIGHT")
	end,
	["FILTERDUNGEON"] = function(self)
		local msg = FP_TOOLTIP_DUNGEON_FILTER
		local desc = FP_GetDungeonFilterList()
		if desc then
			msg = msg..desc
		end
		FP_Tooltip.DEFAULT(msg, self, "ANCHOR_TOPRIGHT")
	end,
	["CLOSE"] = function(self)
		FP_Tooltip.DEFAULT(FP_TOOLTIP_CLOSE, self, "ANCHOR_TOPRIGHT")
	end,
	["MAXMIZE"] = function(self)
		FP_Tooltip.DEFAULT(FP_TOOLTIP_MAXMIZE, self, "ANCHOR_TOPRIGHT")
	end,
	["MINIMIZE"] = function(self)
		FP_Tooltip.DEFAULT(FP_TOOLTIP_MINIMIZE, self, "ANCHOR_TOPRIGHT")
	end,
	["DECREASE"] = function(self)
		FP_Tooltip.DEFAULT(FP_TOOLTIP_DECREASE, self, "ANCHOR_TOPRIGHT")
	end,
	["INCREASE"] = function(self)
		FP_Tooltip.DEFAULT(FP_TOOLTIP_INCREASE, self, "ANCHOR_TOPRIGHT")
	end,
	["OPTION"] = function(self)
		FP_Tooltip.DEFAULT(FP_TOOLTIP_OPTION, self, "ANCHOR_TOPRIGHT")
	end,
	["ACTIVATE"] = function(self)
		local msg
		if FP_Options.activated then
			msg = FP_TOOLTIP_ACTIVATE_ON
		else
			msg = FP_TOOLTIP_ACTIVATE_OFF
		end
		FP_Tooltip.DEFAULT(msg, self, "ANCHOR_TOPRIGHT")
	end,
	["ANNOUNCE"] = function(self)
		local msg
		if isAnnouncing then
			msg = FP_TOOLTIP_AD_ON
		else
			msg = FP_TOOLTIP_AD_OFF
		end
		FP_Tooltip.DEFAULT(msg, self, "ANCHOR_TOPRIGHT")
	end,
	["ACTIVATEBELLNWINDOW"] = function(self)
		local msg
		if FP_Options.activateBellnWindow then
			msg = FP_TOOLTIP_POPUP_ON
		else
			msg = FP_TOOLTIP_POPUP_OFF
		end
		FP_Tooltip.DEFAULT(msg, self, "ANCHOR_TOPRIGHT")
	end,
	["APPLYBINDING"] = function(self)
		FP_Tooltip.DEFAULT(FP_TOOLTIP_SHORTCUT_ALT, self, "ANCHOR_TOPRIGHT")
	end,
	["EXCEPTIONBINDING"] = function(self)
		FP_Tooltip.DEFAULT(FP_TOOLTIP_SHORTCUT_CTRL, self, "ANCHOR_TOPRIGHT")
	end,
	["WHOBINDING"] = function(self)
		FP_Tooltip.DEFAULT(FP_TOOLTIP_SHORTCUT_SHIFT, self, "ANCHOR_TOPRIGHT")
	end,
	["WHISPERBINDING"] = function(self)
		FP_Tooltip.DEFAULT(FP_TOOLTIP_SHORTCUT_ALT_RIGHT, self, "ANCHOR_TOPRIGHT")
	end,
}

-------------------
-- 애드온 초기화 --
-------------------
local function getDungeonFilterNum()
	local num = 0

	for idx, tbl in pairs(FP_Filter_Dungeon) do
		for idx2, tbl2 in pairs(tbl) do
			num = num + 1
		end
	end

	return num
end

function FP_Init()
	-- SavedVariables 에 저장된 버전과 현재 lua 파일 내의 버전이 다를경우 처리하는 부분
	if not (FP_Version == FP_Revision) then
		--FP_Debug("--  New version Init")

		-- FP_Version 값이 number 형식이 아닌 경우 강제 리셋
		if type(FP_Version) ~= "number" then
			FP_Print(FP_MESSAGE_NEWVERSION_RESET)
			if FP_DUNGEON_LIST then
				FP_DUNGEON_LIST = nil
			end
			FP_LoadDefaultOption()
		else
			-- Revision 10 이전 버전 (5.04.01 이전) 버전은 강제 리셋
			if FP_Version < 10 then
				FP_Print(FP_MESSAGE_NEWVERSION_RESET)
				if FP_DUNGEON_LIST then
					FP_DUNGEON_LIST = nil
				end
				FP_LoadDefaultOption()
			else
				-- Revision 16 - noparty 삭제
				if FP_Version < 16 then
					FP_Options.noparty = nil
				end
				-- Revision 15 - 인스턴스 던전에서 비활성화 설정을 기본값으로 변경
				if FP_Version < 15 then
					FP_Options.noraid = true
					FP_Options.noparty = false
					FP_Options.nopvp = true
				end
				-- Revision 14 - FP_Scroll_Info 삭제
				if FP_Version < 14 then
					local savedViewLines
					if FP_Scroll_Info and FP_Scroll_Info.viewLines and type(FP_Scroll_Info.viewLines) == "number" then
						savedViewLines = FP_Scroll_Info.viewLines
					end
					FP_Scroll_Info = nil
					FP_Options.viewLines = savedViewLines or 20
				end
				-- Revision 13 이전 버전 (5.04.05 이전) 경우 필터값이 잘못 들어가 오류가 발생할 수 있으므로 필터 정보를 리셋
				if FP_Version < 13 then
					FP_Filter_Dungeon = {}
					FP_Filter_Class = nil
				end
			end
		end

		FP_Version = FP_Revision
	end

	-- 옵션 테이블이 없을 경우 기본 옵션 테이블을 생성한다.
	if not FP_Options then
		FP_LoadDefaultOption()
	end

	-- 상단, 하단 프레임 설정 및 모양 변경
	if FP_Options.titlebarVisible then FP_TitleFrame:Hide() else FP_TitleFrame:Show() end
	FP_ListFrameBridgeToTitle:GetScript("OnClick")()
	if FP_Options.menubarVisible then FP_MenuFrame:Hide() else FP_MenuFrame:Show() end
	FP_ListFrameBridgeToMenu:GetScript("OnClick")()
	FP_ListFrame:SetClampedToScreen(true)

	-- UI 설정 및 모양 변경
	FP_FontResize()
	FP_SetListColor()
	FP_SetListPosition()
	FP_UIResize(FP_Options.scale)
	if FP_Options.esc then tinsert(UISpecialFrames, "FP_Frame") end

	--미니맵 아이콘 설정
	if FP_Minimap_Button and not FP_Options.icon then FP_Minimap_Button:Hide() end
	if FP_Minimap_Button and FP_Options.iconLocked then FP_Minimap_Button:RegisterForDrag(nil) end

	--광고글 설정
	if FP_UserDefinedAdMsg then FP_MenuFrameAdText:SetText(FP_UserDefinedAdMsg) end
	if FP_UserDefinedWhMsg then FP_MenuFrameWhText:SetText(FP_UserDefinedWhMsg) end

	-- 필터 문자열 설정
	if getDungeonFilterNum() > 0 then
		isDungeonFiltering = true
	end
	FP_SetDungeonFilterText()

	-- 애드온 활성화
	FP_Activate(FP_Options.activated, true)
	if FP_Options.activateBellnWindow then
		FP_ActiveBellnWindow(true)
	end
end

---------------
-- 던전 파싱 --
---------------
-- 유아원때일진님 파티찾기에서 참조 // 문자열 필터링 함수
function FP_FilterIgnoreText(msg, ignoreTextTable, isTooltip)
	local tempMsg
	if not msg then return tempMsg end
	tempMsg = msg
	if not isTooltip then
		-- 공백제거
		tempMsg = string.gsub(tempMsg, " ", "")
		-- 대문자로 변환
		tempMsg = string.upper(tempMsg)
		-- 다시체크
		if not msg then return tempMsg end
	end
	local x = nil
	local y = nil
	local j = 1

	if ((tempMsg == nil) or (ignoreTextTable == nil)) then
		return nil
	end

	for _, v in pairs(ignoreTextTable) do
		j = 1

		while (true) do
			x, y = string.find(tempMsg, v, j)
			if x then
				tempMsg = string.sub(tempMsg, 1, x-1)..string.sub(tempMsg, y+1)
			else
				break
			end
			j = x
			x = nil
		end
	end
	return tempMsg
end

function FP_DungeonParse(msg)
	local dungeon
	local dungeon_keyword
	local difficulty
	local difficultyTable = {}
	local heroicTable = {}
	if not msg then return dungeon, difficulty end
	-- 문자열 파싱 시작
	-- 모든 부분을 파싱하지 않고 앞부분만 짤라냄
	local nmsg = string.sub(msg, 1, PHARSING_MSG_LENGTH)
	if not nmsg then return dungeon, difficulty end
	-- 파싱에 영향을 줄 수 있는 문자열들을 FP_DUNGEON_IGNORE_KEYWORDS 테이블을 참고하여 제거 (by 유아원때일진님)
	-- 제거된 부분은 별도로 보관 (난이도 분류에 영향을 주지 않기 위해)
	local nmsg_dungeon = FP_FilterIgnoreText(nmsg, FP_DUNGEON_IGNORE_KEYWORDS)
	if (nmsg_dungeon == nil) then
		return dungeon, difficulty
	end

	-- 던전을 찾는다(인덱스 테이블이라 순서가 섞일 우려가 없기 때문에, 잡다한 처리는 모조리 삭제. 가장 최근에 출시된 인던으로 무조건 분류.. 어느정도 오분류는 감안하자)
	for idx, tbl in ipairs(FP_DUNGEON_KEYWORDS) do
		for idx2, tbl2 in ipairs(tbl.dungeon) do
			for i = 1, table.getn(tbl2.keywords) do
				local keyword = tbl2.keywords[i]
				if string.find(nmsg_dungeon, keyword) then
					if tbl2.excludekeywords then
						local breaking = false
						for j = 1, table.getn(tbl2.excludekeywords) do
							if string.find(nmsg_dungeon, tbl2.excludekeywords[j]) then
								breaking = true
							end
						end
						if breaking then break end
					end
					-- 운다손, 갈레온손 같은 문자열 제거
					local ignore = false
					for i = 1, table.getn(FP_DUNGEON_IGNORE_POSTFIX_KEYWORDS) do
						if string.find(nmsg_dungeon, keyword..FP_DUNGEON_IGNORE_POSTFIX_KEYWORDS[i]) then
							ignore = true
							break
						end
					end
					if ignore then break end
					dungeon = tbl2.name
					dungeon_keyword = keyword
					difficultyTable = tbl2.difficulty
					heroicTable	= tbl2.heroickeywords or {}
					break
				end
			end
			if dungeon then break end
		end
		if dungeon then break end
	end

	-- 던전을 찾았으면 던전 난이도를 구한다.
	if dungeon then
		-- 던전 정보를 참조해서 난이도가 하나 밖에 없으면 구할 필요가 없으므로 바로 그 난이도로 직행
		if table.getn(difficultyTable) == 1 then
			difficulty = difficultyTable[1]
		-- 그게 아닐 경우는 구해야지
		else
			local difficulty_ok
			-- 10인 25인이 존재하는 과거 던전에서만 사용
			if difficultyTable[1] == "10normal" then
				local numDifficulty
				local txtDifficulty
				local isHeroic
				-- 영웅 난이도 처리
				if not isHeroic then
					for i = 1, table.getn(FP_HEROIC_KEYWORDS) do
						local keyword = FP_HEROIC_KEYWORDS[i]
						if string.find(nmsg, keyword) then
							isHeroic = true
							break
						end
					end
					for i = 1, table.getn(FP_HEROIC_POSTFIX_KEYWORDS) do
						local keyword = dungeon_keyword..FP_HEROIC_POSTFIX_KEYWORDS[i]
						if string.find(nmsg, keyword) then
							isHeroic = true
							break
						end
					end
					for i = 1, table.getn(heroicTable) do
						local keyword = heroicTable[i]
						if string.find(nmsg, keyword) then
							isHeroic = true
							break
						end
					end
				end
				-- 난이도 분류에 영향을 줄 수 있는 문자열 제거
				nmsg = FP_FilterIgnoreText(nmsg, FP_DIFFICULTY_IGNORE_KEYWORDS)
				if not nmsg then return dungeon, difficultyTable[1]	end
				-- numDifficulty 구하기
				local startAddr = nil
				local endAddr = 0
				for w in string.gmatch(nmsg, "%d+") do
					startAddr, endAddr = string.find(nmsg, "%d+", endAddr+1)
					numDifficulty = tonumber(w)
					break
				end
				-- txtDifficulty 구하기
				for idx, tbl in ipairs(FP_DIFFICULTY_KEYWORDS) do
					for i = 1, table.getn(tbl.keywords) do
						local keyword = tbl.keywords[i]
						if string.find(nmsg, keyword) then
							txtDifficulty = tbl.dbname
							break
						end
					end
					if txtDifficulty then break end
				end
				-- 난이도 결정
				if isHeroic and (numDifficulty == 25 or (txtDifficulty == "25normal")) then
					difficulty = "25heroic"
				elseif isHeroic then
					difficulty = "10heroic"
				elseif numDifficulty == 25 then
					difficulty = "25normal"
				elseif numDifficulty == 10 then
					difficulty = "10normal"
				elseif txtDifficulty then
					difficulty = txtDifficulty
				end
			else -- 드군 공격대 및 5인 던전
				-- 난이도 분류에 영향을 줄 수 있는 문자열 제거
				nmsg = FP_FilterIgnoreText(nmsg, FP_DIFFICULTY_IGNORE_KEYWORDS)
				if not nmsg then return dungeon, difficultyTable[1]	end

				-- difficulty 바로 구하기
				for idx, tbl in ipairs(FP_DIFFICULTY_KEYWORDS) do
					for i = 1, table.getn(tbl.keywords) do
						local keyword = tbl.keywords[i]
						if string.find(nmsg, keyword) then
							difficulty = tbl.dbname
							break
						end
					end
					if difficulty then break end
				end
			end
			-- 구한 난이도와 던전에 존재할 수 있는 난이도 테이블(difficultyTable)을 비교해서 난이도 최종 결정
			-- 난이도를 구할 수 없을 경우나 잘못된 경우 던전 정보에서 가장 앞에 있는 난이도로 강제 설정
			for i = 1, table.getn(difficultyTable) do
				if difficulty == difficultyTable[i] then
					difficulty_ok = true
					break
				end
			end
			if not difficulty_ok then
				difficulty = difficultyTable[1]
			end
		end
	end

	-- 디버깅용
	-- print("---")
	-- print(dungeon..", "..difficulty)

	return dungeon, difficulty, dungeon_keyword
end

-------------------
-- 난이도 필터링 --
-------------------
local function getLocalizedDifficultyText(text)
	local difficulty
	if text then
		for i = 1, table.getn(FP_DIFFICULTY_KEYWORDS) do
			if text == FP_DIFFICULTY_KEYWORDS[i].dbname then
				difficulty = FP_DIFFICULTY_KEYWORDS[i].name
				break
			end
		end
	end

	return difficulty or ""
end

local function getCategory(dungeon)
	local category
	if dungeon then
		for idx, tbl in ipairs(FP_DUNGEON_KEYWORDS) do
			for idx2, tbl2 in ipairs(tbl.dungeon) do
				if tbl2.name == dungeon then
					category = tbl.category
					break
				end
			end
			if category then break end
		end
	end

	return category or ""
end

local function getDungeonDifficultyTable(dungeon)
	local difficultyTable = {}
	if dungeon then
		for idx, tbl in ipairs(FP_DUNGEON_KEYWORDS) do
			for idx2, tbl2 in ipairs(tbl.dungeon) do
				if tbl2.name == dungeon then
					difficultyTable = tbl2.difficulty
					break
				end
			end
		end
	end

	return difficultyTable
end

local function toggleDungeonFilter()
	isDungeonFiltering = not isDungeonFiltering
end

function FP_DropDownMenuFilterDungeon_Initialize(frame, level, menu)
	level = level or 1
	local info
	if (level == 1) then
		for idx, tbl in ipairs(FP_DUNGEON_KEYWORDS) do
			info = UIDropDownMenu_CreateInfo()
			info.text = tbl.category
			info.keepShownOnClick = true
			info.disabled = false
			info.hasArrow = true
			info.notCheckable = true
			info.menuList = idx
			UIDropDownMenu_AddButton(info, level)
		end -- for key, subarray

		-- 한줄 비움
		info.text = ""
		info.disabled = true
		info.checked = false
		info.hasArrow = false
		UIDropDownMenu_AddButton(info, level)

		info.text = FP_DUNGEONFILTER_RESETALL
		info.func = function()
						FP_Filter_Dungeon = {}
						FP_SetDungeonFilterText()
						FP_Print(FP_MESSAGE_DUNGEON_RESET)
					end
		info.notCheckable = true
		info.disabled = false
		info.keepShownOnClick = false
		info.textR = 0.95
		info.textG = 0.30
		info.textB = 0.30
		info.arg1 = "resetall"
		info.arg2 = nil
		info.arg3 = nil
		UIDropDownMenu_AddButton(info, level)

		info.text = FP_TEXT_CLOSE
		info.func = nil
		info.notCheckable = true
		info.keepShownOnClick = false
		UIDropDownMenu_AddButton(info, level)
	elseif (level == 2) then
		for idx, tbl in ipairs(FP_DUNGEON_KEYWORDS[menu].dungeon) do
			info = UIDropDownMenu_CreateInfo()
			info.text = tbl.name
			info.keepShownOnClick = true
			info.disabled = false
			info.hasArrow = true
			info.func = FP_FilterDungeonSelected
			info.checked = (FP_Filter_Dungeon[FP_DUNGEON_KEYWORDS[menu].category] and FP_Filter_Dungeon[FP_DUNGEON_KEYWORDS[menu].category][info.text]) or false
			info.value = tbl.difficulty
			info.menuList = info.text
			info.arg1 = info.text
			info.arg2 = nil
			UIDropDownMenu_AddButton(info, level)
		end -- for key, subarray
	elseif (level == 3) then
		info = UIDropDownMenu_CreateInfo()
		info.keepShownOnClick = true
		for i = 1, table.getn(UIDROPDOWNMENU_MENU_VALUE) do
			info.text = getLocalizedDifficultyText(UIDROPDOWNMENU_MENU_VALUE[i])
			info.keepShownOnClick = true
			info.disabled = false
			info.func = FP_FilterDungeonSelected
			info.checked = (FP_Filter_Dungeon[getCategory(menu)] and FP_Filter_Dungeon[getCategory(menu)][menu] and FP_Filter_Dungeon[getCategory(menu)][menu][UIDROPDOWNMENU_MENU_VALUE[i]]) or false
			info.arg1 = menu
			info.arg2 = UIDROPDOWNMENU_MENU_VALUE[i]
			info.value = UIDROPDOWNMENU_MENU_VALUE[i]
			UIDropDownMenu_AddButton(info, level)
		end
	end
end

function FP_FilterDungeonSelected(self, dungeon, difficulty, checked)
	if not dungeon then return end
	local category = getCategory(dungeon)

	-- 난이도 선택으로 필터링 추가
	if difficulty then
		-- 체크설정됨, 필터링 추가
		if checked then
			-- 빈 테이블일 경우 먼저 생성
			if not FP_Filter_Dungeon[category] then
				FP_Filter_Dungeon[category] = {}
			end
			if not FP_Filter_Dungeon[category][dungeon] then
				FP_Filter_Dungeon[category][dungeon] = {}
			end
			FP_Filter_Dungeon[category][dungeon][difficulty] = true
		-- 체크해제됨, 필터링 삭제
		else
			FP_Filter_Dungeon[category][dungeon][difficulty] = nil
			-- 빈 테이블 삭제
			local dungeon_tables = 0
			for idx, tbl in pairs(FP_Filter_Dungeon[category][dungeon]) do
				dungeon_tables = dungeon_tables + 1
			end
			if dungeon_tables == 0 then
				FP_Filter_Dungeon[category][dungeon] = nil
			end
			local category_tables = 0
			for idx, tbl in pairs(FP_Filter_Dungeon[category]) do
				category_tables = category_tables + 1
			end
			if category_tables == 0 then
				FP_Filter_Dungeon[category] = nil
			end
		end
	-- 던전 선택으로 필터링 추가
	else
		-- 체크설정됨, 필터링 추가
		if checked then
			-- 빈 테이블일 경우 먼저 생성
			if not FP_Filter_Dungeon[category] then
				FP_Filter_Dungeon[category] = {}
			end
			if not FP_Filter_Dungeon[category][dungeon] then
				FP_Filter_Dungeon[category][dungeon] = {}
				local difficultyTable = getDungeonDifficultyTable(dungeon)
				for idx, tbl in ipairs(difficultyTable) do
					FP_Filter_Dungeon[category][dungeon][tbl] = true
				end
			end
		else
		-- 체크해제됨, 필터링 삭제
			FP_Filter_Dungeon[category][dungeon] = nil
			-- 빈 테이블 삭제
			local category_tables = 0
			for idx, tbl in pairs(FP_Filter_Dungeon[category]) do
				category_tables = category_tables + 1
			end
			if category_tables == 0 then
				FP_Filter_Dungeon[category] = nil
			end
		end
	end

	-- 던전 필터링 정보 텍스트 업데이트
	if getDungeonFilterNum() > 0 then
		isDungeonFiltering = true
	else
		isDungeonFiltering = false
	end
	FP_SetDungeonFilterText()

	-- 체크 항목 동기화 부분
	local idx = 1
	local loop = true
	-- 무한 루프 방지 (30미만)
	while loop and idx < 30 do
		local button = _G["DropDownList2Button"..idx]
		if button and button:GetText() then
			local button_text = button:GetText()
			if FP_Filter_Dungeon[category] and FP_Filter_Dungeon[category][button_text] then
				button.checked = true
				_G["DropDownList2Button"..idx.."Check"]:Show()
			else
				button.checked = false
				_G["DropDownList2Button"..idx.."Check"]:Hide()
			end
		else
			loop = false
			break
		end
		idx = idx + 1
	end

	local idx2 = 1
	local loop2 = true
	-- 무한 루프 방지 (10미만)
	while loop2 and idx2 < 15 do
		local button2 = _G["DropDownList3Button"..idx2]
		if button2 and button2.value then
			local button2_text = button2.value
			if FP_Filter_Dungeon[category] and FP_Filter_Dungeon[category][dungeon] and FP_Filter_Dungeon[category][dungeon][button2_text] then
				button2.checked = true
				_G["DropDownList3Button"..idx2.."Check"]:Show()
			else
				button2.checked = false
				_G["DropDownList3Button"..idx2.."Check"]:Hide()
			end
		else
			loop2 = false
			break
		end
		idx2 = idx2 + 1
	end
end

function FP_GetDungeonFilterList()
	local desc = ""
	local i = 0
	local num = getDungeonFilterNum()

	for idx, tbl in pairs(FP_Filter_Dungeon) do
		for idx2, tbl2 in pairs(tbl) do
			i = i + 1
			-- 3개 마다 콤마
			if i == num then
				desc = desc..idx2
			elseif i % 3 == 0 then
				desc = desc..idx2.."\n"
			else
				desc = desc..idx2..", "
			end
		end
	end
	if desc == "" then
		desc = FP_DUNGEONFILTER_NONE
	end

	return desc
end

function FP_SetDungeonFilterText()
	local desc = FP_DUNGEONFILTER_NOT_FILTERED
	local filtered_count = getDungeonFilterNum()

	if isDungeonFiltering and filtered_count > 1 then
		desc = string.format(FP_DUNGEONFILTER_MULTI, filtered_count)
	elseif isDungeonFiltering and filtered_count > 0 then
		for idx, tbl in pairs(FP_Filter_Dungeon) do
			for idx2, tbl2 in pairs(tbl) do
				desc = string.format(FP_DUNGEONFILTER_SINGLE, idx2)
			end
		end
	end

	FP_ListFrameFilterDungeonText:SetText(desc)
end

function FP_DungeonFilter(dungeon, difficulty)
	if isDungeonFiltering and getDungeonFilterNum() > 0 then
		for idx, tbl in pairs(FP_Filter_Dungeon) do
			for idx2, tbl2 in pairs(tbl) do
				if dungeon == idx2 then
					for idx3, tbl3 in pairs(tbl2) do
						if difficulty == idx3 then
							return true
						end
					end
				end
			end
		end
		return false
	end
	return true
end

--[[- 2016-10-23 아리보리(아즈샤라)
--
-- 사용자 필터 기능 추가.
-- 사용자가 직접 입력한 필터를 검사하여, 원하는 광고를 구체적으로 필터링 할 수 있다.
-- FP_CustomFiletr 함수는 광고 문자열을 인자로 받아, 사용자가 직접 입력한 문자들과 대조해
-- 입력한 문자열이 광고 문자열 내에 존재하면 true, 아니면 false를 반환한다.
-- -]]

--[[- 2019-02-25 아리보리(아즈샤라)
-- query 지원
-- 특정단어 제외 기능 추가
-- -]]
function FP_CustomFilter(msg)
	local result = {
		['flag'] = false,
		['msg'] = msg
	}
	local userInputCustomFilterString = FP_UserDefineFilterMsg
	if userInputCustomFilterString == "" then
		result.flag = true
		result.msg = msg
		return result
	end

	local includePattern = '([^,+-]+)'
	local excludePattern = '([-]+[^%p]+)'
	local includeCount = 0;
	local excludeCount = 0;

	for word in string.gmatch(userInputCustomFilterString, includePattern) do
		includeCount = includeCount + 1;
	end

	for word in string.gmatch(userInputCustomFilterString, excludePattern) do
		word = string.gsub(word, "-", "")
		excludeCount = excludeCount + 1;
		if string.find(msg, word) then
			result.flag = false
			result.msg = msg
			return result
		end
	end

	if (includeCount - excludeCount == 0) then
		result.flag = true
		result.msg = msg
		return result
	end

	for word in string.gmatch(userInputCustomFilterString, includePattern) do
		word = string.gsub(word, " ", "")
		if string.find(msg, word) then
			msg = string.gsub(msg, word, '|cff7fff00'..word..'|cffffffff')
			result.flag = true
			result.msg = msg
		end
	end

	return result
end

function FP_SetCustomFilterText()
	FP_UserDefineFilterMsg = FP_MenuFrameFilterText:GetText();
end

-----------------
-- 제외 필터링 --
-----------------
function FP_ExceptionFilter(exception)
	if exceptionData then
		for i = 1, #exceptionData, 1 do
			if (exceptionData[i]==exception) then
				return false
			end
		end
	end
	return true
end

---------------------------------------
-- 애드온의 기능들을 처리하는 함수들 --
---------------------------------------
function FP_Activate(active, noMsg)
	FP_Options.activated = active
	if active then
		if not noMsg then FP_Print(string.format(FP_MESSAGE_ACTIVE, FP_DISPLAY_VERSION)) end
		FP_TitleFrameText:SetText(FP_C_TITLE)
		FP_TitleFrameActivation:SetNormalTexture("Interface\\AddOns\\FindParty\\activated")
		FP_RemoveAllList()
		FP_Refresh()
	else
		if not noMsg then FP_Print(string.format(FP_MESSAGE_DEACTIVE, FP_DISPLAY_VERSION)) end
		FP_TitleFrameText:SetText(FP_C_TITLE.." "..FP_TEXT_STOPPED)
		FP_TitleFrameActivation:SetNormalTexture("Interface\\AddOns\\FindParty\\deactivated")
		collectgarbage("collect")
	end
end

function FP_ActiveBellnWindow(active)
	FP_Options.activateBellnWindow = active
	if active then
		FP_Print(FP_MESSAGE_POPUP_ACTIVE)
		FP_TitleFrameActivateBellnWindow:SetNormalTexture("Interface\\AddOns\\FindParty\\bellActivated")
	else
		FP_Print(FP_MESSAGE_POPUP_DEACTIVE)
		FP_TitleFrameActivateBellnWindow:SetNormalTexture("Interface\\AddOns\\FindParty\\bellDeactivated")
	end
end

function FP_AutoDeactivate()
	local _, instancetype = GetInstanceInfo()
	if FP_Options.activated then
		if instancetype == "raid" and FP_Options.noraid then FP_Activate(false) end
		if instancetype == "pvp" and FP_Options.nopvp then FP_Activate(false) end
	elseif not FP_Options.useroffed and not FP_Options.activated then
		if FP_Options.noraid and FP_Options.nopvp then
			if instancetype ~= "raid" and instancetype ~= "pvp" then FP_Activate(true) end
		elseif FP_Options.noraid then
			if instancetype ~= "raid" then FP_Activate(true) end
		elseif FP_Options.nopvp then
			if instancetype ~= "pvp" then FP_Activate(true) end
		end
	end
end

function FP_Whisper(target)
	local msg = FP_MenuFrameWhText:GetText()
	FP_UserDefinedWhMsg = msg -- For save
	if (not msg or string.len(msg) == 0) then
		local playerClass = UnitClass("player")
		local myTalent = FP_GetMyTalent()
		msg = string.format(FP_DEFAULT_WHISPER, myTalent, playerClass)
	end

	SendChatMessage(msg, "WHISPER", nil, target)
end

function FP_Exception(target)
	if exceptionData then
		savePlace = #exceptionData + 1
	else
		savePlace = 1
	end
	exceptionData[savePlace] = target

	FP_Print(string.format(FP_MESSAGE_EXCEPTION, target))
	FP_Refresh(true)
end

function FP_GetMyTalent()
	local myTalent
	local talentNumber = GetSpecialization()
	local _, talentTabName = GetSpecializationInfo(talentNumber)
	myTalent = talentTabName

	return myTalent
end

function FP_Announce()
	local msg = FP_MenuFrameAdText:GetText()
	FP_UserDefinedAdMsg = msg -- For save
	if (not msg or string.len(msg) == 0) then
		FP_Print(FP_MESSAGE_NO_AD_TEXT)
		FP_StopAnnounce()
		return
	end

	local list = { GetChannelList() }
	local chaNum = 0
	for chan, enabled in pairs(FP_Options.channel) do
		if enabled then
			local found
			for i = 1, #list/2 do
				if list[i * 2] == chan then
					chaNum = list[i * 2 - 1]
					found = true
					break
				end
			end
			if found then
				SendChatMessage(msg, "CHANNEL", nil, chaNum)
				found = nil
			end
		end
	end
end

function FP_StartAnnounce()
	FP_Print(FP_MESSAGE_START_AD)
	isAnnouncing = true
	lastAnnouncedTime = GetTime()

	FP_MenuFrameAnnounce:SetText(FP_TEXT_STOP_AD)
	FP_TitleFrameAnnouncing:SetNormalTexture("Interface\\Icons\\INV_Misc_GroupNeedMore")
end

function FP_StopAnnounce()
	FP_Print(FP_MESSAGE_STOP_AD)
	isAnnouncing = false
	lastAnnouncedTime = 0

	FP_MenuFrameAnnounce:SetText(FP_TEXT_START_AD)
	FP_TitleFrameAnnouncing:SetNormalTexture("Interface\\Icons\\INV_Misc_GroupLooking")
end

function FP_IsAnnoucing()
	return isAnnouncing
end

------------------------------
-- UI 버튼 클릭시 처리 부분 --
------------------------------
function FP_SortButtonClicked(self)
	local id = self:GetID()

	column = colName[id]

	sortData[column] = not sortData[column]
	sortData.current_sort = column

	FP_Refresh()
	return sortData[column]
end

function FP_ListSort(list, col, ascd)
	if list ~= nil and col ~= nil then
		local endIdx = getn(list)
		for i = 1, endIdx,1 do
			for j = i + 1, endIdx, 1 do
				local pivot = list[i][col]
				local comp = list[j][col]

				if col == "dungeon" then
					pivot = pivot..list[i]["mode"]
					comp = comp..list[j]["mode"]
				end
				if ((ascd and (pivot > comp)) or (not ascd and (pivot < comp))) then
					local temp = list[i]
					list[i] = list[j]
					list[j] = temp
				end
			end
		end
	end
end

function FP_MenuClicked(self, button, menu, option)
	if menu == "MENU_FILTERDUNGEON" then
		if button == "LeftButton" then
			local filtered_count = getDungeonFilterNum()
			if filtered_count > 0 and not isDungeonFiltering then
				toggleDungeonFilter()
				FP_SetDungeonFilterText()
				FP_Print(FP_MESSAGE_START_DUNGEON_FILTER)
			elseif filtered_count > 0 then
				toggleDungeonFilter()
				FP_SetDungeonFilterText()
				FP_Print(FP_MESSAGE_STOP_DUNGEON_FILTER)
			else
				FP_SortButtonClicked(self)
			end
			FP_Refresh()
		elseif button == "RightButton" then
			UIDropDownMenu_Initialize(FP_DropDownMenu, FP_DropDownMenuFilterDungeon_Initialize)
			ToggleDropDownMenu(1, nil, FP_DropDownMenu, FP_ListFrameFilterDungeon, 0, 0)
		end
	elseif menu == "MENU_OPTION" then
		UIDropDownMenu_Initialize(FP_DropDownMenu, FP_DropDownMenuOption_Initialize)
		ToggleDropDownMenu(1, nil, FP_DropDownMenu, FP_TitleFrameOption, 0, 0)
	elseif menu == "MENU_APPLY" then
		if shouterSelected then
			FP_Whisper(shouterSelected.name)
		else
			FP_Print(FP_MESSAGE_NOTARGET)
		end
	elseif menu == "MENU_WHISPER" then
		if shouterSelected then
			ChatFrame_SendTell(shouterSelected.name, FCF_GetCurrentChatFrame())
		else
			FP_Print(FP_MESSAGE_NOTARGET)
		end
	elseif menu == "MENU_WHO" then
		if shouterSelected then
			SendWho(shouterSelected.name)
		else
			FP_Print(FP_MESSAGE_NOTARGET)
		end
	elseif menu == "MENU_EXCEPTION" then
		if shouterSelected then
			FP_Exception(shouterSelected.name)
		else
			FP_Print(FP_MESSAGE_NOTARGET)
		end
	elseif menu == "MENU_EXCEPTION_DELETE" then
		exceptionData = {}
		FP_Print(FP_MESSAGE_CLEAR_EXCEPTION)
	elseif menu == "MENU_ANNOUNCE" then
		if isAnnouncing then
			FP_StopAnnounce()
		else
			FP_StartAnnounce()
		end
	elseif menu == "APPLY_FILTER" then
		FP_SetCustomFilterText()
		FP_Print(FP_MESSAGE_APPLY_CUSTOM_FILTER)
	elseif menu == "MENU_ACTIVATE_BELLNWINDOW" then
		if FP_Options.activateBellnWindow then
			FP_ActiveBellnWindow(false)
		else
			FP_ActiveBellnWindow(true)
		end
	elseif menu == "MENU_ACTIVATION" then
		if FP_Options.activated then
			FP_Activate(false)
			FP_Options.useroffed = true
		else
			FP_Activate(true)
			FP_Options.useroffed = false
		end
	elseif menu == "MENU_INC" then
		FP_ListAdjust(INC)
	elseif menu == "MENU_DEC" then
		FP_ListAdjust(DEC)
	elseif menu == "MENU_MAX" then
		FP_ListAdjust(MAX)
	elseif menu == "MENU_MIN" then
		FP_ListAdjust(MIN)
	elseif menu == "MENU_INFO" then
		for i, v in ipairs(FP_HELPS) do FP_Nprint(v) end
	elseif menu == "SEL_SHOUT" then
		local index = self:GetID()
		local data = frameData[index]
		if button == "LeftButton" then
			if IsAltKeyDown() then
				shouterSelected = data
				FP_Whisper(shouterSelected.name)
			elseif IsShiftKeyDown() then
				shouterSelected = data
				SendWho(shouterSelected.name)
			elseif IsControlKeyDown() then
				shouterSelected = data
				FP_Exception(shouterSelected.name)
			else
				if shouterSelected == data then
					shouterSelected = nil
				else
					shouterSelected = data
				end
			end
			FP_Refresh()
		elseif button == "RightButton" then
			if IsAltKeyDown() then
				shouterSelected = data
				ChatFrame_SendTell(shouterSelected.name, FCF_GetCurrentChatFrame())
			elseif FP_Options.rightButton then
				-- 2016.10.23 아리보리(아즈샤라) 추가

				-- 파티찾기 창을 띄워놓고 퀘스트를 하다가 자꾸 오른쪽 클릭 실수로 귓말은 보내게 되어
				-- Ctrl 키까지 눌러야 귓말이 가도록 수정
				if IsControlKeyDown() then
					shouterSelected = data
					FP_Whisper(shouterSelected.name)
				end
			end
		end
	end
end

function FP_IconClicked(self, button)
	if button == "LeftButton" then
		if IsAltKeyDown() then
			if FP_Minimap_Button:IsShown() then
				FP_Options.iconLocked = not FP_Options.iconLocked
				if FP_Options.iconLocked then
					FP_Print(FP_MESSAGE_ICON_LOCK)
					FP_Minimap_Button:RegisterForDrag(nil)
					GameTooltip:Hide()
				else
					FP_Print(FP_MESSAGE_ICON_UNLOCK)
					FP_Minimap_Button:RegisterForDrag("LeftButton")
					GameTooltip:Hide()
				end
			end
		elseif (IsShiftKeyDown()) then
			if FP_Options.activated then
				FP_Activate(false)
				FP_Options.useroffed = true
			else
				FP_Activate(true)
				FP_Options.useroffed = false
			end
		elseif (IsControlKeyDown()) then
			if isAnnouncing then
				FP_StopAnnounce()
			else
				FP_StartAnnounce()
			end
		else
			if FP_Frame:IsShown() then
				FP_Frame:Hide()
			else
				FP_Frame:Show()
			end
		end
	elseif button == "RightButton" then
		UIDropDownMenu_Initialize(FP_DropDownMenu, FP_DropDownMenuOption_Initialize)
		ToggleDropDownMenu(1, nil, FP_DropDownMenu, self, 0, 0)
	end
end

-----------------------------------
-- 목록 프레임을 처리하는 함수들 --
-----------------------------------
function FP_Refresh(quick)
	local listOffset = FauxScrollFrame_GetOffset(FP_ListFrameScrollFrame)
	if not listOffset then listOffset = 0 end

	if not quick then
		local sort_col = sortData.current_sort
		local ascd = sortData[sort_col]

		FP_ListSort(frameData, sort_col, ascd)
	end

	local maxScroll = 0
	local rowIdx = 1

	for i = 1, table.getn(frameData) do
		local info = frameData[i]
		if info then

			--[[- 2016-10-23 아리보리(아즈샤라)
			--
			-- 사용자 필터 기능 추가.
			-- 사용자가 직접 입력한 필터를 검사하여, 원하는 광고를 구체적으로 필터링 할 수 있다.
			-- FP_CustomFiletr 함수는 광고 문자열을 인자로 받아, 사용자가 직접 입력한 문자들과 대조해
			-- 입력한 문자열이 광고 문자열 내에 존재하면 true, 아니면 false를 반환한다.
			-- -]]
			local filtered = FP_CustomFilter(info.msg)
			if (not FP_DungeonFilter(info.dungeon, info.mode) or not FP_ExceptionFilter(info.name) or not filtered.flag) then
				if info == shouterSelected then
					shouterSelected = nil
				end
				info.enabled = false
				info.num = nil
			else
				maxScroll = maxScroll + 1
				info.enabled = true
				info.num = maxScroll
			end


			if info.enabled and info.num > listOffset and rowIdx <= FP_Options.viewLines then
				local rowName = "FP_ListFrameRow"..tostring(rowIdx)
				if info.time <= 0 then
					if FP_Options["activateBellnWindow"] then
						PlaySoundFile("Interface\\AddOns\\FindParty\\FindParty.ogg")
						FP_Frame:Show()
						info.time = 1
					end
				end
				_G[rowName]:Show()
				_G[rowName]:SetID(i)
				-- Time
				_G[rowName.."TimeText"]:SetText(info.time)

				--Message
				local msg = filtered.msg

				_G[rowName.."MsgText"]:SetText(msg)
				_G[rowName.."DungeonText"]:SetText(info.dungeon)

				-- Coloring
				if info.mode then
					for i = 1, table.getn(FP_DIFFICULTY_KEYWORDS) do
						if info.mode == FP_DIFFICULTY_KEYWORDS[i].dbname then
							_G[rowName.."DungeonText"]:SetTextColor(FP_DIFFICULTY_KEYWORDS[i].color[1], FP_DIFFICULTY_KEYWORDS[i].color[2], FP_DIFFICULTY_KEYWORDS[i].color[3])
							_G[rowName.."DungeonText"]:SetText(info.dungeon..FP_DIFFICULTY_KEYWORDS[i].postfix)
						end
					end
				end

				-- Name
				local name = info.name
				if info.class then
					local color = RAID_CLASS_COLORS[info.class]
					if color then
						_G[rowName.."NameText"]:SetTextColor(color.r, color.g, color.b)
					end
				else
					_G[rowName.."NameText"]:SetTextColor(1,1,1)
				end
				_G[rowName.."NameText"]:SetText(name)

				-- Highlight
				if info == shouterSelected then
					_G[rowName]:LockHighlight()
				else
					_G[rowName]:UnlockHighlight()
				end
				rowIdx = rowIdx + 1
			end
		end
	end
	for i = rowIdx, 20 do
		local rowName = "FP_ListFrameRow"..tostring(i)
		_G[rowName]:Hide()
	end
	FauxScrollFrame_Update(FP_ListFrameScrollFrame, maxScroll, FP_Options.viewLines, 25)
end

function FP_ListAdjust(adjust)
	local newNumRow
	local curNumRow = FP_Options.viewLines
	if not adjust then
		local curHeight = FP_ListFrame:GetHeight()
		if curHeight > 540 then curHeight = 540 end
		newNumRow = math.floor((curHeight - 40) / 25)
	elseif (adjust == INC) then
		newNumRow = math.min(20, FP_Options.viewLines + 1)
	elseif (adjust == DEC) then
		newNumRow = math.max(1, FP_Options.viewLines - 1)
	elseif (adjust == MAX) then
		newNumRow = 20
	elseif (adjust == MIN) then
		newNumRow = 1
	end

	local newWidth = FP_ListFrame:GetWidth() or 750
	FP_TitleFrame:SetWidth(newWidth)
	FP_ListFrame:SetWidth(newWidth)
	FP_MenuFrame:SetWidth(newWidth)
	if newWidth < 1500 then
		FP_MenuFrameWhText:SetWidth(newWidth-210)
		FP_MenuFrameAdText:SetWidth(newWidth-210)
		FP_MenuFrameFilterText:SetWidth(newWidth-210)
	end
	local newHeight = 40 + (newNumRow * 25)
	FP_ListFrame:SetHeight(newHeight)

	-- 구한값들을 저장
	FP_Position_Save.width = newWidth
	FP_Options.viewLines = newNumRow
	FP_ListMove()

	-- 화면 갱신
	FP_Refresh()
end

function FP_ListMove()
	FP_Position_Save.point, _, FP_Position_Save.relpoint, FP_Position_Save.x, FP_Position_Save.y = FP_ListFrame:GetPoint()
end

function FP_UIResize(scale)
	FP_Frame:SetScale(scale)
end

function FP_FontResize()
	for i = 1, 20 do
		local rowName = "FP_ListFrameRow"..i
		for j = 1, 3 do
			local tempFrame = _G[rowName..colFrame[j]]
			local fontFile, unused, fontFlags = tempFrame:GetFont()
			tempFrame:SetFont(fontFile, FP_Options.fontsize, fontFlags)
		end
	end
end

function FP_SetListColor()
	FP_ListFrame:SetBackdropColor(FP_Options.color.r, FP_Options.color.g, FP_Options.color.b, FP_Options.color.opacity)
end

function FP_SetListPosition()
	if FP_Position_Save.x and FP_Position_Save.y and FP_Position_Save.width and FP_Options.viewLines then
		FP_ListFrame:ClearAllPoints()
		FP_TitleFrame:SetWidth(FP_Position_Save.width)
		FP_ListFrame:SetWidth(FP_Position_Save.width)
		FP_MenuFrame:SetWidth(FP_Position_Save.width)
		FP_ListFrame:SetPoint(FP_Position_Save.point, UIParent, FP_Position_Save.relpoint, FP_Position_Save.x, FP_Position_Save.y)
		if FP_Position_Save.width < 1500 then
			FP_MenuFrameWhText:SetWidth(FP_Position_Save.width-210)
			FP_MenuFrameAdText:SetWidth(FP_Position_Save.width-210)
			FP_MenuFrameFilterText:SetWidth(FP_Position_Save.width-210)
		end
		FP_ListFrame:SetHeight(40 + (FP_Options.viewLines * 25))
	else
		FP_ListAdjust()
	end
end

-------------------------
-- 설정 메뉴 처리 부분 --
-------------------------
local function getChannel()
	table.wipe(FP_Option_Menu[1]["value"])
	local list = { GetChannelList() }
	for i = 1, #list/2 do
		table.insert(FP_Option_Menu[1]["value"], list[i * 2])
	end
end

local function setChannel(self, channel)
	if FP_Options["channel"][channel] then
		FP_Options["channel"][channel] = nil
	else
		FP_Options["channel"][channel] = true
	end
	-- 존재하지 않는 채널 제거
	local list = { GetChannelList() }
	for channelname, bool in pairs(FP_Options["channel"]) do
		local isValidChannel = false
		for i = 1, #list/2 do
			if list[i * 2] == channelname then
				isValidChannel = true
				break
			end
		end
		if not isValidChannel then
			FP_Options["channel"][channelname] = nil
		end
	end
end

local function setOption(self, option, number)
	if not option or not number then return end
	FP_Options[option] = number

	-- 창 크기 및 폰트 옵션 변경 처리
	if option == "scale" then
		FP_UIResize(FP_Options.scale)
	elseif option == "fontsize" then
		FP_FontResize()
	end

	-- 체크표시 동기화를 위한 부분
	if UIDROPDOWNMENU_MENU_LEVEL == 2 then
		for idx, tbl in ipairs(FP_Option_Menu) do
			if tbl.dbname == option then
				for i = 1, (table.getn(tbl.value) or 1) do
					local button = _G["DropDownList2Button"..i]
					if FP_Options[option] == button.value then
						_G["DropDownList2Button"..i.."Check"]:Show()
					else
						_G["DropDownList2Button"..i.."Check"]:Hide()
					end
				end
			end
		end
	end
end

local function setWindowColor(previousValues)
	if (not previousValues) then
		FP_Options.color.r, FP_Options.color.g, FP_Options.color.b = ColorPickerFrame:GetColorRGB()
		FP_Options.color.opacity = OpacitySliderFrame:GetValue()
	else
		FP_Options.color=previousValues
	end

	FP_SetListColor()
end

function FP_SetSpecialFrame(value)
	FP_Options.esc = value
	if FP_Options.esc then
		tinsert(UISpecialFrames, "FP_Frame")
	else
		for i = 1, #UISpecialFrames do
			local v = UISpecialFrames[i]
			if (v == "FP_Frame") then
				table.remove(UISpecialFrames, i)
			end
		end
	end
end

function FP_Minimap_ButtonToggle(value)
	FP_Options.icon = value
	if FP_Options.icon then
		FP_Minimap_Button:Show()
	else
		FP_Minimap_Button:Hide()
	end
end

function FP_LoadDefaultWinPos()
	FP_Position_Save = {
		["point"] = "CENTER",
		["relpoint"] = "CENTER",
		["x"] = 0,
		["y"] = 0,
		["width"] = FP_Position_Save.width or 750
	}
	FP_Minimap_Save = {
		ButtonRadius = 78,
		ButtonShown = true,
		ButtonPosition = 336,
		Angle = 0
	}
	FP_Minimap_Button_UpdatePosition()
	FP_Options.viewLines = FP_Options.viewLines or 20
	FP_SetListPosition()
end

function FP_LoadDefaultWinSize()
	FP_Position_Save = {
		["point"] = FP_Position_Save.point or "CENTER",
		["relpoint"] = FP_Position_Save.relpoint or "CENTER",
		["x"] = FP_Position_Save.x or 0,
		["y"] = FP_Position_Save.y or 0,
		["width"] = 750
	}
	FP_Options.viewLines = 20
	FP_Options.scale = 1
	FP_UIResize(FP_Options.scale)
	FP_SetListPosition()
end

function FP_LoadDefaultOption()
	FP_Print(FP_MESSAGE_RESETALL)

	FP_Options = {}
	for k,v in pairs(FP_Default_Options) do
		FP_Options[k] = v
	end
	FP_Options.channel = {}
	for k,v in pairs(FP_Default_Options.channel) do
		FP_Options.channel[k] = v
	end
	FP_Options.color = {}
	for k,v in pairs(FP_Default_Options.color) do
		FP_Options.color[k] = v
	end

	FP_Filter_Dungeon = {}

	FP_Position_Save = {
		["point"] = "CENTER",
		["relpoint"] = "CENTER",
		["x"] = 0,
		["y"] = 0,
		["width"] = 750
	}
	FP_Minimap_Save = {
		ButtonRadius = 78,
		ButtonShown = true,
		ButtonPosition = 336,
		Angle = 0
	}
	FP_Minimap_Button_UpdatePosition()
	FP_UIResize(FP_Options.scale)
	FP_SetListPosition()

	FP_Frame:Hide()
end

function FP_DropDownMenuOption_Initialize(frame, level, menu)
	level = level or 1
	local info
	if (level == 1) then
		for idx, tbl in ipairs(FP_Option_Menu) do
			info = UIDropDownMenu_CreateInfo()
			info.text = tbl.name
			info.keepShownOnClick = true
			info.disabled = tbl.name == ""
			info.hasArrow = type(tbl.value) == "table"
			info.notCheckable = type(tbl.exec) ~= "function"
			info.func = tbl.exec or nil
			info.checked = FP_Options[tbl.dbname] or false
			info.menuList = tbl.dbname
			info.value = tbl.value or nil
			if tbl.dbname == "color" then
				info.keepShownOnClick = false
				info.hasColorSwatch = true
				info.hasOpacity = true
				info.r = FP_Options.color.r
				info.g = FP_Options.color.g
				info.b = FP_Options.color.b
				info.opacity = FP_Options.color.opacity
				info.func = UIDropDownMenuButton_OpenColorPicker
				info.swatchFunc = setWindowColor
				info.opacityFunc = setWindowColor
				info.cancelFunc = setWindowColor
			end
			if tbl.dbname == "close" then
				info.keepShownOnClick = false
				info.func = nil
			end
			UIDropDownMenu_AddButton(info, level)
		end
	end

	if (level == 2) then
		if menu == "channel" then
			getChannel()
			info = UIDropDownMenu_CreateInfo()
			info.keepShownOnClick = true
			for i = 1, table.getn(UIDROPDOWNMENU_MENU_VALUE) do
				info.text = UIDROPDOWNMENU_MENU_VALUE[i]
				info.checked = FP_Options[menu][info.text]
				info.arg1 = info.text
				info.func = setChannel
				UIDropDownMenu_AddButton(info, level)
			end
		elseif menu == "interval" or menu == "valid" or menu == "fontsize" or menu == "scale" then
			info = UIDropDownMenu_CreateInfo()
			info.keepShownOnClick = true
			for i = 1, table.getn(UIDROPDOWNMENU_MENU_VALUE) do
				info.text = UIDROPDOWNMENU_MENU_VALUE[i]
				info.checked = info.text == tostring(FP_Options[menu])
				info.arg1 = menu
				info.arg2 = tonumber(info.text)
				info.value = tonumber(info.text)
				info.func = setOption
				UIDropDownMenu_AddButton(info, level)
			end
		elseif menu == "reset" then
			info = UIDropDownMenu_CreateInfo()
			info.notCheckable = true
			info.keepShownOnClick = false
			for idx, tbl in ipairs(UIDROPDOWNMENU_MENU_VALUE) do
				info.text = tbl.name
				info.func = tbl.exec
				UIDropDownMenu_AddButton(info, level)
			end
		end
	end
end

----------------------
-- 이벤트 처리 부분 --
----------------------
function FP_AddList(name, rawmsg, class)
	local msg
	local msg_dungeon
	local t = GetTime()
	
	-- See if sender already exists in our frameData
	if frameData[name] then
		if (t - frameData[name].fullscan) < 90 then
			if rawmsg == frameData[name].rawmsg then
				frameData[name].time = 0
				return
			--[[else
				msg = FP_FilterIgnoreText(rawmsg, FP_TOOLTIP_IGNORE_KEYWORDS, true)
				msg_dungeon = FP_FilterIgnoreText(msg, FP_DUNGEON_IGNORE_KEYWORDS)
				if msg_dungeon == nil then return end
				if string.find(msg_dungeon, frameData[name].dungeon_keyword) then
					frameData[name].msg = msg
					frameData[name].rawmsg = rawmsg
					frameData[name].time = 0
					FP_Refresh(quick)
					return
				end]]
			end
		end
	end
	
	-- Dungeon Parse
	local dungeon, difficulty, dungeon_keyword = FP_DungeonParse(rawmsg)
	
	if dungeon then
		msg = FP_FilterIgnoreText(rawmsg, FP_TOOLTIP_IGNORE_KEYWORDS, true)

		if frameData[name] then
			frameData[name].dungeon = dungeon
			frameData[name].dungeon_keyword = dungeon_keyword
			frameData[name].msg = msg
			frameData[name].rawmsg = rawmsg
			frameData[name].time = 0
			frameData[name].mode = difficulty
			frameData[name].fullscan = t
		else
			local info = {}
			info.name = name
			info.class = class
			info.msg = msg
			info.rawmsg = rawmsg
			info.dungeon = dungeon
			info.dungeon_keyword = dungeon_keyword
			info.mode = difficulty
			info.time = 0
			info.fullscan = t
			info.enabled = nil
			info.num = nil
			table.insert(frameData, info)
			frameData[name] = info
		end

		FP_Refresh()
	end
end

function FP_RemoveList(name)
	if frameData[name] then
		if shouterSelected and shouterSelected.name == name then
			shouterSelected = nil
		end

		for i = 1, table.getn(frameData) do
			if frameData[i].name == name then
				table.remove(frameData, i)
				break
			end
		end
		frameData[name] = nil
		FP_Refresh()
	end
end

function FP_RemoveAllList()
	frameData = {}
	shouterSelected = nil
	collectgarbage("collect")
end

function FP_Print(msg)
	if msg and DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00FindParty: |cffffff00"..tostring(msg)) end
end

function FP_Nprint(msg)
	if msg and DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage(tostring(msg)) end
end

function FP_OnLoad()
	FP_InviteControlFrame:RegisterEvent("VARIABLES_LOADED")
	FP_InviteControlFrame:RegisterEvent("CHAT_MSG_CHANNEL")
	FP_InviteControlFrame:RegisterEvent("CHAT_MSG_SYSTEM")
	FP_InviteControlFrame:RegisterEvent("WHO_LIST_UPDATE")
	FP_InviteControlFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	FP_InviteControlFrame:RegisterEvent("ZONE_CHANGED")
	FP_InviteControlFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
	FP_InviteControlFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
end

function FP_OnEvent(event, ...)
	if event=="VARIABLES_LOADED" then
		FP_InviteControlFrame:UnregisterEvent("VARIABLES_LOADED")
		FP_Init()
	end
	-- 자동 비활성화 기능 관련 이벤트 등록
	if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA" then
		if FP_Options.noraid or FP_Options.nopvp then FP_AutoDeactivate() end
	end

	-- 활성화 되어 있지 않을 경우 메세지 처리 안함
	if not FP_Options.activated then return end

	if event == "CHAT_MSG_CHANNEL" then
		local arg1, arg2, _, _, _, _, _, _, arg9, _, _, arg12 = ...
		
		-- 제외부터 필터
		if exceptionData then
			for _,v in pairs(exceptionData) do
				if arg1 == v then
					return
				end
			end
		end
		
		-- remove zone suffix
		local isZoneChannel = string.find(arg9, " - ")
		if isZoneChannel then
			arg9 = string.sub(arg9, 1, isZoneChannel - 1)
		end
		
		-- now pass to FP_AddList()
		if arg1 and FP_Options.channel[arg9] then
			local name = Ambiguate(arg2, "none")
			local _, class = GetPlayerInfoByGUID(arg12)
			FP_AddList(name, arg1, class)
		end
	end
end

function FP_OnUpdate(self, elapsed)
	-- 자동 광고기능. 활성화 유무에 관련 없이 동작
	if isAnnouncing then
		lastAnnouncedTime = lastAnnouncedTime + elapsed

		if lastAnnouncedTime > FP_Options.interval then
			FP_Announce()
			lastAnnouncedTime = 0
		end
	end

	-- 비 활성화시 프레임 업데이트 안함
	if not FP_Options.activated then return end
	lastUpdatedTime = lastUpdatedTime + elapsed
	if lastUpdatedTime > FP_UPDATE_INTERVAL and table.getn(frameData) > 0 then
		local i = 1
		while i <= table.getn(frameData) do
			frameData[i].time = frameData[i].time + FP_UPDATE_INTERVAL

			if frameData[i].time > FP_Options.valid then
				FP_RemoveList(frameData[i].name)
			else
				i = i + 1
			end

		end
		lastUpdatedTime = 0

		FP_Refresh(true)
	end
end

------------------------
-- 슬래쉬 명령어 등록 --
------------------------
SLASH_FINDPARTY1 = "/FP"
SLASH_FINDPARTY2 = "/fp"
SLASH_FINDPARTY3 = "/findparty"

SlashCmdList["FINDPARTY"] = function(msg)
	if FP_Frame:IsShown() then
		FP_Frame:Hide()
	else
		FP_Frame:Show()
	end
end
