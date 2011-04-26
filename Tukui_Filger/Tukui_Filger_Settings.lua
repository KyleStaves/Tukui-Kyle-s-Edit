Filger_Settings = {
	configmode = false,
}

--[[ CD-Example
		{
			Name = "COOLDOWN",
			Direction = "RIGHT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "CENTER", UIParent, "CENTER", 0, -100 },

			-- Wild Growth/Wildwuchs
			{ spellID = 48438, size = 32, filter = "CD" },
		},
]]

Filger_Spells = {
	["DRUID"] = {
		{
			Name = "T_DOTS_ICON",
			Direction = "DOWN",
			Interval = 4,
			Opacity = 1,
			Mode = "ICON",
			setPoint = { "LEFT", UIParent, "CENTER", 150, -12 },
			
			-- Moonfire/Mondfeuer
			{ spellID = 8921, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Sunfire/Sonnenfeuer
			{ spellID = 93402, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Insect Swarm/Insektenschwarm
			{ spellID = 5570, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Rake/Krallenhieb
			{ spellID = 1822, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Rip/Zerfetzen
			{ spellID = 1079, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Lacerate/Aufschlitzen
			{ spellID = 33745, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Pounce Bleed/Anspringblutung
			{ spellID = 9007, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
		},
		{
			Name = "P_SHORTBUFFS_ICONS",
			Direction = "DOWN",
			Interval = 4,
			Opacity = 1,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -150, -12},
			
			-- Pred Strikes (free instant heal) 69369
			{ spellID = 69369, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Savage Roar 52610
			{ spellID = 52610, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Barkskin 22812
			{ spellID = 22812, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Frenz Regen 22842
			{ spellID = 22842, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Bersker 50334
			{ spellID = 50334, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Surv Ins 61336
			{ spellID = 61336, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Tree Of Life 33891
			{ spellID = 33891, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Tiger's Fury 5217
			{ spellID = 5217, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Innervate
			{ spellID = 29166, size = 32, unitId = "player", caster = "all", filter = "BUFF" },
		},
		-- {
			-- Name = "P_BUFF_ICON",
			-- Direction = "LEFT",
			-- Interval = 4,
			-- Opacity = 1,
			-- Mode = "ICON",
			-- setPoint = { "RIGHT", UIParent, "CENTER", -198, 24 },

			-- Lifebloom/Blühendes Leben
			-- { spellID = 33763, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Rejuvenation/Verjüngung
			-- { spellID = 774, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Regrowth/Nachwachsen
			-- { spellID = 8936, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Wild Growth/Wildwuchs
			-- { spellID = 48438, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
		-- },
		-- {
			-- Name = "T_BUFF_ICON",
			-- Direction = "RIGHT",
			-- Interval = 4,
			-- Opacity = 1,
			-- Mode = "ICON",
			-- setPoint = { "LEFT", UIParent, "CENTER", 198, 24 },

			-- Lifebloom/Blühendes Leben
			-- { spellID = 33763, size = 32, unitId = "target", caster = "player", filter = "BUFF" },
			-- Rejuvenation/Verjüngung
			-- { spellID = 774, size = 32, unitId = "target", caster = "player", filter = "BUFF" },
			-- Regrowth/Nachwachsen
			-- { spellID = 8936, size = 32, unitId = "target", caster = "player", filter = "BUFF" },
			-- Wild Growth/Wildwuchs
			-- { spellID = 48438, size = 32, unitId = "target", caster = "player", filter = "BUFF" },
		-- },
		{
			Name = "P_PROC_ICON",
			Direction = "LEFT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -198, -20 },

			-- Bersker! (Lacerate)
			{ spellID = 93622, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Eclipse (Lunar)/Mondfinsternis
			{ spellID = 48518, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Eclipse (Solar)/Sonnenfinsternis
			{ spellID = 48517, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Shooting Stars/Sternschnuppen
			{ spellID = 93400, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Savage Roar/Wildes Brüllen
			-- { spellID = 52610, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Survival Instincts/Überlebensinstinkte
			-- { spellID = 61336, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Tree of Life/Baum des Lebens
			-- { spellID = 33891, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Clearcasting/Freizaubern
			{ spellID = 16870, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Innervate/Anregen
			-- { spellID = 29166, size = 47, unitId = "player", caster = "all", filter = "BUFF" },
			-- Barkskin/Baumrinde
			-- { spellID = 22812, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
		},
		{
			Name = "T_DEBUFF_ICON",
			Direction = "RIGHT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "LEFT", UIParent, "CENTER", 198, -20 },

			-- Hibernate/Winterschlaf
			{ spellID = 2637, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Entangling Roots/Wucherwurzeln
			{ spellID = 339, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Cyclone/Wirbelsturm
			{ spellID = 33786, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Mangle/Zerfleischen
			{ spellID = 33876, size = 47, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Earth and Moon/Erde und Mond
			{ spellID = 48506, size = 47, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Faerie Fire/Feenfeuer
			{ spellID = 770, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },
		},
		{
			Name = "F/DEBUFF_BAR",
			Direction = "UP",
			IconSide = "LEFT",
			Interval = 4,
			Mode = "BAR",
			setPoint = { "LEFT", UIParent, "CENTER", 198, 100 },

			-- Hibernate/Winterschlaf
			{ spellID = 2637, size = 32, barWidth = 200, unitId = "focus", caster = "all", filter = "DEBUFF" },
			-- Entangling Roots/Wucherwurzeln
			{ spellID = 339, size = 32, barWidth = 200, unitId = "focus", caster = "all", filter = "DEBUFF" },
			-- Cyclone/Wirbelsturm
			{ spellID = 33786, size = 32, barWidth = 200, unitId = "focus", caster = "all", filter = "DEBUFF" },
		},
		{
			Name = "P_COOLDOWNS_IMPORTANT",
			Direction = "LEFT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -198, -190 },

			-- Tree Of Life 33891
			{ spellID = 33891, size = 47, filter = "CD" },
			-- Nature's Swiftness 17116
			{ spellID = 17116, size = 47, filter = "CD" },
			-- Mangle (Bear) 33878
			{ spellID = 33878, size = 47, filter = "CD" },
			-- Maul 6807
			{ spellID = 6807, size = 47, filter = "CD" },
			-- Trash 77758
			{ spellID = 77758, size = 47, filter = "CD" },
			-- Swipe (Bear) 779
			{ spellID = 779, size = 47, filter = "CD" },
			-- FFFire 16857
			{ spellID = 16857, size = 47, filter = "CD" },
			
		},
		{
			Name = "P_COOLDOWNS_MEH",
			Direction = "LEFT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -198, -240 },
			
			-- Barkskin 22812
			{ spellID = 22812, size = 32, filter = "CD" },
			-- Frenz Regen 22842
			{ spellID = 22842, size = 32, filter = "CD" },
			-- Bersker 50334
			{ spellID = 50334, size = 32, filter = "CD" },
			-- Surv Ins 61336
			{ spellID = 61336, size = 32, filter = "CD" },
			
			-- Swiftmend  18562
			{ spellID = 18562, size = 32, filter = "CD" },
			-- Wild Growth/Wildwuchs
			{ spellID = 48438, size = 32, filter = "CD" },
			-- Innervate/Anregen
			{ spellID = 29166, size = 32, filter = "CD" },
			-- Tiger's Fury
			{ spellID = 5217, size = 32, filter = "CD" },
			-- Nature's Swiftness 17116
			{ spellID = 17116, size = 32, filter = "CD" },
		},
	},
	["HUNTER"] = {
		{
			Name = "T_DOTS_ICON",
			Direction = "DOWN",
			Interval = 4,
			Opacity = 1,
			Mode = "ICON",
			setPoint = { "LEFT", UIParent, "CENTER", 150, -12 },
			
			-- Serpent Sting
			{ spellID = 1978, size =32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Black Arrow
			{ spellID = 3674, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Explosive Shot
			{ spellID = 53301, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Immolation Trap 13795
			{ spellID = 13795, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			
		},
		{
			Name = "P_SHORTBUFFS_ICONS",
			Direction = "DOWN",
			Interval = 4,
			Opacity = 1,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -150, -12},
			
			-- Rapid Fire
			{ spellID = 3045, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Call of the Wild
			{ spellID = 53434, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Improved Steady Shot/Verbesserter zuverlässiger Schuss
			{ spellID = 53224, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Mend Pet/Tier heilen
			{ spellID = 136, size = 32, unitId = "pet", caster = "player", filter = "BUFF" },
			-- Feed Pet/Tier füttern
			{ spellID = 6991, size = 32, unitId = "pet", caster = "player", filter = "BUFF" },
			
		},
		{
			Name = "P_PROC_ICON",
			Direction = "LEFT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -198, -20 },

			-- Lock and Load
			{ spellID = 56342, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Master Tactician
			{ spellID = 34837, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			
		},
		{
			Name = "T_DEBUFF_ICON",
			Direction = "RIGHT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "LEFT", UIParent, "CENTER", 198, -20 },
			
			-- Freezing Trap 1499
			{ spellID = 1499, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Scatter Shot 19503
			{ spellID = 19503, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Wyvern Sting
			{ spellID = 19386, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Silencing Shot
			{ spellID = 34490, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Wing Clip 2974
			{ spellID = 2974, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Concussive Shot 5116
			{ spellID = 5116, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Hunter's Mark
			{ spellID = 1130, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },

		},
		{
			Name = "F/DEBUFF_BAR",
			Direction = "UP",
			IconSide = "LEFT",
			Interval = 4,
			Mode = "BAR",
			setPoint = { "LEFT", UIParent, "CENTER", 198, 100 },

			-- Wyvern Sting
			{ spellID = 19386, size = 32, barWidth = 200, unitId = "focus", caster = "all", filter = "DEBUFF" },
			-- Silencing Shot
			{ spellID = 34490, size = 32, barWidth = 200, unitId = "focus", caster = "all", filter = "DEBUFF" },
			-- Freezing Trap
			{ spellID = 1499, size = 32, barWidth = 200, unitId = "focus", caster = "all", filter = "DEBUFF" },
			
		},
		{
			Name = "P_COOLDOWNS_IMPORTANT",
			Direction = "LEFT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -198, -190 },
			
			-- Silencing Shot
			{ spellID = 34490, size = 47, filter = "CD" },
			
			-- Concussive Shot
			{ spellID = 5116, size = 47, filter = "CD" },

			-- Rapid Fire
			{ spellID = 3045, size = 47, filter = "CD" },
			
		},
		{
			Name = "P_COOLDOWNS_MEH",
			Direction = "LEFT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -198, -240 },
			
			-- Explosive Shot 53301
			{ spellID = 53301, size = 32, filter = "CD" },
			-- Black Arrow 3674
			{ spellID = 3674, size = 32, filter = "CD" },
			-- Kill Command 34026
			{ spellID = 34026, size = 32, filter = "CD" },
			-- Chimera Shot 53209
			{ spellID = 53209, size = 32, filter = "CD" },
			-- Freezing Trap 1499
			{ spellID = 1499, size = 32, filter = "CD" },
			-- Immolation Trap 13795
			{ spellID = 13795, size = 32, filter = "CD" },
			-- Snake Trap 82948
			{ spellID = 82948, size = 32, filter = "CD" },

		},
	},
	["MAGE"] = {
		{
			Name = "T_DOTS_ICON",
			Direction = "DOWN",
			Interval = 4,
			Opacity = 1,
			Mode = "ICON",
			setPoint = { "LEFT", UIParent, "CENTER", 150, -12 },
			
			
			-- Slow
			{ spellID = 31589, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Arcane Blast
			{ spellID = 36032, size = 32, unitId = "player", caster = "player", filter = "DEBUFF" },
			-- Ignite
			{ spellID = 11119, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Living Bomb
			{ spellID = 44457, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Scorch
			{ spellID = 2948, size = 32, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Improved Scorch
			{ spellID = 11367, size = 32, unitId = "target", caster = "all", filter = "DEBUFF" },
			
		},
		-- {
			-- Name = "P_SHORTBUFFS_ICONS",
			-- Direction = "DOWN",
			-- Interval = 4,
			-- Opacity = 1,
			-- Mode = "ICON",
			-- setPoint = { "RIGHT", UIParent, "CENTER", -150, -12},
			
			--Savage Roar 52610
			-- { spellID = 52610, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			
		-- },
		{
			Name = "P_PROC_ICON",
			Direction = "LEFT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -198, -20 },

			-- Fingers of Frost
			{ spellID = 44544, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Fireball!
			{ spellID = 57761, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Hot Streak
			{ spellID = 44445, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Missile Barrage
			{ spellID = 54486, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Clearcasting
			{ spellID = 12536, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Impact
			{ spellID = 12358, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
		},
		{
			Name = "T_DEBUFF_ICON",
			Direction = "RIGHT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "LEFT", UIParent, "CENTER", 198, -20 },

			-- Polymorph
			{ spellID = 118, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },

		},
		{
			Name = "F/DEBUFF_BAR",
			Direction = "UP",
			IconSide = "LEFT",
			Interval = 4,
			Mode = "BAR",
			setPoint = { "LEFT", UIParent, "CENTER", 198, 100 },

			-- Polymorph
			{ spellID = 2637, size = 32, barWidth = 200, unitId = "focus", caster = "all", filter = "DEBUFF" },
		},
		-- {
			-- Name = "P_COOLDOWNS_IMPORTANT",
			-- Direction = "LEFT",
			-- Interval = 4,
			-- Mode = "ICON",
			-- setPoint = { "RIGHT", UIParent, "CENTER", -198, -190 },

			--Barkskin 22812
			-- { spellID = 22812, size = 47, filter = "CD" },
			
		-- },
		-- {
			-- Name = "P_COOLDOWNS_MEH",
			-- Direction = "LEFT",
			-- Interval = 4,
			-- Mode = "ICON",
			-- setPoint = { "RIGHT", UIParent, "CENTER", -198, -240 },

			--Swiftmend  18562
			-- { spellID = 18562, size = 32, filter = "CD" },

		-- },
	},
	["WARRIOR"] = {
		{
			Name = "T_DOTS_ICON",
			Direction = "DOWN",
			Interval = 4,
			Opacity = 1,
			Mode = "ICON",
			setPoint = { "LEFT", UIParent, "CENTER", 150, -12 },
			
			-- Colossus Smash 86346
			{ spellID = 86346, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Rend
			{ spellID = 94009, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Thunder Clap
			{ spellID = 6343, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Demo Shout 1160
			{ spellID = 1160, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			
		},
		{
			Name = "P_SHORTBUFFS_ICONS",
			Direction = "DOWN",
			Interval = 4,
			Opacity = 1,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -150, -12},
			
			-- Last Stand
			{ spellID = 12975, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Shield Wall
			{ spellID = 871, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Enrage 14202
			{ spellID = 14202, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Berserker Rage  18499
			{ spellID = 18499, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			
		},
		{
			Name = "P_PROC_ICON",
			Direction = "LEFT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -198, -20 },

			-- Sudden Death
			{ spellID = 52437, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Slam!
			{ spellID = 46916, size = 47, unitId = "player", caster = "all", filter = "BUFF" },
			-- Sword and Board
			{ spellID = 50227, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			
		},
		{
			Name = "T_DEBUFF_ICON",
			Direction = "RIGHT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "LEFT", UIParent, "CENTER", 198, -20 },

			-- Hamstring
			{ spellID = 1715, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Sunder Armor
			{ spellID = 7386, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },

		},
		-- {
			-- Name = "F/DEBUFF_BAR",
			-- Direction = "UP",
			-- IconSide = "LEFT",
			-- Interval = 4,
			-- Mode = "BAR",
			-- setPoint = { "LEFT", UIParent, "CENTER", 198, 100 },

			--Hibernate/Winterschlaf
			-- { spellID = 2637, size = 32, barWidth = 200, unitId = "focus", caster = "all", filter = "DEBUFF" },
			
		-- },
		{
			Name = "P_COOLDOWNS_IMPORTANT",
			Direction = "LEFT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -198, -190 },

			-- Shield Slam 23922
			{ spellID = 23922, size = 47, filter = "CD" },
			-- Revenge 6572
			{ spellID = 6572, size = 47, filter = "CD" },
			-- Shield Block 2565
			{ spellID = 2565, size = 47, filter = "CD" },
			-- Last Stand 12975
			{ spellID = 12975, size = 47, filter = "CD" },
			-- Shield Wall 871
			{ spellID = 871, size = 47, filter = "CD" },
			
			-- Bloodthirst 23881
			{ spellID = 23881, size = 47, filter = "CD" },
			-- Raging BLow 85288
			{ spellID = 85288, size = 47, filter = "CD" },
			-- 
			
			
			
			-- Mortal Strike 12294
			{ spellID = 12294, size = 47, filter = "CD" },
			-- Heroic Strike 78
			{ spellID = 78, size = 47, filter = "CD" },
			-- Colossus Smash 86346
			{ spellID = 86346, size = 47, filter = "CD" },
			-- Thunder Clap 6343
			{ spellID = 6343, size = 47, filter = "CD" },
			-- Throwdown 85388
			{ spellID = 85388, size = 47, filter = "CD" },
			-- Whirlwind 1680
			{ spellID = 1680, size = 47, filter = "CD" },
			
			
		},
		{
			Name = "P_COOLDOWNS_MEH",
			Direction = "LEFT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -198, -240 },
			
			-- Shockwave 46968
			{ spellID = 46968, size = 32, filter = "CD" },
			-- Conc Blow 12809
			{ spellID = 12809, size = 32, filter = "CD" },
			-- Shield Bash 72
			{ spellID = 72, size = 32, filter = "CD" },
			
			-- Death Wish 12292
			{ spellID = 12292, size = 32, filter = "CD" },
			
			-- Pummel 6552
			{ spellID = 6552, size = 32, filter = "CD" },
			-- Charge  100
			{ spellID = 100, size = 32, filter = "CD" },
			-- Bladestorm  46924
			{ spellID = 46924, size = 32, filter = "CD" },
			-- Sweeping Strikes  12328
			{ spellID = 12328, size = 32, filter = "CD" },
			-- Deadly Calm  85730
			{ spellID = 85730, size = 32, filter = "CD" },
			-- Heroic Throw  57755
			{ spellID = 57755, size = 32, filter = "CD" },
			-- Retaliation  20230
			{ spellID = 20230, size = 32, filter = "CD" },
			-- Shattering Throw  64382
			{ spellID = 64382, size = 32, filter = "CD" },
			-- Battle Shout  6673
			{ spellID = 6673, size = 32, filter = "CD" },
			-- Berserker Rage  18499
			{ spellID = 18499, size = 32, filter = "CD" },
			-- Enraged Regen  55694
			{ spellID = 55694, size = 32, filter = "CD" },
			-- Intercept 20252
			{ spellID = 20252, size = 32, filter = "CD" },
			-- Heroic Leap 6544
			{ spellID = 6544, size = 32, filter = "CD" },
			

		},
	},
	["SHAMAN"] = {
		{
			Name = "T_DOTS_ICON",
			Direction = "DOWN",
			Interval = 4,
			Opacity = 1,
			Mode = "ICON",
			setPoint = { "LEFT", UIParent, "CENTER", 150, -12 },
			
			-- Storm Strike
			{ spellID = 17364, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Earth Shock
			{ spellID = 8042, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Frost Shock
			{ spellID = 8056, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Flame Shock
			{ spellID = 8050, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			
		},
		{
			Name = "P_SHORTBUFFS_ICONS",
			Direction = "DOWN",
			Interval = 4,
			Opacity = 1,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -150, -12},
			
			-- RESTO
			-- Focused Insight 77796
			{ spellID = 77796, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			
			-- ELE
			-- Elemental Mastery 16166
			{ spellID = 16166, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			
		},
		{
			Name = "P_PROC_ICON",
			Direction = "LEFT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -198, -20 },

			-- Tidal Waves
			{ spellID = 51562, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Maelstorm Weapon
			{ spellID = 53817, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Shamanistic Rage
			{ spellID = 30823, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Clearcasting
			{ spellID = 16246, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			
		},
		{
			Name = "T_DEBUFF_ICON",
			Direction = "RIGHT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "LEFT", UIParent, "CENTER", 198, -20 },

			-- Hex
			{ spellID = 51514, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },

		},
		{
			Name = "F/DEBUFF_BAR",
			Direction = "UP",
			IconSide = "LEFT",
			Interval = 4,
			Mode = "BAR",
			setPoint = { "LEFT", UIParent, "CENTER", 198, 100 },

			-- Hex
			{ spellID = 51514, size = 32, barWidth = 200, unitId = "focus", caster = "all", filter = "DEBUFF" },
		},
		{
			Name = "P_COOLDOWNS_IMPORTANT",
			Direction = "LEFT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -198, -190 },
			
			-- Wind Shear 57994
			{ spellID = 57994, size = 47, filter = "CD" },
			-- Earth Shock 8042
			{ spellID = 8042, size = 47, filter = "CD" },
			-- Lava Burst 51505
			{ spellID = 51505, size = 47, filter = "CD" },
			-- Lava Lash 60103
			{ spellID = 60103, size = 47, filter = "CD" },
			-- Stormstrike 17364
			{ spellID = 17364, size = 47, filter = "CD" },
			
			-- Riptide 61295
			{ spellID = 61295, size = 47, filter = "CD" },
			-- Unleash Elements 73680
			{ spellID = 73680, size = 47, filter = "CD" },
			-- Healing Rain 73920
			{ spellID = 73920, size = 47, filter = "CD" },
			
		},
		{
			Name = "P_COOLDOWNS_MEH",
			Direction = "LEFT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -198, -240 },
			
			-- Chain Lightning 421
			{ spellID = 421, size = 32, filter = "CD" },
			-- Thunderstorm  51490
			{ spellID = 51490, size = 32, filter = "CD" },
			-- Elemental Mastery 16166
			{ spellID = 16166, size = 32, filter = "CD" },
			-- Mana Tide Totem 16190
			{ spellID = 16190, size = 32, filter = "CD" },
			-- NSwiftness 16188
			{ spellID = 16188, size = 32, filter = "CD" },
			
		},
	},
	["PALADIN"] = {
		-- {
			-- Name = "T_DOTS_ICON",
			-- Direction = "DOWN",
			-- Interval = 4,
			-- Opacity = 1,
			-- Mode = "ICON",
			-- setPoint = { "LEFT", UIParent, "CENTER", 150, -12 },
			
			-- Judgement of Light
			-- { spellID = 20271, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			
		-- },
		{
			Name = "P_SHORTBUFFS_ICONS",
			Direction = "DOWN",
			Interval = 4,
			Opacity = 1,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -150, -12},
			
			-- Judgements of the Pure
			{ spellID = 53671, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Holy Shield
			{ spellID = 20925, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Infusion of Light
			{ spellID = 54149, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Divine Plea
			{ spellID = 54428, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Divine Illumination
			{ spellID = 31842, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			
		},
		{
			Name = "P_PROC_ICON",
			Direction = "LEFT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -198, -20 },

			-- Infusion of Light
			{ spellID = 54149, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			
		},
		{
			Name = "T_DEBUFF_ICON",
			Direction = "RIGHT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "LEFT", UIParent, "CENTER", 198, -20 },

			-- Hammer of Justice/Hammer der Gerechtigkeit
			{ spellID = 853, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },

		},
		{
			Name = "F/DEBUFF_BAR",
			Direction = "UP",
			IconSide = "LEFT",
			Interval = 4,
			Mode = "BAR",
			setPoint = { "LEFT", UIParent, "CENTER", 198, 100 },

			-- Hammer of Justice/Hammer der Gerechtigkeit
			{ spellID = 853, size = 32, barWidth = 200, unitId = "focus", caster = "all", filter = "DEBUFF" },
			
		},
		{
			Name = "P_COOLDOWNS_IMPORTANT",
			Direction = "LEFT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -198, -190 },
			
			-- Holy Shock 20473
			{ spellID = 20473, size = 47, filter = "CD" },
			-- Holy Radiance 82327
			{ spellID = 82327, size = 47, filter = "CD" },
			
		},
		{
			Name = "P_COOLDOWNS_MEH",
			Direction = "LEFT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -198, -240 },
			
			-- Divine Favor 31842
			{ spellID = 31842, size = 32, filter = "CD" },
			-- Divine Plea 54428
			{ spellID = 54428, size = 32, filter = "CD" },
			-- GoTAC 86150
			{ spellID = 86150, size = 32, filter = "CD" },

		},
	},
	["PRIEST"] = {
		{
			Name = "T_DOTS_ICON",
			Direction = "DOWN",
			Interval = 4,
			Opacity = 1,
			Mode = "ICON",
			setPoint = { "LEFT", UIParent, "CENTER", 150, -12 },
			
			-- Shadow Word: Pain
			{ spellID = 589, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Devouring Plague
			{ spellID = 2944, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Vampiric Touch
			{ spellID = 34914, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			
		},
		{
			Name = "P_SHORTBUFFS_ICONS",
			Direction = "DOWN",
			Interval = 4,
			Opacity = 1,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -150, -12},
			
			-- Fade/Verblassen
			{ spellID = 586, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Fear Ward/Furchtzauberschutz
			{ spellID = 6346, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Shadow Orb
			{ spellID = 77487, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Archangel
			{ spellID = 81700, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Evangelism
			{ spellID = 81661, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Dispersion
			{ spellID = 47585, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			
		},
		{
			Name = "P_PROC_ICON",
			Direction = "LEFT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -198, -20 },

			-- Surge of Light
			{ spellID = 33151, size = 47, unitId = "player", caster = "all", filter = "BUFF" },
			-- Serendipity
			{ spellID = 63730, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			
		},
		{
			Name = "T_DEBUFF_ICON",
			Direction = "RIGHT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "LEFT", UIParent, "CENTER", 198, -20 },

			-- Shackle undead
			{ spellID = 9484, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Psychic Scream
			{ spellID = 8122, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },

		},
		{
			Name = "F/DEBUFF_BAR",
			Direction = "UP",
			IconSide = "LEFT",
			Interval = 4,
			Mode = "BAR",
			setPoint = { "LEFT", UIParent, "CENTER", 198, 100 },

			-- Shackle undead
			{ spellID = 9484, size = 32, barWidth = 200, unitId = "focus", caster = "all", filter = "DEBUFF" },
			-- Psychic Scream
			{ spellID = 8122, size = 32, barWidth = 200, unitId = "focus", caster = "all", filter = "DEBUFF" },
			
		},
		-- {
			-- Name = "P_COOLDOWNS_IMPORTANT",
			-- Direction = "LEFT",
			-- Interval = 4,
			-- Mode = "ICON",
			-- setPoint = { "RIGHT", UIParent, "CENTER", -198, -190 },

			-- Barkskin 22812
			-- { spellID = 22812, size = 47, filter = "CD" },
			
		-- },
		-- {
			-- Name = "P_COOLDOWNS_MEH",
			-- Direction = "LEFT",
			-- Interval = 4,
			-- Mode = "ICON",
			-- setPoint = { "RIGHT", UIParent, "CENTER", -198, -240 },

			-- Swiftmend  18562
			-- { spellID = 18562, size = 32, filter = "CD" },

		-- },
	},
	["WARLOCK"] = {
		{
			Name = "T_DOTS_ICON",
			Direction = "DOWN",
			Interval = 4,
			Opacity = 1,
			Mode = "ICON",
			setPoint = { "LEFT", UIParent, "CENTER", 150, -12 },
			
			-- Seed of Corruption
			{ spellID = 27243, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Unstable Affliction
			{ spellID = 30108, size =32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Corruption
			{ spellID = 172, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Immolate
			{ spellID = 348, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Curse of Agony
			{ spellID = 980, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Bane of Doom
			{ spellID = 603, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Haunt
			{ spellID = 48181, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Shadow Embrace
			{ spellID = 32385, size = 32, unitId = "target", caster = "player", filter = "BUFF" },
			
		},
		{
			Name = "P_SHORTBUFFS_ICONS",
			Direction = "DOWN",
			Interval = 4,
			Opacity = 1,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -150, -12},
			
			-- Meta 59672
			{ spellID = 59672, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			
		},
		{
			Name = "P_PROC_ICON",
			Direction = "LEFT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -198, -20 },

			--Devious Minds/Teuflische Absichten
			{ spellID = 70840, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Improved Soul Fire
			{ spellID = 85114, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Molten Core
			{ spellID = 47383, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Decimation
			{ spellID = 63158, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Backdraft
			{ spellID = 54277, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Backlash
			{ spellID = 34939, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Nether Protection
			{ spellID = 30301, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Nightfall
			{ spellID = 18095, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Burning Soul
			{ spellID = 74434, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			
		},
		{
			Name = "T_DEBUFF_ICON",
			Direction = "RIGHT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "LEFT", UIParent, "CENTER", 198, -20 },

			-- Death Coil
			{ spellID = 6789, size = 47, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Fear
			{ spellID = 5782, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Banish
			{ spellID = 710, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Howl of Terror
			{ spellID = 5484, size = 47, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Enslave Demon
			{ spellID = 1098, size = 47, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Demon Charge
			{ spellID = 54785, size = 47, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Curse of the Elements
			{ spellID = 1490, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Curse of Tongues
			{ spellID = 1714, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Curse of Exhaustion
			{ spellID = 18223, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Curse of Weakness
			{ spellID = 702, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },

		},
		{
			Name = "F/DEBUFF_BAR",
			Direction = "UP",
			IconSide = "LEFT",
			Interval = 4,
			Mode = "BAR",
			setPoint = { "LEFT", UIParent, "CENTER", 198, 100 },

			-- Fear
			{ spellID = 5782, size = 32, barWidth = 200, unitId = "focus", caster = "all", filter = "DEBUFF" },
			-- Banish
			{ spellID = 710, size = 32, barWidth = 200, unitId = "focus", caster = "all", filter = "DEBUFF" },
			
		},
		{
			Name = "P_COOLDOWNS_IMPORTANT",
			Direction = "LEFT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -198, -190 },

			-- Hand of Gul'dan
			{ spellID = 71521, size = 47, filter = "CD" },
			-- Metamorphosis
			{ spellID = 59672, size = 47, filter = "CD" },
			
		},
		{
			Name = "P_COOLDOWNS_MEH",
			Direction = "LEFT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -198, -240 },

			-- Demonic Empowerment
			{ spellID = 47193, size = 32, filter = "CD" },
			--- Confag
			{ spellID = 17962, size = 32, filter = "CD" },
			-- Chaos Bolt
			{ spellID = 50796, size = 32, filter = "CD" },
			-- Shadowfury
			{ spellID = 30283, size = 32, filter = "CD" },
			-- Shadowflame
			{ spellID = 47897, size = 32, filter = "CD" },

		},
	},
	["ROGUE"] = {
		{
			Name = "T_DOTS_ICON",
			Direction = "DOWN",
			Interval = 4,
			Opacity = 1,
			Mode = "ICON",
			setPoint = { "LEFT", UIParent, "CENTER", 150, -12 },
			
			-- Rupture
			{ spellID = 1943, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Garrote
			{ spellID = 703, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Deadly Poison
			{ spellID = 2818, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Mind-numbing Poison
			{ spellID = 5760, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Crippling Poison
			{ spellID = 3409, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Wound Poison
			{ spellID = 13218, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			
		},
		{
			Name = "P_SHORTBUFFS_ICONS",
			Direction = "DOWN",
			Interval = 4,
			Opacity = 1,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -150, -12},
			
			-- Sprint
			{ spellID = 2983, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Cloak of Shadows
			{ spellID = 31224, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Adrenaline Rush
			{ spellID = 13750, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Evasion
			{ spellID = 5277, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Envenom
			{ spellID = 32645, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Overkill
			{ spellID = 58426, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Slice and Dice
			{ spellID = 5171, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Tricks of the Trade
			{ spellID = 57934, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Turn the Tables
			{ spellID = 51627, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			
		},
		-- {
			-- Name = "P_PROC_ICON",
			-- Direction = "LEFT",
			-- Interval = 4,
			-- Mode = "ICON",
			-- setPoint = { "RIGHT", UIParent, "CENTER", -198, -20 },

			-- Bersker! (Lacerate)
			-- { spellID = 93622, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			
		-- },
		{
			Name = "T_DEBUFF_ICON",
			Direction = "RIGHT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "LEFT", UIParent, "CENTER", 198, -20 },

			-- Gouge
			{ spellID = 1776, size = 47, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Cheap shot
			{ spellID = 1833, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Kidney shot
			{ spellID = 408, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Blind
			{ spellID = 2094, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Sap
			{ spellID = 6770, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },
			-- Expose Armor
			{ spellID = 8647, size = 47, unitId = "target", caster = "player", filter = "DEBUFF" },

		},
		{
			Name = "F/DEBUFF_BAR",
			Direction = "UP",
			IconSide = "LEFT",
			Interval = 4,
			Mode = "BAR",
			setPoint = { "LEFT", UIParent, "CENTER", 198, 100 },

			-- Blind
			{ spellID = 2094, size = 32, barWidth = 200, unitId = "focus", caster = "all", filter = "DEBUFF" },
			-- Sap
			{ spellID = 6770, size = 32, barWidth = 200, unitId = "focus", caster = "all", filter = "DEBUFF" },
			
		},
		{
			Name = "P_COOLDOWNS_IMPORTANT",
			Direction = "LEFT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -198, -190 },
			
			-- Kick 1766
			{ spellID = 1766, size = 47, filter = "CD" },
			-- Kidney Shot 408
			{ spellID = 408, size = 47, filter = "CD" },
			-- Gouge 1776
			{ spellID = 1776, size = 47, filter = "CD" },
			-- Blind 2094
			{ spellID = 2094, size = 47, filter = "CD" },
			-- Dismantle 51722
			{ spellID = 51722, size = 47, filter = "CD" },
			
		},
		{
			Name = "P_COOLDOWNS_MEH",
			Direction = "LEFT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -198, -240 },
			
			-- Premed 14183
			{ spellID = 14183, size = 32, filter = "CD" },
			-- Shadow Step 36554
			{ spellID = 36554, size = 32, filter = "CD" },
			-- Vanish 1856
			{ spellID = 1856, size = 32, filter = "CD" },
			-- Evasion 5277
			{ spellID = 5277, size = 32, filter = "CD" },
			-- Sprint 2983
			{ spellID = 2983, size = 32, filter = "CD" },

		},
	},
	["DEATHKNIGHT"] = {
		{
			Name = "T_DOTS_ICON",
			Direction = "DOWN",
			Interval = 4,
			Opacity = 1,
			Mode = "ICON",
			setPoint = { "LEFT", UIParent, "CENTER", 150, -12 },
			
			-- Summon Gargoyle/Gargoyle beschwören
			{ spellID = 49206, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Blood Plague/Blutseuche
			{ spellID = 59879, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Frost Fever/Frostfieber
			{ spellID = 59921, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			-- Unholy Blight/Unheilige Verseuchung
			{ spellID = 49194, size = 32, unitId = "target", caster = "player", filter = "DEBUFF" },
			
		},
		{
			Name = "P_SHORTBUFFS_ICONS",
			Direction = "DOWN",
			Interval = 4,
			Opacity = 1,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -150, -12},
			
			-- Blood Shield 77513
			{ spellID = 77513, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Vamp Blood 55233
			{ spellID = 55233, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Bone Shield 49222
			{ spellID = 49222, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Icebound 48792
			{ spellID = 48792, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Anti-Magic 48707
			{ spellID = 48707, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			
		},
		{
			Name = "P_PROC_ICON",
			Direction = "LEFT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -198, -20 },

			-- Dancing Rune Weapon/Tanzende Runenwaffe
			{ spellID = 49028, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Killing machine
			{ spellID = 51124, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Freezing fog
			{ spellID = 59052, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Unholy Force/Unheilige Kraft
			{ spellID = 67383, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Desolation/Verwüstung
			--{ spellID = 66817, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Unholy Strength/Unheilige Stärke
			{ spellID = 53365, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			-- Unholy Might/Unheilige Macht
			{ spellID = 67117, size = 47, unitId = "player", caster = "player", filter = "BUFF" },
			
		},
		{
			Name = "T_DEBUFF_ICON",
			Direction = "RIGHT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "LEFT", UIParent, "CENTER", 198, -20 },

			-- Chains of Ice
			{ spellID = 45524, size = 47, unitId = "target", caster = "all", filter = "DEBUFF" },

		},
		{
			Name = "F/DEBUFF_BAR",
			Direction = "UP",
			IconSide = "LEFT",
			Interval = 4,
			Mode = "BAR",
			setPoint = { "LEFT", UIParent, "CENTER", 198, 100 },

			-- Chains of Ice
			{ spellID = 45524, size = 32, barWidth = 200, unitId = "focus", caster = "all", filter = "DEBUFF" },
			-- Strangulate 47476
			{ spellID = 47476, size = 32, barWidth = 200, unitId = "focus", caster = "all", filter = "DEBUFF" },

		},
		{
			Name = "P_COOLDOWNS_IMPORTANT",
			Direction = "LEFT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -198, -190 },

			-- Vamp Blood 55233
			{ spellID = 55233, size = 47, filter = "CD" },
			-- Bone Shield 49222
			{ spellID = 49222, size = 47, filter = "CD" },
			-- Icebound 48792
			{ spellID = 48792, size = 47, filter = "CD" },
			-- Anti-Magic 48707
			{ spellID = 48707, size = 47, filter = "CD" },
			-- DRuneWep 49028
			{ spellID = 49028, size = 47, filter = "CD" },
			
		},
		{
			Name = "P_COOLDOWNS_MEH",
			Direction = "LEFT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -198, -240 },

			-- Outbreak 77575
			{ spellID = 77575, size = 32, filter = "CD" },
			-- Blood Tap 45529
			{ spellID = 45529, size = 32, filter = "CD" },
			-- Rune Tap 48982
			{ spellID = 48982, size = 32, filter = "CD" },
			-- Empower Rune Weapon 47568
			{ spellID = 47568, size = 32, filter = "CD" },
			-- Horn of Winter 57330
			{ spellID = 57330, size = 32, filter = "CD" },

		},
	},
	["ALL"] = {
		{
			Name = "SPECIAL_P_BUFF_ICON",
			Direction = "LEFT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -198, -139 },

			-- Eyes of Twilight/Augen des Zwielichts
			{ spellID = 75495, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Piercing Twilight/Durchbohrendes Zwielicht
			{ spellID = 75456, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Twilight Flames/Zwielichtflammen
			{ spellID = 75473, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Scaly Nimbleness/Schuppige Gewandtheit
			{ spellID = 75480, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Surge of Power/Kraftsog
			{ spellID = 71644, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Thick Skin/Dicke Haut
			{ spellID = 71639, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Siphoned Power/Entzogene Kraft
			{ spellID = 71636, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Aegis of Dalaran/Aegis von Dalaran
			{ spellID = 71638, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Speed of the Vrykul/Geschwindigkeit der Vrykul
			{ spellID = 71560, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Power of the Taunka/Macht der Taunka
			{ spellID = 71558, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Agility of the Vrykul/Beweglichkeit der Vrykul
			{ spellID = 71556, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Mote of Anger/Partikel des Zorns
			{ spellID = 71432, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Icy Rage/Eisige Wut
			{ spellID = 71541, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Cultivated Power/Kultivierte Macht
			{ spellID = 71572, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Invigorated/Gestärkt
			{ spellID = 71577, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Revitalized/Revitalisiert
			{ spellID = 71584, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Rage of the Fallen/Zorn der Gefallenen
			{ spellID = 71396, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Hardened Skin/Gehärtete Haut
			{ spellID = 71586, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Elusive Power/Flüchtige Macht
			{ spellID = 71579, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Shard of Flame/Flammensplitter
			{ spellID = 67759, size = 32, unitId = "player", caster = "player", filter = "BUFF" },

			-- Frostforged Champion/Frostgeschmiedeter Champion
			{ spellID = 72412, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Chilling Knowledge/Kühlendes Wissen
			{ spellID = 72418, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Frostforged Sage/Frostgeschmiedeter Weiser
			{ spellID = 72416, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Frostforged Defender/Frostgeschmiedeter Verteidiger
			{ spellID = 72414, size = 32, unitId = "player", caster = "player", filter = "BUFF" },

			-- Hyperspeed Accelerators/Hypergeschwindigkeitsbeschleuniger
			{ spellID = 54999, size = 32, unitId = "player", caster = "player", filter = "BUFF" },

			-- Speed/Geschwindigkeit
			{ spellID = 53908, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Wild Magic/Wilde Magie
			{ spellID = 53909, size = 32, unitId = "player", caster = "player", filter = "BUFF" },

			--Tricks of the Trade/Schurkenhandel
			{ spellID = 57934, size = 32, unitId = "player", caster = "all", filter = "BUFF" },
			--Power Infusion/Seele der Macht
			{ spellID = 10060, size = 32, unitId = "player", caster = "all", filter = "BUFF" },
			-- Bloodlust/Kampfrausch
			{ spellID = 2825, size = 32, unitId = "player", caster = "all", filter = "BUFF" },
			-- Heroism/Heldentum
			{ spellID = 32182, size = 32, unitId = "player", caster = "all", filter = "BUFF" },
			
			--[[	Cataclysm Buffs	   ]]--
			-- Race Against Death
			{ spellID = 91821, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Dire Magic
			{ spellID = 91007, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Revelation
			{ spellID = 91024, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Heedless Carnage
			{ spellID = 92108, size = 32, unitId = "player", caster = "player", filter = "BUFF" },			

			-- Weapon Enchants
			-- Hurricane
			{ spellID = 74221, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Heartsong
			{ spellID = 74225, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Power Torrent
			{ spellID = 74242, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
			-- Landslide
			{ spellID = 74246, size = 32, unitId = "player", caster = "player", filter = "BUFF" },
		},
		{
			Name = "PVE/PVP_P_DEBUFF_ICON",
			Direction = "LEFT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -198, -83 },

			-- Death Knight
			-- Gnaw (Ghoul)
			{ spellID = 47481, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Strangulate
			{ spellID = 47476, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Chains of Ice
			{ spellID = 45524, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Desecration (no duration, lasts as long as you stand in it)
			{ spellID = 55741, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Glyph of Heart Strike
			{ spellID = 58617, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Icy Clutch (Chilblains)
			--{ spellID = 50436, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Hungering Cold
			{ spellID = 51209, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },

			-- Druid
			-- Cyclone
			{ spellID = 33786, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Hibernate
			{ spellID = 2637, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Bash
			{ spellID = 5211, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Maim
			{ spellID = 22570, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Pounce
			{ spellID = 9005, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Entangling Roots
			{ spellID = 339, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Feral Charge Effect
			{ spellID = 45334, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Infected Wounds
			{ spellID = 58179, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },

			-- Hunter
			-- Freezing Trap Effect
			{ spellID = 3355, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Freezing Arrow Effect
			--{ spellID = 60210, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Scare Beast
			{ spellID = 1513, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Scatter Shot
			{ spellID = 19503, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Chimera Shot - Scorpid
			--{ spellID = 53359, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Snatch (Bird of Prey)
			{ spellID = 50541, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Silencing Shot
			{ spellID = 34490, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Intimidation
			{ spellID = 24394, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Sonic Blast (Bat)
			{ spellID = 50519, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Ravage (Ravager)
			{ spellID = 50518, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Concussive Barrage
			{ spellID = 35101, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Concussive Shot
			{ spellID = 5116, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Frost Trap Aura
			{ spellID = 13810, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Glyph of Freezing Trap
			{ spellID = 61394, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Wing Clip
			{ spellID = 2974, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Counterattack
			{ spellID = 19306, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Entrapment
			{ spellID = 19185, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Pin (Crab)
			{ spellID = 50245, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Venom Web Spray (Silithid)
			{ spellID = 54706, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Web (Spider)
			{ spellID = 4167, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Froststorm Breath (Chimera)
			{ spellID = 51209, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Tendon Rip (Hyena)
			{ spellID = 51209, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },

			-- Mage
			-- Dragon's Breath
			{ spellID = 31661, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Polymorph
			{ spellID = 118, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Silenced - Improved Counterspell
			{ spellID = 18469, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Deep Freeze
			{ spellID = 44572, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Freeze (Water Elemental)
			{ spellID = 33395, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Frost Nova
			{ spellID = 122, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Shattered Barrier
			{ spellID = 55080, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Chilled
			{ spellID = 6136, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Cone of Cold
			{ spellID = 120, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Slow
			{ spellID = 31589, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },

			-- Paladin
			-- Repentance
			{ spellID = 20066, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Turn Evil
			{ spellID = 10326, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Shield of the Templar
			{ spellID = 63529, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Hammer of Justice
			{ spellID = 853, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Holy Wrath
			{ spellID = 2812, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Stun (Seal of Justice proc)
			{ spellID = 20170, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Avenger's Shield
			{ spellID = 31935, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },

			-- Priest
			-- Psychic Horror
			{ spellID = 64058, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Mind Control
			{ spellID = 605, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Psychic Horror
			{ spellID = 64044, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Psychic Scream
			{ spellID = 8122, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Silence
			{ spellID = 15487, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Mind Flay
			{ spellID = 15407, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },

			-- Rogue
			-- Dismantle
			{ spellID = 51722, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Blind
			{ spellID = 2094, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Gouge
			{ spellID = 1776, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Sap
			{ spellID = 6770, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Garrote - Silence
			{ spellID = 1330, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Silenced - Improved Kick
			{ spellID = 18425, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Cheap Shot
			{ spellID = 1833, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Kidney Shot
			{ spellID = 408, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Blade Twisting
			{ spellID = 31125, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Crippling Poison
			{ spellID = 3409, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Deadly Throw
			{ spellID = 26679, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },

			-- Shaman
			-- Hex
			{ spellID = 51514, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Earthgrab
			{ spellID = 64695, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Freeze
			{ spellID = 63685, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Stoneclaw Stun
			{ spellID = 39796, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Earthbind
			{ spellID = 3600, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Frost Shock
			{ spellID = 8056, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },

			-- Warlock
			-- Banish
			{ spellID = 710, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Death Coil
			{ spellID = 6789, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Fear
			{ spellID = 5782, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Howl of Terror
			{ spellID = 5484, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Seduction (Succubus)
			{ spellID = 6358, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Spell Lock (Felhunter)
			{ spellID = 24259, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Shadowfury
			{ spellID = 30283, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Intercept (Felguard)
			{ spellID = 30153, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Aftermath
			{ spellID = 18118, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Curse of Exhaustion
			{ spellID = 18223, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },

			-- Warrior
			-- Intimidating Shout
			{ spellID = 20511, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Disarm
			{ spellID = 676, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Silenced (Gag Order)
			{ spellID = 18498, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Charge Stun
			{ spellID = 7922, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Concussion Blow
			{ spellID = 12809, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Intercept
			{ spellID = 20253, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Revenge Stun
			--{ spellID = 12798, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Shockwave
			{ spellID = 46968, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Glyph of Hamstring
			{ spellID = 58373, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Improved Hamstring
			{ spellID = 23694, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Hamstring
			{ spellID = 1715, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Piercing Howl
			{ spellID = 12323, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },

			-- Racials
			-- War Stomp
			{ spellID = 20549, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },

			-- ICC
			-- Mark of the Fallen Champion/Mal des gefallenen Champions (Deathbringer Saurfang)
			{ spellID = 72293, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Inoculated/Geimpft (Festergut)
			{ spellID = 72103, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Mutated Infection/Mutierte Infektion (Rotface)
			{ spellID = 71224, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Unbound Plague/Entfesselte Seuche (Professor Putricide)
			{ spellID = 72856, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			--Plague Sickness/Seuchenkrankheit (Professor Putricide)
			{ spellID = 73117, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Gas Variable/Gasvariable (Professor Putricide)
			{ spellID = 70353, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Ooze Variable/Schlammvariable (Professor Putricide)
			{ spellID = 70352, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Pact of the Darkfallen/Pakt der Sinistren (Bloodqueen Lana'thel)
			{ spellID = 71340, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Swarming Shadows/Schwärmende Schatten (Bloodqueen Lana'thel)
			{ spellID = 71861, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Essence of the Blood Queen/Essenz der Blutkönigin (Bloodqueen Lana'thel)
			{ spellID = 71473, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Frost Bomb/Frostbombe (Sindragosa)
			{ spellID = 71053, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Instability/Instabilität (Sindragosa)
			{ spellID = 69766, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Unchained Magic/Entfesselte Magie (Sindragosa)
			{ spellID = 69762, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Mystic Buffet/Mystischer Puffer (Sindragosa)
			{ spellID = 70128, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Necrotic Plague/Nekrotische Seuche (Arthas - The Lich King)
			{ spellID = 73912, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			--Fiery Combustion/Feurige Einäscherung (Halion)
			{ spellID = 74562, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			--Soul Consumption/Seelenverzehrung (Halion)
			{ spellID = 74792, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			
			-- CATA INSTANCES
			
			-- Blackrock Caverns
			-- Corla, Herald of Twilight // Normalmode
			-- Dark Command
			{ spellID = 75823, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Corla, Herald of Twilight
			-- Dark Command
			{ spellID = 93462, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Beauty
			-- Magma Spit
			{ spellID = 76031, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Ascendant Lord Obsidius
			-- Thunderclap 50% run speed
			{ spellID = 76186, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Crepuscular Veil
			{ spellID = 76189, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Grim Batol
			-- General Umbriss
			-- Bleeding Wound normal
			{ spellID = 91937, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Bleeding Wound
			{ spellID = 74846, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Erudax
			-- Binding Shadows normal
			{ spellID = 91081, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Binding Shadows
			{ spellID = 79466, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Halls of Origination
			-- Anraphet
			-- Crumbling Ruin normal
			{ spellID = 75609, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Crumbling Ruin
			{ spellID = 91206, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Ammunae
			-- Wither
			{ spellID = 76043, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- The Stonecore
			-- Corborus
			-- Dampening Wave normal
			{ spellID = 82415, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Dampening Wave
			{ spellID = 92650, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Azil
			-- Curse of Blood normal
			{ spellID = 79345, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Curse of Blood
			{ spellID = 92663, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Throne of Tides
			-- Lady Naz'jar
			-- Fungal Spores normal
			{ spellID = 91470, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Commander Ulthok
			-- Curse of Fatique
			{ spellID = 76094, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Squeeze normal
			{ spellID = 76026, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Squeeze
			{ spellID = 91484, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Erunak Stonespeaker
			-- Enslave normal
			{ spellID = 91413, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Enslave
			{ spellID = 76207, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Ozumat
			-- Veil of Shadow
			{ spellID = 83926, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Vortex Pinnacle
			-- Altairus
			-- Downwind of Altairus
			{ spellID = 88286, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Upwind of Altairus
			{ spellID = 88282, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Asaad
			-- Static Cling
			{ spellID = 87618, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Lost City of the Tol'vir
			-- Lockmaw
			-- Viscous Poison normal
			{ spellID = 81630, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Viscous Poison
			{ spellID = 90004, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Paralytic Blow Dart
			{ spellID = 89989, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Heroic Deadmines
			-- "Captain" Cookie
			-- Nauseated
			{ spellID = 92066, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Satiated
			{ spellID = 92834, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Shadowfang Keep Heroic
			-- Baron Ashbury
			-- Asphyxiate
			{ spellID = 93710, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Stay of Execution
			{ spellID = 93705, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Pain & Suffering
			{ spellID = 93712, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Wracking Pain
			{ spellID = 93720, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Baron Silverlaine
			-- Cursed Veil
			{ spellID = 93956, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Soul Drain
			{ spellID = 93920, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Commander Springvale
			-- Desecration
			{ spellID = 93687, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Word of Shame
			{ spellID = 93852, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Lord Walden
			-- Toxic Catalyst
			{ spellID = 93689, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Lord Godfrey Ghul
			-- Mortal Wound
			{ spellID = 93771, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			
			-- Throne of Four Winds
			-- Al'Akir
			-- Static Shock
			{ spellID = 87873, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Acid Rain
			{ spellID = 88301, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Bastion of Twilight
			-- Cho'gall
			-- Corruption: Accelerated(25% Corruption)
			{ spellID = 81836, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Corruption: Sickness (vomit infront of you)
			{ spellID = 81831, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Corruption: Malformation (75% Corruption)
			{ spellID = 82125, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Corruption: Absolute (100% Corruption)
			{ spellID = 82170, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Valiona & Theralion
			-- Blackout
			{ spellID = 86788, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Twilight Ascendant Council
			-- Waterlogged
			{ spellID = 82762, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Frozen
			{ spellID = 82772, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Blackwing Descent
			-- Chimaeron
			-- Finkle's Mixture
			{ spellID = 82705, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Magmaw
			-- Constricting Chains
			{ spellID = 79589, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Maloriak
			-- Flash Freeze
			{ spellID = 77699, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Omnitron Defense System
			-- Lightning Conductor
			{ spellID = 79888, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
			-- Unstable Shield
			{ spellID = 79900, size = 72, unitId = "target", caster = "all", filter = "BUFF" },
			-- Baradin Hold(PvP)
			-- Argaloth
			-- Meteor Slash
			{ spellID = 88942, size = 72, unitId = "player", caster = "all", filter = "DEBUFF" },
		},
		{
			Name = "PVP_T_BUFF_ICON",
			Direction = "RIGHT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "LEFT", UIParent, "CENTER", 198, -83 },

			-- Aspect of the Pack
			{ spellID = 13159, size = 72, unitId = "player", caster = "player", filter = "BUFF" },
			-- Innervate
			{ spellID = 29166, size = 72, unitId = "target", caster = "all", filter = "BUFF"},
			-- Spell Reflection
			{ spellID = 23920, size = 72, unitId = "target", caster = "all", filter = "BUFF" },
			-- Aura Mastery
			{ spellID = 31821, size = 72, unitId = "target", caster = "all", filter = "BUFF" },
			-- Ice Block
			{ spellID = 45438, size = 72, unitId = "target", caster = "all", filter = "BUFF" },
			-- Cloak of Shadows
			{ spellID = 31224, size = 72, unitId = "target", caster = "all", filter = "BUFF" },
			-- Divine Shield
			{ spellID = 642, size = 72, unitId = "target", caster = "all", filter = "BUFF" },
			-- Deterrence
			{ spellID = 19263, size = 72, unitId = "target", caster = "all", filter = "BUFF" },
			-- Anti-Magic Shell
			{ spellID = 48707, size = 72, unitId = "target", caster = "all", filter = "BUFF" },
			-- Lichborne
			{ spellID = 49039, size = 72, unitId = "target", caster = "all", filter = "BUFF" },
			-- Hand of Freedom
			{ spellID = 1044, size = 72, unitId = "target", caster = "all", filter = "BUFF" },
			-- Hand of Sacrifice
			{ spellID = 6940, size = 72, unitId = "target", caster = "all", filter = "BUFF" },
			-- Grounding Totem Effect
			{ spellID = 8178, size = 72, unitId = "target", caster = "all", filter = "BUFF" },
		},
		{
			Name = "P_COOLDOWNS_MEH",
			Direction = "LEFT",
			Interval = 4,
			Mode = "ICON",
			setPoint = { "RIGHT", UIParent, "CENTER", -198, -240 },

			--Gloves
			{ slotID = 10, size = 32, filter = "CD" },
			--Belt
			{ slotID = 6, size = 32, filter = "CD" },
			--Back
			{ slotID = 15, size = 32, filter = "CD" },
			
			--Trinket
			{ slotID = 13, size = 32, filter = "CD" },
			{ slotID = 14, size = 32, filter = "CD" },
			
			-- Dwarf Stoneform 20594
			{ spellID = 20594, size = 32, filter = "CD" },
			-- Worgen Darkflight 68992
			{ spellID = 68992, size = 32, filter = "CD" },
			-- Goblin Rocket Jump 69070
			{ spellID = 69070, size = 32, filter = "CD" },
			
			-- Saronite Bomb
			{ itemID = 41119, size = 32, filter = "CD" },
		},
	},
}