local _;
local pairs = pairs;

local VUHDO_BUFF_PANEL_X, VUHDO_BUFF_PANEL_Y;
local VUHDO_BUFF_PANEL_WIDTH;
local VUHDO_BUFF_PANEL_HEIGHT;
local VUHDO_PANEL_INSET_X = 5;
local VUHDO_PANEL_INSET_Y = 5;
local VUHDO_PANEL_MAX_HEIGHT = 430;

local BUFF_PANEL_BASE_HEIGHT = nil;

local function VUHDO_getGenericPanel(aCategoryName)
	return _G["VuhDoBuffSetupPanel" .. aCategoryName .. "GenericPanel"];
end

local function VUHDO_getBuffPanelCheckBox(aCategoryName)
	return _G["VuhDoBuffSetupPanel" .. aCategoryName .. "EnableCheckButton"];
end

local function VUHDO_buffSetupOkayOnClick()
	local tCategories = VUHDO_CLASS_BUFFS[VUHDO_PLAYER_CLASS];
	local tCategoryName, tCategoryBuffs;
	local tGenericPanel;
	local tFound = false;

	for tCategoryName, tCategoryBuffs in pairs(tCategories) do
		local tNameStr = strsub(tCategoryName, 3);
		local tSettings = VUHDO_BUFF_SETTINGS[tNameStr];
		tGenericPanel = VUHDO_getGenericPanel(tNameStr);

		if (VUHDO_getBuffPanelCheckBox(tNameStr) ~= nil) then
			tFound = true;

			if (tSettings ~= nil) then
				tSettings["enabled"] = VUHDO_forceBooleanValue(VUHDO_getBuffPanelCheckBox(tNameStr):GetChecked());
			end

			if (tGenericPanel ~= nil) then
				local tMaxVariant = VUHDO_getBuffVariantMaxTarget(tCategoryBuffs[1]);
				local tSingleVariant = VUHDO_getBuffVariantSingleTarget(tCategoryBuffs[1]);

		local tBuffTarget;

		if (VUHDO_BUFFS[tMaxVariant[1]].present) then
				tBuffTarget = tMaxVariant[2];
		else
				tBuffTarget = tSingleVariant[2];
		end

		if (VUHDO_BUFF_TARGET_CLASS == tBuffTarget) then
					tSettings["classes"] = {
						["WARRIOR"] = VUHDO_comboGetSelectedBuff(_G[tGenericPanel:GetName() .. "WarriorsCombo"]),
						["ROGUE"] = VUHDO_comboGetSelectedBuff(_G[tGenericPanel:GetName() .. "RoguesCombo"]),
						["HUNTER"] = VUHDO_comboGetSelectedBuff(_G[tGenericPanel:GetName() .. "HuntersCombo"]),
						["PALADIN"] = VUHDO_comboGetSelectedBuff(_G[tGenericPanel:GetName() .. "PaladinsCombo"]),
						["MAGE"] = VUHDO_comboGetSelectedBuff(_G[tGenericPanel:GetName() .. "MagesCombo"]),
						["WARLOCK"] = VUHDO_comboGetSelectedBuff(_G[tGenericPanel:GetName() .. "WarlocksCombo"]),
						["SHAMAN"] = VUHDO_comboGetSelectedBuff(_G[tGenericPanel:GetName() .. "ShamansCombo"]),
						["DRUID"] = VUHDO_comboGetSelectedBuff(_G[tGenericPanel:GetName() .. "DruidsCombo"]),
						["PRIEST"] = VUHDO_comboGetSelectedBuff(_G[tGenericPanel:GetName() .. "PriestsCombo"]),
						["DEATHKNIGHT"] = VUHDO_comboGetSelectedBuff(_G[tGenericPanel:GetName() .. "DeathKnightsCombo"])
					};
			elseif (VUHDO_BUFF_TARGET_UNIQUE == tBuffTarget) then
					local tEditBox = _G[tGenericPanel:GetName() .. "PlayerNameEditBox"];
					tSettings["name"] = tEditBox:GetText();
			else -- Aura, Totem, own group, self
				if (#tCategoryBuffs > 1) then
					local tCombo = _G[tGenericPanel:GetName() .. "DedicatedComboBox"];
					tSettings["buff"] = VUHDO_comboGetSelectedBuff(tCombo);
					end
				end
			end
		end
	end

	if (tFound) then
		VUHDO_reloadBuffPanel();
	end
end

local function VUHDO_buffSetupNewRowCheck(aWidth, anAddHeight)
	if (VUHDO_BUFF_PANEL_Y > VUHDO_BUFF_PANEL_HEIGHT) then
		VUHDO_BUFF_PANEL_HEIGHT = VUHDO_BUFF_PANEL_Y;
	end

	if (VUHDO_BUFF_PANEL_Y + anAddHeight > VUHDO_PANEL_MAX_HEIGHT) then
		VUHDO_BUFF_PANEL_X = VUHDO_BUFF_PANEL_X + aWidth;
		VUHDO_BUFF_PANEL_Y = VUHDO_PANEL_INSET_Y;
	end

	if (VUHDO_BUFF_PANEL_X > VUHDO_BUFF_PANEL_WIDTH) then
		VUHDO_BUFF_PANEL_WIDTH = VUHDO_BUFF_PANEL_X;
	end

end

function VUHDO_buffChanged(aComponent)
	VUHDO_buffSetupOkayOnClick();
end

local function VUHDO_addGenericBuffFrame(aBuffVariant, aFrameTemplateName, aCategoryName, anIsPresent)
	local tBuffPanel, tGenericFrame;

	-- main panel
	local tFrameName = "VuhDoBuffSetupPanel" .. aCategoryName;
	tBuffPanel = _G[tFrameName];
	if (tBuffPanel == nil) then
		tBuffPanel = CreateFrame("Frame", tFrameName, VuhDoNewOptionsBuffsGeneric, "VuhDoBuffSetupPanelTemplate");
		BUFF_PANEL_BASE_HEIGHT = tBuffPanel:GetHeight();
	end

	_G[tBuffPanel:GetName() .. "BuffNameLabelLabel"]:SetText(aCategoryName);

	if (anIsPresent) then
		_G[tBuffPanel:GetName() .. "BuffTextureTexture"]:SetTexture(VUHDO_BUFFS[aBuffVariant[1]].icon);
	else
		_G[tBuffPanel:GetName() .. "BuffTextureTexture"]:SetTexture("interface\\icons\\spell_chargenegative");
	end
	local tInFrameY = BUFF_PANEL_BASE_HEIGHT;

	if (aFrameTemplateName ~= nil) then
		tGenericFrame = _G[tFrameName .. "GenericPanel"];
		if (tGenericFrame == nil) then
			tGenericFrame = CreateFrame("Frame", "$parentGenericPanel", tBuffPanel, aFrameTemplateName);
		end
		tGenericFrame:ClearAllPoints();
		tGenericFrame:SetPoint("TOPLEFT", tBuffPanel:GetName(), "TOPLEFT", 0, -tInFrameY);
		tInFrameY = tInFrameY + tGenericFrame:GetHeight() + 5;
	end

	VUHDO_buffSetupNewRowCheck(tBuffPanel:GetWidth(), tInFrameY);
	tBuffPanel:ClearAllPoints();
	tBuffPanel:SetPoint("TOPLEFT", "VuhDoNewOptionsBuffsGeneric", "TOPLEFT", VUHDO_BUFF_PANEL_X, -VUHDO_BUFF_PANEL_Y);
	tBuffPanel:SetHeight(tInFrameY);
	tBuffPanel:Show();

	VUHDO_BUFF_PANEL_Y = VUHDO_BUFF_PANEL_Y + tInFrameY;

	return tBuffPanel, tGenericFrame;
end

local function VUHDO_setupStaticBuffPanel(aCategoryName, aBuffPanel, anIsPresent)
	local tBuffSettings;

	if (VUHDO_BUFF_SETTINGS[aCategoryName] == nil) then
		VUHDO_BUFF_SETTINGS[aCategoryName] = {["enabled"] = anIsPresent};
	end

	if (VUHDO_BUFF_SETTINGS[aCategoryName]["missingColor"] == nil) then
		VUHDO_BUFF_SETTINGS[aCategoryName]["missingColor"] = {
			["show"] = false,
			["R"] = 1, ["G"] = 1, ["B"] = 1, ["O"] = 1,
			["TR"] = 1, ["TG"] = 1, ["TB"] = 1, ["TO"] = 1,
			["useText"] = true, ["useBackground"] = true, ["useOpacity"] = true,
		}
	end

	tBuffSettings = VUHDO_BUFF_SETTINGS[aCategoryName];

	local tEnableCheckButton = _G[aBuffPanel:GetName() .. "EnableCheckButton"];
	tEnableCheckButton:SetChecked(tBuffSettings["enabled"] and anIsPresent);
	if (anIsPresent) then
		tEnableCheckButton:Show();
	else
		tEnableCheckButton:Hide();
	end
	VUHDO_lnfCheckButtonClicked(tEnableCheckButton);

	local tMissButton = _G[aBuffPanel:GetName() .. "MissingCheckButton"];
	VUHDO_lnfSetModel(tMissButton, "VUHDO_BUFF_SETTINGS." .. aCategoryName .. ".missingColor.show");
	VUHDO_lnfSetTooltip(tMissButton, VUHDO_I18N_TT.K386);
	tMissButton:Hide();
	tMissButton:Show();

	local tMissTexture = _G[aBuffPanel:GetName() .. "MissingTexture"];
	VUHDO_lnfSetModel(tMissTexture, "VUHDO_BUFF_SETTINGS." .. aCategoryName .. ".missingColor");
	VUHDO_lnfSetTooltip(tMissTexture, VUHDO_I18N_TT.K385);
	tMissTexture:Hide();
	tMissTexture:Show();
end

local function VUHDO_buffNameAvail(aBuffName)
	if (VUHDO_BUFFS[aBuffName] ~= nil and VUHDO_BUFFS[aBuffName].present) then
		return aBuffName;
	else
		return nil;
	end
end

local function VUHDO_getAllBuffNamesAvail(someCategoryBuffs)
	local tBuffNames = {};
	local tVariants, tMaxVariant, tName;

	for _, tVariants in ipairs(someCategoryBuffs) do
		local tMaxVariant = VUHDO_getBuffVariantSingleTarget(tVariants);
		tName = tMaxVariant[1];
		if (VUHDO_BUFFS[tName].present) then
			table.insert(tBuffNames, tName);
		end
	end

	return tBuffNames;
end

local function VUHDO_setBuffBoxIcon(aGenericPanel, aTexture)
	local tTexture = _G[aGenericPanel:GetParent():GetName() .. "BuffTextureTexture"];
	tTexture:SetTexture(aTexture);
end

local function VUHDO_addBuffsToCombo(aComboBox, someBuffNames, aSelectedValue, tIsEmpty)
	local tEntryTable = {};
	local tBuffName;

	if (tIsEmpty) then
		tinsert(tEntryTable, {"", "-- " .. VUHDO_I18N_EMPTY_HOTS .. " --"});
	end

	for _, tBuffName in ipairs(someBuffNames) do
		local tEntry = {tBuffName, tBuffName};
		tinsert(tEntryTable, tEntry);
	end

	aComboBox:SetAttribute("combo_table", tEntryTable);
	VUHDO_lnfComboInitItems(aComboBox);
	VUHDO_lnfComboSetSelectedValue(aComboBox, aSelectedValue);
end

local function VUHDO_setupGenericBuffPanel(aBuffVariant, aGenericPanel, someCategoryBuffs, aCategoryName)
	local tBuffTarget = aBuffVariant[2];
	local tSettings = VUHDO_BUFF_SETTINGS[aCategoryName];

	if (VUHDO_BUFF_TARGET_RAID == tBuffTarget or VUHDO_BUFF_TARGET_SINGLE == tBuffTarget) then
		local tComboBox = _G[aGenericPanel:GetName() .. "ComboBox"];
		VUHDO_setComboModel(tComboBox, "VUHDO_BUFF_SETTINGS." .. aCategoryName .. ".filter", VUHDO_BUFF_FILTER_COMBO_TABLE, VUHDO_I18N_TRACK_BUFFS_FOR);
		VUHDO_lnfComboBoxInitFromModel(tComboBox);
	elseif (VUHDO_BUFF_TARGET_CLASS == tBuffTarget) then
		local tClassBuffs = VUHDO_getAllBuffNamesAvail(someCategoryBuffs);

		if (tSettings["classes"] == nil) then
			tSettings["classes"] = {
				["WARRIOR"] = VUHDO_buffNameAvail(tClassBuffs[1]),
				["ROGUE"] = VUHDO_buffNameAvail(tClassBuffs[1]),
				["HUNTER"] = VUHDO_buffNameAvail(tClassBuffs[1]),
				["PALADIN"] = VUHDO_buffNameAvail(tClassBuffs[1]),
				["MAGE"] = VUHDO_buffNameAvail(tClassBuffs[1]),
				["WARLOCK"] = VUHDO_buffNameAvail(tClassBuffs[1]),
				["SHAMAN"] = VUHDO_buffNameAvail(tClassBuffs[1]),
				["DRUID"] = VUHDO_buffNameAvail(tClassBuffs[1]),
				["PRIEST"] = VUHDO_buffNameAvail(tClassBuffs[1]),
				["DEATHKNIGHT"] = VUHDO_buffNameAvail(tClassBuffs[1])
			};
		end

		local tClassSettings = tSettings["classes"];

		VUHDO_addBuffsToCombo(_G[aGenericPanel:GetName() .. "WarriorsCombo"], tClassBuffs, tClassSettings["WARRIOR"], true);
		VUHDO_addBuffsToCombo(_G[aGenericPanel:GetName() .. "DeathKnightsCombo"], tClassBuffs, tClassSettings["DEATHKNIGHT"], true);
		VUHDO_addBuffsToCombo(_G[aGenericPanel:GetName() .. "DruidsCombo"], tClassBuffs, tClassSettings["DRUID"], true);
		VUHDO_addBuffsToCombo(_G[aGenericPanel:GetName() .. "PriestsCombo"], tClassBuffs, tClassSettings["PRIEST"], true);
		VUHDO_addBuffsToCombo(_G[aGenericPanel:GetName() .. "ShamansCombo"], tClassBuffs, tClassSettings["SHAMAN"], true);
		VUHDO_addBuffsToCombo(_G[aGenericPanel:GetName() .. "PaladinsCombo"], tClassBuffs, tClassSettings["PALADIN"], true);
		VUHDO_addBuffsToCombo(_G[aGenericPanel:GetName() .. "WarlocksCombo"], tClassBuffs, tClassSettings["WARLOCK"], true);
		VUHDO_addBuffsToCombo(_G[aGenericPanel:GetName() .. "MagesCombo"], tClassBuffs, tClassSettings["MAGE"], true);
		VUHDO_addBuffsToCombo(_G[aGenericPanel:GetName() .. "HuntersCombo"], tClassBuffs, tClassSettings["HUNTER"], true);
		VUHDO_addBuffsToCombo(_G[aGenericPanel:GetName() .. "RoguesCombo"], tClassBuffs, tClassSettings["ROGUE"], true);

	elseif (VUHDO_BUFF_TARGET_UNIQUE == tBuffTarget) then
		if (tSettings["name"] == nil) then
			tSettings["name"] = VUHDO_PLAYER_NAME;
		end

		local tEditBox = _G[aGenericPanel:GetName() .. "PlayerNameEditBox"];
		tEditBox:SetText(tSettings["name"]);
	else -- Aura, Totem, own group, self
		if (tSettings["buff"] == nil) then
			tSettings["buff"] = VUHDO_buffNameAvail(aBuffVariant[1]);
		end

		if (#someCategoryBuffs > 1) then
			--VUHDO_Msg(aCategoryName);
			local tCategBuffNames = VUHDO_getAllBuffNamesAvail(someCategoryBuffs);
			local tCombo = _G[aGenericPanel:GetName() .. "DedicatedComboBox"];
			VUHDO_addBuffsToCombo(tCombo, tCategBuffNames, tSettings["buff"], true);
			VUHDO_setBuffBoxIcon(aGenericPanel, VUHDO_comboGetSelectedBuff(tCombo));
		end
	end
end

local function VUHDO_buildBuffSetupGenericPanel(aCategoryName, someCategoryBuffs)
	local tAllVariants;
	local tMaxVariant;
	local tSingleVariant;
	local tMaxTarget;
	local tBuffPanell;
	local tGenericPanel;
	local tPanelTemplate;
	local tIsMaxPresent;
	local tIsSinglePresent;

	tMaxVariant = VUHDO_getBuffVariantMaxTarget(someCategoryBuffs[1]);
	tSingleVariant = VUHDO_getBuffVariantSingleTarget(someCategoryBuffs[1]);
	tIsMaxPresent = VUHDO_BUFFS[tMaxVariant[1]]["present"];
	tIsSinglePresent = VUHDO_BUFFS[tSingleVariant[1]]["present"];

	if (tIsMaxPresent) then
		tMaxTarget = tMaxVariant[2];
	else
		tMaxTarget = tSingleVariant[2];
	end

	if (VUHDO_BUFF_TARGET_CLASS == tMaxTarget) then
		-- add classes panel
		tPanelTemplate = "VuhDoBuffSetupClassTargetPanelTemplate";
	elseif (VUHDO_BUFF_TARGET_UNIQUE == tMaxTarget) then
		-- add player name panel
		tPanelTemplate = "VuhDoBuffSetupUniqueSingleTargetPanelTemplate";
	elseif (VUHDO_BUFF_TARGET_RAID == tMaxTarget or VUHDO_BUFF_TARGET_SINGLE == tMaxTarget) then
		tPanelTemplate = "VuhDoBuffSetupFilterTemplate";
	else -- Aura, Totem, own group, self
		-- If more than one mutual exclusive
		if (#someCategoryBuffs > 1) then
			-- add Combo-Box having all spells
			tPanelTemplate = "VuhDoBuffSetupDedicatedPanelTemplate";
		else
			-- add basic panel only (only en-/disable)
			tPanelTemplate = nil;
		end
	end

	if (tIsMaxPresent) then
		tBuffPanel, tGenericPanel = VUHDO_addGenericBuffFrame(tMaxVariant, tPanelTemplate, aCategoryName, tIsMaxPresent);
		VUHDO_setupStaticBuffPanel(aCategoryName, tBuffPanel, tIsMaxPresent);
		VUHDO_setupGenericBuffPanel(tMaxVariant, tGenericPanel, someCategoryBuffs, aCategoryName);
	else
		tBuffPanel, tGenericPanel = VUHDO_addGenericBuffFrame(tSingleVariant, tPanelTemplate, aCategoryName, tIsSinglePresent);
		VUHDO_setupStaticBuffPanel(aCategoryName, tBuffPanel, tIsSinglePresent);
		VUHDO_setupGenericBuffPanel(tSingleVariant, tGenericPanel, someCategoryBuffs, aCategoryName);
	end

	return tBuffPanel, tGenericPanel;
end

function VUHDO_buildAllBuffSetupGenerericPanel()
	local tAllBuffs = VUHDO_CLASS_BUFFS[VUHDO_PLAYER_CLASS];
	local tCategoryName, tAllCategoryBuffs;
	local tBuffPanel = nil;
	local tCurPanel;
	local tIndex;
	local tCategSpec;

	VUHDO_BUFF_PANEL_X = VUHDO_PANEL_INSET_X;
	VUHDO_BUFF_PANEL_Y = VUHDO_PANEL_INSET_Y;
	VUHDO_BUFF_PANEL_WIDTH = 0;
	VUHDO_BUFF_PANEL_HEIGHT = 0;

	if (tAllBuffs == nil) then
		return;
	end

	for tCategoryName, tAllCategoryBuffs in pairs(tAllBuffs) do
		if (VUHDO_BUFF_ORDER[tCategoryName] == nil) then
			local tNumber = tonumber(strsub(tCategoryName, 1, 2));
			VUHDO_BUFF_ORDER[tCategoryName] = tNumber;
		end
	end

	tIndex = 0;
	for _, _ in pairs(tAllBuffs) do
		for tCategoryName, tAllCategoryBuffs in pairs(tAllBuffs) do
			local tNumber = VUHDO_BUFF_ORDER[tCategoryName];

			local tName = strsub(tCategoryName, 3);

			if (tNumber == tIndex + 1) then
				tIndex = tIndex + 1;
				tCurPanel, _ = VUHDO_buildBuffSetupGenericPanel(tName, tAllCategoryBuffs);
				if (tBuffPanel == nil) then
					tBuffPanel = tCurPanel;
				end
			end
		end
	end

	if (tBuffPanel == nil) then
		return;
	end

	local tWidth = VUHDO_BUFF_PANEL_WIDTH + tBuffPanel:GetWidth();
	local tScale = 528 / tWidth;

	if (tScale < 1) then
		VuhDoNewOptionsBuffsGeneric:SetScale(tScale);
	end
end

function VUHDO_buffWatchSetupDedicatedChanged(aComboBox, aValue)
	if (aValue ~= aComboBox:GetAttribute("selected_value")) then
		aComboBox:SetAttribute("selected_value", aValue);
		VUHDO_buffChanged(aComboBox);
	end
end

function VUHDO_buffWatchSetupFilterChanged(aComboBox, aValue, anArrayModel)
	if (aValue ~= nil) then
		if (VUHDO_ID_ALL == aValue) then
			table.wipe(anArrayModel);
			anArrayModel[VUHDO_ID_ALL] = true;
		else
			anArrayModel[VUHDO_ID_ALL] = nil;
		end
		VUHDO_lnfComboSetSelectedValue(aComboBox, nil);
		VUHDO_updateBuffFilters();
	end
end

function VUHDO_comboGetSelectedBuff(aComboBox)
	if (aComboBox == nil) then
		return "";
	else
		return aComboBox:GetAttribute("selected_value");
	end
end

function VUHDO_buffUpButtonClicked(aButton)
	local tCategName = strsub(aButton:GetParent():GetName(), 20);
	local tCategSpec, tNumber;
	local tIndex = nil;
	local tPreIndex = nil;

	for tCategSpec, tNumber in pairs(VUHDO_BUFF_ORDER) do
		if (strfind(tCategSpec, tCategName, 1, true)) then
			tIndex = tCategSpec;
			break;
		end
	end

	local tPredec = -1;
	local tCurrOrder = VUHDO_BUFF_ORDER[tIndex];
	if (tIndex ~= nil) then
		for tCategSpec, tNumber in pairs(VUHDO_BUFF_ORDER) do
			if (tNumber > tPredec and tNumber < tCurrOrder) then
				tPredec = tNumber;
				tPreIndex = tCategSpec;
			end
		end
	end

	if (tPredec > 0) then
		VUHDO_BUFF_ORDER[tPreIndex] = tCurrOrder;
		VUHDO_BUFF_ORDER[tIndex] = tPredec;
	end

	VUHDO_buildAllBuffSetupGenerericPanel();
	VUHDO_buffSetupOkayOnClick();
end

function VUHDO_buffDownButtonClicked(aButton)
	local tCategName = strsub(aButton:GetParent():GetName(), 20);
	local tCategSpec, tNumber;
	local tIndex = nil;
	local tPreIndex = nil;

	for tCategSpec, tNumber in pairs(VUHDO_BUFF_ORDER) do
		if (strfind(tCategSpec, tCategName, 1, true)) then
			tIndex = tCategSpec;
			break;
		end
	end

	local tPredec = 1000;
	local tCurrOrder = VUHDO_BUFF_ORDER[tIndex];
	if (tIndex ~= nil) then
		for tCategSpec, tNumber in pairs(VUHDO_BUFF_ORDER) do
			if (tNumber < tPredec and tNumber > tCurrOrder) then
				tPredec = tNumber;
				tPreIndex = tCategSpec;
			end
		end
	end

	if (tPredec < 1000) then
		VUHDO_BUFF_ORDER[tPreIndex] = tCurrOrder;
		VUHDO_BUFF_ORDER[tIndex] = tPredec;
	end

	VUHDO_buildAllBuffSetupGenerericPanel();
	VUHDO_buffSetupOkayOnClick();
end

