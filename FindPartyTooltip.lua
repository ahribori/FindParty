
FP_Tooltip_Func = {
	["DEFAULT"] = function(msg, frame, anchor, pX, pY)
		GameTooltip:SetOwner(frame, 'ANCHOR_TOPRIGHT');
		GameTooltip:ClearLines();
		GameTooltip:AddLine(msg);
		GameTooltip:Show();
	end,
	["LIST"] = function(self)
		local text = getglobal(self:GetName().."MsgText"):GetText();
		if (text) then
			FP_Tooltip_Func.DEFAULT(text, getglobal(self:GetName().."Msg"), "ANCHOR_BOTTOMLEFT", getglobal(self:GetName().."Msg"):GetWidth(), 0);
		end
	end,
	["SORTTIME"] = function(self)
		FP_Tooltip_Func.DEFAULT("시간순으로 정렬", self, "ANCHOR_BOTTOM", 80, 0);
	end,
	["FILTERDUNGEON"] = function(self)
		local msg = "왼쪽 클릭 : 모든 던전 정렬\n오른쪽 클릭 : 관심 던전 광고만 골라냄";
		local desc = FP_GetDungeonFilterDesc();
		if (desc) then
			msg = msg.."\n선택 : "..desc;
		end
		FP_Tooltip_Func.DEFAULT(msg, self, "ANCHOR_BOTTOM", 170, 0);
	end,
	["FILTERCLASS"] = function(self)
		local msg = "왼쪽 클릭 : 내 직업 골라냄\n오른쪽 클릭 : 관심 직업만 골라냄";
		local desc = FP_GetClassFilterInfo();
		if (desc) then
			msg = msg.."\n현재 선택 : "..desc;
		end
		FP_Tooltip_Func.DEFAULT(msg, self, "ANCHOR_TOPRIGHT", 0 - (self:GetWidth()/2- 120), 0);
	end,
	["TITLEBAR"] = function(self)
		FP_Tooltip_Func.DEFAULT("", self, "ANCHOR_TOPRIGHT",-250, 0);
	end,
	["CLOSE"] = function(self)
		FP_Tooltip_Func.DEFAULT("창 닫기", self, "ANCHOR_BOTTOM", 50, 0);
	end,
	["MAXMIZE"] = function(self)
		FP_Tooltip_Func.DEFAULT("창 최대화", self, "ANCHOR_BOTTOM", 50, 0);
	end,
	["MINIMIZE"] = function(self)
		FP_Tooltip_Func.DEFAULT("창 최소화", self, "ANCHOR_BOTTOM", 50, 0);
	end,
	["DECREASE"] = function(self)
		FP_Tooltip_Func.DEFAULT("창 줄이기", self, "ANCHOR_BOTTOM", 50, 0);
	end,
	["INCREASE"] = function(self)
		FP_Tooltip_Func.DEFAULT("창 늘리기", self, "ANCHOR_BOTTOM", 50, 0);
	end,
	["OPTION"] = function(self)
		FP_Tooltip_Func.DEFAULT("옵션", self, "ANCHOR_BOTTOM",40, 0);
	end,
	["ACTIVATE"] = function(self)
		local msg;
		if (FP_Options.activated) then
			msg = "작동중\n클릭하면 작동 중단";
		else
			msg = "쉬는중\n클릭하면 다시 작동";
		end
		FP_Tooltip_Func.DEFAULT(msg, self, "ANCHOR_BOTTOM",50, 0);
	end,
	["ANNOUNCE"] = function(self)
		local msg;
		if (FP_IsAnnoucing()) then
			msg = "파티 광고중\n클릭하면 중단";
		else
			msg = "클릭하면 파티광고 시작";
		end
		FP_Tooltip_Func.DEFAULT(msg, self, "ANCHOR_BOTTOM",80, 0);
	end,
	["ACTIVATEBELLNWINDOW"] = function(self)
		local msg;
		if (FP_IsActiveBellnWindow()) then
			msg = "팝업 모드 작동중\n클릭하면 중단";
		else
			msg = "팝업 모드 쉬는중";
		end
		FP_Tooltip_Func.DEFAULT(msg, self, "ANCHOR_BOTTOM",80, 0);
	end,
	["APPLYBINDING"] = function(self)
		local msg = "단축키 : Alt + Click";
		FP_Tooltip_Func.DEFAULT(msg, self, "ANCHOR_BOTTOM",80, 0);
	end,
	["EXCEPTIONBINDING"] = function(self)
		local msg = "단축키 : Ctrl + Click";
		FP_Tooltip_Func.DEFAULT(msg, self, "ANCHOR_BOTTOM",80, 0);
	end,
	["WHOBINDING"] = function(self)
		local msg = "단축키 : Shift + Click";
		FP_Tooltip_Func.DEFAULT(msg, self, "ANCHOR_BOTTOM",80, 0);
	end,
};
