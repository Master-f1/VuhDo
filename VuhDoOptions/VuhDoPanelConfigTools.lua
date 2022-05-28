local _;
local VUHDO_GROUP_ORDER_BARS_LEFT = {};
local VUHDO_GROUP_ORDER_BARS_RIGHT = {};

function VUHDO_removeFromModel(aPanelNum, anOrderNum)
	tremove(VUHDO_PANEL_MODELS[aPanelNum], anOrderNum);
	VUHDO_initDynamicPanelModels();
end

function VUHDO_insertIntoModel(aPanelNum, anOrderNum, anIsLeft, aModelId)
	if (anIsLeft) then
		tinsert(VUHDO_PANEL_MODELS[aPanelNum], anOrderNum, aModelId)
	else
		tinsert(VUHDO_PANEL_MODELS[aPanelNum], anOrderNum + 1, aModelId)
	end
	VUHDO_initDynamicPanelModels();
end

local tCnt;
function VUHDO_rewritePanelModels()
	for tCnt = 1, VUHDO_MAX_PANELS do
		VUHDO_PANEL_SETUP[tCnt]["MODEL"].groups = VUHDO_PANEL_MODELS[tCnt];
	end
end

local tCount;
function VUHDO_tableCount(anArray)
	tCount = 0;
	for _, _ in pairs(anArray) do
		tCount = tCount + 1;
	end

	return tCount;
end

function VUHDO_getOrCreateGroupOrderPanel(aParentPanelNum, aPanelNum)
	local tName = "VdAc" .. aParentPanelNum .. "GrpOrd" .. aPanelNum;
	if (_G[tName] == nil) then
		CreateFrame("Frame", tName, _G["VdAc" .. aParentPanelNum], "VuhDoGrpOrdTemplate");
	end

	return _G[tName];
end

function VUHDO_getOrCreateGroupSelectPanel(aParentPanelNum, aPanelNum)
	local tName = "VdAc" .. aParentPanelNum .. "GrpSel" .. aPanelNum;
	if (_G[tName] == nil) then
		CreateFrame("Frame", tName, _G["VdAc" .. aParentPanelNum], "VuhDoGrpSelTemplate");
	end

	return _G[tName];
end

function VUHDO_getConfigOrderBarRight(aPanelNum, anOrderNum)
	local tIndex = aPanelNum * 100 + anOrderNum;
	if (VUHDO_GROUP_ORDER_BARS_RIGHT[tIndex] == nil) then
		local tPanel = VUHDO_getOrCreateGroupOrderPanel(aPanelNum, anOrderNum);
		VUHDO_GROUP_ORDER_BARS_RIGHT[tIndex] = _G[tPanel:GetName() .. "InsTxuR"];
	end

	return VUHDO_GROUP_ORDER_BARS_RIGHT[tIndex];
end

function VUHDO_getConfigOrderBarLeft(aPanelNum, anOrderNum)
	local tIndex = aPanelNum * 100 + anOrderNum;
	if (VUHDO_GROUP_ORDER_BARS_LEFT[tIndex] == nil) then
		local tPanel = VUHDO_getOrCreateGroupOrderPanel(aPanelNum, anOrderNum);
		VUHDO_GROUP_ORDER_BARS_LEFT[tIndex] = _G[tPanel:GetName() .. "InsTxuL"];
	end

	return VUHDO_GROUP_ORDER_BARS_LEFT[tIndex];
end

function VUHDO_forceBooleanValue(aRawValue)
	if (aRawValue == nil or aRawValue == 0 or aRawValue == false) then
		return false;
	else
		return true;
	end
end
