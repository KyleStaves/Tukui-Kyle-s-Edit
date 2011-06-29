-- ********************************************
-- **             DBM Info Frame             **
-- **     http://www.deadlybossmods.com      **
-- ********************************************
--
-- This addon is written and copyrighted by:
--    * Paul Emmerich (Tandanu @ EU-Aegwynn) (DBM-Core)
--    * Martin Verges (Nitram @ EU-Azshara) (DBM-GUI)
--
-- The localizations are written by:
--    * enGB/enUS: Tandanu				http://www.deadlybossmods.com
--    * deDE: Tandanu					http://www.deadlybossmods.com
--    * zhCN: Diablohu					http://wow.gamespot.com.cn
--    * ruRU: BootWin					bootwin@gmail.com
--    * ruRU: Vampik					admin@vampik.ru
--    * zhTW: Hman						herman_c1@hotmail.com
--    * zhTW: Azael/kc10577				paul.poon.kw@gmail.com
--    * koKR: BlueNyx/nBlueWiz			bluenyx@gmail.com / everfinale@gmail.com
--    * esES: Snamor/1nn7erpLaY      	romanscat@hotmail.com
--
-- Special thanks to:
--    * Arta
--    * Omegal @ US-Whisperwind (continuing mod support for 3.2+)
--    * Tennberg (a lot of fixes in the enGB/enUS localization)
--
--
-- The code of this addon is licensed under a Creative Commons Attribution-Noncommercial-Share Alike 3.0 License. (see license.txt)
-- All included textures and sounds are copyrighted by their respective owners.
--
--
--  You are free:
--    * to Share ?to copy, distribute, display, and perform the work
--    * to Remix ?to make derivative works
--  Under the following conditions:
--    * Attribution. You must attribute the work in the manner specified by the author or licensor (but not in any way that suggests that they endorse you or your use of the work).
--    * Noncommercial. You may not use this work for commercial purposes.
--    * Share Alike. If you alter, transform, or build upon this work, you may distribute the resulting work only under the same or similar license to this one.
--
--
-- This file makes use of the following free (Creative Commons Sampling Plus 1.0) sounds:
--    * alarmclockbeeps.ogg by tedthetrumpet (http://www.freesound.org/usersViewSingle.php?id=177)
--    * blip_8.ogg by Corsica_S (http://www.freesound.org/usersViewSingle.php?id=7037)
--  The full of text of the license can be found in the file "Sounds\Creative Commons Sampling Plus 1.0.txt".

---------------
--  Globals  --
---------------
DBM.InfoFrame = {}

--------------
--  Locals  --
--------------
local infoFrame = DBM.InfoFrame
local frame
local createFrame
local onUpdate
local dropdownFrame
local initializeDropdown
local maxlines
local infoFrameThreshold 
local pIndex
local headerText = "DBM Info Frame"	-- this is only used if DBM.InfoFrame:SetHeader(text) is not called before :Show()
local currentEvent
local sortingAsc
local lines = {}
local icons = {}
local sortedLines = {}

---------------------
--  Dropdown Menu  --
---------------------
-- todo: this dropdown menu is somewhat ugly and unflexible....
do
	local function toggleLocked()
		DBM.Options.InfoFrameLocked = not DBM.Options.InfoFrameLocked
	end
	local function toggleShowSelf()
		DBM.Options.InfoFrameShowSelf = not DBM.Options.InfoFrameShowSelf
	end
	
	function initializeDropdown(dropdownFrame, level, menu)
		local info
		if level == 1 then
			info = UIDropDownMenu_CreateInfo()
			info.text = DBM_CORE_INFOFRAME_LOCK
			if DBM.Options.InfoFrameLocked then
				info.checked = true
			end
			info.func = toggleLocked
			UIDropDownMenu_AddButton(info, 1)

			info = UIDropDownMenu_CreateInfo()
			info.text = DBM_CORE_INFOFRAME_SHOW_SELF
			if DBM.Options.InfoFrameShowSelf then
				info.checked = true
			end
			info.func = toggleShowSelf
			UIDropDownMenu_AddButton(info, 1)		

			info = UIDropDownMenu_CreateInfo()
			info.text = DBM_CORE_INFOFRAME_HIDE
			info.notCheckable = true
			info.func = infoFrame.Hide
			info.arg1 = infoFrame
			UIDropDownMenu_AddButton(info, 1)
		end
	end
end


------------------------
--  Create the frame  --
------------------------
function createFrame()
	local elapsed = 0
	local frame = CreateFrame("GameTooltip", "DBMInfoFrame", UIParent, "GameTooltipTemplate")
	dropdownFrame = CreateFrame("Frame", "DBMInfoFrameDropdown", frame, "UIDropDownMenuTemplate")
	frame:SetFrameStrata("DIALOG")
	frame:SetPoint(DBM.Options.InfoFramePoint, UIParent, DBM.Options.InfoFramePoint, DBM.Options.InfoFrameX, DBM.Options.InfoFrameY)
	frame:SetHeight(maxlines*12)
	frame:SetWidth(64)
	frame:EnableMouse(true)
	frame:SetToplevel(true)
	frame:SetMovable()
	GameTooltip_OnLoad(frame)
	frame:SetPadding(16)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", function(self)
		if not DBM.Options.InfoFrameLocked then
			self:StartMoving()
		end
	end)
	frame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		ValidateFramePosition(self)
		local point, _, _, x, y = self:GetPoint(1)
		DBM.Options.InfoFrameX = x
		DBM.Options.InfoFrameY = y
		DBM.Options.InfoFramePoint = point
	end)
	frame:SetScript("OnUpdate", function(self, e)
		elapsed = elapsed + e
		if elapsed >= 0.5 then
			onUpdate(self, elapsed)
			elapsed = 0
		end
	end)
	frame:SetScript("OnEvent", function(self, event, ...)
		if infoFrame[event] then
			infoFrame[event](self, ...)
		end
	end)
	frame:SetScript("OnMouseDown", function(self, button)
		if button == "RightButton" then
			UIDropDownMenu_Initialize(dropdownFrame, initializeDropdown, "MENU")
			ToggleDropDownMenu(1, nil, dropdownFrame, "cursor", 5, -10)
		end
	end)
	return frame
end


------------------------
--  Update functions  --
------------------------
local function sortFuncDesc(a, b) return lines[a] > lines[b] end
local function sortFuncAsc(a, b) return lines[a] < lines[b] end
local function updateLines()
	table.wipe(sortedLines)
	for i in pairs(lines) do
		sortedLines[#sortedLines + 1] = i
	end
	if sortingAsc then
		table.sort(sortedLines, sortFuncAsc)
	else
		table.sort(sortedLines, sortFuncDesc)
	end
end

local function updateIcons()
	table.wipe(icons)
	if GetNumRaidMembers() > 0 then
		for i=1, GetNumRaidMembers() do
			local uId = "raid"..i
			local icon = GetRaidTargetIndex(uId)
			if icon then
				icons[UnitName(uId)] = ("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t"):format(icon)
			end
		end
	elseif GetNumPartyMembers() > 0 then
		for i=1, GetNumPartyMembers() do
			local uId = "party"..i
			local icon = GetRaidTargetIndex(uId)
			if icon then
				icons[UnitName(uId)] = ("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t"):format(icon)
			end
		end
		local icon = GetRaidTargetIndex("player")
		if icon then
			icons[UnitName("player")] = ("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:0|t"):format(icon)
		end
	end
end
		

--Icons are violently unstable in this method do to the health sorting code, it will creating about 200 errors per second.
local function updateHealth()
	table.wipe(lines)
	if GetNumRaidMembers() > 0 then
		for i = 1, GetNumRaidMembers() do
			local uId = "raid"..i
			local icon = GetRaidTargetIndex(uId)
			if UnitHealth(uId) < infoFrameThreshold and not UnitIsDeadOrGhost(uId) then
				lines[UnitName(uId)] = UnitHealth(uId) - infoFrameThreshold
			end
		end
	elseif GetNumPartyMembers() > 0 then
		for i = 1, GetNumPartyMembers() do
			local uId = "party"..i
			if UnitHealth(uId) < infoFrameThreshold and not UnitIsDeadOrGhost(uId) then
				lines[UnitName(uId)] = UnitHealth(uId) - infoFrameThreshold
			end
		end
		if UnitHealth("player") < infoFrameThreshold and not UnitIsDeadOrGhost("player") then
			lines[UnitName("player")] = UnitHealth("player") - infoFrameThreshold
		end
	end
	updateLines()
	updateIcons()
end



local function updatePlayerPower()
	table.wipe(lines)
	for i = 1, GetNumRaidMembers() do
		if not UnitIsDeadOrGhost("raid"..i) and UnitPower("raid"..i, pIndex)/UnitPowerMax("raid"..i, pIndex)*100 >= infoFrameThreshold then
			lines[UnitName("raid"..i)] = UnitPower("raid"..i, pIndex)
		end
	end
	if DBM.Options.InfoFrameShowSelf and not lines[UnitName("player")] and UnitPower("player", pIndex) > 0 then
		lines[UnitName("player")] = UnitPower("player", pIndex)
	end
	updateLines()
	updateIcons()
end

local function updateEnemyPower()
	table.wipe(lines)
	for i = 1, 4 do
		if UnitPower("boss"..i, pIndex)/UnitPowerMax("boss"..i, pIndex)*100 >= infoFrameThreshold then
			lines[UnitName("boss"..i)] = UnitPower("boss"..i, pIndex)
		end
	end
	updateLines()
end

local function updatePlayerBuffs()
	table.wipe(lines)
	if GetNumRaidMembers() > 0 then
		for i = 1, GetNumRaidMembers() do
			local uId = "raid"..i
			if not UnitBuff(uId, GetSpellInfo(infoFrameThreshold)) and not UnitIsDeadOrGhost(uId) then
				lines[UnitName(uId)] = ""
			end
		end
	elseif GetNumPartyMembers() > 0 then
		for i = 1, GetNumPartyMembers() do
			local uId = "party"..i
			if not UnitBuff(uId, GetSpellInfo(infoFrameThreshold)) and not UnitIsDeadOrGhost(uId) then
				lines[UnitName(uId)] = ""
			end
		end
		if not UnitBuff("player", GetSpellInfo(infoFrameThreshold)) and not UnitIsDeadOrGhost("player") then
			lines[UnitName("player")] = ""
		end
	end
	updateLines()
	updateIcons()
end

local function updatePlayerDebuffs()
	table.wipe(lines)
	if GetNumRaidMembers() > 0 then
		for i = 1, GetNumRaidMembers() do
			local uId = "raid"..i
			if not UnitDebuff(uId, GetSpellInfo(infoFrameThreshold)) and not UnitIsDeadOrGhost(uId) then
				lines[UnitName(uId)] = ""
			end
		end
	elseif GetNumPartyMembers() > 0 then
		for i = 1, GetNumPartyMembers() do
			local uId = "party"..i
			if not UnitDebuff(uId, GetSpellInfo(infoFrameThreshold)) and not UnitIsDeadOrGhost(uId) then
				local icon = GetRaidTargetIndex(uId)
				lines[UnitName(uId)] = ""
			end
		end
		if not UnitDebuff("player", GetSpellInfo(infoFrameThreshold)) and not UnitIsDeadOrGhost("player") then--"party"..i excludes player but "raid"..i includes player wtf?
			lines[UnitName("player")] = ""
		end
	end
	updateLines()
	updateIcons()
end

local function updatePlayerAggro()
	table.wipe(lines)
	if GetNumRaidMembers() > 0 then
		for i = 1, GetNumRaidMembers() do
			local uId = "raid"..i
			if UnitThreatSituation(uId) == infoFrameThreshold then
				lines[UnitName(uId)] = ""
			end
		end
	elseif GetNumPartyMembers() > 0 then
		for i = 1, GetNumPartyMembers() do
			local uId = "party"..i
			if UnitThreatSituation(uId) == infoFrameThreshold then
				lines[UnitName(uId)] = ""
			end
		end
	end
	updateLines()
	updateIcons()
end

----------------
--  OnUpdate  --
----------------
function onUpdate(self, elapsed)
	local addedSelf = false
	local color = NORMAL_FONT_COLOR
	self:ClearLines()
	if headerText then
		self:AddLine(headerText, 255, 255, 255, 0)
	end
	if currentEvent == "health" then
		updateHealth()
	elseif currentEvent == "playerpower" then
		updatePlayerPower()
	elseif currentEvent == "enemypower" then
		updateEnemyPower()
	elseif currentEvent == "playerbuff" then
		updatePlayerBuffs()
	elseif currentEvent == "playerdebuff" then
		updatePlayerDebuffs()
	elseif currentEvent == "playeraggro" then
		updatePlayerAggro()
	end
--	updateIcons()
	for i = 1, #sortedLines do
		if self:NumLines() > maxlines or not addedSelf and DBM.Options.InfoFrameShowSelf and self:NumLines() > maxlines-1 then break end
		local name = sortedLines[i]
		local power = lines[name]
		local icon = icons[name]
		if name == UnitName("player") then
			addedSelf = true
		end
		if icon then
			name = icons[name]..name
		end
		self:AddDoubleLine(name, power, color.R, color.G, color.B, 255, 255, 255)	-- (leftText, rightText, left.R, left.G, left.B, right.R, right.G, right.B)
	end					 						-- Add a method to color the power value?
	if not addedSelf and DBM.Options.InfoFrameShowSelf and currentEvent == "playerpower" then 	-- Don't show self on health/enemypower/playerdebuff
		self:AddDoubleLine(UnitName("player"), lines[UnitName("player")], color.R, color.G, color.B, 255, 255, 255)
	end
	self:Show()
end


---------------
--  Methods  --
---------------
function infoFrame:Show(maxLines, event, threshold, ...)
	if type(maxLines) ~= "number" then
		return self:Show(5, maxLines, event, ...)
	end

	infoFrameThreshold = threshold
	maxlines = maxLines or 5	-- default 5 lines
	pIndex = select(1, ...)
	currentEvent = event
	frame = frame or createFrame()

	if event == "health" then
		sortingAsc = true	-- Person who misses the most HP to be at threshold is listed on top
		updateHealth()
	elseif event == "playerpower" then
		updatePlayerPower()
	elseif event == "enemypower" then
		updateEnemyPower()
	elseif event == "playerbuff" then
		updatePlayerBuffs()
	elseif event == "playerdebuff" then
		updatePlayerDebuffs()
	elseif currentEvent == "playeraggro" then
		updatePlayerAggro()
	else
		print("DBM-InfoFrame: Unsupported event given")
	end
	
	frame:Show()
	frame:SetOwner(UIParent, "ANCHOR_PRESERVE")
	onUpdate(frame, 0)
end

function infoFrame:Hide()
	table.wipe(lines)
	table.wipe(sortedLines)
	headerText = "DBM Info Frame"
	sortingAsc = false
	infoFrameThreshold = nil
	pIndex = nil
	currentEvent = nil
	if frame then 
		frame:Hide()
	end
end

function infoFrame:IsShown()
	return frame and frame:IsShown()
end

function infoFrame:SetHeader(text)
	if not text then return end
	headerText = text
end

function infoFrame:SetSorting(ascending)
	sortingAsc = ascending
end