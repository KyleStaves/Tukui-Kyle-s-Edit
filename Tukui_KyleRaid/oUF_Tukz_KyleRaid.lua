local ADDON_NAME, ns = ...
local oUF = oUFTukui or oUF
assert(oUF, "Tukui was unable to locate oUF install.")

ns._Objects = {}
ns._Headers = {}

local T, C, L = unpack(Tukui) -- Import: T - functions, constants, variables; C - config; L - locales
if not C["unitframes"].enable == true then return end

local font2 = C["media"].uffont
local font1 = C["media"].font
local normTex = C["media"].normTex
local pixelfont = C["media"].pixelfont

local function Shared(self, unit)
	self.colors = T.oUF_colors
	self:RegisterForClicks("AnyUp")
	self:SetScript('OnEnter', UnitFrame_OnEnter)
	self:SetScript('OnLeave', UnitFrame_OnLeave)
	
	self.menu = T.SpawnMenu
	
	self:SetBackdrop({bgFile = C["media"].blank, insets = {top = -T.mult, left = -T.mult, bottom = -T.mult, right = -T.mult}})
	self:SetBackdropColor(0.1, 0.1, 0.1)
	
	local health = CreateFrame('StatusBar', nil, self)
	health:SetPoint("TOPLEFT")
	health:SetPoint("BOTTOMRIGHT")
	health:SetStatusBarTexture(normTex)
	self.Health = health
	
	if C["unitframes"].gridhealthvertical == true then
		health:SetOrientation('VERTICAL')
	end
	
	health.bg = health:CreateTexture(nil, 'BORDER')
	health.bg:SetAllPoints(health)
	health.bg:SetTexture(normTex)
	health.bg:SetTexture(0.3, 0.3, 0.3)
	health.bg.multiplier = (0.3)
	self.Health.bg = health.bg
	
	local name = health:CreateFontString(nil, "OVERLAY")
    name:SetPoint("CENTER", health, "CENTER", 0, 0)
	name:SetFont(pixelfont, 10, "THINOUTLINEMONOCHROME")
	self:Tag(name, "[Tukui:getnamecolor][Tukui:verynameshort]")
	self.Name = name
	
	health.value = health:CreateFontString(nil, "OVERLAY")
	health.value:Point("BOTTOM", name, "TOP", 0, 4)
	health.value:SetFont(pixelfont, 10, "THINOUTLINEMONOCHROME")
	health.value:SetTextColor(1,1,1)
	--health.value:SetShadowOffset(1, -1)
	self.Health.value = health.value
	
	health.PostUpdate = T.PostUpdateHealthRaid
	
	health.frequentUpdates = true
	
	if C.unitframes.unicolor == true then
		health.colorDisconnected = false
		health.colorClass = false
		health:SetStatusBarColor(.3, .3, .3, 1)
		health.bg:SetVertexColor(.1, .1, .1, 1)		
	else
		health.colorDisconnected = true
		health.colorClass = true
		health.colorReaction = true			
	end
	
	-- health border
	local Healthbg = CreateFrame("Frame", nil, self)
	Healthbg:SetPoint("TOPLEFT", self, "TOPLEFT", T.Scale(-2), T.Scale(2))
	Healthbg:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", T.Scale(2), T.Scale(-2))
	T.SetTemplate(Healthbg)
	T.CreateShadow(Healthbg)
	Healthbg:SetBackdropBorderColor(unpack(C["media"].altbordercolor))
	Healthbg:SetFrameLevel(2)
	self.Healthbg = Healthbg
	-- end health border
	
	local power = CreateFrame("StatusBar", nil, self)
	power:SetHeight(T.Scale(3))
	power:SetWidth(T.Scale(C.kyle.grid.width - 8))
	power:Point("TOP", self.Health, "BOTTOM", 0, 1)
	power:SetStatusBarTexture(normTex)
	power:SetFrameStrata(health:GetFrameStrata())
	power:SetFrameLevel(health:GetFrameLevel() + 2)
	self.Power = power
	
	-- power border
	local powerborder = CreateFrame("Frame", nil, self)
	T.CreatePanel(powerborder, 1, 1, "CENTER", health, "CENTER", 0, 0)
	powerborder:ClearAllPoints()
	powerborder:SetPoint("TOPLEFT", power, T.Scale(-2), T.Scale(2))
	powerborder:SetPoint("BOTTOMRIGHT", power, T.Scale(2), T.Scale(-2))
	powerborder:SetFrameStrata(health:GetFrameStrata())
	powerborder:SetFrameLevel(health:GetFrameLevel() + 1)
	T.SetTemplate(powerborder)
	T.CreateShadow(powerborder)
	self.powerborder = powerborder
	-- end border
	
	power.frequentUpdates = true
	power.colorDisconnected = true

	power.bg = power:CreateTexture(nil, "BORDER")
	power.bg:SetAllPoints(power)
	power.bg:SetTexture(normTex)
	power.bg:SetAlpha(1)
	power.bg.multiplier = 0.4
	
	if C.unitframes.unicolor == true then
		power.colorClass = true
		power.bg.multiplier = 0.1				
	else
		power.colorPower = true
	end
	
    if C["unitframes"].aggro == true then
		table.insert(self.__elements, T.UpdateThreat)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', T.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_LIST_UPDATE', T.UpdateThreat)
		self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', T.UpdateThreat)
	end
	
	if C["unitframes"].showsymbols == true then
		local RaidIcon = health:CreateTexture(nil, 'OVERLAY')
		RaidIcon:Height(18*T.raidscale)
		RaidIcon:Width(18*T.raidscale)
		RaidIcon:SetPoint('CENTER', self, 'TOP')
		RaidIcon:SetTexture("Interface\\AddOns\\Tukui\\medias\\textures\\raidicons.blp") -- thx hankthetank for texture
		self.RaidIcon = RaidIcon
	end
	
	local ReadyCheck = power:CreateTexture(nil, "OVERLAY")
	ReadyCheck:Height(12*C["unitframes"].gridscale*T.raidscale)
	ReadyCheck:Width(12*C["unitframes"].gridscale*T.raidscale)
	ReadyCheck:SetPoint('CENTER') 	
	self.ReadyCheck = ReadyCheck
	
	--local picon = self.Health:CreateTexture(nil, 'OVERLAY')
	--picon:SetPoint('CENTER', self.Health)
	--picon:SetSize(16, 16)
	--picon:SetTexture[[Interface\AddOns\Tukui\medias\textures\picon]]
	--picon.Override = T.Phasing
	--self.PhaseIcon = picon
	
	if not C["unitframes"].raidunitdebuffwatch == true then
		self.DebuffHighlightAlpha = 1
		self.DebuffHighlightBackdrop = true
		self.DebuffHighlightFilter = true
	end
	
	if C["unitframes"].showrange == true then
		local range = {insideAlpha = 1, outsideAlpha = C["unitframes"].raidalphaoor}
		self.Range = range
	end
	
	if C["unitframes"].showsmooth == true then
		health.Smooth = true
		power.Smooth = true
	end
	
	if C["unitframes"].healcomm then
		local mhpb = CreateFrame('StatusBar', nil, self.Health)
		if C["unitframes"].gridhealthvertical then
			mhpb:SetOrientation("VERTICAL")
			mhpb:SetPoint('BOTTOM', self.Health:GetStatusBarTexture(), 'TOP', 0, 0)
			mhpb:Width(C.kyle.grid.width)
			mhpb:Height(C.kyle.grid.height)		
		else
			mhpb:SetPoint('TOPLEFT', self.Health:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
			mhpb:SetPoint('BOTTOMLEFT', self.Health:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			mhpb:Width(C.kyle.grid.width)
		end				
		mhpb:SetStatusBarTexture(normTex)
		mhpb:SetStatusBarColor(0, 1, 0.5, 0.25)

		local ohpb = CreateFrame('StatusBar', nil, self.Health)
		if C["unitframes"].gridhealthvertical then
			ohpb:SetOrientation("VERTICAL")
			ohpb:SetPoint('BOTTOM', mhpb:GetStatusBarTexture(), 'TOP', 0, 0)
			ohpb:Width(C.kyle.grid.width)
			ohpb:Height(C.kyle.grid.height)
		else
			ohpb:SetPoint('TOPLEFT', mhpb:GetStatusBarTexture(), 'TOPRIGHT', 0, 0)
			ohpb:SetPoint('BOTTOMLEFT', mhpb:GetStatusBarTexture(), 'BOTTOMRIGHT', 0, 0)
			ohpb:Width(C.kyle.grid.width)
		end
		ohpb:SetStatusBarTexture(normTex)
		ohpb:SetStatusBarColor(0, 1, 0, 0.25)

		self.HealPrediction = {
			myBar = mhpb,
			otherBar = ohpb,
			maxOverflow = 1,
		}
	end
	
	if C["unitframes"].raidunitdebuffwatch == true then
		-- AuraWatch (corner icon)
		T.createAuraWatch(self,unit)
		
		-- Raid Debuffs (big middle icon)
		local RaidDebuffs = CreateFrame('Frame', nil, self)
		RaidDebuffs:Height(24*C["unitframes"].gridscale)
		RaidDebuffs:Width(24*C["unitframes"].gridscale)
		RaidDebuffs:Point('CENTER', health, 1,0)
		RaidDebuffs:SetFrameStrata(health:GetFrameStrata())
		RaidDebuffs:SetFrameLevel(health:GetFrameLevel() + 2)
		
		RaidDebuffs:SetTemplate("Default")
		
		RaidDebuffs.icon = RaidDebuffs:CreateTexture(nil, 'OVERLAY')
		RaidDebuffs.icon:SetTexCoord(.1,.9,.1,.9)
		RaidDebuffs.icon:Point("TOPLEFT", 2, -2)
		RaidDebuffs.icon:Point("BOTTOMRIGHT", -2, 2)
		
		-- just in case someone want to add this feature, uncomment to enable it
		--[[
		if C["unitframes"].auratimer then
			RaidDebuffs.cd = CreateFrame('Cooldown', nil, RaidDebuffs)
			RaidDebuffs.cd:SetPoint("TOPLEFT", T.Scale(2), T.Scale(-2))
			RaidDebuffs.cd:SetPoint("BOTTOMRIGHT", T.Scale(-2), T.Scale(2))
			RaidDebuffs.cd.noOCC = true -- remove this line if you want cooldown number on it
		end
		--]]
		
		RaidDebuffs.count = RaidDebuffs:CreateFontString(nil, 'OVERLAY')
		RaidDebuffs.count:SetFont(pixelfont, 10, "THINOUTLINEMONOCHROME")
		RaidDebuffs.count:SetPoint('BOTTOMRIGHT', RaidDebuffs, 'BOTTOMRIGHT', 0, 2)
		RaidDebuffs.count:SetTextColor(1, .9, 0)
		
		RaidDebuffs:FontString('time', pixelfont, 10, "THINOUTLINEMONOCHROME")
		RaidDebuffs.time:SetPoint('CENTER')
		RaidDebuffs.time:SetTextColor(1, .9, 0)
		
		self.RaidDebuffs = RaidDebuffs
    end

	return self
end

-- CREATE ANCHOR
local raidAnchorFrame = CreateFrame("Frame", "TukuiKyleRaidFrameAnchor", UIParent)
raidAnchorFrame:CreatePanel("Default", 8, 8, "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
raidAnchorFrame:SetFrameStrata("HIGH")
raidAnchorFrame:SetFrameLevel(1)
if C.chat.background then
	raidAnchorFrame:Point("BOTTOMLEFT", TukuiChatBackgroundLeft, "TOPLEFT", 0, 50)
end
raidAnchorFrame:EnableMouse(true)
raidAnchorFrame:RegisterForDrag("LeftButton")
raidAnchorFrame:SetMovable(true)
raidAnchorFrame:SetScript("OnDragStart",function(self) self:StartMoving() end)
raidAnchorFrame:SetScript("OnDragStop",function(self) self:StopMovingOrSizing() end)

oUF:RegisterStyle('TukuiKyleRaid', Shared)
oUF:Factory(function(self)
	oUF:SetActiveStyle("TukuiKyleRaid")
	local raid = self:SpawnHeader("TukuiGrid", nil, "solo,party,raid",
		'oUF-initialConfigFunction', [[
			local header = self:GetParent()
			self:SetWidth(header:GetAttribute('initial-width'))
			self:SetHeight(header:GetAttribute('initial-height'))
		]],
		'initial-width', T.Scale(C.kyle.grid.width),
		'initial-height', T.Scale(C.kyle.grid.height),
		"showParty", true,
		"showPlayer", true, 
		"showRaid", true,
		"showSolo", true,
		"xoffset", T.Scale(10),
		"yOffset", T.Scale(10),
		"point", "LEFT",
		"groupFilter", "1,2,3,4,5,6,7,8",
		"groupingOrder", "1,2,3,4,5,6,7,8",
		"groupBy", "GROUP",
		"maxColumns", 8,
		"unitsPerColumn", 5,
		"columnSpacing", T.Scale(10),
		"columnAnchorPoint", "BOTTOM"		
	)
	raid:SetPoint("BOTTOMLEFT", TukuiKyleRaidFrameAnchor, "TOPRIGHT", T.Scale(6), T.Scale(6))
end)