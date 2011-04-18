local SetJob_Frame = function(self, job)
    if job.alpha then
        self:SetAlpha(job.alpha)
    end
end
local Frame_HideFunc = function(self)
    self:SetAlpha(1) -- to exit frrom OOR status
end
local SetJob_HealthBar = function(self, job)
    local c
    if job.classcolor then
        c = self.parent.classcolor
    elseif job.color then
        c = job.color
    end
    if c then
        self:SetStatusBarColor(0,0,0,0.8)
        self.bg:SetVertexColor(unpack(c))
    end
end

local SetJob_PowerBar = function(self, job)
	local c = self.parent.classcolor
	
	if c then
		self:SetStatusBarColor(unpack(c))
		local r, g, b, a = unpack(c);
		self.bg:SetVertexColor(r * 0.4, g * 0.4, b * 0.4, a);
	end
end

local PowerBar_OnPowerTypeChange = function(self, powertype)
    local self = self.parent
    if powertype ~= "MANA" then
        self.health:SetPoint("TOPRIGHT",self,"TOPRIGHT",0,0)
        self.power:Hide()
        self.power.bg:Hide()
    else
        self.health:SetPoint("TOPRIGHT",self.power,"TOPLEFT",0,0)
        self.power:Show()
        self.power.bg:Show()
    end
	
	-- self.health:SetPoint("BOTTOMRIGHT",self.power,"BOTTOMLEFT",0,7)
    -- self.power:Show()
    -- self.power.bg:Show()
end
local SetJob_Indicator = function(self,job)
    if job.showDuration then
        self.cd:SetCooldown(job.expirationTime - job.duration,job.duration)
        self.cd:Show()
    else
        self.cd:Hide()
    end

    local color
    if job.foreigncolor and job.isforeign then
        color = job.foreigncolor
    else
        color = job.color or { 1,1,1,1 }
    end
    self.color:SetVertexColor(unpack(color))
    
    if job.fade then
        if self.blink:IsPlaying() then self.blink:Finish() end
        self.traceJob = job
        self.blink.a2:SetDuration(job.fade)
        self.blink:Play()
    end
    if job.pulse and (not self.currentJob or job.priority > self.currentJob.priority) then
        if not self.pulse:IsPlaying() then self.pulse:Play() end
    end
end
local CreateIndicator = function (parent,w,h,point,frame,to,x,y,nobackdrop)
    local f = CreateFrame("Frame",nil,parent)
    f:SetWidth(w); f:SetHeight(h);
    if not nobackdrop then
    f:SetBackdrop{
        bgFile = "Interface\\Addons\\Aptechka\\white", tile = true, tileSize = 0,
        insets = {left = TukuiDB.Scale(-1), right = TukuiDB.Scale(-1), top = TukuiDB.Scale(-1), bottom = TukuiDB.Scale(-1)},
    }
    f:SetBackdropColor(0, 0, 0, .2)
    end
    f:SetFrameLevel(6)
    local t = f:CreateTexture(nil,"ARTWORK")
    t:SetTexture[[Interface\AddOns\Aptechka\white]]
    t:SetAllPoints(f)
    f.color = t
    local icd = CreateFrame("Cooldown",nil,f)
    icd.noCooldownCount = true -- disable OmniCC for this cooldown
    icd:SetReverse(true)
    icd:SetAllPoints(f)
    f.cd = icd
    f:SetPoint(point,frame,to,x,y)
    f.parent = parent
    f.SetJob = SetJob_Indicator
    
    local pag = f:CreateAnimationGroup()
    local pa1 = pag:CreateAnimation("Scale")
    pa1:SetScale(2,2)
    pa1:SetDuration(0.2)
    pa1:SetOrder(1)
    local pa2 = pag:CreateAnimation("Scale")
    pa2:SetScale(0.5,0.5)
    pa2:SetDuration(0.8)
    pa2:SetOrder(2)
    
    f.pulse = pag
    
    local bag = f:CreateAnimationGroup()
    local ba1 = bag:CreateAnimation("Alpha")
    ba1:SetChange(1)
    ba1:SetDuration(0.1)
    ba1:SetOrder(1)
    local ba2 = bag:CreateAnimation("Alpha")
    ba2:SetChange(-1)
    ba2:SetDuration(0.7)
    ba2:SetOrder(2)
    bag.a2 = ba2
    bag:SetScript("OnFinished",function(self)
        self = self:GetParent()
        Aptechka.FrameSetJob(self.parent,self.traceJob, false)
    end)
    f.blink = bag
    
    f:Hide()
    return f
end

local SetJob_Icon = function(self,job)
    if job.fade then self.jobs[job.name] = nil; return end
    if job.showDuration then
        self.cd:SetCooldown(job.expirationTime - job.duration,job.duration)
        self.cd:Show()
    else
        self.cd:Hide()
    end
    self.texture:SetTexture(job.texture)
    
    if self.stacktext then
        if job.stacks then self.stacktext:SetText(job.stacks > 1 and job.stacks or "") end
    end
end
local CreateIcon = function(parent,w,h,alpha,point,frame,to,x,y)
    local icon = CreateFrame("Frame",nil,parent)
    icon:SetWidth(w); icon:SetHeight(h)
    icon:SetPoint(point,frame,to,x,y)
    local icontex = icon:CreateTexture(nil,"ARTWORK")
    icon:SetFrameLevel(6)
    icontex:SetAllPoints(icon)
    icon.texture = icontex
    icon:SetAlpha(alpha)
    
    local icd = CreateFrame("Cooldown",nil,icon)
    icd.noCooldownCount = true -- disable OmniCC for this cooldown
    icd:SetReverse(true)
    icd:SetAllPoints(icon)
    icon.cd = icd
    
    local stacktext = icon:CreateFontString(nil,"OVERLAY")
    if AptechkaUserConfig.font then
        stacktext:SetFont(AptechkaUserConfig.font,10,"OUTLINE")
    else
        stacktext:SetFontObject("NumberFontNormal")
    end
    stacktext:SetJustifyH"RIGHT"
    stacktext:SetPoint("BOTTOMRIGHT",icon,"BOTTOMRIGHT",0,0)
    stacktext:SetTextColor(1,1,1)
    icon.stacktext = stacktext
    icon.SetJob = SetJob_Icon
    
    return icon
end

local SetJob_Text1 = function(self,job)
    if job.healthtext then
		--local r, g, b = oUF.ColorGradient(self.parent.vHealth/self.parent.vHealthMax, 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
        --self:SetFormattedText("-%.0fk", (self.parent.vHealthMax - self.parent.vHealth) / 1e3)
		self:SetFormattedText("|cff%02x%02x%02x%s%.0fk|r", 1 * 255, 1 * 255, 1 * 255, "-" ,(self.parent.vHealthMax - self.parent.vHealth) / 1e3)
    elseif job.nametext then
        self:SetText(self.parent.name)
    elseif job.text then
        self:SetText(job.text)
    end
    local c
    if job.classcolor then
        c = self.parent.classcolor
    elseif job.color then
        c = job.color
    end
    if c then self:SetTextColor(unpack(c)) end
end
local SetJob_Text2 = function(self,job) -- text2 is always green
    if job.healthtext then
        --local r, g, b = oUF.ColorGradient(self.parent.vHealth/self.parent.vHealthMax, 0.69, 0.31, 0.31, 0.65, 0.63, 0.35, 0.33, 0.59, 0.33)
        --self:SetFormattedText("-%.0fk", (self.parent.vHealthMax - self.parent.vHealth) / 1e3)
		self:SetFormattedText("|cff%02x%02x%02x%s%.0fk|r", 1 * 255, 1 * 255, 1 * 255, "-" ,(self.parent.vHealthMax - self.parent.vHealth) / 1e3)
    elseif job.inchealtext then
        self:SetFormattedText("+%.0fk", self.parent.vIncomingHeal / 1e3)
    elseif job.nametext then
        self:SetText(self.parent.name)
    elseif job.text then
        self:SetText(job.text)
    end
end
    local Text3_OnUpdate = function(self,time)
        self.text:SetText(string.format("%.1f",self.text.expirationTime - GetTime()))
    end
    local Text3_HideFunc = function(self)
        self.frame:SetScript("OnUpdate",nil)
        self:Hide()
    end
local SetJob_Text3 = function(self,job) -- text2 is always green
    self.expirationTime = job.expirationTime
    self.frame:SetScript("OnUpdate",Text3_OnUpdate)
    
    local c
    if job.color then
        c = job.color
    end
    self:SetTextColor(unpack(c))
end
local CreateTextTimer = function(parent,point,frame,to,x,y,hjustify,fontsize,font,flags)
    local text3container = CreateFrame("Frame", nil, parent) -- We need frame to create OnUpdate handler for time updates
    local text3 = text3container:CreateFontString(nil, "ARTWORK")
    text3container.text = text3
--~     text3container:Hide()
    text3:SetPoint(point,frame,to,x,y)--"TOPLEFT",self,"TOPLEFT",-2,0)
    text3:SetJustifyH"LEFT"
    text3:SetFont(font, fontsize or 11, flags)
    text3.SetJob = SetJob_Text3
    text3.HideFunc = Text3_HideFunc
    text3.parent = parent
    text3.frame = text3container
    return text3
end

local SetJob_Border = function(self,job)
    if job.color then
        self:SetBackdropBorderColor(job.color)
    end
end

local OnMouseEnterFunc = function(self)
    self.mouseover:Show()
end
local OnMouseLeaveFunc = function(self)
    self.mouseover:Hide()
end

AptechkaDefaultConfig.VanceSkin = function(self)
    local config
    if AptechkaUserConfig then config = AptechkaUserConfig else config = AptechkaDefaultConfig end
    AptechkaDefaultConfig.width = 55
    AptechkaDefaultConfig.height = 55
    --AptechkaDefaultConfig.texture = [[Interface\AddOns\Aptechka_Vance\media\statusbar]]
    AptechkaDefaultConfig.font = [[Interface\AddOns\Aptechka_Vance\media\SFPixelate.ttf]]
	AptechkaDefaultConfig.texture = TukuiCF["media"].normTex
	--AptechkaDefaultConfig.font = TukuiCF["media"].pixelfont
    --AptechkaDefaultConfig.fontsize = TukuiCF["datatext"].fontsize
	AptechkaDefaultConfig.fontsize = 10
    AptechkaDefaultConfig.cropNamesLen = 6
	AptechkaDefaultConfig.resize = false
    local texture = config.texture
    local font = config.font
    local fontsize = config.fontsize
    local manabar_width = config.manabarwidth
	local glowTex = TukuiCF["media"].glowTex
	
	local db = TukuiCF["unitframes"]
    
    self:SetWidth(TukuiDB.Scale(config.width))
    self:SetHeight(TukuiDB.Scale(config.height))
    
    local backdrop = {
        bgFile = TukuiCF["media"].blank,
		insets = {top = -TukuiDB.mult, left = -TukuiDB.mult, bottom = -TukuiDB.mult, right = -TukuiDB.mult},
    }
    --self:SetBackdrop(backdrop)
	--self:SetBackdropColor(0, 0, 0, 1)
	-- self:SetBackdrop(backdrop)
	-- self:SetBackdropColor(0, 0, 0, 0)
    
    local powerbar = CreateFrame("StatusBar", nil, self)
    powerbar:SetPoint("TOPRIGHT",self,"TOPRIGHT",0,0)
    powerbar:SetPoint("BOTTOMRIGHT",self,"BOTTOMRIGHT",0,0)
	powerbar:SetWidth(TukuiDB.Scale(3))
	powerbar:SetStatusBarTexture(texture)
    powerbar:SetMinMaxValues(0,100)
    powerbar.parent = self
    powerbar:SetOrientation("VERTICAL")
    powerbar.SetJob = SetJob_PowerBar
    powerbar.OnPowerTypeChange = PowerBar_OnPowerTypeChange
    
    local pbbg = self:CreateTexture()
	pbbg:SetAllPoints(powerbar)
	pbbg:SetTexture(texture)
    powerbar.bg = pbbg
	pbbg:SetVertexColor(0,0,0,0.8)
	
	-- power border
	-- local powerborder = CreateFrame("Frame", nil, powerbar)
	-- TukuiDB.SetTemplate(powerborder)
	-- TukuiDB.CreateShadow(powerborder)
	-- powerborder:SetPoint("TOPLEFT", powerbar, "TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
	-- powerborder:SetPoint("BOTTOMRIGHT", powerbar, "BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
	-- powerborder:SetBackdropColor( 0,0,0,1 )
	-- powerborder:SetFrameLevel(1)
    
    
    local hp = CreateFrame("StatusBar", nil, self)
	--hp:SetAllPoints(self)
    hp:SetPoint("TOPLEFT",self,"TOPLEFT",0,0)
    hp:SetPoint("BOTTOMRIGHT",powerbar,"BOTTOMLEFT",0,0)
	hp:SetStatusBarTexture(texture)
    hp:SetMinMaxValues(0,100)
    hp:SetOrientation("VERTICAL")
	hp:SetStatusBarColor(0.33, 0.33, 0.33, 1)
    hp.parent = self
	hp:SetFrameLevel(4)
    --hp.SetJob = SetJob_HealthBar
    --hp:SetValue(0)
	
	
	-- health bar
	-- local health = CreateFrame('StatusBar', nil, self)
	-- if TukuiDB.lowversion then
		-- health:SetHeight(TukuiDB.Scale(13))
	-- else
		-- health:SetHeight(TukuiDB.Scale(19))
	-- end
	-- health:SetPoint("TOPLEFT")
	-- health:SetPoint("TOPRIGHT")
	-- health:SetStatusBarTexture(normTex)
	
	-- health border
	local hpborder = CreateFrame("Frame", nil, self)
	TukuiDB.SetTemplate(hpborder)
	TukuiDB.CreateShadow(hpborder)
	hpborder:SetPoint("TOPLEFT", self, "TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
	hpborder:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
	hpborder:SetBackdropColor( 0,0,0,1 )
	hpborder:SetFrameLevel(1)
	
	local border = CreateFrame("Frame", nil, self)
	TukuiDB.SetTemplate(border)
	border:SetPoint("TOPLEFT", self, "TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
	border:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
	border:SetBackdropColor( 0,0,0,1 )
	border:SetBackdropBorderColor( 1, 0, 0, 1)
	border:SetFrameLevel(2)
	border:Hide()
	
	-- local testBorder = CreateFrame("Frame", nil, hp)
	-- TukuiDB.SetTemplate(testBorder)
	-- testBorder:SetPoint("TOPLEFT", hp, "TOPLEFT", TukuiDB.Scale(-2), TukuiDB.Scale(2))
	-- testBorder:SetPoint("BOTTOMRIGHT", hp, "BOTTOMRIGHT", TukuiDB.Scale(2), TukuiDB.Scale(-2))
	-- testBorder:SetBackdropColor( 0,0,0,1 )
	-- testBorder:SetBackdropBorderColor( 1, 1, 1, 1)
	-- testBorder:SetFrameLevel(3)
			
	-- health bar background
	--local healthBG = hp:CreateTexture(nil, 'BORDER')
	--healthBG:SetAllPoints()
	--healthBG:SetTexture(.1, .1, .1)

	--health.value = TukuiDB.SetFontString(panel, pixelfont, 8, "OUTLINEMONOCHROME")
	--health.value:SetPoint("RIGHT", panel, "RIGHT", TukuiDB.Scale(-4), 0)
	--health.PostUpdate = TukuiDB.PostUpdateHealth
			
	--self.Health = health
	--self.Health.bg = healthBG
	
    
    local hpbg = self:CreateTexture()
	hpbg:SetAllPoints(hp)
	hpbg:SetTexture(texture)
    hp.bg = hpbg
	hpbg:Hide()
    
    local hpi = CreateFrame("StatusBar", nil, self)
	hpi:SetAllPoints(hp)
	hpi:SetStatusBarTexture("Interface\\Tooltips\\UI-Tooltip-Background")
    hpi:SetOrientation("VERTICAL")
    hpi:SetStatusBarColor(0,1,0,0.5)
    hpi:SetMinMaxValues(0,100)
	hpi:SetFrameLevel(3)
    --hpi:SetValue(0)
    
	-- local hpi2 = CreateFrame("StatusBar", nil, self)
	-- hpi2:SetAllPoints(hp)
	-- hpi2:SetStatusBarTexture(texture)
    -- hpi2:SetOrientation("VERTICAL")
    -- hpi2:SetStatusBarColor(1,1,1,1)
    -- hpi2:SetMinMaxValues(0,100)
	-- hpi:SetValue(75)
	
	local mot = self:CreateTexture(nil,"OVERLAY")
    mot:SetAllPoints(hp)
    --mot:SetTexture(texture)
    mot:SetBlendMode("ADD")
    mot:Hide()
    self.mouseover = mot
    
    local text = hp:CreateFontString(nil, "ARTWORK") --, "GameFontNormal")
    text:SetPoint("CENTER",hp,"CENTER",0,0)
    text:SetJustifyH"CENTER"
    text:SetFont(font, fontsize)
    text:SetTextColor(1, 1, 1)
    text:SetShadowColor(0,0,0)
    text:SetShadowOffset(1,-1)
    text.SetJob = SetJob_Text1
    text.parent = self
    
    local text2 = hp:CreateFontString(nil, "ARTWORK")
    text2:SetPoint("TOP",text,"BOTTOM",0,0)
    text2:SetJustifyH"CENTER"
    text2:SetFont(font, fontsize)
    text2.SetJob = SetJob_Text2
    text2:SetTextColor(0.2, 1, 0.2)
	text2:SetShadowColor(0,0,0)
    text2:SetShadowOffset(1,-1)
    text2.parent = self
    
    local icon = CreateIcon(self,24,24,0.4,"CENTER",self,"CENTER",0,0)
    
    local raidicon = CreateFrame("Frame",nil,self)
    raidicon:SetWidth(20); raidicon:SetHeight(20)
    raidicon:SetPoint("CENTER",hp,"TOPLEFT",0,0)
    local raidicontex = raidicon:CreateTexture(nil,"OVERLAY")
    raidicontex:SetAllPoints(raidicon)
    raidicon.texture = raidicontex
    raidicon:SetAlpha(0.3)
    
    local topind = CreateIndicator(self,10,10,"TOP",hp,"TOP",0,0)
    local tr = CreateIndicator(self,7,7,"TOPRIGHT",hp,"TOPRIGHT",0,0)
    local br = CreateIndicator(self,9,9,"BOTTOMRIGHT",hp,"BOTTOMRIGHT",0,0)
    local btm = CreateIndicator(self,7,7,"BOTTOM",hp,"BOTTOM",0,0)
    local left = CreateIndicator(self,7,7,"LEFT",hp,"LEFT",0,0)
    local tl = CreateIndicator(self,5,5,"TOPLEFT",hp,"TOPLEFT",0,0)
    local text3 = CreateTextTimer(self,"TOPLEFT",hp,"TOPLEFT",-2,0,"LEFT",fontsize,font,"OUTLINE")
    
    self.SetJob = SetJob_Frame
    self.HideFunc = Frame_HideFunc
    
    self.health = hp
    self.health.incoming = hpi
    self.text1 = text
    self.text2 = text2
    self.healthtext = self.text2
    self.text3 = text3
    self.power = powerbar
    self.spell1 = br
    self.spell2 = topind
    self.spell3 = tr
    self.bossdebuff = left
    self.raidbuff = tl
    self.border = border
    self.dispel = btm
    self.icon = icon
    self.raidicon = raidicon
    
    self.OnMouseEnterFunc = OnMouseEnterFunc
    self.OnMouseLeaveFunc = OnMouseLeaveFunc
	
end