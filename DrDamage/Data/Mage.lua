if select(2, UnitClass("player")) ~= "MAGE" then return end
local GetSpellInfo = DrDamage.SafeGetSpellInfo
local GetSpellCritChance = GetSpellCritChance
local UnitBuff = UnitBuff
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local math_max = math.max
local math_floor = math.floor
local UnitDebuff = UnitDebuff
local Orc = (select(2,UnitRace("player")) == "Orc")
local select = select
local GetPetSpellBonusDamage = GetPetSpellBonusDamage
local IsSpellKnown = IsSpellKnown

--Waterbolt, Freeze
local spells = { [GetSpellInfo(31707)] = true, [GetSpellInfo(33395)] = true, }
function DrDamage:UpdatePetSpells()
	self:UpdateAB(spells)
end

function DrDamage:PlayerData()
	--Health Updates
	self.TargetHealth = { [1] = 0.35 }
	--Special AB info
	--Evocation
	self.ClassSpecials[GetSpellInfo(12051)] = function()
		return 0.6 * UnitPowerMax("player",0), false, true
	end
	--Torment the Weak
	--TODO for 4.0: Check if we need to add anything
	local snareList = {
	--Hunter snares (4.0): Wing Clip, Ice trap, Concussive Shot,
	(GetSpellInfo(2974)), (GetSpellInfo(13810)), (GetSpellInfo(5116)),
	--Rogue snares (4.0): Crippling Poison, Deadly Throw
	(GetSpellInfo(3409)), (GetSpellInfo(26679)),
	--Warrior snares (4.0): Hamstring, Piercing Howl
	(GetSpellInfo(1715)), (GetSpellInfo(12323)),
	--Shaman snares (4.0): Frost Shock, Earthbind,
	(GetSpellInfo(8056)), (GetSpellInfo(3600)),
	--Others (4.0): Curse of Exhaustion, Mind Flay, Dazed, Desecration (DK), Chilblains (DK talent)
	(GetSpellInfo(18223)), (GetSpellInfo(15407)), (GetSpellInfo(29703)), (GetSpellInfo(55741)), (GetSpellInfo(50434))
	}
--GENERAL
	self.Calculation["Stats"] = function( calculation, ActiveAuras, Talents, spell, baseSpell )
		local mastery = calculation.mastery
		local masteryLast = calculation.masteryLast
		local spec = calculation.spec
		if spec == 1 then
			if mastery > 0 and mastery ~= masteryLast then
				local masteryBonus = calculation.masteryBonus
				if masteryBonus then
					calculation.dmgM = calculation.dmgM / masteryBonus
				end
				--Mana Adept: Damage bonus to all spells based on mana left
				local bonus = 1 + mastery * 0.01 * 1.5 * (UnitPower("player",0) / UnitPowerMax("player",0))
				calculation.dmgM = calculation.dmgM * bonus
				calculation.masteryLast = mastery
				calculation.masteryBonus = bonus
			end
		elseif spec == 2 then
			if mastery > 0 and mastery ~= masteryLast then
				if (calculation.school == "Fire" or calculation.school == "Frostfire") then
					if calculation.spellName == "Flame Orb" then
						--local bonus = mastery * 0.01 * 2.8
						calculation.masteryLast = mastery
						--if Talents["Ignite"] then						
						--	calculation.extraCrit = Talents["Ignite"] * calculation.dmgM_dot * (1 + calculation.dmgM_dot_Add + bonus)
						--end					
					else
						local masteryBonus = calculation.masteryBonus
						if masteryBonus then
							calculation.dmgM_dot_Add = calculation.dmgM_dot_Add - masteryBonus
						end
						--Flashburn: Damage Multiplier to Fire DoTs - Additive 4.0.3
						local bonus = mastery * 0.01 * 2.8
						calculation.dmgM_dot_Add = calculation.dmgM_dot_Add + bonus
						calculation.masteryLast = mastery
						calculation.masteryBonus = bonus
						if Talents["Ignite"] then
							calculation.extraCrit = Talents["Ignite"] * calculation.dmgM_dot * (1 + calculation.dmgM_dot_Add)
						end
					end
				end
			end
		elseif spec == 3 then
			if mastery > 0 and mastery ~= masteryLast then
				if ActiveAuras["Frozen"] then
					local masteryBonus = calculation.masteryBonus
					if masteryBonus then
						calculation.dmgM = calculation.dmgM / masteryBonus
					end
					--Frostburn: Damage Multiplier against Frozen Targets
					local bonus = 1 + mastery * 0.01 * 2.5
					calculation.dmgM = calculation.dmgM * bonus
					calculation.masteryLast = mastery
					calculation.masteryBonus = bonus
				end
			end
		end
	end
	local ignite = GetSpellInfo(11119)
	self.Calculation["MAGE"] = function( calculation, ActiveAuras, Talents, spell, baseSpell )
		--General stats
		if IsSpellKnown(89744) then
			calculation.intM = calculation.intM * 1.05
		end
		--Set crits to 199.5%
		calculation.critM = calculation.critM + 0.495
		calculation.casterCrit = true
		--Specialization
		local spec = calculation.spec
		if spec == 1 then
			if calculation.school == "Arcane" then
				calculation.dmgM = calculation.dmgM * 1.25
			end
		elseif spec == 2 then
			if calculation.school == "Fire" or calculation.school == "Frostfire" then
				--Multiplicative - 4.03
				calculation.dmgM = calculation.dmgM * 1.25
			end
		elseif spec == 3 then
			if calculation.school == "Frost" or calculation.school == "Frostfire" then
				calculation.dmgM = calculation.dmgM * 1.25
				if calculation.spellName == "Frostbolt" then
					--TODO 4.0.6 - Additive or multiplicative?
					calculation.dmgM = calculation.dmgM * 1.15
				end
			end
		end
		--General bonuses
		if calculation.group == "Pet" then
			if Orc then
				calculation.dmgM = calculation.dmgM * 1.05
			end
		end
		if self:GetSetAmount( "T7" ) >= 4 then
			calculation.critM = calculation.critM + 0.025
		end
		if self:GetSetAmount( "T9" ) >= 2 then
			--BUG: Doesn't add currently
			--calculation.dmgM_Add = calculation.dmgM_Add + 0.05
		end
		if self.db.profile.ManaConsumables then
			--Mana Gem
			local managem = self:ScaleData(27.32, nil, nil, nil, true) / 120
			calculation.manaRegen = calculation.manaRegen + managem * ((self:GetSetAmount( "T7" ) >= 2) and 1.25 or 1)
		end
		if ActiveAuras["Mage Armor"] then
			calculation.manaRegen = calculation.manaRegen + 0.03 * UnitPowerMax("player", 0) / 5
		end
		if Talents["Torment the Weak"] then --Multiplicative - 3.3.3
			if ActiveAuras["Snare"] then
				calculation.dmgM = calculation.dmgM * (1 + Talents["Torment the Weak"])
			else
				--Snares that aren't handled actively, i.e. don't trigger updates
				for i = 1, #snareList do
					if UnitDebuff("target", snareList[i]) then
						calculation.dmgM = calculation.dmgM * (1 + Talents["Torment the Weak"])
						break
					end
				end
			end
		end
		if Talents["Molten Fury"] then --Multiplicative - 3.3.3
			if UnitHealth("target") ~= 0 and (UnitHealth("target") / UnitHealthMax("target")) < 0.35 then
				calculation.dmgM = calculation.dmgM * (1 + Talents["Molten Fury"])
			end
		end
		if Talents["Shatter"] and ActiveAuras["Frozen"] then
			calculation.critPerc = calculation.critPerc * (1 + Talents["Shatter"])
			if calculation.spellName == "Frostbolt" then
				calculation.dmgM = calculation.dmgM * (1 + 0.1 * Talents["Shatter"])
			end
		end
		if Talents["Ignite"] then
			calculation.extraCrit = Talents["Ignite"] * calculation.dmgM_dot * (1 + calculation.dmgM_dot_Add)
			calculation.extraChanceCrit = true
			calculation.extraTicks = 2
			calculation.extraName = ignite
		end
	end
--ABILITIES
	self.Calculation["Ice Lance"] = function( calculation, ActiveAuras )
		if ActiveAuras["Frozen"] then
			calculation.dmgM = calculation.dmgM * 2
		end
		--Glyph of Ice Lance 4.0
		if self:HasGlyph(56377) then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.05
		end
		if self:GetSetAmount("T11") >= 2 then
			calculation.critPerc = calculation.critPerc + 5
		end
	end
	self.Calculation["Frostfire Bolt"] = function( calculation, ActiveAuras, Talents, _, baseSpell )
		--Glyph of Frostfire 4.0
		if self:HasGlyph( 61205 ) then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.15
			calculation.hybridDotDmg = 0.03 * 0.5 * (calculation.minDam + calculation.maxDam)
			calculation.SPBonus_dot = 0.03 * calculation.SPBonus
			calculation.eDuration = 12
			calculation.sTicks = 3
			baseSpell.DotStacks = 3
		end
		if self:GetSetAmount("T9") >= 4 then
			calculation.critPerc = calculation.critPerc + 5
		end
		if self:GetSetAmount("PvP") >= 4 then
			 calculation.dmgM_Add = calculation.dmgM_Add + 0.05
		end
	end
	self.Calculation["Arcane Missiles"] = function( calculation, ActiveAuras, _, spell, baseSpell )
		--Glyph of Arcane Missiles 4.0
		if self:HasGlyph( 56363 ) then
			calculation.critPerc = calculation.critPerc + 5
		end
		if (self:GetSetAmount("T9") >= 4 or self:GetSetAmount("T11") >= 2) then
			calculation.critPerc = calculation.critPerc + 5
		end
	end
	self.Calculation["Fireball"] = function( calculation, _, _, spell )
		if self:GetSetAmount("T9") >= 4 then
			calculation.critPerc = calculation.critPerc + 5
		end
		if self:GetSetAmount("PvP") >= 4 then
			 calculation.dmgM_Add = calculation.dmgM_Add + 0.05
		end
		--Glyph of Fireball 4.0
		if self:HasGlyph( 56368 ) then
			calculation.critPerc = calculation.critPerc + 5
		end
	end
	self.Calculation["Frostbolt"] = function( calculation )
		--Glyph of Frostbolt 4.0 (additive - 3.3.3)
		if self:HasGlyph( 56370 ) then
			calculation.critPerc = calculation.critPerc + 5
		end
		if self:GetSetAmount("T9") >= 4 then
			calculation.critPerc = calculation.critPerc + 5
		end
		if self:GetSetAmount("PvP") >= 4 then
			 calculation.dmgM_Add = calculation.dmgM_Add + 0.05
		end
	end
	self.Calculation["Ice Barrier"] = function( calculation )
		--Glyph of Ice Barrier 4.0
		if self:HasGlyph( 63095 ) then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.3
		end
	end
	self.Calculation["Living Bomb"] = function( calculation )
		--Glyph of Living Bomb 4.0
		if self:HasGlyph( 89926 ) then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.03
		end
	end
	self.Calculation["Arcane Blast"] = function( calculation )
		if self:GetSetAmount("T9") >= 4 then
			calculation.critPerc = calculation.critPerc + 5
		end
		if self:GetSetAmount("PvP") >= 4 then
			 calculation.dmgM_Add = calculation.dmgM_Add + 0.05
		end
	end
	self.Calculation["Scorch"] = function( calculation )
		if self:GetSetAmount("PvP") >= 4 then
			 calculation.dmgM_Add = calculation.dmgM_Add + 0.05
		end
	end
	self.Calculation["Arcane Barrage"] = function( calculation )
		--Glyph of Arcane Barrage 4.0
		if self:HasGlyph( 63092 ) then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.04
		end
	end
	self.Calculation["Cone of Cold"] = function( calculation )
		--Glyph of Cone of Cold 4.0
		if self:HasGlyph( 56364 ) then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.25
		end
	end
	self.Calculation["Deep Freeze"] = function( calculation )
		--Glyph of Deep Freeze 4.0
		if self:HasGlyph( 63090 ) then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.2
		end
	end
	self.Calculation["Pyroblast"] = function( calculation )
		--Glyph of Pyroblast 4.0
		if self:HasGlyph( 56384 ) then
			calculation.critPerc = calculation.critPerc + 5
		end
		if self:GetSetAmount("T11") >= 2 then
			calculation.critPerc = calculation.critPerc + 5
		end
	end
	self.Calculation["Pyroblast!"] = self.Calculation["Pyroblast"]
	self.Calculation["Dragon's Breath"] = function( calculation )
		--Glyph of Dragon's Breath 4.0
		if self:HasGlyph( 56373 ) then
			calculation.cooldown = calculation.cooldown - 3
		end
	end
	self.Calculation["Mana Shield"] = function( calculation )
		--Glyph of Mana Shield 4.0
		if self:HasGlyph( 70937 ) then
			calculation.cooldown = calculation.cooldown - 2
		end
	end
	local fire_power_icon = "|T" .. select(3,GetSpellInfo(18459)) .. ":16:16:1:-1|t"
	self.Calculation["Flame Orb"] = function( calculation, _, Talents )
		if Talents["Fire Power"] then
			local avg, min, max = self:ScaleData(1.318, 0.164)
			calculation.extra = avg
			calculation.extraMin = min
			calculation.extraMax = max
			calculation.extraDamage = 0.193
			calculation.extraBonus = true
			calculation.extraCanCrit = true
			calculation.extraChance = Talents["Fire Power"]
			calculation.extraName = fire_power_icon
		end
	end
	self.Calculation["Waterbolt"] = function( calculation )
		calculation.SP = GetPetSpellBonusDamage()
	end
	self.Calculation["Freeze"] = function( calculation )
		calculation.SP = GetPetSpellBonusDamage()
	end
	--self.Calculation["Mirror Image"] = function( calculation )
	--	calculation.critPerc = calculation.critPerc - GetSpellCritChance(5) + 5
	--	calculation.critM = 0.5
	--end

--SETS
	self.SetBonuses["PvP"] = {
		--Gladiator's Regalia
		64928, 64929, 64930, 64931, 64932,
		--Relentless Gladiator's Regalia
		41947, 41954, 41960, 41966, 41972,		
		--Wrathful Gladiator's Regalia
		51463, 51464, 51465, 51466, 51467,
		--Bloodthirsty Gladiator's Regalia
		64853, 64854, 64855, 64856, 64857,
		--Vicious Gladiator's Regalia
		60463, 60464, 60465, 60466, 60467,
	}
	self.SetBonuses["T7"] = { 39491, 39492, 39493, 39494, 39495, 40415, 40416, 40417, 40418, 40419 }
	self.SetBonuses["T9"] = { 47748, 47749, 47750, 47751, 47752, 47773, 47774, 47775, 47776, 47777, 47753, 47754, 47755, 47756, 47757, 47762, 47761, 47760, 47759, 47758, 47772, 47771, 47770, 47769, 47768, 47763, 47764, 47765, 47766, 47767 }
	self.SetBonuses["T11"] = { 60243, 60244, 60245, 60246, 60247, 65209, 65210, 65211, 65212, 65213 }
--AURA
--Player
	--Mage Armor - 4.0
	self.PlayerAura[GetSpellInfo(6117)] = { ActiveAura = "Mage Armor", ID = 6117 }
	--Presence of Mind - 4.0
	self.PlayerAura[GetSpellInfo(12043)] = { Update = true }
	--Icy Veins - 4.0
	self.PlayerAura[GetSpellInfo(12472)] = { Mods = { ["haste"] = function(v) return v*1.2 end }, ID = 12472 }
	--Arcane Power - 4.0
	self.PlayerAura[GetSpellInfo(12042)] = { Value = 0.2, ID = 12042, ModType = "dmgM_Add", Mods = { function(calculation) calculation.manaCost = calculation.manaCost + calculation.baseCost * 0.1 end }, Not = { "Summon Water Elemental", "Mirror Image" } }
	--Hot Streak - 4.0
	self.PlayerAura[GetSpellInfo(48108)] = { Update = true, Spells = { "Pyroblast", "Pyroblast!" } }
	--Brain Freeze - 4.0
	self.PlayerAura[GetSpellInfo(57761)] = { Update = true, Spells = { "Fireball", "Frostfire Bolt" } }
	--Fingers of Frost - 4.1
	self.PlayerAura[GetSpellInfo(44544)] = { NoManual = true, ModType =
		function( calculation, ActiveAuras )
			if calculation.spellName == "Ice Lance" then
				calculation.dmgM = calculation.dmgM * 1.25
			end
			ActiveAuras["Frozen"] = 1
		end
	}
	--Invocation - 4.0
	self.PlayerAura[GetSpellInfo(87098)] = { School = "All", ID = 87098, ModType =
		function( calculation, _, Talents )
			if Talents["Invocation"] then
				calculation.dmgM = calculation.dmgM * (1 + Talents["Invocation"])
			end
		end
	}

--Target
	--Frost Nova - 4.0
	self.TargetAura[GetSpellInfo(122)] = { ActiveAura = "Frozen", ID = 122, Manual = GetSpellInfo(50635) }
	--Improved Cone of Cold - 4.0
	self.TargetAura[GetSpellInfo(83301)] = self.TargetAura[GetSpellInfo(122)]
	--Shattered Barrier - 4.0
	self.TargetAura[GetSpellInfo(83073)] = self.TargetAura[GetSpellInfo(122)]
	--Deep Freeze - 4.0
	self.TargetAura[GetSpellInfo(44572)] = self.TargetAura[GetSpellInfo(122)]
	--Ring of Frost - 4.0
	self.TargetAura[GetSpellInfo(82691)] = self.TargetAura[GetSpellInfo(122)]
	--Freeze - 4.0
	self.TargetAura[GetSpellInfo(33395)] = self.TargetAura[GetSpellInfo(122)]
--Snares (shows up as Slow in the DrDamage buff menu)
	--TODO 4.0: Check what we need to add to this list
	--Thunder Clap (Warrior Ability) - 4.0
	self.TargetAura[GetSpellInfo(6343)] = { ActiveAura = "Snare", Manual = GetSpellInfo(31589), ID = 31589 }
	--Piercing Chill (Frost Talent) - 4.0
	self.TargetAura[GetSpellInfo(83154)] = self.TargetAura[GetSpellInfo(6343)]
	--Infected Wounds (Druid Feral Talent) - 4.0
	self.TargetAura[GetSpellInfo(58179)] = self.TargetAura[GetSpellInfo(6343)]
	--Frost Fever (Death Knight Frost Ability) - 4.0
	self.TargetAura[GetSpellInfo(59921)] = self.TargetAura[GetSpellInfo(6343)]
	--Slow (Mage Arcane Talent) - 4.0
	self.TargetAura[GetSpellInfo(31589)] = self.TargetAura[GetSpellInfo(6343)]
	--Frostbolt (Mage Ability) - 4.0
	self.TargetAura[GetSpellInfo(116)] = self.TargetAura[GetSpellInfo(6343)]
	--Cone of Cold (Mage Ability) - 4.0
	self.TargetAura[GetSpellInfo(120)] = self.TargetAura[GetSpellInfo(6343)]
	--Blast Wave (Mage Fire Ability) - 4.0
	self.TargetAura[GetSpellInfo(11113)] = self.TargetAura[GetSpellInfo(6343)]
	--Chilled (Mage Frost Armor debuff, Improved Blizzard uses the same name but spellID of 12484) - 4.0
	self.TargetAura[GetSpellInfo(7321)] = self.TargetAura[GetSpellInfo(6343)]
	--Frostfire bolt - 4.0
	self.TargetAura[GetSpellInfo(44614)] = self.TargetAura[GetSpellInfo(6343)]
--Custom (Fix these for 4.0 Mirror Image/Water Elemental)
	--Moonkin Aura
	--self.PlayerAura[GetSpellInfo(24907)]["Not"] = "Mirror Image"
	--Elemental Oath
	--self.PlayerAura[GetSpellInfo(51466)]["Not"] = "Mirror Image"
	--Bloodlust
	--if self.PlayerAura[GetSpellInfo(2825)] then self.PlayerAura[GetSpellInfo(2825)]["ActiveAura"] = "Bloodlust"
	--Heroism
	--else self.PlayerAura[GetSpellInfo(32182)]["ActiveAura"] = "Bloodlust" end
	--Wrath of Air
	--self.PlayerAura[GetSpellInfo(3738)]["ActiveAura"] = "Wrath of Air"
--Custom
	--Arcane Blast - 4.0
	self.PlayerAura[GetSpellInfo(36032)] = { Spells = "Arcane Blast", Apps = 4, ID = 30451, ModType =
		function( calculation, _, _, index, apps )
			--Glyph of Arcane Blast - 4.0 (additive - 3.3.3)
			calculation.dmgM_Add = calculation.dmgM_Add + apps * (0.10 + (self:HasGlyph(62210) and 0.03 or 0))
			if not index then
				calculation.manaCost = calculation.manaCost + calculation.baseCost * apps * 1.5
			end
		end
	}

	self.spellInfo = {
	--FIRE
		[GetSpellInfo(133)] = {
					["Name"] = "Fireball",
					["ID"] = 133,
					["Data"] = { 1.091, 0.242, 1.124, ["ct_min"] = 1500, ["ct_max"] = 2500, ["c_scale"] = 0.88, },
					[0] = { School = "Fire", },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(2948)] = {
					["Name"] = "Scorch",
					["ID"] = 2948,
					["Data"] = { 0.781, 0.17, 0.512, },
					[0] = { School = "Fire", },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(2136)] = {
					["Name"] = "Fire Blast",
					["ID"] = 2136,
					["Data"] = { 1.113, 0.17, 0.429 },
					[0] = { School = "Fire", Cooldown = 8, },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(2120)] = {
					["Name"] = "Flamestrike",
					["ID"] = 2120,
					["Data"] = { 0.662, 0.202, 0.146, 0.103, 0, 0.061 },
					[0] = { School = "Fire", eDuration = 8, sTicks = 2, AoE = true, HybridAoE = true, },
					[1] = { 0, 0, hybridDotDmg = 0 },
		},
		[GetSpellInfo(44614)] = {
					["Name"] = "Frostfire Bolt",
					["ID"] = 44614,
					["Data"] = { 0.949, 0.242, 0.977, ["ct_min"] = 1500, ["ct_max"] = 2500, ["c_scale"] = 0.8 },
					[0] = { School = "Frostfire", Double = { "Frost", "Fire" }, },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(11366)] = {
					["Name"] = "Pyroblast",
					["ID"] = 11366,
					["Data"] = { 1.575, 0.238, 1.25, 0.235, 0, 0.087, ["ct_min"] = 2100, ["ct_max"] = 3500, ["c_scale"] = 0.88, },
					[0] = { School = "Fire", Hits_dot = 4, eDuration = 12, sTicks = 3, },
					[1] = { 0, 0, hybridDotDmg = 0 },
		},
		[GetSpellInfo(92315)] = {
					["Name"] = "Pyroblast!",
					["ID"] = 92315,
					--BUG?: Blizzard tooltip has a higher SP coefficient. Verify?
					["Data"] = { 1.575, 0.238, 1.305, 0.235, 0, 0.087, ["c_scale"] = 0.88, },
					[0] = { School = "Fire", Hits_dot = 4, eDuration = 12, sTicks = 3, },
					[1] = { 0, 0, hybridDotDmg = 0 },
		},		
		[GetSpellInfo(11113)] = {
					["Name"] = "Blast Wave",
					["ID"] = 11113,
					["Data"] = { 0.989, 0.164, 0.143, },
					[0] = { School = "Fire", Cooldown = 15, AoE = true, },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(31661)] = {
					["Name"] = "Dragon's Breath",
					["ID"] = 31661,
					["Data"] = { 1.378, 0.15, 0.193 },
					[0] = { School = "Fire", Cooldown = 20, AoE = true, },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(44457)] = {
					["Name"] = "Living Bomb",
					["ID"] = 44457,
					["Data"] = { 0.43, 0, 0.233, 0.43, 0, 0.233, ["c_scale"] = 0.88 },
					[0] = { School = "Fire", Hits_dot = 4, eDuration = 12, sTicks = 3, AoE = 3 },
					[1] = { 0, 0, hybridDotDmg = 0 },
		},
		--Combustion
		--TODO: Combustion completely different. Now combines all active DoTs into a new DoT
		[GetSpellInfo(11129)] = {
					["Name"] = "Combustion",
					["ID"] = 11129,
					["Data"] = { 1.113, 0.17, 0.429 },
					[0] = { School = "Fire", --[[eDuration = 10, sTicks = 1, Hits_dot = 4--]] },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(82731)] = {
					["Name"] = "Flame Orb",
					["ID"] = 82731,
					["Data"] = { 0.278, 0.25, 0.134 },
					[0] = { School = "Fire", eDot = true, Hits = 15, eDuration = 15, sTicks = 1, Cooldown = 60, NoDotHaste = true },
					[1] = { 0, 0 },
		},
		--FROST
		[GetSpellInfo(116)] = {
			-- Checked in 4.1
					["Name"] = "Frostbolt",
					["ID"] = 116,
					["Data"] = { 0.884, 0.242, 0.943, ["ct_min"] = 1500, ["ct_max"] = 2000, ["c_scale"] = 0.88 },
					[0] = { School = "Frost", },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(10)] = {
			-- Checked in 4.1
					["Name"] = "Blizzard",
					["ID"] = 10,
					["Data"] = { 0.542, 0, 0.162 },
					[0] = { School = "Frost", sTicks = 1, Hits = 8, Channeled = 8, AoE = true },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(120)] = {
					["Name"] = "Cone of Cold",
					["ID"] = 120,
					["Data"] = { 0.84, 0.09, 0.214 },
					[0] = { School = "Frost", Cooldown = 10, AoE = true, },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(122)] = {
					["Name"] = "Frost Nova",
					["ID"] = 122,
					["Data"] = { 0.424, 0.15, 0.193 },
					[0] = { School = "Frost", Cooldown = 25, AoE = true, },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(30455)] = {
					["Name"] = "Ice Lance",
					["ID"] = 30455,
					["Data"] = { 0.432, 0.242, 0.378, ["c_scale"] = 0.8 },
					[0] = { School = "Frost", },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(11426)] = {
			-- Checked in 4.1
					["Name"] = "Ice Barrier",
					["ID"] = 11426,
					["Data"] = { 8.601 },
					[0] = { School = { "Frost", "Absorb" }, SPBonus = 0.87, Cooldown = 30, NoCrits = true, NoGlobalMod = true, NoTargetAura = true, NoSchoolTalents = true, NoNext = true, NoDPS = true, NoDoom = true, Unresistable = true, NoDPM = true, BaseIncrease = true, },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(44572)] = {
					["Name"] = "Deep Freeze",
					["ID"] = 44572,
					["Data"] = { 1.392, 0.225, 2.058 },
					[0] = { School = "Frost", Cooldown = 30 },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(84721)] = {
					["Name"] = "Frostfire Orb",
					["ID"] = 84721,
					["Data"] = { 0.278, 0.25, 0.134 },
					[0] = { School = "Frostfire", Double = { "Frost", "Fire" }, Hits = 15, eDot = true, eDuration = 15, sTicks = 1 },
					[1] = { 0, 0 },
		},
		--[[
		[GetSpellInfo(31707)] = {
					["Name"] = "Waterbolt",
					["ID"] = 31707,
					["Data"] = { 1.075, 0.063, 0.46, ["ct_min"] = 1500, ["ct_max"] = 2500, ["c_scale"] = 0, ["c_scale_level"] = 50 },
					--["Data"] = { 0.405, 0.25, 0.833, ["ct_min"] = 1500, ["ct_max"] = 2500, ["c_scale"] = 0, ["c_scale_level"] = 50 },
					[0] = { School = { "Frost", "Pet" }, NoGlobalMod = true, NoManaCalc = true, NoNext = true, NoMPS = true, NoDPM = true, },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(33395)] = {
					["Name"] = "Freeze",
					["ID"] = 33395,
					["Data"] = { 0.41, 0.15, 0.029, ["c_scale"] = 0, ["c_scale_level"] = 50 },
					[0] = { School = { "Frost", "Pet" }, Cooldown = 25, NoGlobalMod = true, NoManaCalc = true, NoNext = true, NoMPS = true, NoDPM = true, AoE = true },
					[1] = { 0, 0 },
		},
		--]]
	--ARCANE
		[GetSpellInfo(5143)] = {
			-- Checked in 4.1
					["Name"] = "Arcane Missiles",
					["ID"] = 5143,
					["Data"] = { 0.432, 0, 0.278 },
					[0] = { School = "Arcane", Hits = 3, Channeled = 2.25, },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(1449)] = {
			-- Checked in 4.1
					["Name"] = "Arcane Explosion",
					["ID"] = 1449,
					["Data"] = { 0.368, 0.08, 0.186 },
					[0] = { School = "Arcane", AoE = true, },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(30451)] = {
					["Name"] = "Arcane Blast",
					["ID"] = 30451,
					["Data"] = { 2.035, 0.15, 1.06, ["c_scale"] = 0.485 },
					[0] = { School = "Arcane", },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(44425)] = {
			-- Checked in 4.1
					["Name"] = "Arcane Barrage",
					["ID"] = 44425,
					["Data"] = { 1.413, 0.2, 0.907, ["c_scale"] = 0.83 },
					[0] = { School = "Arcane", Cooldown = 4, },
					[1] = { 0, 0 },
		},
		[GetSpellInfo(1463)] = {
					["Name"] = "Mana Shield",
					["ID"] = 1463,
					["Data"] = { 1.585 },
					[0] = { School = { "Arcane", "Absorb" }, SPBonus = 0.807, Cooldown = 12, NoCrits = true, NoGlobalMod = true, NoTargetAura = true, NoSchoolTalents = true, NoDPS = true, NoNext = true, NoDPM = true, NoDoom = true, Unresistable = true, },
					[1] = { 0, 0, },
		},
		[GetSpellInfo(543)] = {
					["Name"] = "Mage Ward",
					["ID"] = 1463,
					["Data"] = { 2.324 },
					[0] = { School = { "Arcane", "Absorb" }, SPBonus = 0.807, Cooldown = 30, NoCrits = true, NoGlobalMod = true, NoTargetAura = true, NoSchoolTalents = true, NoDPS = true, NoNext = true, NoDPM = true, NoDoom = true, Unresistable = true },
					[1] = { 0, 0, },
		},
		--TODO: Mirror Image
		--[GetSpellInfo(55342)] = {
		--			["Name"] = "Mirror Image",
		--			[0] = { School = "Arcane", eDot = true, eDuration = 30, SPBonus = 3, Cooldown = 180, canCrit = true, NoSchoolTalents = true, NoDownrank = true, NoNext = true },
		--			[1] = { 4968, 5232, spellLevel = 80, },
		--},
	}
	self.talentInfo = {
	--ARCANE:
		--Torment the Weak (multiplicative - 3.3.3)
		[GetSpellInfo(29447)] = {	[1] = { Effect = 0.02, Spells = "Arcane", Not = "Absorb", ModType = "Torment the Weak" }, },
		--Invocation
		[GetSpellInfo(84722)] = {	[1] = { Effect = 0.05, Spells = "All", Not = "Absorb", ModType = "Invocation" }, },
		--Improved Arcane Missiles
		[GetSpellInfo(83513)] = {	[1] = { Effect = 1, Spells = "Arcane Missiles", ModType = "hits" },
									[2] = { Effect = 0.75, Spells = "Arcane Missiles", ModType = "castTime" }, },
		--Missile Barrage
		[GetSpellInfo(44404)] = {	[1] = { Effect = { -0.75, -1.25 }, Spells = "Arcane Missiles", ModType = "castTime" }, },
		--Improved Arcane Explosion
		[GetSpellInfo(90787)] = {	[1] = { Effect = -0.25, Spells = "Arcane Explosion", ModType = "castTime" }, },
	--FIRE:
		--Master of Elements
		[GetSpellInfo(29074)] = {	[1] = { Effect = 0.15, Spells = "All", ModType = "freeCrit", }, },
		--Improved Fire Blast
		[GetSpellInfo(11078)] = {	[1] = { Effect = 4, Spells = "Fire Blast", ModType = "critPerc", }, },
		--Ignite
		[GetSpellInfo(11119)] = {	[1] = { Effect = 0.08, Spells = { "Fire", "Frostfire" }, Not = "Flame Orb", ModType = "Ignite", }, },
		--Fire Power (multiplicative - 4.0.3)
		[GetSpellInfo(18459)] = {	[1] = { Effect = 0.01, Multiply = true, Spells = { "Fire", "Frostfire" }, },
									[2] = { Effect = { 0.33, 0.66, 1 }, Spells = "Flame Orb", ModType = "Fire Power" }, },
		--Molten Fury (multiplicative?)
		[GetSpellInfo(31679)] = {	[1] = { Effect = 0.04, Spells = "All", ModType = "Molten Fury", }, },
		--Critical Mass (additive - 4.0.3)
		[GetSpellInfo(11095)] = {	[1] = { Effect = 0.05, Spells = { "Living Bomb", "Flame Orb" }, }, },
	--FROST:
		--Shatter
		[GetSpellInfo(11170)] = {	[1] = { Effect = 1, Spells = "All", ModType = "Shatter" }, },
		--Ice Floes
		[GetSpellInfo(31670)] = {	[1] = { Effect = { -1.75, -3.5, 5 }, Spells = "Frost Nova", ModType = "cooldown" },
									[2] = { Effect = { -0.7, -1.4, -2 }, Spells = "Cone of Cold", ModType = "cooldown" }, },
	}
end