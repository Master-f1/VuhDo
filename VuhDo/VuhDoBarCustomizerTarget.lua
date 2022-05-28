local VUHDO_IN_RAID_TARGETS = {};
VUHDO_IN_RAID_TARGET_BUTTONS = {};
local VUHDO_IN_RAID_TARGET_BUTTONS = VUHDO_IN_RAID_TARGET_BUTTONS;
local VUHDO_TOT_GUIDS = {};

local UnitClass = UnitClass;
local UnitPowerType = UnitPowerType;
local UnitHealthMax = UnitHealthMax;
local UnitHealth = UnitHealth;
local UnitName = UnitName;
local UnitMana = UnitMana;
local UnitManaMax = UnitManaMax;
local UnitIsDeadOrGhost = UnitIsDeadOrGhost;
local UnitIsConnected = UnitIsConnected;
local UnitIsUnit = UnitIsUnit;
local UnitExists = UnitExists;
local UnitCreatureType = UnitCreatureType;
local strfind = strfind;
local gsub = gsub;
local UnitIsFriend = UnitIsFriend;
local UnitIsEnemy = UnitIsEnemy;
local GetRaidTargetIndex = GetRaidTargetIndex;
local tonumber = tonumber;
local pairs = pairs;
local tostring = tostring;
local twipe = table.wipe;
local _;

local VUHDO_CUSTOM_INFO;
local VUHDO_CLASS_IDS;
local VUHDO_getHealthBar;
local VUHDO_customizeBarSize;
local VUHDO_customizeText;
local VUHDO_setRaidTargetIconTexture
local VUHDO_RAID;
local VUHDO_getUnitButtons;
local VUHDO_getTargetButton;
local VUHDO_getTotButton;
local VUHDO_PANEL_SETUP;
local VUHDO_getTargetBarRoleIcon;
local VUHDO_POWER_TYPE_COLORS;
local VUHDO_BUTTON_CACHE;
local VUHDO_getUnitZoneName;

function VUHDO_customTargetInitBurst()
	VUHDO_CUSTOM_INFO = _G["VUHDO_CUSTOM_INFO"];
	VUHDO_CLASS_IDS = _G["VUHDO_CLASS_IDS"];
	VUHDO_getHealthBar = _G["VUHDO_getHealthBar"];
	VUHDO_customizeBarSize = _G["VUHDO_customizeBarSize"];
	VUHDO_customizeText = _G["VUHDO_customizeText"];
	VUHDO_setRaidTargetIconTexture = _G["VUHDO_setRaidTargetIconTexture"];
	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_getUnitButtons = _G["VUHDO_getUnitButtons"];
	VUHDO_getTargetButton = _G["VUHDO_getTargetButton"];
	VUHDO_getTotButton = _G["VUHDO_getTotButton"];
	VUHDO_BUTTON_CACHE = _G["VUHDO_BUTTON_CACHE"];
	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];
	VUHDO_getTargetBarRoleIcon = _G["VUHDO_getTargetBarRoleIcon"];
	VUHDO_POWER_TYPE_COLORS = _G["VUHDO_POWER_TYPE_COLORS"];
	VUHDO_getUnitZoneName = _G["VUHDO_getUnitZoneName"];
end

local tManaBar;
local function VUHDO_customizeManaBar(aButton, aColor, anInfo)

	if anInfo["connected"] then
		tManaBar = VUHDO_getHealthBar(aButton, 2);
		-- Some addons return 1 mana-max instead of zero
		if (anInfo["powermax"] < 2) then
			tManaBar:SetValue(0);
		else
			tManaBar:SetValue(100 * anInfo["power"] / anInfo["powermax"]);
		end

		if aColor then
			tManaBar:SetStatusBarColor(aColor["R"], aColor["G"], aColor["B"], aColor["O"]);
		end
	else
		VUHDO_getHealthBar(aButton, 2):SetValue(0);
	end
end

local tInfo;
local tLocalClass, tClassName;
local tPowerType;
local tName;
local function VUHDO_fillCustomInfo(aUnit)
	tLocalClass, tClassName = UnitClass(aUnit);
	tPowerType = UnitPowerType(aUnit);
	tName = UnitName(aUnit);

	tInfo = VUHDO_CUSTOM_INFO;
	tInfo["healthmax"] = UnitHealthMax(aUnit);
	tInfo["health"] = UnitHealth(aUnit);
	tInfo["name"] = tName;
	tInfo["unit"] = aUnit;
	tInfo["class"] = tClassName;
	tInfo["powertype"] = tonumber(tPowerType);
	tInfo["power"] = UnitMana(aUnit);
	tInfo["powermax"] = UnitManaMax(aUnit);
	tInfo["dead"] = UnitIsDeadOrGhost(aUnit);
	tInfo["connected"] = UnitIsConnected(aUnit);
	if (tLocalClass == tInfo["name"]) then
		tInfo["className"] = UnitCreatureType(aUnit) or "";
	else
		tInfo["className"] = tLocalClass or "";
	end
	tInfo["classId"] = VUHDO_CLASS_IDS[tClassName];
	tInfo["fullName"] = tName;
	tInfo["zone"], tInfo["map"] = (VUHDO_RAID["player"] or {})["zone"], (VUHDO_RAID["player"] or {})["map"];
	tInfo["fixResolveId"] = nil;
end

local tManaColor;
local tTexture;
local tTargetBar;
local tRaidTargetColor;

local function VUHDO_customizeTargetBar(aButton, anIsFriend, anIsEnemy, anIcon, anIsDead, anIconIndex)
	tTargetBar = VUHDO_getHealthBar(aButton, 1);
	tTargetBar:Show();

	if anIsDead then
		tTargetBar:SetStatusBarColor(0, 0, 0, 1);
	elseif anIconIndex and anIcon and VUHDO_PANEL_SETUP["BAR_COLORS"]["RAID_ICONS"]["enable"] then
		tRaidTargetColor = VUHDO_PANEL_SETUP["BAR_COLORS"]["RAID_ICONS"][anIconIndex];
		tTargetBar:SetStatusBarColor(tRaidTargetColor["R"], tRaidTargetColor["G"], tRaidTargetColor["B"], 1);
	elseif anIsFriend then
		tTargetBar:SetStatusBarColor(0, 1, 0, 1);
	elseif anIsEnemy then
		tTargetBar:SetStatusBarColor(1, 0, 0, 1);
	else
		tTargetBar:SetStatusBarColor(1, 1, 0, 1);
	end

	VUHDO_customizeBarSize(aButton);
	VUHDO_customizeText(aButton, 1, true); -- VUHDO_UPDATE_ALL
	VUHDO_customizeManaBar(aButton, VUHDO_POWER_TYPE_COLORS[VUHDO_CUSTOM_INFO["powertype"]], VUHDO_CUSTOM_INFO);

	if anIcon then
		tTexture = VUHDO_getTargetBarRoleIcon(aButton, 50);
		VUHDO_setRaidTargetIconTexture(tTexture, anIcon);
		tTexture:Show();
	else
		VUHDO_getTargetBarRoleIcon(aButton, 50):Hide();
	end
end

-- We remember the target buttons when the target is in
-- the raid to perform health updates with the regular mechanism.
-- So the target buttons are indexed by the target name.


local tUnit, tInfo;
local tName;
local function VUHDO_rememberTargetButton(aTargetUnit, aButton)
	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if UnitIsUnit(tUnit, aTargetUnit) then
			tName = tInfo["name"];
			if not VUHDO_IN_RAID_TARGET_BUTTONS[tName] then
				VUHDO_IN_RAID_TARGET_BUTTONS[tName] = {};
			end

			VUHDO_IN_RAID_TARGET_BUTTONS[tName][aButton:GetName()] = aButton;
			VUHDO_IN_RAID_TARGETS[aTargetUnit] = tName;
			break;
		end
	end
end

-- Delete all the target buttons of the person whose target has changed.
-- Where the buttons are indexed with the name of the TARGET, which we have
-- which we have remembered VUHDO_IN_RAID_TARGETS.


local tName;
local function VUHDO_forgetTargetButton(aTargetUnit, aButton)
	tName = VUHDO_IN_RAID_TARGETS[aTargetUnit];
	if tName then
		if not VUHDO_IN_RAID_TARGET_BUTTONS[tName] then
			VUHDO_IN_RAID_TARGET_BUTTONS[tName] = {};
		end
		VUHDO_IN_RAID_TARGET_BUTTONS[tName][aButton:GetName()] = nil;
	end
end

local tTargetButton, tTotButton, tInfo;
local tAllButtons;
local tButton;
local tTarget;
local tTargetOfTarget;
local tIsFriend;
local tIsEnemy;
local tIsDead;
local tIcon;
local tPanelNum;
local tConfig;
local tDispIcon;
function VUHDO_updateTargetBars(aUnit)
	if strfind(aUnit, "target", 1, true) and aUnit ~= "target" then
		aUnit = gsub(aUnit, "target", "");
	end

	tAllButtons = VUHDO_getUnitButtons(aUnit);
		if not tAllButtons then return; end

	if "player" == aUnit then
		tTarget = "target";
	else
		tTarget = aUnit .. "target";
	end

	tTargetOfTarget = tTarget .. "target";

	for _, tButton in pairs(tAllButtons) do
		VUHDO_forgetTargetButton(tTarget, VUHDO_getTargetButton(tButton));
		VUHDO_forgetTargetButton(tTargetOfTarget, VUHDO_getTotButton(tButton));
	end

	VUHDO_IN_RAID_TARGETS[tTarget] = nil;
	VUHDO_IN_RAID_TARGETS[tTargetOfTarget] = nil;

	if not UnitExists(tTarget) then
		for _, tButton in pairs(tAllButtons) do
			tTargetButton = VUHDO_getTargetButton(tButton);
			tTargetButton:SetAlpha(0);

			tTotButton = VUHDO_getTotButton(tButton);
			tTotButton:SetAlpha(0);
		end
	return;
end

	-- Target
	tIsFriend = UnitIsFriend(aUnit, tTarget);
	tIsEnemy = UnitIsEnemy(aUnit, tTarget);
	tIsDead = UnitIsDeadOrGhost(tTarget);

	VUHDO_fillCustomInfo(tTarget);

	for _, tButton in pairs(tAllButtons) do
		tPanelNum = VUHDO_BUTTON_CACHE[tButton];
		tConfig = VUHDO_PANEL_SETUP[tPanelNum]["SCALING"];
		if tConfig["showTarget"] then
			tIcon = GetRaidTargetIndex(tTarget);
		if VUHDO_PANEL_SETUP[tPanelNum]["RAID_ICON"]["show"] and VUHDO_PANEL_SETUP["RAID_ICON_FILTER"][tIcon] then
			tDispIcon = tIcon;
		else
			tDispIcon = nil;
		end
		tTargetButton = VUHDO_getTargetButton(tButton);
		VUHDO_customizeTargetBar(tTargetButton, tIsFriend, tIsEnemy, tDispIcon, tIsDead, tostring(tDispIcon));
			tTargetButton:SetAlpha(1);
			VUHDO_rememberTargetButton(tTarget, tTargetButton);
		end
	end

	-- Target-of-target
	if not UnitExists(tTargetOfTarget) then
		for _, tButton in pairs(tAllButtons) do
			tTotButton = VUHDO_getTotButton(tButton);
			tTotButton:SetAlpha(0);
		end
		return;
	end

	tIsFriend = UnitIsFriend(aUnit, tTargetOfTarget);
	tIsEnemy = UnitIsEnemy(aUnit, tTargetOfTarget);
	tIsDead = UnitIsDeadOrGhost(tTargetOfTarget);

	VUHDO_fillCustomInfo(tTargetOfTarget);

	for _, tButton in pairs(tAllButtons) do
		tPanelNum = VUHDO_BUTTON_CACHE[tButton];
		tConfig = VUHDO_PANEL_SETUP[tPanelNum]["SCALING"];
		if tConfig["showTot"] then
			tIcon = GetRaidTargetIndex(tTargetOfTarget);
		if VUHDO_PANEL_SETUP[tPanelNum]["RAID_ICON"]["show"] and VUHDO_PANEL_SETUP["RAID_ICON_FILTER"][tIcon] then
			tDispIcon = tIcon;
		else
			tDispIcon = nil;
		end
		tTotButton = VUHDO_getTotButton(tButton);
			VUHDO_customizeTargetBar(tTotButton, tIsFriend, tIsEnemy, tDispIcon, tIsDead, tostring(tDispIcon));
			tTotButton:SetAlpha(1);
			VUHDO_rememberTargetButton(tTargetOfTarget, tTotButton);
		end
	end
end
local VUHDO_updateTargetBars = VUHDO_updateTargetBars;

local tUnit;
function VUHDO_rebuildTargets()
	if not VUHDO_INTERNAL_TOGGLES[22] then return; end -- VUHDO_UPDATE_UNIT_TARGET

	twipe(VUHDO_IN_RAID_TARGETS);
	twipe(VUHDO_IN_RAID_TARGET_BUTTONS);
	twipe(VUHDO_TOT_GUIDS);

	for tUnit, _ in pairs(VUHDO_RAID) do
		VUHDO_updateTargetBars(tUnit);
	end
end

local tButton, tTotUnit, tGuid;
local tAllButtons;
local tButton;
local function VUHDO_updateTargetHealth(aUnit, aTargetUnit)
	tAllButtons = VUHDO_getUnitButtons(aUnit);
	if not tAllButtons then return; end

	if not VUHDO_IN_RAID_TARGETS[aTargetUnit] then
		VUHDO_fillCustomInfo(aTargetUnit);
		for _, tButton in pairs(tAllButtons) do
			tButton = VUHDO_getTargetButton(tButton);
			VUHDO_customizeBarSize(tButton);
			VUHDO_customizeText(tButton, VUHDO_UPDATE_HEALTH, true);
			VUHDO_customizeManaBar(tButton, nil, VUHDO_CUSTOM_INFO);
		end
	end

	tTotUnit = aTargetUnit .. "target";

	tGuid = UnitGUID(tTotUnit);
	if VUHDO_TOT_GUIDS[aUnit] ~= tGuid then
		VUHDO_updateTargetBars(aUnit);
		VUHDO_TOT_GUIDS[aUnit] = tGuid;
	end

	if not VUHDO_IN_RAID_TARGETS[tTotUnit] and UnitExists(tTotUnit) then
	VUHDO_fillCustomInfo(tTotUnit);
	for _, tButton in pairs(tAllButtons) do
		tButton = VUHDO_getTotButton(tButton);
		VUHDO_customizeBarSize(tButton);
		VUHDO_customizeText(tButton, VUHDO_UPDATE_HEALTH, true);
		VUHDO_customizeManaBar(tButton, nil, VUHDO_CUSTOM_INFO);
	end
	end
end

local tUnit, tInfo;
function VUHDO_updateAllOutRaidTargetButtons()
	for tUnit, tInfo in pairs(VUHDO_RAID) do
		if UnitExists(tInfo["targetUnit"]) then
			VUHDO_updateTargetHealth(tUnit, tInfo["targetUnit"]);
		end
	end
end
