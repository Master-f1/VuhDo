local _;

local VUHDO_IS_SMART_CAST = false;

local IsAltKeyDown = IsAltKeyDown;
local IsControlKeyDown = IsControlKeyDown;
local IsShiftKeyDown = IsShiftKeyDown;
local SecureButton_GetButtonSuffix = SecureButton_GetButtonSuffix;
local InCombatLockdown = InCombatLockdown;
local strlower = strlower;
local strfind = strfind;
local pairs = pairs;

local VUHDO_CURRENT_MOUSEOVER = nil;

local VUHDO_updateBouquetsForEvent;
local VUHDO_highlightClusterFor;
local VUHDO_showTooltip;
local VUHDO_hideTooltip;
local VUHDO_resetClusterUnit;
local VUHDO_removeAllClusterHighlights;
local VUHDO_getHealthBar;
local VUHDO_resolveButtonUnit;
local VUHDO_setupSmartCast;
local VUHDO_updateDirectionFrame;

local VUHDO_SPELL_CONFIG;
local VUHDO_SPELL_ASSIGNMENTS;
local VUHDO_getUnitButtons;
local VUHDO_CONFIG;
local VUHDO_INTERNAL_TOGGLES;
local VUHDO_RAID;
function VUHDO_actionEventHandlerInitBurst()
	VUHDO_updateBouquetsForEvent = _G["VUHDO_updateBouquetsForEvent"];
	VUHDO_highlightClusterFor = _G["VUHDO_highlightClusterFor"];
	VUHDO_showTooltip = _G["VUHDO_showTooltip"];
	VUHDO_hideTooltip = _G["VUHDO_hideTooltip"];
	VUHDO_resetClusterUnit = _G["VUHDO_resetClusterUnit"];
	VUHDO_removeAllClusterHighlights = _G["VUHDO_removeAllClusterHighlights"];
	VUHDO_getHealthBar = _G["VUHDO_getHealthBar"];
	VUHDO_resolveButtonUnit = _G["VUHDO_resolveButtonUnit"];
	VUHDO_setupSmartCast = _G["VUHDO_setupSmartCast"];
	VUHDO_updateDirectionFrame = _G["VUHDO_updateDirectionFrame"];
	VUHDO_getUnitButtons = _G["VUHDO_getUnitButtons"];

	VUHDO_SPELL_CONFIG = _G["VUHDO_SPELL_CONFIG"];
	VUHDO_SPELL_ASSIGNMENTS = _G["VUHDO_SPELL_ASSIGNMENTS"];
	VUHDO_CONFIG = _G["VUHDO_CONFIG"];
	VUHDO_INTERNAL_TOGGLES = _G["VUHDO_INTERNAL_TOGGLES"];
	VUHDO_RAID = _G["VUHDO_RAID"];
end

function VUHDO_getCurrentMouseOver()
	return VUHDO_CURRENT_MOUSEOVER;
end

local function VUHDO_placePlayerIcon(aButton, anIcon, anIndex)
	anIcon:ClearAllPoints();
	if 2 == anIndex then
		anIcon:SetPoint("CENTER", aButton:GetName(), "TOPRIGHT", -5, -10);
	else
		if anIndex > 2 then
			anIndex = anIndex - 1;
		end
		local tCol = floor(anIndex * 0.5);
		local tRow = anIndex - tCol * 2;
		anIcon:SetPoint("TOPLEFT", aButton:GetName(), "TOPLEFT", tCol * 14, -tRow * 14);
	end

	anIcon:SetWidth(16);
	anIcon:SetHeight(16);
	anIcon:SetAlpha(1);
	anIcon:SetVertexColor(1, 1, 1);
	anIcon:Show();
end

local function VUHDO_showPlayerIcons(aButton)
	local tUnit = VUHDO_resolveButtonUnit(aButton);
	local tIsLeader = false;
	local tIsAssist = false;
	local tIsMasterLooter = false;
	local tIsPvPEnabled;
	local tFaction;

	if not tUnit then return; end

	if UnitInRaid(tUnit) then
		local tUnitNo = VUHDO_getUnitNo(tUnit);
		if tUnitNo then
			local tRank;
			_, tRank, _, _, _, _, _, _, _, _, tIsMasterLooter = GetRaidRosterInfo(tUnitNo);
			if 2 == tRank then
				tIsLeader = true;
			elseif 1 == tRank then
				tIsAssist = true;
			end
		end
	else
		tIsLeader = UnitIsPartyLeader(tUnit);
	end

	tIsPvPEnabled = UnitIsPVP(tUnit);

	local tIcon;
	if tIsLeader then
		tIcon = VUHDO_getBarIcon(aButton, 1);
		tIcon:SetTexture("Interface\\groupframe\\ui-group-leadericon");
		VUHDO_placePlayerIcon(aButton, tIcon, 0);
	elseif (tIsAssist) then
		tIcon = VUHDO_getBarIcon(aButton, 1);
		tIcon:SetTexture("Interface\\groupframe\\ui-group-assistanticon");
		VUHDO_placePlayerIcon(aButton, tIcon, 0);
	end

	if tIsMasterLooter then
		tIcon = VUHDO_getBarIcon(aButton, 2);
		tIcon:SetTexture("Interface\\groupframe\\ui-group-masterlooter");
		VUHDO_placePlayerIcon(aButton, 2, 1);
	end

	if tIsPvPEnabled then
		tIcon = VUHDO_getBarIcon(aButton, 3);

		tFaction, _ = UnitFactionGroup(tUnit);
		if ("Alliance" == tFaction) then
			tIcon:SetTexture("Interface\\groupframe\\ui-group-pvp-alliance");
		else
			tIcon:SetTexture("Interface\\groupframe\\ui-group-pvp-horde");
		end

		VUHDO_placePlayerIcon(aButton, 3, 2);
		tIcon:SetWidth(32);
		tIcon:SetHeight(32);
	end

	local tClass = (VUHDO_RAID[tUnit] or {})["class"];
	if tClass then
		tIcon = VUHDO_getBarIcon(aButton, 4);

		tIcon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles");
		tIcon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[tClass]));
		VUHDO_placePlayerIcon(aButton, 4, 3);
	end

	local tRole = (VUHDO_RAID[tUnit] or {})["role"];
	if tRole then
		tIcon = VUHDO_getBarIcon(aButton, 5);
		tIcon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-ROLES");
		if (VUHDO_ID_MELEE_TANK == tRole) then
			tIcon:SetTexCoord(GetTexCoordsForRole("TANK"));
		elseif (VUHDO_ID_RANGED_HEAL == tRole) then
			tIcon:SetTexCoord(GetTexCoordsForRole("HEALER"));
		else
			tIcon:SetTexCoord(GetTexCoordsForRole("DAMAGER"));
		end
		VUHDO_placePlayerIcon(aButton, 5, 5);
	end

	local tBar = VUHDO_getHealthBar(aButton, 1);
	VUHDO_getBarText(tBar):SetAlpha(0.5);
	VUHDO_getLifeText(tBar):SetAlpha(0.5);
end

function VUHDO_hideAllPlayerIcons()
	local tPanelNum;
	local tAllButtons;
	local tPanel;
	local tButton;

	for tPanelNum = 1, 10 do -- VUHDO_MAX_PANELS
		tPanel = VUHDO_getActionPanel(tPanelNum);
		local tAllButtons = {tPanel:GetChildren()};
		VUHDO_initLocalVars(tPanelNum);

		for _, tButton in pairs(tAllButtons) do
			if (strfind(tButton:GetName(), "HlU", 1, true) and tButton:IsShown()) then
				VUHDO_initButtonStatics(tButton, tPanelNum);
				VUHDO_initAllHotIcons();
			end
		end
	end

	VUHDO_removeAllHots();
	VUHDO_suspendHoTs(false);
end

local function VUHDO_showAllPlayerIcons(aPanel)
	VUHDO_suspendHoTs(true);
	VUHDO_removeAllHots();

	local tAllButtons = {aPanel:GetChildren()};
	local tButton;

	for _, tButton in pairs(tAllButtons) do
		if (strfind(tButton:GetName(), "HlU", 1, true) and tButton:IsShown()) then
			VUHDO_showPlayerIcons(tButton);
		end
	end
end

local tHighlightBar;
local tAllUnits;
local tUnit;
local tAllButtons;
local tButton;
local tInfo;
local tOldMouseover;

function VuhDoActionOnEnter(aButton)
	VUHDO_showTooltip(aButton);

	tOldMouseover = VUHDO_CURRENT_MOUSEOVER;
	VUHDO_CURRENT_MOUSEOVER = VUHDO_resolveButtonUnit(aButton);
	if VUHDO_INTERNAL_TOGGLES[15] then -- VUHDO_UPDATE_MOUSEOVER
		VUHDO_updateBouquetsForEvent(tOldMouseover, 15); -- Seems to be ghosting sometimes, -- VUHDO_UPDATE_MOUSEOVER
		VUHDO_updateBouquetsForEvent(VUHDO_CURRENT_MOUSEOVER, 15); -- VUHDO_UPDATE_MOUSEOVER
	end

	if (VUHDO_CONFIG["DIRECTION"]["enable"]) then
		VUHDO_updateDirectionFrame(aButton);
	end

	if (VUHDO_CONFIG["IS_SHOW_GCD"]) then
		VuhDoGcdStatusBar:ClearAllPoints();
		VuhDoGcdStatusBar:SetAllPoints(aButton);
		VuhDoGcdStatusBar:SetValue(0);
		VuhDoGcdStatusBar:Show();
	end

	if VUHDO_INTERNAL_TOGGLES[18] then -- VUHDO_UPDATE_MOUSEOVER_CLUSTER
		if VUHDO_CURRENT_MOUSEOVER then
			VUHDO_highlightClusterFor(VUHDO_CURRENT_MOUSEOVER);
		end
	end

	if VUHDO_INTERNAL_TOGGLES[20] then -- VUHDO_UPDATE_MOUSEOVER_GROUP
		tInfo = VUHDO_RAID[VUHDO_CURRENT_MOUSEOVER];
		if not tInfo then
			return;
		end

		tAllUnits = VUHDO_GROUPS[tInfo["group"]];
		if tAllUnits then
			for _, tUnit in pairs(tAllUnits) do
				VUHDO_updateBouquetsForEvent(tUnit, 20); -- VUHDO_UPDATE_MOUSEOVER_GROUP
			end
		end
	end
end

local tOldMouseover;
function VuhDoActionOnLeave(aButton)

	VUHDO_hideTooltip();
	VuhDoDirectionFrame["shown"] = false;
	VuhDoDirectionFrame:Hide();

	tOldMouseover = VUHDO_CURRENT_MOUSEOVER;
	VUHDO_CURRENT_MOUSEOVER = nil;
	if VUHDO_INTERNAL_TOGGLES[15] then -- VUHDO_UPDATE_MOUSEOVER
		VUHDO_updateBouquetsForEvent(tOldMouseover, 15); -- VUHDO_UPDATE_MOUSEOVER
	end

	if VUHDO_INTERNAL_TOGGLES[18] then -- VUHDO_UPDATE_MOUSEOVER_CLUSTER
		VUHDO_resetClusterUnit();
		VUHDO_removeAllClusterHighlights();
	end

	if VUHDO_INTERNAL_TOGGLES[20] then -- VUHDO_UPDATE_MOUSEOVER_GROUP
		tUnit = VUHDO_resolveButtonUnit(aButton);
		tInfo = VUHDO_RAID[tUnit];

		if not tInfo then
			return;
		end
		tAllUnits = VUHDO_GROUPS[tInfo["group"]];
		if tAllUnits then
			for _, tUnit in pairs(tAllUnits) do
				VUHDO_updateBouquetsForEvent(tUnit, 20); -- VUHDO_UPDATE_MOUSEOVER_GROUP
			end
		end
	end
end

local tAllButtons, tButton, tQuota, tHighlightBar;
function VUHDO_highlighterBouquetCallback(aUnit, anIsActive, anIcon, aCurrValue, aCounter, aMaxValue, aColor, aBuffName, aBouquetName)
	aMaxValue = aMaxValue or 0;
	aCurrValue = aCurrValue or 0;

	if (aCurrValue == 0 and aMaxValue == 0) then
		if (anIsActive) then
			tQuota = 100;
		else
			tQuota = 0;
		end
	elseif (aMaxValue > 1) then
		tQuota = 100 * aCurrValue / aMaxValue;
	else
		tQuota = 0;
	end

	tAllButtons = VUHDO_getUnitButtons(aUnit);
	if tAllButtons then
		for _, tButton in pairs(tAllButtons) do
			if (tQuota > 0) then
				tHighlightBar = VUHDO_getHealthBar(tButton, 8);
				tHighlightBar:SetAlpha(1);
				tHighlightBar:SetStatusBarColor(aColor["R"], aColor["G"], aColor["B"], aColor["O"]);
				tHighlightBar:SetValue(tQuota); -- Mouseover highlight
			else
				if (VUHDO_INDICATOR_CONFIG["CUSTOM"]["HEALTH_BAR"]["invertGrowth"]) then
					VUHDO_getHealthBar(tButton, 8):SetValue(100);
				else
					VUHDO_getHealthBar(tButton, 8):SetValue(0);
				end
			end
		end
	end
end

local tModi;
local tKey;
function VuhDoActionPreClick(aButton, aMouseButton, aDown)


	-- allow VuhDo menu command to be bound even when using Clique compat mode
	if VUHDO_CONFIG["IS_CLIQUE_COMPAT_MODE"] then
		return;
	end

	tModi = "";
	if IsAltKeyDown() then
		tModi = tModi .. "alt";
	end

	if IsControlKeyDown() then
		tModi = tModi .. "ctrl";
	end

	if IsShiftKeyDown() then
		tModi = tModi .. "shift";
	end

	tKey = VUHDO_SPELL_ASSIGNMENTS[tModi .. SecureButton_GetButtonSuffix(aMouseButton)];
	if tKey and strlower(tKey[3]) == "menu" then
		VUHDO_disableActions(aButton);
		VUHDO_setMenuUnit(aButton);
		ToggleDropDownMenu(1, nil, VuhDoPlayerTargetDropDown, aButton:GetName(), 0, -5);
		VUHDO_IS_SMART_CAST = true;
	elseif tKey and strlower(tKey[3]) == "tell" then
		ChatFrame_SendTell(VUHDO_RAID[VUHDO_resolveButtonUnit(aButton)]["name"]);
	else
		if VUHDO_SPELL_CONFIG["smartCastModi"] == "all"
			or strfind(tModi, VUHDO_SPELL_CONFIG["smartCastModi"], 1, true) then
			VUHDO_IS_SMART_CAST = VUHDO_setupSmartCast(aButton);
		else
			VUHDO_IS_SMART_CAST = false;
		end
	end
end

function VuhDoActionPostClick(aButton, aMouseButton)
	if VUHDO_IS_SMART_CAST then
		VUHDO_setupAllHealButtonAttributes(aButton, nil, false, false, false);
		VUHDO_IS_SMART_CAST = false;
	end
end

function VuhDoActionOnMouseDown(aPanel, aMouseButton)
	VUHDO_startMoving(aPanel);
end

function VuhDoActionOnMouseUp(aPanel, aMouseButton)
	VUHDO_stopMoving(aPanel);
end

function VUHDO_startMoving(aPanel)
	if VuhDoNewOptionsPanelPanel and VuhDoNewOptionsPanelPanel:IsVisible() then

		local tNewNum = VUHDO_getComponentPanelNum(aPanel);
		if tNewNum ~= DESIGN_MISC_PANEL_NUM then
			VuhDoNewOptionsTabbedFrame:Hide();
			DESIGN_MISC_PANEL_NUM = tNewNum;
			VuhDoNewOptionsTabbedFrame:Show();
			VUHDO_redrawAllPanels(false);
			return;
		end
	end

	if (IsMouseButtonDown(1) and VUHDO_mayMoveHealPanels()) then
		if (not aPanel["isMoving"]) then
			aPanel["isMoving"] = true;
			aPanel:StartMoving();
		end
	elseif IsMouseButtonDown(2) and not InCombatLockdown()
		and (not VuhDoNewOptionsPanelPanel or not VuhDoNewOptionsPanelPanel:IsVisible()) then
		VUHDO_showAllPlayerIcons(aPanel);
	end
end

function VUHDO_stopMoving(aPanel)
	if not aPanel then aPanel = VUHDO_MOVE_PANEL; end
	aPanel:StopMovingOrSizing();
	aPanel["isMoving"] = false;
	VUHDO_savePanelCoords(aPanel);
	VUHDO_saveCurrentProfilePanelPosition(VUHDO_getPanelNum(aPanel));
	VUHDO_hideAllPlayerIcons();
end

local tPosition;
function VUHDO_savePanelCoords(aPanel)
	tPosition = VUHDO_PANEL_SETUP[VUHDO_getPanelNum(aPanel)]["POSITION"];
	tPosition["orientation"], _, tPosition["relativePoint"], tPosition["x"], tPosition["y"] = aPanel:GetPoint(0);
	tPosition["width"] = aPanel:GetWidth();
	tPosition["height"] = aPanel:GetHeight();
end
