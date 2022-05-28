local _;
local sIsFade;
local sIsWarnColor;
local sIsSwiftmend;
local sHotSetup;
local sBuffs2Hots = {};
local sHotCols;
local sHotSlots;
local sBarColors;
local sIsHotShowIcon;
local sHotSlotCfgs;
local sIsChargesIcon;

local VUHDO_KNOWS_SWIFTMEND = false;
local VUHDO_SWIFTMEND_UNITS = {};

VUHDO_MY_HOTS = {};
local VUHDO_MY_HOTS = VUHDO_MY_HOTS;
VUHDO_OTHER_HOTS = {};
local VUHDO_OTHER_HOTS = VUHDO_OTHER_HOTS;
VUHDO_MY_AND_OTHERS_HOTS = {};
local VUHDO_MY_AND_OTHERS_HOTS = VUHDO_MY_AND_OTHERS_HOTS;

local VUHDO_ACTIVE_HOTS = {};
local VUHDO_ACTIVE_HOTS_OTHERS = {};
local VUHDO_OTHER_PLAYERS_HOT_INFO = {};

local VUHDO_CHARGE_TEXTURES = {
	"Interface\\AddOns\\VuhDo\\Images\\hot_stacks1",
	"Interface\\AddOns\\VuhDo\\Images\\hot_stacks2",
	"Interface\\AddOns\\VuhDo\\Images\\hot_stacks3",
	"Interface\\AddOns\\VuhDo\\Images\\hot_stacks4"
};

local VUHDO_SHIELD_TEXTURES = {
	"Interface\\AddOns\\VuhDo\\Images\\shield_stacks1",
	"Interface\\AddOns\\VuhDo\\Images\\shield_stacks2",
	"Interface\\AddOns\\VuhDo\\Images\\shield_stacks3",
	"Interface\\AddOns\\VuhDo\\Images\\shield_stacks4"
};

local VUHDO_CHARGE_COLORS = {
	"HOT_CHARGE_1",
	"HOT_CHARGE_2",
	"HOT_CHARGE_3",
	"HOT_CHARGE_4"
};

local VUHDO_HOT_CFGS = {
	"HOT1",
	"HOT2",
	"HOT3",
	"HOT4",
	"HOT5",
	"HOT6",
	"HOT7",
	"HOT8",
	"HOT9"
};

-- BURST CACHE


local floor = floor;
local strlen = strlen;
local table = table;
local UnitBuff = UnitBuff;
local GetSpellCooldown = GetSpellCooldown;
local GetTime = GetTime;
local strfind = strfind;
local pairs = pairs;
local twipe = table.wipe;
local tostring = tostring;

local _G = _G;

local VUHDO_getHealthBar;
local VUHDO_getBarRoleIcon;
local VUHDO_updateAllClusterIcons;
local VUHDO_shouldScanUnit;
local VUHDO_getShieldLeftCount;
local VUHDO_resolveVehicleUnit;
local VUHDO_isPanelVisible;
local VUHDO_getHealButton;
local VUHDO_getUnitButtons;
local VUHDO_getBarIcon;
local VUHDO_getBarIconTimer;
local VUHDO_getBarIconCounter;
local VUHDO_getBarIconCharge;

local VUHDO_PANEL_SETUP;
local VUHDO_CAST_ICON_DIFF;
local VUHDO_HEALING_HOTS;
local VUHDO_SPELLS;
local VUHDO_RAID;
local VUHDO_INTERNAL_TOGGLES;

function VUHDO_customHotsInitBurst()
	-- variables
	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];
	VUHDO_CAST_ICON_DIFF = _G["VUHDO_CAST_ICON_DIFF"];
	VUHDO_HEALING_HOTS = _G["VUHDO_HEALING_HOTS"];
	VUHDO_SPELLS = _G["VUHDO_SPELLS"];
	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_ACTIVE_HOTS = _G["VUHDO_ACTIVE_HOTS"];
	VUHDO_ACTIVE_HOTS_OTHERS = _G["VUHDO_ACTIVE_HOTS_OTHERS"];
	VUHDO_INTERNAL_TOGGLES = _G["VUHDO_INTERNAL_TOGGLES"];
	-- functions
	VUHDO_getUnitButtons = _G["VUHDO_getUnitButtons"];
	VUHDO_getHealthBar = _G["VUHDO_getHealthBar"];
	VUHDO_getBarRoleIcon = _G["VUHDO_getBarRoleIcon"];
	VUHDO_updateAllClusterIcons = _G["VUHDO_updateAllClusterIcons"];
	VUHDO_shouldScanUnit = _G["VUHDO_shouldScanUnit"];
	VUHDO_getShieldLeftCount = _G["VUHDO_getShieldLeftCount"];
	VUHDO_resolveVehicleUnit = _G["VUHDO_resolveVehicleUnit"];
	VUHDO_isPanelVisible = _G["VUHDO_isPanelVisible"];
	VUHDO_getHealButton = _G["VUHDO_getHealButton"];
	VUHDO_getBarIcon = _G["VUHDO_getBarIcon"];
	VUHDO_getBarIconTimer = _G["VUHDO_getBarIconTimer"];
	VUHDO_getBarIconCounter = _G["VUHDO_getBarIconCounter"];
	VUHDO_getBarIconCharge = _G["VUHDO_getBarIconCharge"];

	sBarColors = VUHDO_PANEL_SETUP["BAR_COLORS"];
	sHotCols = sBarColors["HOTS"];
	sIsFade = sHotCols["isFadeOut"];
	sIsWarnColor = sHotCols["WARNING"]["enabled"];
	sHotSetup = VUHDO_PANEL_SETUP["HOTS"];
	sHotSlots = VUHDO_PANEL_SETUP["HOTS"]["SLOTS"];
	sHotSlotCfgs = VUHDO_PANEL_SETUP["HOTS"]["SLOTCFG"];
	sIsHotShowIcon = sHotSetup["iconRadioValue"] == 1;
	sIsChargesIcon = sHotSetup["stacksRadioValue"] == 3;
end

local tOtherPlayersHotEmpty = {nil, 0};
function VUHDO_getOtherPlayersHotInfo(aUnit)
	return VUHDO_OTHER_PLAYERS_HOT_INFO[aUnit] or tOtherPlayersHotEmpty;
end

function VUHDO_setKnowsSwiftmend(aKnowsSwiftmend)
	VUHDO_KNOWS_SWIFTMEND = aKnowsSwiftmend;
end

local tCopy = {};
local function VUHDO_copyColor(aColor)
	tCopy["R"], tCopy["G"], tCopy["B"], tCopy["O"] = aColor["R"], aColor["G"], aColor["B"], aColor["O"];
	tCopy["TR"], tCopy["TG"], tCopy["TB"], tCopy["TO"] = aColor["TR"], aColor["TG"], aColor["TB"], aColor["TO"];
	tCopy["useBackground"], tCopy["useText"], tCopy["useOpacity"] = aColor["useBackground"], aColor["useText"], aColor["useOpacity"];
	return tCopy;
end

local tHotBar;
local function VUHDO_customizeHotBar(aButton, aRest, anIndex, aDuration, aColor)
	tHotBar = VUHDO_getHealthBar(aButton, anIndex + 3);
	if aColor then
		tHotBar:SetStatusBarColor(aColor["R"], aColor["G"], aColor["B"], aColor["O"]);
	end
	if not aDuration or not aRest then
		tHotBar:SetValue(0);
	elseif (aDuration == 0) then
		tHotBar:SetValue(100);
	else
		tHotBar:SetValue(100 * aRest / aDuration);
	end
end

local tHotName;
local tDuration2;
local tChargeTexture;
local tIsChargeShown;
local tIcon;
local tTimer;
local tCounter;
local tDuration;
local tHotCfg;
local tIsChargeAlpha;
local function VUHDO_customizeHotIcons(aButton, aHotName, aRest, aTimes, anIcon, aDuration, aMode, aShieldCharges, aColor, anIndex)

	tIcon = VUHDO_getBarIcon(aButton, anIndex);
	tTimer = VUHDO_getBarIconTimer(aButton, anIndex);
	tCounter = VUHDO_getBarIconCounter(aButton, anIndex);
	tChargeTexture = VUHDO_getBarIconCharge(aButton, anIndex);

	if not aRest then
		tIcon:SetAlpha(0);
		tTimer:SetText("");
		tCounter:SetText("");
		tChargeTexture:Hide();
		return;
	end

	tIsChargeAlpha = false;

	if anIcon and sIsHotShowIcon then
		tIcon:SetTexture(anIcon);
	end

	tHotCfg = sBarColors[VUHDO_HOT_CFGS[anIndex]];

	aTimes = aTimes or 0;
	tIsChargeShown = sIsChargesIcon and aTimes > 0;

	if aRest == 999 then -- Other players' HoTs
		if aTimes > 0 then
			tIcon:SetAlpha(tHotCfg["O"]);
			if aTimes > 1 then
				tCounter:SetText(aTimes);
			else
				tCounter:SetText("");
			end
		else
			tIcon:SetAlpha(0);
			tCounter:SetText("");
		end
		tTimer:SetText("");
		return;
	elseif aRest > 0 then
		if aRest < 10 and sIsFade then
			tIcon:SetAlpha(tHotCfg["O"] * aRest * 0.1);
		else
			tIcon:SetAlpha(tHotCfg["O"]);
		end

		if aRest < 10 or tHotCfg["isFullDuration"] then
			if (tHotCfg["countdownMode"] == 2 and aRest < sHotCols["WARNING"]["lowSecs"]) then
				tDuration = "" .. floor(aRest * 10) * 0.1;
				if (strlen(tDuration) < 3) then
					tDuration = tDuration .. ".0";
				end
			else
				tDuration = floor(aRest);
			end
		else
			if (tHotCfg["O"] > 0 or tIsChargeShown) then
				tDuration = "";
			else
				tDuration = "X";
			end
		end

		tTimer:SetText(tDuration);

		if sIsFade and aRest < 10 then
			tIcon:SetAlpha(tHotCfg["O"] * aRest * 0.1);
		else
			tIcon:SetAlpha(tHotCfg["O"]);
		end

		if aRest > 5 then
			tTimer:SetTextColor(1, 1, 1, 1);
		else
			tDuration2 = aRest * 0.2;
			tTimer:SetTextColor(1, tDuration2, tDuration2, 1);
		end

		if aTimes > 1 then
			tCounter:SetText(aTimes);
		else
			tCounter:SetText("");
		end
	else
		tTimer:SetText("");
		tIcon:SetAlpha(tHotCfg["O"]);
		tCounter:SetText("");
	end

	-- @TESTING
	-- aTimes = floor(aRest / 3.5);

	if aTimes > 4 then
		aTimes = 4;
	end

	if aColor and (not aColor["isDefault"] or not sIsHotShowIcon) then
		tHotColor = aColor;

		if aTimes > 1 then
			tChargeColor = sBarColors[VUHDO_CHARGE_COLORS[aTimes]];
			if sHotCols["useColorBack"] then
				tHotColor["R"], tHotColor["G"], tHotColor["B"], tHotColor["O"]
					= tChargeColor["R"], tChargeColor["G"], tChargeColor["B"], tChargeColor["O"];
				tIsChargeAlpha = true;
			end
			if sHotCols["useColorText"] then
				tHotColor["TR"], tHotColor["TG"], tHotColor["TB"], tHotColor["TO"]
					= tChargeColor["TR"], tChargeColor["TG"], tChargeColor["TB"], tChargeColor["TO"];
			end
		end

		if tHotColor["useText"] and not sIsHotShowIcon then
			tTimer:SetTextColor(tHotColor["TR"], tHotColor["TG"], tHotColor["TB"], tHotColor["TO"]);
		end

	elseif sIsWarnColor and aRest < sHotCols["WARNING"]["lowSecs"] then
		tHotColor = sHotCols["WARNING"];
		tTimer:SetTextColor(tHotColor["TR"], tHotColor["TG"], tHotColor["TB"], tHotColor["TO"]);
	else
		tHotColor = VUHDO_copyColor(tHotCfg);
		if sIsHotShowIcon then
			tHotColor["R"], tHotColor["G"], tHotColor["B"] = 1, 1, 1;
		elseif (aTimes <= 1 or not sHotCols["useColorText"]) then
			tTimer:SetTextColor(tHotColor["TR"], tHotColor["TG"], tHotColor["TB"], tHotColor["TO"]);
		end

		if aTimes > 1 then
			tChargeColor = sBarColors[VUHDO_CHARGE_COLORS[aTimes]];
			if sHotCols["useColorBack"] then
				tHotColor["R"], tHotColor["G"], tHotColor["B"], tHotColor["O"]
					= tChargeColor["R"], tChargeColor["G"], tChargeColor["B"], tChargeColor["O"];
				tIsChargeAlpha = true;
			end
			if sHotCols["useColorText"] then
				tHotColor["TR"], tHotColor["TG"], tHotColor["TB"], tHotColor["TO"]
					= tChargeColor["TR"], tChargeColor["TG"], tChargeColor["TB"], tChargeColor["TO"];
				tTimer:SetTextColor(tHotColor["TR"], tHotColor["TG"], tHotColor["TB"], tHotColor["TO"]);
			end
		end
	end

	if tIsChargeAlpha then
		tIcon:SetVertexColor(tHotColor["R"], tHotColor["G"], tHotColor["B"], tHotColor["O"]);
	else
		tIcon:SetVertexColor(tHotColor["R"], tHotColor["G"], tHotColor["B"]);
	end

	if tIsChargeShown then
		tChargeTexture:SetTexture(VUHDO_CHARGE_TEXTURES[aTimes]);
		if (tHotColor["R"]) then
			tChargeTexture:SetVertexColor(tHotColor["R"], tHotColor["G"], tHotColor["B"], tHotColor["O"]);
		end
		tChargeTexture:Show();
	elseif aShieldCharges > 0 then
		if sIsHotShowIcon then
			tHotColor = tHotCfg;
		end
		tChargeTexture:SetTexture(VUHDO_SHIELD_TEXTURES[aShieldCharges]);
		if tHotColor["R"] then
			tChargeTexture:SetVertexColor(tHotColor["R"] + 0.15, tHotColor["G"] + 0.15, tHotColor["B"] + 0.15, tHotColor["O"]);
		end
		tChargeTexture:Show();
	else
		tChargeTexture:Hide();
	end
end

local tAllButtons;
local tButton;
local tShieldCharges;
local tIsMatch;
local tIndex, tHotName;
local tSlotCfg;

local function VUHDO_updateHotIcons(aUnit, aHotName, aRest, aTimes, anIcon, aDuration, aMode, aColor, aHotSpellName)
	tAllButtons = VUHDO_getUnitButtons(VUHDO_resolveVehicleUnit(aUnit));
	if not tAllButtons then
		return;
	end

	if aMode ~= 2 then -- if not our shield don't show remaining absorption
		tShieldCharges = VUHDO_getShieldLeftCount(aUnit, aHotSpellName or aHotName);
	else
		tShieldCharges = 0;
	end

	for tIndex, tHotName in pairs(sHotSlots) do
		if aHotName == tHotName then

			if aMode == 0 or aColor then tIsMatch = true; -- Bouquet => aColor ~= nil
			else
				tSlotCfg = sHotSlotCfgs[tostring(tIndex)];
				tIsMatch = (aMode == 1 and tSlotCfg["mine"] and not tSlotCfg["others"])
					or (aMode == 2 and not tSlotCfg["mine"] and tSlotCfg["others"])
						or (aMode == 3 and tSlotCfg["mine"] and tSlotCfg["others"]);
			end

			if tIsMatch then
				if tIndex >= 6 and tIndex <= 8 then
					for _, tButton in pairs(tAllButtons) do
						VUHDO_customizeHotBar(tButton, aRest, tIndex, aDuration, aColor);
					end
				else
					for _, tButton in pairs(tAllButtons) do
						VUHDO_customizeHotIcons(tButton, aHotName, aRest, aTimes, anIcon, aDuration, aMode, tShieldCharges, aColor, tIndex);
					end
				end
			end
		end
	end

end

local tCnt;
function VUHDO_removeHots(aUnit)
	tAllButtons = VUHDO_getUnitButtons(aUnit);
	if not tAllButtons then
		return;
	end

	for _, tButton in pairs(tAllButtons) do
		for tCnt = 1, 5 do
			VUHDO_getBarIcon(tButton, tCnt):SetAlpha(0);
			VUHDO_getBarIconTimer(tButton, tCnt):SetText("");
			VUHDO_getBarIconCounter(tButton, tCnt):SetText("");
			VUHDO_getBarIconCharge(tButton, tCnt):Hide();
		end

		for tCnt = 9, 11 do
			VUHDO_getHealthBar(tButton, tCnt):SetValue(0);
		end

		VUHDO_getBarRoleIcon(tButton, 51):Hide(); -- Swiftmend indicator
	end
end
local VUHDO_removeHots = VUHDO_removeHots;

local tCount;
local tHotInfo;
local function VUHDO_snapshotHot(aHotName, aRest, aStacks, anIcon, anIsMine, aDuration, aUnit)
	aStacks = aStacks or 0;
	if aStacks == 0 then
		tCount = 1;
	else
		tCount = aStacks;
	end

	if anIsMine then
		if not VUHDO_MY_HOTS[aUnit][aHotName] then
			VUHDO_MY_HOTS[aUnit][aHotName] = {};
		end
		tHotInfo = VUHDO_MY_HOTS[aUnit][aHotName];
		tHotInfo[1], tHotInfo[2], tHotInfo[3], tHotInfo[4] = aRest, aStacks, anIcon, aDuration;

	elseif VUHDO_ACTIVE_HOTS_OTHERS[aHotName] then
		if not VUHDO_OTHER_HOTS[aUnit][aHotName] then
			VUHDO_OTHER_HOTS[aUnit][aHotName] = {};
		end
		tHotInfo = VUHDO_OTHER_HOTS[aUnit][aHotName];

		if not tHotInfo[1] then
			tHotInfo[1], tHotInfo[2], tHotInfo[3], tHotInfo[4] = aRest, aStacks, anIcon, aDuration;
		else
			if aRest > tHotInfo[1] then
				tHotInfo[1] = aRest;
			end
			tHotInfo[2] = tHotInfo[2] + tCount;
		end
	end

	if not VUHDO_MY_AND_OTHERS_HOTS[aUnit][aHotName] then
		VUHDO_MY_AND_OTHERS_HOTS[aUnit][aHotName] = {};
	end
	tHotInfo = VUHDO_MY_AND_OTHERS_HOTS[aUnit][aHotName];
	if not tHotInfo[1] then
		tHotInfo[1], tHotInfo[2], tHotInfo[3], tHotInfo[4] = aRest, aStacks, anIcon, aDuration;
	else
		if anIsMine or aRest > tHotInfo[1] then
			tHotInfo[1] = aRest;
		end

		tHotInfo[2] = tHotInfo[2] + tCount;
	end
end



local VUHDO_IGNORE_HOT_IDS = {
	[67358] = true, -- "Rejuvenating" proc has same name in russian and spanish as rejuvenation
}

function VUHDO_hotBouquetCallback(aUnit, anIsActive, anIcon, aTimer, aCounter, aDuration, aColor, aBuffName, aBouquetName)
	VUHDO_updateHotIcons(aUnit, "BOUQUET_" .. (aBouquetName or ""), aTimer, aCounter, anIcon, aDuration, 0, aColor, aBuffName);
end

local tHotCmpName;
local tOtherHotCnt;
local tIconFound;
local tOtherIcon;
local tBuffIcon;
local tRest;
local tStacks;
local tCnt;
local tCaster;
local tBuffName;
local tStart, tEnabled;
local tSmDuration;
local tDiffIcon;
local tHotFromBuff;
local tIsMine;
local sDuration;
local tHotInfo, tIndex;
local tSpellId, tDebuffOffset;
local tNow;
local function VUHDO_updateHots(aUnit, anInfo)
	tNow = GetTime();

	if anInfo["isVehicle"] then
		VUHDO_removeHots(aUnit);
		aUnit = anInfo["petUnit"];
		if not aUnit then -- bei z.B. focus/target
			return;
		end
	end

	if not VUHDO_MY_HOTS[aUnit] then
		VUHDO_MY_HOTS[aUnit] = {};
	end

	if not VUHDO_OTHER_HOTS[aUnit] then
		VUHDO_OTHER_HOTS[aUnit] = {};
	end

	if not VUHDO_MY_AND_OTHERS_HOTS[aUnit] then
		VUHDO_MY_AND_OTHERS_HOTS[aUnit] = {};
	end

	for tIndex, tHotInfo in pairs(VUHDO_MY_HOTS[aUnit]) do
		tHotInfo[1] = nil; -- Rest == nil => Icon lцschen
	end

	for tIndex, tHotInfo in pairs(VUHDO_OTHER_HOTS[aUnit]) do
		tHotInfo[1] = nil;
	end

	for tIndex, tHotInfo in pairs(VUHDO_MY_AND_OTHERS_HOTS[aUnit]) do
		tHotInfo[1] = nil;
	end

	sIsSwiftmend = false;
	tOtherIcon = nil;
	tOtherHotCnt = 0;

	if not VUHDO_OTHER_PLAYERS_HOT_INFO[aUnit] then
		VUHDO_OTHER_PLAYERS_HOT_INFO[aUnit] = {nil, 0};
	else
		VUHDO_OTHER_PLAYERS_HOT_INFO[aUnit][1], VUHDO_OTHER_PLAYERS_HOT_INFO[aUnit][2] = nil, 0;
	end

	if VUHDO_shouldScanUnit(aUnit) then
		tDebuffOffset = nil;
		for tCnt = 1, 255 do

			if not tDebuffOffset then
				tBuffName, _, tBuffIcon, tStacks, _, sDuration, tRest, tCaster, _, _, tSpellId = UnitBuff(aUnit, tCnt);

			if not tBuffIcon then
				tDebuffOffset = tCnt - 1;
			end
		end
			if tDebuffOffset then -- Achtung kein elseif
				tBuffName, _, tBuffIcon, tStacks, _, sDuration, tRest, tCaster, _, _, tSpellId = UnitDebuff(aUnit, tCnt - tDebuffOffset);
			if not tBuffIcon then
				break;
			end
		end

			if VUHDO_KNOWS_SWIFTMEND and not sIsSwiftmend then
				if VUHDO_SPELL_ID_REGROWTH == tBuffName or VUHDO_SPELL_ID_REJUVENATION == tBuffName then
					tStart, tSmDuration, tEnabled = GetSpellCooldown(VUHDO_SPELLS[VUHDO_SPELL_ID_SWIFTMEND].id, BOOKTYPE_SPELL);
					if tEnabled ~= 0 and (tStart == nil or tSmDuration == nil or tStart <= 0 or tSmDuration <= 1.6) then
						sIsSwiftmend = true;
					end
				end
			end

			if (tRest ~= nil and tCaster ~= nil) then
				tIsMine = tCaster == "player" or tCaster == VUHDO_PLAYER_RAID_ID;
				tHotFromBuff = sBuffs2Hots[tBuffName .. tBuffIcon];
				if tHotFromBuff == "" or VUHDO_IGNORE_HOT_IDS[tSpellId] then -- non hot buff
				elseif tHotFromBuff then -- Hot buff cached
					tRest = tRest - tNow;
					if tRest > 0 then
						VUHDO_snapshotHot(tHotFromBuff, tRest, tStacks, tBuffIcon, tIsMine, sDuration, aUnit);
					end
				else -- not yet scanned
					sBuffs2Hots[tBuffName .. tBuffIcon] = "";
					for tHotCmpName, _ in pairs(VUHDO_ACTIVE_HOTS) do
						tDiffIcon = VUHDO_CAST_ICON_DIFF[tHotCmpName];

						if tDiffIcon == tBuffIcon
						or (tDiffIcon == nil and tBuffName == tHotCmpName)
						or (VUHDO_SPELLS[tHotCmpName] ~= nil and tBuffIcon == VUHDO_SPELLS[tHotCmpName]["icon"]) then
							tRest = tRest - tNow;
							if tRest > 0 then
								VUHDO_snapshotHot(tHotCmpName, tRest, tStacks, tBuffIcon, tIsMine, sDuration, aUnit);
							end

							sBuffs2Hots[tBuffName .. tBuffIcon] = tHotCmpName;
							break;
						end
					end
				end

				if not tIsMine and VUHDO_HEALING_HOTS[tBuffName] and not VUHDO_ACTIVE_HOTS_OTHERS[tBuffName] then
					tOtherHotCnt = tOtherHotCnt + 1;
					tOtherIcon = tBuffIcon;
					VUHDO_OTHER_PLAYERS_HOT_INFO[aUnit][1] = tOtherIcon;
					VUHDO_OTHER_PLAYERS_HOT_INFO[aUnit][2] = tOtherHotCnt;
				end
			end
		end

		-- Other players' HoTs
		if VUHDO_ACTIVE_HOTS["OTHER"] then
			VUHDO_updateHotIcons(aUnit, "OTHER", 999, tOtherHotCnt, tOtherIcon, nil, 0, nil, nil);
		end

		-- Clusters
		if (VUHDO_INTERNAL_TOGGLES[16] or VUHDO_INTERNAL_TOGGLES[18]) then -- VUHDO_UPDATE_NUM_CLUSTER -- VUHDO_UPDATE_MOUSEOVER_CLUSTER
			VUHDO_updateAllClusterIcons(aUnit);
		end

		if (VUHDO_KNOWS_SWIFTMEND) then
			VUHDO_SWIFTMEND_UNITS[aUnit] = sIsSwiftmend;
		end

	end -- Should scan unit

	-- Own
	for tHotCmpName, tHotInfo in pairs(VUHDO_MY_HOTS[aUnit]) do
		VUHDO_updateHotIcons(aUnit, tHotCmpName, tHotInfo[1], tHotInfo[2], tHotInfo[3], tHotInfo[4], 1, nil, nil);
		if not tHotInfo[1] then
			twipe(tHotInfo);
			VUHDO_MY_HOTS[aUnit][tHotCmpName] = nil;
		end
	end
	-- Others
	for tHotCmpName, tHotInfo in pairs(VUHDO_OTHER_HOTS[aUnit]) do
		VUHDO_updateHotIcons(aUnit, tHotCmpName, tHotInfo[1], tHotInfo[2], tHotInfo[3], tHotInfo[4], 2, nil, nil);
		if not tHotInfo[1] then
			twipe(tHotInfo);
			VUHDO_OTHER_HOTS[aUnit][tHotCmpName] = nil;
		end
	end
	-- Own+Others
	for tHotCmpName, tHotInfo in pairs(VUHDO_MY_AND_OTHERS_HOTS[aUnit]) do
		VUHDO_updateHotIcons(aUnit, tHotCmpName, tHotInfo[1], tHotInfo[2], tHotInfo[3], tHotInfo[4], 3, nil, nil);
		if not tHotInfo[1] then
			twipe(tHotInfo);
			VUHDO_MY_AND_OTHERS_HOTS[aUnit][tHotCmpName] = nil;
		end
	end

end

local tAllButtons, tButton, tIcon;
function VUHDO_swiftmendIndicatorBouquetCallback(aUnit, anIsActive, anIcon, aTimer, aCounter, aDuration, aColor, aBuffName, aBouquetName)
	tAllButtons = VUHDO_getUnitButtons(aUnit);
	if tAllButtons then
		for _, tButton in pairs(tAllButtons) do
			if anIsActive and aColor then
				tIcon = VUHDO_getBarRoleIcon(tButton, 51);
				tIcon:SetTexture(anIcon);
				tIcon:SetVertexColor(aColor["R"], aColor["G"], aColor["B"], aColor["O"]);
				tIcon:Show();
			else
				VUHDO_getBarRoleIcon(tButton, 51):Hide();
			end
		end
	end
end

local VUHDO_HOTS_SUSPENDED = false;
function VUHDO_suspendHoTs(aFlag)
	VUHDO_HOTS_SUSPENDED = aFlag;
end

local tUnit, tInfo;
function VUHDO_updateAllHoTs()
	if VUHDO_HOTS_SUSPENDED then return; end

	twipe(VUHDO_SWIFTMEND_UNITS);

	for tUnit, tInfo in pairs(VUHDO_RAID) do
		VUHDO_updateHots(tUnit, tInfo);
	end
end

local tCnt, tCnt2, tCnt3;
local tButton;
function VUHDO_removeAllHots()
	for tCnt = 1, 10 do -- VUHDO_MAX_PANELS
		if VUHDO_isPanelVisible(tCnt) then

			for tCnt2 = 1, 51 do -- VUHDO_MAX_BUTTONS_PANEL
				tButton = VUHDO_getHealButton(tCnt2, tCnt);
				if not tButton then break; end -- Auch nicht belegte buttons ausblenden

				for tCnt3 = 1, 5 do
					VUHDO_getBarIcon(tButton, tCnt3):SetAlpha(0);
					VUHDO_getBarIconTimer(tButton, tCnt3):SetText("");
					VUHDO_getBarIconCounter(tButton, tCnt3):SetText("");
					VUHDO_getBarIconCharge(tButton, tCnt3):Hide();
				end

				for tCnt3 = 9, 11 do
					VUHDO_getHealthBar(tButton, tCnt3):SetValue(0);
				end

				VUHDO_getBarRoleIcon(tButton, 51):Hide();
			end
		end
	end

	VUHDO_updatePlayerTarget();
end

function VUHDO_resetHotBuffCache()
	twipe(sBuffs2Hots);
end

function VUHDO_isUnitSwiftmendable(aUnit)
	return VUHDO_SWIFTMEND_UNITS[aUnit];
end
