if select(2, UnitClass("player")) ~= "PRIEST" then return end
local GetSpellInfo = DrDamage.SafeGetSpellInfo
local UnitExists = UnitExists
local UnitIsFriend = UnitIsFriend
local UnitIsUnit = UnitIsUnit
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitPowerMax = UnitPowerMax
local math_min = math.min
local select = select
local IsSpellKnown = IsSpellKnown

function DrDamage:PlayerData()
	--Health Updates (All healing, Shadow Word: Death, Flash Heal)
	self.TargetHealth = { [1] = 0.501, [2] = 0.251, [0.251] = { [GetSpellInfo(32379)] = true, [GetSpellInfo(2061)] = true } }
	--Shadowfiend 4.0
	self.ClassSpecials[GetSpellInfo(34433)] = function()
		return 0.3 * UnitPowerMax("player",0), false, true
	end
	--Dispersion 4.0
	self.ClassSpecials[GetSpellInfo(47585)] = function()
		return 0.36 * UnitPowerMax("player",0), false, true
	end
	--Dispel Magic 4.0
	self.ClassSpecials[GetSpellInfo(527)] = function()
		--Glyph of Dispel Magic 4.0
		if self:HasGlyph(55677) then
			local heal
			if UnitExists("target") and UnitIsFriend("target","player") then
				heal = 0.03 * UnitHealthMax("target")
			else
				heal = 0.03 * UnitHealthMax("player")
			end
			return heal, true
		end
	end
--GENERAL
	self.Calculation["Stats"] = function( calculation, ActiveAuras, Talents, spell, baseSpell )
		local mastery = calculation.mastery
		local masteryLast = calculation.masteryLast
		local spec = calculation.spec
		if spec == 1 then
			if mastery > 0 and mastery ~= masteryLast then
				if calculation.subType == "Absorb" then
					local masteryBonus = calculation.masteryBonus
					if masteryBonus then
						calculation.dmgM = calculation.dmgM / masteryBonus
					end
					--All absorption increased by 2.5% per point of mastery.
					local bonus = 1 + mastery * 0.01 * 2.5
					calculation.dmgM = calculation.dmgM * bonus
					calculation.masteryLast = mastery
					calculation.masteryBonus = bonus
				elseif Talents["Divine Aegis"] then
					local masteryBonus = calculation.masteryBonus
					if masteryBonus then
						if calculation.spellName == "Prayer of Healing" then
							calculation.extraAvg = calculation.extraAvg / masteryBonus
						else
							calculation.extraCrit = calculation.extraCrit / masteryBonus
						end
					end
					local bonus = 1 + mastery * 0.01 * 2.5
					if calculation.spellName == "Prayer of Healing" then
						calculation.extraAvg = calculation.extraAvg * bonus
					else
						calculation.extraCrit = calculation.extraCrit * bonus
					end
					calculation.masteryLast = mastery
					calculation.masteryBonus = bonus			
				end
			end
		elseif spec == 2 then
			if mastery > 0 and mastery ~= masteryLast then
				if baseSpell.DirectHeal then
					--All direct heals heal for an additional 1.25% per point of mastery over 6 seconds.
					local bonus = mastery * 0.01 * 1.25
					calculation.hybridDotDmg = bonus * 0.5 * (calculation.minDam + calculation.maxDam)
					calculation.SPBonus_dot = bonus * calculation.SPBonus
					calculation.eDuration = 6
					calculation.sTicks = 1
					calculation.dotStacks = true
					calculation.masteryLast = mastery
				end
			end
		elseif spec == 3 then
			if mastery > 0 and mastery ~= masteryLast then
				if ActiveAuras["Shadow Orb"] then
					calculation.dmgM = calculation.dmgM / (1 + ActiveAuras["Shadow Orb"] * (0.1 + (calculation.masteryBonus or 0)))
					--Additional damage from Shadow Orbs due to Mastery.
					--Mastery: Shadow Orb Power
					local bonus = mastery * 0.01 * 1.45
					calculation.dmgM = calculation.dmgM * (1 + ActiveAuras["Shadow Orb"] * (0.1 + bonus))
					calculation.masteryLast = mastery
					calculation.masteryBonus = bonus
				end
			end
		end
		if calculation.spi ~= 0 then
			if Talents["Twisted Faith"] then
				--Grants you spell hit rating equal to 50%/100% of any Spirit gained from items or effects.
				local rating = calculation.spi * Talents["Twisted Faith"]
				calculation.hitPerc = calculation.hitPerc + self:GetRating("Hit", rating, true)
			end
		end
	end
	self.Calculation["PRIEST"] = function ( calculation, ActiveAuras, Talents, spell, baseSpell )
		--General stats
		if IsSpellKnown(89745) then
			calculation.intM = calculation.intM * 1.05
		end
		--Specialization
		local spec = calculation.spec
		if spec == 1 then
			--Intellect increased by 15%
			calculation.intM = calculation.intM * 1.15
		elseif spec == 2 then
			--Holy Spec
			--Increase healing by 15%.
			if calculation.healingSpell then
				calculation.dmgM = calculation.dmgM * 1.15
				calculation.dmgM_absorb = (calculation.dmgM_absorb or 1) * 1.15
			end
		elseif spec == 3 then
			-- Shadow Spec
			-- Spell damage increased by 15%.  Shadow crit damage increased by 100%.
			if not calculation.healingSpell then
				--Passive: Shadow Power
				calculation.dmgM = calculation.dmgM * 1.15
				if calculation.school == "Shadow" then
					calculation.critM = calculation.critM + 0.5
				end
			end
			if ActiveAuras["Shadow Orb"] then
				calculation.dmgM = calculation.dmgM * (1 + ActiveAuras["Shadow Orb"] * 0.1)
			end
		end
		if calculation.healingSpell then
			--Glyph of Power Word: Barrier 4.0
			if self:HasGlyph(55689) and ActiveAuras["Power Word: Barrier"] then
				if UnitIsUnit(calculation.target,"player") then
					calculation.dmgM = calculation.dmgM * 1.1
				end
			end
			if self:GetSetAmount( "T9 Healing" ) >= 4 then
				calculation.dmgM_Add = calculation.dmgM_Add + 0.05
			end
		else
			if ActiveAuras["Shadowform"] then
				--Multiplicative - 3.3.3
				calculation.dmgM = calculation.dmgM * 1.15
			end
		end
	end
--TALENTS
	local daicon = "|T" .. select(3,GetSpellInfo(47509)) .. ":16:16:1:-1|t"
	self.Calculation["Divine Aegis"] = function( calculation, value, Talents )
		if calculation.spellName == "Prayer of Healing" then
			calculation.extraAvg = value
		else
			calculation.extraCrit = value / (calculation.hits or 1)
			calculation.extraChanceCrit = true
		end
		calculation.extraName = daicon
		Talents["Divine Aegis"] = 1
	end
	self.Calculation["Test of Faith"] = function( calculation, value )
		local target = calculation.target
		if target and UnitHealth(target) ~= 0 and (UnitHealth(target) / UnitHealthMax(target)) <= 0.5 then
			calculation.dmgM = calculation.dmgM * (1 + value)
		end
	end
--ABILITIES
	self.Calculation["Mind Sear"] = function ( calculation )
		if self:GetSetAmount( "T11 Damage" ) >= 2 then
			calculation.critPerc = calculation.critPerc + 5
		end
	end
	self.Calculation["Mind Flay"] = function ( calculation, ActiveAuras, Talents )
		--Glyph of Mind Flay 4.0
		if self:HasGlyph(55687) then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
		if self:GetSetAmount( "T9 Damage" ) >= 4 then
			calculation.critPerc = calculation.critPerc + 5
		end
		if self:GetSetAmount( "T10 Damage" ) >= 4 then
			calculation.castTime = 2.49
		end
		if self:GetSetAmount( "T11 Damage" ) >= 2 then
			calculation.critPerc = calculation.critPerc + 5
		end
	end
	local shadowy_apparition_icon = "|T" .. select(3,GetSpellInfo(78202)) .. ":16:16:1:-1|t"
	self.Calculation["Shadow Word: Pain"] = function ( calculation, ActiveAuras, Talents )
		if Talents["Shadowy Apparition"] then
			local bonus = (self:GetSetAmount( "T11 Damage" ) >= 4) and 1.3 or 1
			calculation.extra = self:ScaleData(0.514) * bonus
			calculation.extraDamage = 0.515 * bonus
			calculation.extraBonus = true
			calculation.extraCanCrit = true --Let's assume this crits for now
			calculation.extraChance = calculation.hits * Talents["Shadowy Apparition"]
			calculation.extraName = shadowy_apparition_icon
		end
		--Glyph of Shadow Word: Pain 4.0
		if self:HasGlyph(55681) then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
		if self:GetSetAmount( "T10 Damage" ) >= 2 then
			calculation.critPerc = calculation.critPerc + 5
		end
	end
	self.Calculation["Vampiric Touch"] = function ( calculation, ActiveAuras )
		if self:GetSetAmount( "T9 Damage" ) >= 2 then
			calculation.eDuration = calculation.eDuration + 6
		end
		if self:GetSetAmount( "T10 Damage" ) >= 2 then
			calculation.critPerc = calculation.critPerc + 5
		end
	end
	self.Calculation["Devouring Plague"] = function ( calculation, ActiveAuras, Talents )
		if Talents["Improved Devouring Plague"] then
			calculation.eDot = false
			calculation.hybridDotDmg = (calculation.minDam + calculation.maxDam) / 2
			calculation.SPBonus_dot = calculation.SPBonus
			calculation.dotToDD = Talents["Improved Devouring Plague"]
			calculation.bDmgM = calculation.hits * Talents["Improved Devouring Plague"] * calculation.bDmgM
			calculation.SPBonus = calculation.hits * Talents["Improved Devouring Plague"] * calculation.SPBonus
			calculation.hits_dot = calculation.hits
			calculation.hits = nil			
		end
		if self:GetSetAmount( "T8 Damage" ) >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.15
		end
		if self:GetSetAmount( "T10 Damage" ) >= 2 then
			calculation.critPerc = calculation.critPerc + 5
		end
	end
	self.Calculation["Renew"] = function ( calculation, _, Talents )
		--Glyph of Renew 4.0
		if self:HasGlyph(55674) then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
		if Talents["Divine Touch"] then
			calculation.eDot = false
			calculation.hybridDotDmg = (calculation.minDam + calculation.maxDam) / 2
			calculation.SPBonus_dot = calculation.SPBonus
			calculation.dotToDD = Talents["Divine Touch"]
			calculation.bDmgM = calculation.hits * Talents["Divine Touch"] * calculation.bDmgM
			calculation.SPBonus = calculation.hits * Talents["Divine Touch"] * calculation.SPBonus
			calculation.hits_dot = calculation.hits
			calculation.hits = nil
		end
	end
	self.Calculation["Holy Nova"] = function( calculation )
		--Glyph of Holy Nova 4.0
		if self:HasGlyph(55683) then
			calculation.castTime = calculation.castTime - 0.5
		end
	end
	self.Calculation["Lightwell"] = function( calculation )
		--Glyph of Lightwell 4.0
		if self:HasGlyph(55673) then
			--TODO: stacks??
			--calculation.hits = calculation.hits + 5
		end
	end
	self.Calculation["Shadow Word: Death"] = function( calculation, ActiveAuras, Talents )
		if UnitHealth("target") ~= 0 and (UnitHealth("target") / UnitHealthMax("target")) <= 0.25 then
			calculation.dmgM = calculation.dmgM * 3 * (1 + (Talents["Mind Melt"] or 0))
		end
		if self:GetSetAmount( "T7 Damage" ) >= 4 then
			calculation.critPerc = calculation.critPerc + 10
		end
	end
	self.Calculation["Smite"] = function( calculation, ActiveAuras )
		--Glyph of Smite 4.0
		if self:HasGlyph(55692) and ActiveAuras["Holy Fire"] then
			--Multiplicative - 3.3.3
 			calculation.dmgM = calculation.dmgM * 1.2
		end
		--Glyph of Divine Accuracy 4.1
		if self:HasGlyph(63246) then
			calculation.hitPerc = calculation.hitPerc + 18
		end
	end
	self.Calculation["Holy Fire"] = function( calculation, ActiveAuras )
		--Glyph of Divine Accuracy 4.1
		if self:HasGlyph(63246) then
			calculation.hitPerc = calculation.hitPerc + 18
		end
	end
		
	local glyph = GetSpellInfo(52817)
	local glyphicon = "|TInterface\\Icons\\INV_Glyph_MajorPriest:16:16:1:-1|t"	
	self.Calculation["Prayer of Healing"] = function( calculation )
		--Glyph of Prayer of Healing 4.0
		if self:HasGlyph(55680) then
			if calculation.spec == 2 then
				calculation.extraAvg = 0.2
				calculation.extraTicks = 2
				calculation.extraName = glyph
			else
				calculation.hybridDotDmg = 0.2 * 0.5 * (calculation.minDam + calculation.maxDam)
				calculation.SPBonus_dot = 0.2 * calculation.SPBonus
				calculation.eDuration = 6
				calculation.sTicks = 3
			end
		end
		if self:GetSetAmount( "T8 Healing" ) >= 2 then
			calculation.critPerc = calculation.critPerc + 10
		end
	end
	self.Calculation["Power Word: Shield"] = function( calculation, _, Talents )
		local auraMod = calculation.dmgM
		calculation.dmgM = (calculation.dmgM_absorb or 1) * (1 + (Talents["Twin Disciplines"] or 0)) * (1 + (Talents["Improved Power Word: Shield"] or 0))
		--Glyph of Power Word: Shield 4.0
		if self:HasGlyph(55672) then
			calculation.extraCrit = 0.2 * auraMod
			calculation.extraCanCrit = true
			calculation.extraName = glyph
			if Talents["Divine Aegis Bonus"] then
				calculation.extraName = glyphicon .. "+" .. daicon
				calculation.extraCritEffect = Talents["Divine Aegis Bonus"]
			end
		end
		if self:GetSetAmount( "T10 Healing" ) >= 4 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.05
		end
	end
	self.Calculation["Circle of Healing"] = function( calculation )
		--Glyph of Circle of Healing 4.0
		if self:HasGlyph(55675) then
			calculation.aoe = calculation.aoe + 1
		end
		if self:GetSetAmount( "T10 Healing" ) >= 4 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
	end
	self.Calculation["Divine Hymn"] = function( calculation )
		calculation.dmgM = calculation.dmgM * 1.1
		if calculation.targets > 1 then
			calculation.hits = calculation.hits * math_min(3, calculation.targets)
		end
	end
	self.Calculation["Prayer of Mending"] = function( calculation )
		if self:GetSetAmount( "T7 Healing" ) >= 2 then
			calculation.hits = calculation.hits + 1
		end
		if self:GetSetAmount( "T9 Healing" ) >= 2 then
			--Multiplicative - 3.3.3
			calculation.dmgM = calculation.dmgM * 1.2
		end
		--Glyph of Prayer of Mending (4.0.6)
		if self:HasGlyph(55685) then
			calculation.finalMod_M = 1.12
		end
	end
	self.Calculation["Flash Heal"] = function( calculation, ActiveAuras )
		--Glyph of Flash Heal 4.0
		if self:HasGlyph(55679) then
			local target = calculation.target
			if target and UnitHealth(target) ~= 0 and (UnitHealth(target) / UnitHealthMax(target)) <= 0.25 then
				calculation.critPerc = calculation.critPerc + 10
			end
		end
		--[[
		if self:GetSetAmount( "T10 Healing" ) >= 2 then
			--TODO: Support DA + set bonus?
			if calculation.extraCrit then
				calculation.extraCrit = nil
				calculation.extraChanceCrit = nil
			end
			calculation.extraAvg = (1/3)
			calculation.extraChance = (1/3)
			calculation.extraTicks = 3
			calculation.extraName = "2T10"
		end
		--]]
	end
	self.Calculation["Penance"] = function( calculation )
		--Glyph of Penance 4.0
		if self:HasGlyph(63235) then
			calculation.cooldown = calculation.cooldown - 2
		end
	end
	self.Calculation["Heal"] = function( calculation )
		if self:GetSetAmount( "T11 Healing" ) >= 2 then
			calculation.critPerc = calculation.critPerc + 5
		end
	end
	self.Calculation["Desperate Prayer"] = function( calculation )
		calculation.minDam = 0.3 * UnitHealthMax("player")
		calculation.maxDam = calculation.minDam
	end
--SETS
	self.SetBonuses["T7 Damage"] = { 40454, 40456, 40457, 40458, 40459, 39521, 39523, 39528, 39529, 39530 }
	self.SetBonuses["T7 Healing"] = { 40445, 40447, 40448, 40449, 40450, 39514, 39515, 39517, 39518, 39519 }
	self.SetBonuses["T8 Damage"] = { 46163, 46165, 46168, 46170, 46172, 45391, 45392, 45393, 45394, 45395 }
	self.SetBonuses["T8 Healing"] = { 46188, 46190, 46193, 46195, 46197, 45386, 45387, 45388, 45389, 45390 }
	self.SetBonuses["T9 Damage"] = { 48072, 48073, 48074, 48075, 48076, 48097, 48098, 48099, 48100, 48101, 48078, 48077, 48081, 48079, 48080, 48085, 48086, 48082, 48084, 48083, 48095, 48096, 48092, 48094, 48093, 48088, 48087, 48091, 48089, 48090 }
	self.SetBonuses["T9 Healing"] = { 47914, 47936, 47980, 47981, 47982, 48067, 48068, 48069, 48070, 48071, 48065, 48066, 48064, 48063, 48062, 48058, 48057, 48059, 48060, 48061, 47984, 47983, 47985, 47986, 47987, 48035, 48037, 48033, 48031, 48029 }
	self.SetBonuses["T10 Damage"] = { 50392, 50391, 50396, 50393, 50394, 51255, 51184, 51256, 51183, 51257, 51182, 51258, 51181, 51259, 51180 }
	self.SetBonuses["T10 Healing"] = { 50766, 50765, 50769, 50768, 50767, 51260, 51179, 51261, 51178, 51262, 51177, 51263, 51176, 51264, 51175 }
	self.SetBonuses["T11 Damage"] = { 60253, 60254, 60255, 60256, 60257, 65234, 65235, 65236, 65237, 65238 }
	self.SetBonuses["T11 Healing"] = { 60258, 60259, 60261, 60262, 60275, 65229, 65230, 65231, 65232, 65233 }
--AURA
--Player
	--Shadowform 4.0
	self.PlayerAura[GetSpellInfo(15473)] = { School = "Shadow", ActiveAura = "Shadowform", ID = 15473 }
	--Shadow Orb 4.0
	self.PlayerAura[GetSpellInfo(77487)] = { Spells = { "Mind Blast", "Mind Spike" }, ActiveAura = "Shadow Orb", Apps = 3, ID = 77487, }
	--Empowered Shadow 4.0 (TODO: Check Mind Sear)
	self.PlayerAura[GetSpellInfo(95799)] = { Value = 0.1, ID = 95799, Spells = { "Mind Flay", "Devouring Plague", "Shadow Word: Pain", "Vampiric Touch", "Mind Sear" } }
	--Borrowed time 4.0
	--self.PlayerAura[GetSpellInfo(59887)] = { Update = true }
	--Surge of Light 4.0
	self.PlayerAura[GetSpellInfo(88688)] = { Update = true, Spells = "Flash Heal" }
	--Inner Will 4.0
	self.PlayerAura[GetSpellInfo(73413)] = { Update = true }
	--Power Word: Barrier 4.0
	self.PlayerAura[GetSpellInfo(81782)] = { School = "Healing", ActiveAura = "Power Word: Barrier", NoManual = true }
	--Serendipity 4.0
	self.PlayerAura[GetSpellInfo(63731)] = { Update = true, Spells = { "Greater Heal", "Prayer of Healing" } }
	--Inner Focus 4.0
	self.PlayerAura[GetSpellInfo(89485)] = { Spells = { "Flash Heal", "Binding Heal", "Greater Heal", "Prayer of Healing" }, Value = 25, ModType = "critPerc", ID = 89485, NoManual = true }
	--Mind Melt 4.0
	self.PlayerAura[GetSpellInfo(81292)] = { Update = true, Spells = "Mind Blast" }
	--Evangelism 4.0
	self.PlayerAura[GetSpellInfo(81660)] = { Spells = { "Smite", "Holy Fire", "Penance" }, NoManual = true, Apps = 5, ModType =
		function( calculation, _, Talents, _, apps )
			if Talents["Evangelism"] then
				calculation.dmgM = calculation.dmgM * (1 + apps * 0.02 * Talents["Evangelism"])
			end
		end
	}
	--Dark Evangelism 4.0 (TODO: Check Mind Sear)
	self.PlayerAura[GetSpellInfo(87117)] = { Spells = { "Mind Flay", "Devouring Plague", "Shadow Word: Pain", "Vampiric Touch", "Mind Sear" }, NoManual = true, Apps = 5, ModType =
		function( calculation, _, Talents, _, apps )
			if Talents["Evangelism"] then
				calculation.dmgM = calculation.dmgM * (1 + apps * 0.01 * Talents["Evangelism"])
			end
		end
	}
	--Archangel 4.0
	self.PlayerAura[GetSpellInfo(81700)] = { School = "Healing", NoManual = true, Apps = 5, Value = 0.03 }
	--Dark Archangel 4.0
	self.PlayerAura[GetSpellInfo(87153)] = { Spells = { "Mind Flay", "Mind Spike", "Mind Blast", "Shadow Word: Death" }, NoManual = true, Apps = 5, Value = 0.04 }
	--Chakra: Chastise 4.0
	self.PlayerAura[GetSpellInfo(81209)] = { School = { "Shadow", "Holy" }, NoManual = true, Value = 0.15 }
	--Chakra: Sanctuary 4.0 (TODO: Any missing AoE spells?)
	self.PlayerAura[GetSpellInfo(81206)] = { Spells = { "Prayer of Healing", "Circle of Healing", "Divine Hymn", "Holy Word: Sanctuary", "Renew" }, NoManual = true, ModType =
		function( calculation )
			calculation.dmgM = calculation.dmgM * 1.15
			if calculation.spellName == "Circle of Healing" then
				calculation.cooldown = calculation.cooldown - 2
			end
		end
	}
	--Chakra: Serenity 4.0
	self.PlayerAura[GetSpellInfo(81208)] = { Spells = { "Heal", "Flash Heal", "Greater Heal", "Desperate Prayer", "Binding Heal", "Holy Word: Serenity" }, NoManual = true, ModType = "critPerc", Value = 10 }

--Target
	--Holy Fire 4.0
	self.TargetAura[GetSpellInfo(14914)] = { Spells = "Smite", ActiveAura = "Holy Fire", ID = 14914 }
	--Divine Hymn 4.0
	self.TargetAura[GetSpellInfo(64844)] = { School = "Healing", Value = 0.1, Not = "Divine Hymn", NoManual = true }
	--Mind Spike 4.0
	self.TargetAura[GetSpellInfo(87178)] = { Spells = "Mind Blast", Apps = 3, Value = 30, ModType = "critPerc" }
	--Grace 4.0
	self.TargetAura[GetSpellInfo(47930)] = { School = "Healing", Apps = 3, SelfCastBuff = true, ID = 47930, ModType =
		function( calculation, _, Talents, _, apps )
			if Talents["Grace"] then
				calculation.dmgM = calculation.dmgM * (1 + apps * Talents["Grace"])
			end
			if Talents["Renewed Hope"] then
				calculation.critPerc = calculation.critPerc + Talents["Renewed Hope"]
			end
		end
	}
	--Weakened Soul 4.0
	self.TargetAura[GetSpellInfo(6788)] = { Spells = { "Flash Heal", "Greater Heal", "Heal", "Penance" }, ID = 6788, ModType =
		function( calculation, _, Talents )
			if Talents["Renewed Hope"] and calculation.healingSpell then
				calculation.critPerc = calculation.critPerc + Talents["Renewed Hope"]
			end
		end
	}
	--Holy Word: Serenity 4.0
	self.TargetAura[GetSpellInfo(88684)] = { School = "Healing", SelfCastBuff = true, ID = 88684, ModType = "critPerc", Value = 25 }

	--SPELLS
	self.spellInfo = {
		[GetSpellInfo(15407)] = {
					-- Checked in 4.0.3
					["Name"] = "Mind Flay",
					["ID"] = 15407,
					["Data"] = { 0.177, 0, 0.257 },
					[0] = { School = "Shadow",  Hits = 3, sTicks = 1, Channeled = 3 },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(2944)] = {
					-- Checked in 4.0.3
					["Name"] = "Devouring Plague",
					["ID"] = 2944,
					["Data"] = { 0.164, 0, 0.185 },
					[0] = { School = "Shadow", eDot = true, eDuration = 24, Hits = 8, Hits_dot = 8, sTicks = 3, Leech = 0.15, DotLeech = true, },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(589)] = {
					-- Checked in 4.0.3
					["Name"] = "Shadow Word: Pain",
					["ID"] = 589,
					["Data"] = { 0.234, 0, 0.183 },
					[0] = { School = "Shadow", eDot = true, Hits = 6, eDuration = 18 , sTicks = 3 },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(34914)] = {
					-- Checked in 4.0.3
					["Name"] = "Vampiric Touch",
					["ID"] = 34914,
					["Data"] = { 0.115, 0, 0.4 },
					[0] = { School = "Shadow", eDot = true, Hits = 5, eDuration = 15, sTicks = 3, },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(32379)] = {
					-- Checked in 4.0.3
					["Name"] = "Shadow Word: Death",
					["ID"] = 32379,
					["Data"] = { 0.319, 0, 0.282 },
					[0] = { School = "Shadow",  Cooldown = 10, },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(8092)] = {
					-- Checked in 4.0.6
					["Name"] = "Mind Blast",
					["ID"] = 8092,
					["Data"] = { 1.39, 0.055, 0.9858 },
					[0] = { School = "Shadow", Cooldown = 8, },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(73510)] = {
					-- Checked in 4.0.6
					["Name"] = "Mind Spike",
					["ID"] = 73510,
					["Data"] = { 1.178, 0.055, 0.8355 },
					[0] = { School = "Shadow", },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(17)] = {
					-- Checked in 4.0.3
					["Name"] = "Power Word: Shield",
					["ID"] = 17,
					["Data"] = { 8.6088, 0, 0.87 },
					[0] = { School = { "Holy", "Healing", "Absorb" }, Cooldown = 4, NoDPS = true, NoDoom = true, NoSchoolTalents = true, NoTypeTalents = true },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(2050)] = {
					-- Checked in 4.0.6
					["Name"] = "Heal",
					["ID"] = 2050,
					["Data"] = { 3.587, 0.15, 0.362, ["ct_min"] = 1500, ["ct_max"] = 3000 },
					[0] = { School = { "Holy", "Healing" }, DirectHeal = true, },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(2060)] = {
					-- Checked in 4.0.3
					["Name"] = "Greater Heal",
					["ID"] = 2060,
					["Data"] = { 9.564, 0.15, 0.967 },
					[0] = { School = { "Holy", "Healing" }, DirectHeal = true, },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(596)] = {
					-- Checked in 4.0.6
					["Name"] = "Prayer of Healing",
					["ID"] = 596,
					["Data"] = { 3.359, 0.055, 0.34 },
					[0] = { School = { "Holy", "Healing" }, AoE = 5 },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(34861)] = {
					-- Checked in 4.0.6
					["Name"] = "Circle of Healing",
					["ID"] = 34861,
					["Data"] = { 2.571, 0.1, 0.26 },
					[0] = { School = { "Holy", "Healing" }, AoE = 5 },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(2061)] = {
					-- Checked in 4.0.6
					["Name"] = "Flash Heal",
					["ID"] = 2061,
					["Data"] = { 7.174, 0.15, 0.725 },
					[0] = { School = { "Holy", "Healing" }, DirectHeal = true,  },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(19236)] = {
					-- Checked in 4.0.3
					["Name"] = "Desperate Prayer",
					["ID"] = 19236,
					[0] = { School = { "Holy", "Healing" }, DirectHeal = true, Cooldown = 120, NoDoom = true, SelfHeal = true, },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(139)] = {
					-- Checked in 4.0.3
					["Name"] = "Renew",
					["ID"] = 139,
					["Data"] = { 1.29, 0, 0.131 },
					[0] = { School = { "Holy", "Healing" }, eDot = true, Hits = 5, eDuration = 15, sTicks = 3, },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(32546)] = {
					-- Checked in 4.0.6
					["Name"] = "Binding Heal",
					["ID"] = 32546,
					["Data"] = { 5.746, 0.25, 0.544 },
					[0] = { School = { "Holy", "Healing" }, DirectHeal = true, },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(33076)] = {
					-- Checked in 4.0.3
					["Name"] = "Prayer of Mending",
					["ID"] = 33076,
					["Data"] = { 3.144, 0, 0.318 },
					[0] = { School = { "Holy", "Healing" }, Cooldown = 10, Hits = 5, NoDPS = true, NoPeriod = true },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(88625)] = {
					-- Checked in 4.0.3
					["Name"] = "Holy Word: Chastise",
					["ID"] = 88625,
					["Data"] = { 0.633, 0.115, 0.614 },
					[0] = { School = "Holy", Cooldown = 30 },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(88685)] = {
					-- Checked in 4.1
					["Name"] = "Holy Word: Sanctuary",
					["ID"] = 88685,
					["Data"] = { 0.346, 0.173, 0.042 },
					[0] = { School = { "Holy", "Healing" }, Cooldown = 40, Hits = 9, AoE = 6, eDot = true, eDuration = 18, sTicks = 2, },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(88684)] = {
					-- Checked in 4.0.3
					["Name"] = "Holy Word: Serenity",
					["ID"] = 88684,
					["Data"] = { 5.997, 0.16, 0.486 },
					[0] = { School = { "Holy", "Healing" }, Cooldown = 15 },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(585)] = {
					-- Checked in 4.0.3
					["Name"] = "Smite",
					["ID"] = 585,
					["Data"] = { 0.733, 0.115, 0.856, ["ct_min"] = 1500, ["ct_max"] = 2500 },
					[0] = { School = "Holy", },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(14914)] = {
					-- Checked in 4.0.3
					["Name"] = "Holy Fire",
					["ID"] = 14914,
					["Data"] = { 1.0829, 0.238, 1.11, 0.054, 0, 0.0312 },
					[0] = { School = "Holy",  Cooldown = 10, Hits_dot = 7, eDuration = 7, sTicks = 1 },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(15237)] = {
					-- Checked in 4.1
					["Name"] = "Holy Nova",
					["ID"] = 15237,
					["Data"] = { 1.94, 0.15, 0.196 },
					["Text1"] = GetSpellInfo(15237),
					["Text2"] = GetSpellInfo(37455),
					[0] = { School = { "Holy", "Healing", "Holy Nova Heal" }, AoE = 5 },
					[1] = { 0, 0 },
			["Secondary"] = {
					["Name"] = "Holy Nova",
					["ID"] = 15237,
					["Data"] = { 0.316, 0.15, 0.143 },
					["Text1"] = GetSpellInfo(15237),
					["Text2"] = GetSpellInfo(48360),
					[0] = { School = { "Holy", "Holy Nova Damage" }, AoE = true },
					[1] = { 0, 0 },
			}
		},
		[GetSpellInfo(724)] = {
					-- Checked in 4.0.3
					["Name"] = "Lightwell",
					["ID"] = 724,
					["Data"] = { 3.045 * 1.15, 0, 0.308 * 1.15 },
					[0] = { School = { "Holy", "Healing" }, Cooldown = 180, Hits = 3, eDot = true, eDuration = 6, sTicks = 2, Stacks = 10 },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(64843)] = {
					-- Checked in 4.0.3
					["Name"] = "Divine Hymn",
					["ID"] = 64843,
					["Data"] = { 4.242, 0, 0.429 },
					[0] = { School = { "Holy", "Healing" }, eDot = true, eDuration = 8, sTicks = 2, Hits = 4, Cooldown = 480, Channeled = 8 },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(48045)] = {
					-- Checked in 4.1
					["Name"] = "Mind Sear",
					["ID"] = 48045,
					["Data"] = { 0.23, 0.080, 0.2622 },
					[0] = { School = "Shadow", Hits = 5, Channeled = 5, AoE = true },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(47540)] = {
					-- Checked in 4.0.6
					["Name"] = "Penance",
					["ID"] = 47540,
					["Data"] = { 3.18, 0.122, 0.321 },
					[0] = { School = { "Holy", "Healing" }, Cooldown = 12, Hits = 3, Channeled = 2 },
					[1] = { 0, 0 },
			["Secondary"] = {
					["Name"] = "Penance",
					["ID"] = 47540,
					["Data"] = { 0.788, 0.122, 0.458 },
					[0] = { School = "Holy", Cooldown = 12,  Hits = 3, Channeled = 2, },
					[1] = { 0, 0 },
			}
		},
	}
	self.talentInfo = {
	--DISCIPLINE:
		--Improved Power Word: Shield (multiplicative - 3.3.3, updated for 4.0.3)
		[GetSpellInfo(14748)] = { 	[1] = { Effect = 0.1, Spells = "Power Word: Shield", ModType = "Improved Power Word: Shield" }, },
		--Twin Disciplines (additive - 3.3.3, updated for 4.0.3)
		[GetSpellInfo(47586)] = { 	[1] = { Effect = 0.02, Spells = { "All", "Power Word: Shield" }, }, 
									[2] = { Effect = 0.02, Spells = "Power Word: Shield", ModType = "Twin Disciplines" }, },
		--Evangelism (updated for 4.0.3)
		[GetSpellInfo(81659)] = { 	[1] = { Effect = 1, Spells = "All", ModType = "Evangelism" }, },
		--Soul Warding (updated for 4.0.3)
		[GetSpellInfo(63574)] = {	[1] = { Effect = -1, Spells = "Power Word: Shield", ModType = "cooldown" }, },
		--Renewed Hope (updated for 4.0.3)
		[GetSpellInfo(57470)] = {	[1] = { Effect = 5, Spells = { "Flash Heal", "Greater Heal", "Heal", "Penance" }, ModType = "Renewed Hope" }, },
		--Divine Aegis (updated for 4.0.3)
		[GetSpellInfo(47509)] = {	[1] = { Effect = 0.1, Spells = "Healing", Not = { "Lightwell", "Power Word: Shield" }, ModType = "Divine Aegis", },
									[2] = { Effect = 0.1, Spells = "Power Word: Shield", ModType = "Divine Aegis Bonus" }, },
		--Grace (updated for 4.0.3)
		[GetSpellInfo(47516)] = { 	[1] = { Effect = 0.04, Spells = "Healing", ModType = "Grace" }, },
	--HOLY:
		--Improved Renew (additive - 3.3.3; updated for 4.0.3)
		[GetSpellInfo(14908)] = { 	[1] = { Effect = 0.05, Spells = "Renew" }, },
		--Empowered Healing (additive? - updated for 4.0.3)
		[GetSpellInfo(82980)] = {	[1] = { Effect = 0.05, Spells = { "Flash Heal", "Heal", "Binding Heal", "Greater Heal" }, }, },
		--Divine Touch (updated for 4.0.3)
		[GetSpellInfo(63534)] = {	[1] = { Effect = 0.05, Spells = "Renew", ModType = "Divine Touch", }, },
		--Rapid Renewal (updated for 4.0.3)
		[GetSpellInfo(95649)] = {	[1] = { Effect = -0.5, Spells = "Renew", ModType = "castTime" }, },
		--Test of Faith (multiplicative - 3.3.3; update for 4.0.3)
		[GetSpellInfo(47558)] = {	[1] = { Effect = 0.04, Spells = "Healing", ModType = "Test of Faith", }, },
	--SHADOW:
		--Improved Shadow Word: Pain (additive - 3.3.3; updated for 4.0.3)
		[GetSpellInfo(15275)] = { 	[1] = { Effect = 0.03, Spells = "Shadow Word: Pain" }, },
		--Improved Mind Blast (updated for 4.0.3)
		[GetSpellInfo(15273)] = { 	[1] = { Effect = -0.5, Spells = "Mind Blast", ModType = "cooldown" }, },
		--Improved Devouring Plague (updated for 4.0.3)
		[GetSpellInfo(63625)] = {	[1] = { Effect = 0.15, Spells = "Devouring Plague", ModType = "Improved Devouring Plague" }, },
		--Twisted Faith (multiplicative - 3.3.3; updated for 4.0.3)
		[GetSpellInfo(47573)] = {	[1] = { Effect = 0.01, Spells = "Shadow", },
									[2] = { Effect = 0.5, Spells = "All", Not = "Healing", ModType = "Twisted Faith" }, },
		--Mind Melt (multiplicative? - updated for 4.0.3)
		[GetSpellInfo(14910)] = {	[1] = { Effect = 0.15, Spells = "Shadow Word: Death", ModType = "Mind Melt", }, },
		--Shadowy Apparition (updated for 4.0.3)
		[GetSpellInfo(78202)] = {	[1] = { Effect = 0.04, Spells = "Shadow Word: Pain", ModType = "Shadowy Apparition" }, },
	}
end