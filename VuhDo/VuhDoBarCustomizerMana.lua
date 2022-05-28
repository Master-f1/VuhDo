-- BURST CACHE

local VUHDO_RAID;
local VUHDO_getUnitButtons;
local VUHDO_IN_RAID_TARGET_BUTTONS;
local VUHDO_PANEL_SETUP;
local VUHDO_BUTTON_CACHE;
local UnitPowerType = UnitPowerType;
local UnitMana = UnitMana;
local UnitManaMax = UnitManaMax;
local InCombatLockdown = InCombatLockdown;
local pairs = pairs;

local VUHDO_getHealthBar;
local VUHDO_isConfigDemoUsers;
local VUHDO_updateBouquetsForEvent;
local sIsInverted;
function VUHDO_customManaInitBurst()
	VUHDO_RAID = _G["VUHDO_RAID"];
	VUHDO_getUnitButtons = _G["VUHDO_getUnitButtons"];
	VUHDO_IN_RAID_TARGET_BUTTONS = _G["VUHDO_IN_RAID_TARGET_BUTTONS"];
	VUHDO_PANEL_SETUP = _G["VUHDO_PANEL_SETUP"];
	VUHDO_BUTTON_CACHE = _G["VUHDO_BUTTON_CACHE"];

	VUHDO_getHealthBar = _G["VUHDO_getHealthBar"];
	VUHDO_isConfigDemoUsers = _G["VUHDO_isConfigDemoUsers"];
	VUHDO_updateBouquetsForEvent = _G["VUHDO_updateBouquetsForEvent"];
	sIsInverted = VUHDO_INDICATOR_CONFIG["CUSTOM"]["MANA_BAR"]["invertGrowth"];
end

local tInfo;
local tPowerType;
function VUHDO_updateManaBars(aUnit, aChange)
	tInfo = VUHDO_RAID[aUnit];
	if not tInfo then return; end

	if (tInfo["isVehicle"]) then
		if not tInfo["petUnit"] then return; end

		aUnit = tInfo["petUnit"];
		tInfo = VUHDO_RAID[aUnit];
		if not tInfo then return; end
	end

	if not VUHDO_isConfigDemoUsers() then
		if 1 == aChange then
			tInfo["power"] = UnitMana(aUnit);
		elseif 2 == aChange  then
			tInfo["powermax"] = UnitManaMax(aUnit);
		elseif 3 == aChange then
			tPowerType, _ = UnitPowerType(aUnit);
			tInfo["powertype"] = tonumber(tPowerType);
			tInfo["powermax"] = UnitManaMax(aUnit);
			tInfo["power"] = UnitMana(aUnit);
		end
	end

	if tInfo["powertype"] == 0 then -- VUHDO_UNIT_POWER_MANA
		VUHDO_updateBouquetsForEvent(aUnit, 13); -- VUHDO_UPDATE_MANA

		if 3 == aChange then
			VUHDO_updateBouquetsForEvent(aUnit, 21); -- VUHDO_UPDATE_OTHER_POWERS
		end
	else
		VUHDO_updateBouquetsForEvent(aUnit, 21); -- VUHDO_UPDATE_OTHER_POWERS

		if 3 == aChange then
			VUHDO_updateBouquetsForEvent(aUnit, 13); -- VUHDO_UPDATE_MANA
		end
	end
end

local tAllButtons, tButton, tManaBar, tHealthBar, tQuota;
local tManaBarHeight;
local tRegularHeight;
function VUHDO_manaBarBouquetCallback(aUnit, anIsActive, anIcon, aCurrValue, aCounter, aMaxValue, aColor, aBuffName, aBouquetName)

	if not aMaxValue or not aCurrValue then
		anIsActive = false;
	end
	aMaxValue = aMaxValue or 0;
	aCurrValue = aCurrValue or 0;

	if aMaxValue + aCurrValue == 0 then
		anIsActive = false;
	end

	tManaBarHeight = 0;
	tAllButtons = VUHDO_getUnitButtons(aUnit);
	if (aCurrValue == 0 and aMaxValue == 0) then
		if anIsActive then
			tQuota = 100;
		else
			tQuota = 0;
		end
	elseif aMaxValue > 1 then
		tQuota = 100 * aCurrValue / aMaxValue;
	else
		tQuota = 0;
	end

	if tAllButtons then
		for _, tButton in pairs(tAllButtons) do
			if anIsActive then
				tManaBarHeight = VUHDO_PANEL_SETUP[VUHDO_BUTTON_CACHE[tButton]]["SCALING"]["manaBarHeight"];
			end
			tManaBar = VUHDO_getHealthBar(tButton, 2);
			if tQuota > 0 and tManaBarHeight > 0 then
				if aColor then
					tManaBar:SetStatusBarColor(aColor["R"], aColor["G"], aColor["B"], aColor["O"]);
				end
				tManaBar:SetValue(tQuota);
			else
				if not anIsActive and sIsInverted then
					tManaBar:SetValue(100);
				else
					tManaBar:SetValue(0);
				end
			end

			if not InCombatLockdown() then
				if tManaBarHeight > 0 then
					tManaBar:SetHeight(tManaBarHeight);
				end
				tRegularHeight = tButton["regularHeight"];
				if tRegularHeight then
					VUHDO_getHealthBar(tButton, 1):SetHeight(tRegularHeight - tManaBarHeight);
				end
			end
		end
	end

	if not VUHDO_RAID[aUnit] then return; end

	-- Targets und targets-of-target, die im Raid sind
	tAllButtons = VUHDO_IN_RAID_TARGET_BUTTONS[VUHDO_RAID[aUnit]["name"]];
	if not tAllButtons then return; end

	for _, tButton in pairs(tAllButtons) do
		tManaBar = VUHDO_getHealthBar(tButton, 2);
		if tQuota > 0 then
			if aColor then tManaBar:SetStatusBarColor(aColor["R"], aColor["G"], aColor["B"], aColor["O"]); end
			tManaBar:SetValue(tQuota);
		else
			tManaBar:SetValue(0);
		end
		if not InCombatLockdown() then
			tManaBarHeight = VUHDO_PANEL_SETUP[VUHDO_BUTTON_CACHE[tButton]]["SCALING"]["manaBarHeight"];
			tManaBar:SetHeight(tManaBarHeight);
			tRegularHeight = tButton["regularHeight"];
			if tRegularHeight then
				VUHDO_getHealthBar(tButton, 1):SetHeight(tRegularHeight - tManaBarHeight);
			end
		end
	end
end
