-- tab size is 4
-- registrations for media from the client itself belongs in LibSharedMedia-3.0

if not SharedMedia then return end
local revision = tonumber(string.sub("$Revision: 76383 $", 12, -3))
SharedMedia.revision = (revision > SharedMedia.revision) and revision or SharedMedia.revision

-- -----
-- BACKGROUND
-- -----
SharedMedia:Register("background", "HalBackground1",                    [[Interface\Addons\SharedMedia\background\HalBackground.tga]])
SharedMedia:Register("background", "HalBackground2",                    [[Interface\Addons\SharedMedia\background\HalBackgroundA.tga]])
SharedMedia:Register("background", "DSMBG",								[[Interface\Addons\SharedMedia\DSM\background.tga]])
-- -----
--  BORDER
-- ----
SharedMedia:Register("border", "DSMBRD",								[[Interface\Addons\SharedMedia\DSM\border.tga]])
SharedMedia:Register("border", "FreeUIglowTex",                             [[Interface\Addons\SharedMedia\FreeUI\glowTex.tga]])
SharedMedia:Register("border", "FreeUIBorder",                             [[Interface\Addons\SharedMedia\FreeUI\border.tga]])
SharedMedia:Register("border", "FreeUIQuestGlow",                             [[Interface\Addons\SharedMedia\FreeUI\questglow.tga]])
SharedMedia:Register("border", "glowTex1",                             [[Interface\Addons\SharedMedia\border\glowTex1.tga]])
SharedMedia:Register("border", "HalBorder",                             [[Interface\Addons\SharedMedia\border\HalBorder.tga]])
SharedMedia:Register("border", "IshBorder",                             [[Interface\Addons\SharedMedia\border\IshBorder.tga]])
SharedMedia:Register("border", "Rothborder",                            [[Interface\Addons\SharedMedia\border\Rothborder.tga]])
-- -----
--   FONT
-- -----
SharedMedia:Register("font", "DSMFONT",								[[Interface\Addons\SharedMedia\DSM\font.ttf]])
SharedMedia:Register("font", "FreeUIPixel1",					            [[Interface\Addons\SharedMedia\FreeUI\Hooge0655.ttf]])
SharedMedia:Register("font", "FreeUIPixel2",					            [[Interface\Addons\SharedMedia\FreeUI\SFPixelate.ttf]])
SharedMedia:Register("font", "Pixel_01",					            [[Interface\Addons\SharedMedia\fonts\visitor1.ttf]])
SharedMedia:Register("font", "Sanserif_01",				                [[Interface\Addons\SharedMedia\fonts\AvantGarde.ttf]])
SharedMedia:Register("font", "Sanserif_02",				                [[Interface\Addons\SharedMedia\fonts\ITC Avant Garde Gothic LT Demi.ttf]])
SharedMedia:Register("font", "Sanserif_03",				                [[Interface\Addons\SharedMedia\fonts\ITC Avant Garde Gothic LT Extra Light.ttf]])
SharedMedia:Register("font", "Sanserif_04",				                [[Interface\Addons\SharedMedia\fonts\ITC Avant Garde Gothic LT Medium.ttf]])
SharedMedia:Register("font", "Sanserif_05",				                [[Interface\Addons\SharedMedia\fonts\ITC Avant Garde Gothic LT Book.ttf]])
SharedMedia:Register("font", "Sanserif_06",				                [[Interface\Addons\SharedMedia\fonts\ITC Avant Garde Gothic LT Bold.ttf]])
-- -----
--   SOUND
-- -----

-- -----
--   STATUSBAR
-- -----
SharedMedia:Register("statusbar", "DSMBAR",								[[Interface\Addons\SharedMedia\DSM\statusbar.tga]])
SharedMedia:Register("statusbar", "FreeUIStatusBar",			                            [[Interface\Addons\SharedMedia\FreeUI\statusbar]])
SharedMedia:Register("statusbar", "FreeUIStatusBar",			                            [[Interface\Addons\SharedMedia\FreeUI\statusbar]])
SharedMedia:Register("statusbar", "AANewBar",			                            [[Interface\Addons\SharedMedia\statusbar\AANewBar]])
SharedMedia:Register("statusbar", "Aluminium",			                            [[Interface\Addons\SharedMedia\statusbar\Aluminium]])
SharedMedia:Register("statusbar", "Armory",				                            [[Interface\Addons\SharedMedia\statusbar\Armory]])
SharedMedia:Register("statusbar", "Flat",				                            [[Interface\Addons\SharedMedia\statusbar\Flat]])