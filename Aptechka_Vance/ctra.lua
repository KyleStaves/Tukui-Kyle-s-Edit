local bdc

local SetJob_Frame = function(self, job)
    if job.alpha then
        self:SetAlpha(job.alpha)
    end
end
local Frame_HideFunc = function(self)
    self:SetAlpha(1)
end
local SetJob_Backdrop = function(self,job)
    local c
    if job.color then
        c = job.color
    end
    if c then
        self.parent:SetBackdropColor(c[1],c[2],c[3],bdc[4])
    end
end
local Backdrop_HideFunc = function(self)
    self.parent:SetBackdropColor(unpack(bdc))
end
local SetJob_Text1 = function(self,job)
    if job.healthtext then
        self:SetFormattedText("-%.0fk", (self.parent.vHealthMax - self.parent.vHealth) / 1e3)
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
        self:SetFormattedText("-%.0fk", (self.parent.vHealthMax - self.parent.vHealth) / 1e3)
    elseif job.inchealtext then
        self:SetFormattedText("+%.0fk", self.parent.vIncomingHeal / 1e3)
    elseif job.nametext then
        self:SetText(self.parent.name)
    elseif job.text then
        self:SetText(job.text)
    end
end
local DynamicColorSetValue = function(self,value)
    self:_SetValue(value)
    local min,max = self:GetMinMaxValues()
    local r,g,b
    if value > max / 2 then
        r,g,b = (max - value)*2/max, 1, 0
    else
        r,g,b = 1, value*2/max, 0
    end
    self:SetStatusBarColor(r,g,b)
    self.bg:SetVertexColor(r,g,b)
end

local PowerBar_OnPowerTypeChange = function(self,ptype)
    local c = PowerBarColor[ptype]
    self:SetStatusBarColor(c.r,c.g,c.b)
    self.bg:SetVertexColor(c.r,c.g,c.b)
end

AptechkaDefaultConfig.CTRaidAssist = function(self)
    local config
    if AptechkaUserConfig then config = AptechkaUserConfig else config = AptechkaDefaultConfig end
    bdc = config.ctraBackdropColor or {0,0,1,0.7}
    self:SetWidth(90)
    self:SetHeight(40)
    local bdp = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, 
        insets = { left = 5, right = 5, top = 5, bottom = 5 }
    }
    if config.ctraNoBorder then bdp.edgeFile = nil; bdp.tile = nil; bdp.tileSize = nil; bdp.edgeSize = nil; end
    self:SetBackdrop(bdp)
    self:SetBackdropColor(unpack(bdc))
    
    local pb = CreateFrame("StatusBar",nil,self)
    pb:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
    pb:SetStatusBarColor(0,0,1)
    pb:SetMinMaxValues(0,100)
    pb:SetPoint("BOTTOM",self,"BOTTOM",0,6)
    pb:SetPoint("LEFT",self,"LEFT",10,0)
    pb:SetPoint("RIGHT",self,"RIGHT",-10,0)
    pb:SetHeight(6)
    
    local pbbg = pb:CreateTexture(nil,"BACKGROUND")
    pbbg:SetTexture([[Interface\TargetingFrame\UI-StatusBar]])
    pbbg:SetAllPoints(pb)
    pbbg:SetAlpha(0.5)
    pbbg:SetVertexColor(0,0,1)
    pb.bg = pbbg
    pb.parent = self
    
    pb.OnPowerTypeChange = PowerBar_OnPowerTypeChange
    
    local hp = CreateFrame("StatusBar",nil,self)
    hp:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
    hp:SetStatusBarColor(0,1,0)
    hp:SetMinMaxValues(0,100)
    hp:SetPoint("BOTTOMRIGHT",pb,"TOPRIGHT",0,0)
    hp:SetPoint("BOTTOMLEFT",pb,"TOPLEFT",0,0)
    hp:SetHeight(6)
    local hpbg = hp:CreateTexture(nil,"BACKGROUND")
    hpbg:SetTexture([[Interface\TargetingFrame\UI-StatusBar]])
    hpbg:SetAllPoints(hp)
    hpbg:SetAlpha(0.5)
    hp.bg = hpbg
    hp.parent = self
    
    hp._SetValue = hp.SetValue
    hp.SetValue = DynamicColorSetValue
    
    local text = hp:CreateFontString()
    text:SetPoint("TOPLEFT",self,"TOPLEFT",7,-7)
    text:SetJustifyH"LEFT"
    text:SetJustifyV"TOP"
    text:SetFontObject("GameFontNormalSmall")
    text:SetTextColor(1, 1, 1)
    text.SetJob = SetJob_Text1
    text.parent = self
    
    local text2 = hp:CreateFontString()
    text2:SetPoint("BOTTOM",hp,"BOTTOM",0,0)
    text2:SetJustifyH"CENTER"
    text2:SetFontObject("GameFontNormalSmall")
    text2:SetTextColor(1, 1, 1)
    text2.SetJob = SetJob_Text2
    text2.parent = self
    
    local icon1 = AptechkaDefaultConfig.GridSkin_CreateIcon(self,16,16,0.6,"TOPRIGHT",self,"TOPRIGHT",-5,-5)
    local icon2 = AptechkaDefaultConfig.GridSkin_CreateIcon(self,16,16,0.6,"TOPRIGHT",icon1,"TOPLEFT",0,0)
    local icon3 = AptechkaDefaultConfig.GridSkin_CreateIcon(self,16,16,0.5,"TOPRIGHT",icon1,"BOTTOMRIGHT",0,0)
    
    local raidicon = CreateFrame("Frame",nil,self)
    raidicon:SetWidth(20); raidicon:SetHeight(20)
    raidicon:SetPoint("CENTER",self,"TOPLEFT",0,0)
    local raidicontex = raidicon:CreateTexture(nil,"OVERLAY")
    raidicontex:SetAllPoints(raidicon)
    raidicon.texture = raidicontex
    raidicon:SetAlpha(0.3)
    
    local backdrop = CreateFrame("Frame") -- dummy frame
    backdrop.parent = self
    backdrop.HideFunc = Backdrop_HideFunc
    backdrop.SetJob = SetJob_Backdrop
    
    self.SetJob = SetJob_Frame
    self.HideFunc = Frame_HideFunc
    
    self.health = hp
    self.power = pb
    self.text1 = text
    self.text2 = text2
    self.healthtext = text2
    self.spell1 = icon1
    self.spell2 = icon2
    self.spell3 = icon3
    self.icon = icon1
    self.raidicon = raidicon
    
    self.dispel = backdrop
    --self.border = backdrop
    self.bossdebuff = self.icon
end

AptechkaDefaultConfig.CTRaidAssistSettings = function()
    local config = AptechkaUserConfig
    if config.unitGrowth ~= "TOP" and config.unitGrowth ~= "BOTTOM" then config.unitGrowth = "BOTTOM" end
--~     config.unitGap = 0
end