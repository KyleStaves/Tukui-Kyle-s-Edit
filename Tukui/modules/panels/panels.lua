local T, C, L = unpack(select(2, ...)) -- Import: T - functions, constants, variables; C - config; L - locales

-- INVISIBLE FRAME COVERING BOTTOM ACTIONBARS JUST TO PARENT UF CORRECTLY
local invbarbg = CreateFrame("Frame", "InvTukuiActionBarBackground", UIParent)
invbarbg:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 2)
invbarbg:SetHeight((T.buttonsize * 2) + (T.buttonspacing * 3))
invbarbg:SetWidth((T.buttonsize * 24) + (T.buttonspacing * 25))

-- BOTTOM BARS --

local TukuiBar1 = CreateFrame("Frame", "TukuiBar1", UIParent, "SecureHandlerStateTemplate")
TukuiBar1:CreatePanel("Invisible", 1, 1, "BOTTOMLEFT", invbarbg, "BOTTOMLEFT", 0, 0)
TukuiBar1:SetWidth((T.buttonsize * 12) + (T.buttonspacing * 13))
TukuiBar1:SetHeight((T.buttonsize * 1) + (T.buttonspacing * 2))
TukuiBar1:SetFrameStrata("BACKGROUND")
TukuiBar1:SetFrameLevel(1)

local TukuiBar4 = CreateFrame("Frame", "TukuiBar4", UIParent, "SecureHandlerStateTemplate")
TukuiBar4:CreatePanel("Invisible", 1, 1, "BOTTOMRIGHT", invbarbg, "BOTTOMRIGHT", 0, 0)
TukuiBar4:SetWidth((T.buttonsize * 12) + (T.buttonspacing * 13))
TukuiBar4:SetHeight((T.buttonsize * 1) + (T.buttonspacing * 2))
TukuiBar4:SetFrameStrata("BACKGROUND")
TukuiBar4:SetFrameLevel(1)

-- RIGHT BARS --

local TukuiBarRight = CreateFrame("Frame", "TukuiBarRight", UIParent)
TukuiBarRight:CreatePanel("Invisible", 1, (T.buttonsize * 12) + (T.buttonspacing * 13), "RIGHT", UIParent, "RIGHT", -5, -14)
TukuiBarRight:SetWidth((T.buttonsize * 2) + (T.buttonspacing * 3))
TukuiBarRight:SetHeight((T.buttonsize * 12) + (T.buttonspacing * 13))
TukuiBarRight:SetFrameStrata("BACKGROUND")
TukuiBarRight:SetFrameLevel(4)

local TukuiBar5 = CreateFrame("Frame", "TukuiBar5", UIParent)
TukuiBar5:CreatePanel("Invisible", 1, 1, "TOPRIGHT", TukuiBarRight, "TOPRIGHT", 0, 0)
TukuiBar5:SetWidth((T.buttonsize * 1) + (T.buttonspacing * 2))
TukuiBar5:SetFrameStrata("BACKGROUND")
TukuiBar5:SetFrameLevel(2)
TukuiBar5:SetAlpha(0)

local TukuiBar3 = CreateFrame("Frame", "TukuiBar3", UIParent)
TukuiBar3:CreatePanel("Invisible", 1, 1, "TOPLEFT", TukuiBarRight, "TOPLEFT", 0, 0)
TukuiBar3:SetWidth((T.buttonsize * 1) + (T.buttonspacing * 2))
TukuiBar3:SetHeight((T.buttonsize * 12) + (T.buttonspacing * 13))
TukuiBar3:SetFrameStrata("BACKGROUND")
TukuiBar3:SetFrameLevel(2)

local TukuiBar6 = CreateFrame("Frame", "TukuiBar6", UIParent)
TukuiBar6:SetWidth((T.buttonsize * 1) + (T.buttonspacing * 2))
TukuiBar6:SetHeight((T.buttonsize * 12) + (T.buttonspacing * 13))
TukuiBar6:SetPoint("LEFT", TukuiBar5, "LEFT", 0, 0)
TukuiBar6:SetFrameStrata("BACKGROUND")
TukuiBar6:SetFrameLevel(2)
TukuiBar6:SetAlpha(0)

local TukuiBar7 = CreateFrame("Frame", "TukuiBar7", UIParent)
TukuiBar7:SetWidth((T.buttonsize * 1) + (T.buttonspacing * 2))
TukuiBar7:SetHeight((T.buttonsize * 12) + (T.buttonspacing * 13))
TukuiBar7:SetPoint("TOP", TukuiBar5, "TOP", 0 , 0)
TukuiBar7:SetFrameStrata("BACKGROUND")
TukuiBar7:SetFrameLevel(2)
TukuiBar7:SetAlpha(0)

-- PET BARS --
local petbg = CreateFrame("Frame", "TukuiPetBar", UIParent, "SecureHandlerStateTemplate")
petbg:CreatePanel("Invisible", T.petbuttonsize + (T.petbuttonspacing * 2), (T.petbuttonsize * 10) + (T.petbuttonspacing * 11), "RIGHT", TukuiBarRight, "LEFT", -6, 0)
petbg:SetAlpha(0)

-- DISABLED BARS --
local TukuiBar2 = CreateFrame("Frame", "TukuiBar2", UIParent)
TukuiBar2:CreatePanel("Default", 1, 1, "BOTTOMRIGHT", TukuiBar1, "BOTTOMLEFT", -25, 0)
TukuiBar2:SetWidth((T.buttonsize * 6) + (T.buttonspacing * 7))
TukuiBar2:SetHeight((T.buttonsize * 2) + (T.buttonspacing * 3))
TukuiBar2:SetFrameStrata("BACKGROUND")
TukuiBar2:SetFrameLevel(2)
TukuiBar2:SetAlpha(0)
if true or T.lowversion then
	TukuiBar2:SetAlpha(0)
else
	TukuiBar2:SetAlpha(1)
end

-- LEFT VERTICAL LINE
local ileftlv = CreateFrame("Frame", "TukuiInfoLeftLineVertical", TukuiBar1)
ileftlv:CreatePanel("Default", 2, 130, "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 22, 30)

-- RIGHT VERTICAL LINE
local irightlv = CreateFrame("Frame", "TukuiInfoRightLineVertical", TukuiBar1)
irightlv:CreatePanel("Default", 2, 130, "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -22, 30)

if not C.chat.background then
	-- CUBE AT LEFT, ACT AS A BUTTON (CHAT MENU)
	local cubeleft = CreateFrame("Frame", "TukuiCubeLeft", TukuiBar1)
	cubeleft:CreatePanel("Default", 10, 10, "BOTTOM", ileftlv, "TOP", 0, 0)
	cubeleft:EnableMouse(true)
	cubeleft:SetScript("OnMouseDown", function(self, btn)
		if TukuiInfoLeftBattleGround and UnitInBattleground("player") then
			if btn == "RightButton" then
				if TukuiInfoLeftBattleGround:IsShown() then
					TukuiInfoLeftBattleGround:Hide()
				else
					TukuiInfoLeftBattleGround:Show()
				end
			end
		end
		
		if btn == "LeftButton" then	
			ToggleFrame(ChatMenu)
		end
	end)

	-- CUBE AT RIGHT, ACT AS A BUTTON (CONFIGUI or BG'S)
	local cuberight = CreateFrame("Frame", "TukuiCubeRight", TukuiBar1)
	cuberight:CreatePanel("Default", 10, 10, "BOTTOM", irightlv, "TOP", 0, 0)
	if C["bags"].enable then
		cuberight:EnableMouse(true)
		cuberight:SetScript("OnMouseDown", function(self)
			if T.toc < 40200 then ToggleKeyRing() else ToggleAllBags() end
		end)
	end
end

-- HORIZONTAL LINE LEFT
local ltoabl = CreateFrame("Frame", "TukuiLineToABLeft", TukuiBar1)
ltoabl:CreatePanel("Default", 5, 2, "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
ltoabl:ClearAllPoints()
ltoabl:Point("BOTTOMLEFT", ileftlv, "BOTTOMLEFT", 0, 0)
ltoabl:Point("RIGHT", TukuiBar1, "BOTTOMLEFT", -1, 17)
ltoabl:SetFrameStrata("BACKGROUND")
ltoabl:SetFrameLevel(1)

-- HORIZONTAL LINE RIGHT
local ltoabr = CreateFrame("Frame", "TukuiLineToABRight", TukuiBar1)
ltoabr:CreatePanel("Default", 5, 2, "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
ltoabr:ClearAllPoints()
ltoabr:Point("LEFT", TukuiBar1, "BOTTOMRIGHT", 1, 17)
ltoabr:Point("BOTTOMRIGHT", irightlv, "BOTTOMRIGHT", 0, 0)
ltoabr:SetFrameStrata("BACKGROUND")
ltoabr:SetFrameLevel(1)

-- MOVE/HIDE SOME ELEMENTS IF CHAT BACKGROUND IS ENABLED
local movechat = 0
if C.chat.background then movechat = 10 ileftlv:SetAlpha(0) irightlv:SetAlpha(0) end

-- BOTTOM BAR
local bottomBar = CreateFrame("Frame", "TukuiBottomBar", UIParent)
bottomBar:CreatePanel("Default", 6000, 23, "BOTTOM", UIParent, "BOTTOM", 0, -5)
bottomBar:CreateShadow()
bottomBar:SetFrameLevel(0)
bottomBar:SetFrameStrata("BACKGROUND")

-- TOP BAR
local topBar = CreateFrame("Frame", "TukuiTopBar", UIParent)
topBar:CreatePanel("Default", 6000, 23, "TOP", UIParent, "TOP", 0, 7)
topBar:CreateShadow()
topBar:SetFrameLevel(0)
topBar:SetFrameStrata("BACKGROUND")

if C.chat.background then
	-- Alpha horizontal lines because all panels is dependent on this frame.
	ltoabl:SetAlpha(0)
	ltoabr:SetAlpha(0)
	
	-- CHAT BG LEFT
	local chatleftbg = CreateFrame("Frame", "TukuiChatBackgroundLeft", UIParent)
	chatleftbg:CreatePanel("Transparent", C.kyle.chatWidth + 11, C.kyle.chatHeight + 11, "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 7, 7)
	chatleftbg:CreateShadow()
	
	-- CHAT BG RIGHT
	local chatrightbg = CreateFrame("Frame", "TukuiChatBackgroundRight", UIParent)
	chatrightbg:CreatePanel("Transparent", C.kyle.chatWidth + 11, C.kyle.chatHeight + 11, "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -7, 7)
	chatrightbg:CreateShadow()
	
	-- LEFT TAB PANEL
	if not C.kyle.disableChatTabs then
		local tabsbgleft = CreateFrame("Frame", "TukuiTabsLeftBackground", TukuiBar1)
		tabsbgleft:CreatePanel("Default", T.InfoLeftRightWidth, 23, "TOP", chatleftbg, "TOP", 0, -6)
		tabsbgleft:SetFrameLevel(2)
		tabsbgleft:SetFrameStrata("BACKGROUND")
	end
		
	-- RIGHT TAB PANEL
	if not C.kyle.disableChatTabs then
		local tabsbgright = CreateFrame("Frame", "TukuiTabsRightBackground", TukuiBar1)
		tabsbgright:CreatePanel("Default", T.InfoLeftRightWidth, 23, "TOP", chatrightbg, "TOP", 0, -6)
		tabsbgright:SetFrameLevel(2)
		tabsbgright:SetFrameStrata("BACKGROUND")
	end
	
	-- [[ Create new horizontal line for chat background ]] --
	-- HORIZONTAL LINE LEFT
	--[[
	local ltoabl2 = CreateFrame("Frame", "TukuiLineToABLeftAlt", TukuiBar1)
	ltoabl2:CreatePanel("Default", 5, 2, "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
	ltoabl2:ClearAllPoints()
	ltoabl2:Point("RIGHT", TukuiBar1, "LEFT", 0, 16)
	ltoabl2:Point("BOTTOMLEFT", chatleftbg, "BOTTOMRIGHT", 0, 16)

	-- HORIZONTAL LINE RIGHT
	local ltoabr2 = CreateFrame("Frame", "TukuiLineToABRightAlt", TukuiBar1)
	ltoabr2:CreatePanel("Default", 5, 2, "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
	ltoabr2:ClearAllPoints()
	ltoabr2:Point("LEFT", TukuiBar1, "RIGHT", 0, 16)
	ltoabr2:Point("BOTTOMRIGHT", chatrightbg, "BOTTOMLEFT", 0, 16)
	]]--
end

-- Experience Frame
local expFrame = CreateFrame("Frame", "TukuiExperienceFrame", UIParent)
expFrame:CreatePanel("Default", 300, 17, "TOP", UIParent, "TOP", 0, -6)
expFrame:SetFrameStrata("BACKGROUND")
expFrame:SetFrameLevel(1)

-- Buttons
-- local expLeftButton = CreateFrame("Frame", "TukuiExperienceButtonLeft", UIParent)
-- expLeftButton:CreatePanel("Default", 15, 15, "RIGHT", expFrame, "LEFT", -3, 0)
-- expLeftButton:SetFrameStrata("BACKGROUND")
-- expLeftButton:SetFrameLevel(1)

local expLeftButton = CreateFrame("Button", "TukuiExperienceButtonLeft", UIParent)
expLeftButton:Width(15)
expLeftButton:Height(15)
expLeftButton:Point("RIGHT", expFrame, "LEFT", -3, 0)
expLeftButton:SetFrameStrata("BACKGROUND")
expLeftButton:SetFrameLevel(1)
expLeftButton:SetTemplate("Default")
expLeftButton:RegisterForClicks("AnyUp")

local expRightButton = CreateFrame("Frame", "TukuiExperienceButtonRight", UIParent)
expRightButton:CreatePanel("Default", 15, 15, "LEFT", expFrame, "RIGHT", 3, 0)
expRightButton:SetFrameStrata("BACKGROUND")
expRightButton:SetFrameLevel(1)

-- Stats Frames
local statFrame1 = CreateFrame("Frame", "TukuiStatFrameTopLeft1", UIParent)
statFrame1:CreatePanel("Default", 82, 17, "TOPLEFT", UIParent, "TOPLEFT", 6, -6)
statFrame1:SetFrameStrata("BACKGROUND")
statFrame1:SetFrameLevel(1)

local statFrame2 = CreateFrame("Frame", "TukuiStatFrameTopLeft2", UIParent)
statFrame2:CreatePanel("Default", 82, 17, "LEFT", TukuiStatFrameTopLeft1, "RIGHT", 6, 0)
statFrame2:SetFrameStrata("BACKGROUND")
statFrame2:SetFrameLevel(1)

local statFrame3 = CreateFrame("Frame", "TukuiStatFrameTopLeft3", UIParent)
statFrame3:CreatePanel("Default", 82, 17, "LEFT", TukuiStatFrameTopLeft2, "RIGHT", 6, 0)
statFrame3:SetFrameStrata("BACKGROUND")
statFrame3:SetFrameLevel(1)

local statFrame6 = CreateFrame("Frame", "TukuiStatFrameTopRight3", UIParent)
statFrame6:CreatePanel("Default", 82, 17, "TOPRIGHT", UIParent, "TOPRIGHT", -6, -6)
statFrame6:SetFrameStrata("BACKGROUND")
statFrame6:SetFrameLevel(1)

local statFrame5 = CreateFrame("Frame", "TukuiStatFrameTopRight2", UIParent)
statFrame5:CreatePanel("Default", 82, 17, "RIGHT", TukuiStatFrameTopRight3, "LEFT", -6, 0)
statFrame5:SetFrameStrata("BACKGROUND")
statFrame5:SetFrameLevel(1)

local statFrame4 = CreateFrame("Frame", "TukuiStatFrameTopRight1", UIParent)
statFrame4:CreatePanel("Default", 82, 17, "RIGHT", TukuiStatFrameTopRight2, "LEFT", -6, 0)
statFrame4:SetFrameStrata("BACKGROUND")
statFrame4:SetFrameLevel(1)



--BATTLEGROUND STATS FRAME
if C["datatext"].battleground == true then
	local bgframe = CreateFrame("Frame", "TukuiInfoLeftBattleGround", UIParent)
	bgframe:CreatePanel("Default", 1, 1, "TOPLEFT", UIParent, "BOTTOMLEFT", 0, 0)
	bgframe:SetAllPoints(expFrame)
	bgframe:SetFrameStrata("HIGH")
	bgframe:SetFrameLevel(0)
	bgframe:EnableMouse(true)
	
	local function ToggleBattlegroundFrame()
		if TukuiInfoLeftBattleGround:IsShown() then
			TukuiInfoLeftBattleGround:Hide()
		else
			TukuiInfoLeftBattleGround:Show()
		end
	end
	
	expLeftButton:EnableMouse(true)
	expLeftButton:SetScript("OnClick", function() ToggleBattlegroundFrame() end)
	
end
