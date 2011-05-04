local T, C, L = unpack(select(2, ...))

InterfaceOptionsFrame:EnableMouse(true)
InterfaceOptionsFrame:RegisterForDrag("LeftButton")
InterfaceOptionsFrame:SetMovable(true)
InterfaceOptionsFrame:SetScript("OnDragStart",function(self) self:StartMoving() end)
InterfaceOptionsFrame:SetScript("OnDragStop",function(self) self:StopMovingOrSizing() end)