if select(2, UnitClass("player")) ~= "DRUID" then return end
local GetSpellInfo = DrDamage.SafeGetSpellInfo
local GetCombatRatingBonus = GetCombatRatingBonus
local GetCritChance = GetCritChance
local GetShapeshiftForm = GetShapeshiftForm
local UnitExists = UnitExists
local UnitIsFriend = UnitIsFriend
local UnitIsUnit = UnitIsUnit
local UnitBuff = UnitBuff
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local math_floor = math.floor
local math_abs = math.abs
local math_min = math.min
local math_max = math.max
local select = select
local tonumber = tonumber
local IsSpellKnown = IsSpellKnown

--TODO: Attack Power gained from Vengeance does not increase Thorns damage

function DrDamage:PlayerData()
	--Health updates
	self.TargetHealth = { [1] = 0.5, [0.5] = GetSpellInfo(774), [2] = 0.8, [0.8] = GetSpellInfo(6785) }
	--Events
	local lastEnergy = 0
	local ferocious_bite = GetSpellInfo(22568)
	self.Calculation["UNIT_POWER"] = function()
		local energy = UnitPower("player",3)
		if (energy < 65) and (lastEnergy > 65 or math_abs(energy - lastEnergy) >= 20) or (energy >= 65 and lastEnergy < 65) then
			lastEnergy = energy
			self:UpdateAB(ferocious_bite)
		end
	end
	--Innervate
	local dreamstate_talent = GetSpellInfo(33597)
	self.ClassSpecials[GetSpellInfo(29166)] = function()
		return (0.2 + select(self.talents[dreamstate_talent] or 3,0.15,0.3,0)) * UnitPowerMax("player",0), nil, true
	end
--GENERAL
	self.Calculation["Stats"] = function( calculation, ActiveAuras, Talents, spell, baseSpell )
		local mastery = calculation.mastery
		local masteryLast = calculation.masteryLast
		local spec = calculation.spec
		if spec == 1 then
			if mastery > 0 and mastery ~= masteryLast then
				if ActiveAuras["Eclipse"] then
					--NOTE: Eclipse added in aura module if no mastery present
					local eclipse = 1.25 + ((self:GetSetAmount("T8 Moonkin" ) >= 2) and 0.07 or 0)
					calculation.dmgM = calculation.dmgM / (eclipse + (calculation.masteryBonus or 0))
					--Mastery: Total Eclipse
					local bonus = mastery * 0.01 * 2
					calculation.dmgM = calculation.dmgM * (eclipse + bonus)
					calculation.masteryLast = mastery
					calculation.masteryBonus = bonus
				end
			end
		elseif spec == 2 then
			if mastery > 0 and mastery ~= masteryLast then
				if baseSpell.Melee and (ActiveAuras["Cat Form"] or calculation.spellName == "Rake") and calculation.spellName ~= "Shred" then
					local masteryBonus = calculation.masteryBonus
					if masteryBonus then
						calculation.bleedBonus = calculation.bleedBonus / masteryBonus
					end
					local bonus = 1 + mastery * 0.01 * 3.13
					calculation.bleedBonus = calculation.bleedBonus * bonus
					calculation.masteryLast = mastery
					calculation.masteryBonus = bonus
				end
			end
		elseif spec == 3 then
			if mastery > 0 and mastery ~= masteryLast then
				if calculation.healingSpell then
					if baseSpell.DirectHeal or ActiveAuras["Harmony"] then
						local masteryBonus = calculation.masteryBonus
						if masteryBonus then
							calculation.dmgM = calculation.dmgM / masteryBonus
						end
						--Mastery: Harmony
						local bonus = 1 + mastery * 0.01 * 1.25
						calculation.dmgM = calculation.dmgM * bonus
						calculation.masteryLast = mastery
						calculation.masteryBonus = bonus
					end
				end
			end
		end
		if calculation.spi ~= 0 then
			if Talents["Balance of Power"] then
				--Increases your spell hit rating by an additional amount equal to 50/100% of your Spirit.
				local rating = calculation.spi * Talents["Balance of Power"]
				calculation.hitPerc = calculation.hitPerc + self:GetRating("Hit", rating, true)
			end
		end
		if calculation.agi ~= 0 then
			if Talents["Nurturing Instinct"] then	
				calculation.SP_mod = calculation.SP_mod + Talents["Nurturing Instinct"] * calculation.agi
			end
		end
	end
	local moonfury = { ["Wrath"] = true, ["Moonfire"] = true, ["Starfire"] = true, ["Starsurge"] = true, ["Insect Swarm"] = true, ["Starfall"] = true }
	self.Calculation["DRUID"] = function( calculation, ActiveAuras, Talents, spell, baseSpell )
		--Stat mods
		if Talents["Heart of the Wild"] and ActiveAuras["Cat Form"] then
			--While in Cat Form your attack power is increased by 3/7/10%.
			calculation.APM = calculation.APM * (1 + Talents["Heart of the Wild"])
		end
		--Specialization
		local spec = calculation.spec
		if spec == 1 then
			--TODO: Check specialization is active
			if IsSpellKnown(86530) then
				calculation.intM = calculation.intM * 1.05
			end
			if not calculation.healingSpell then
				if (calculation.school == "Nature" or calculation.school == "Arcane" or calculation.school == "Spellstorm") then
					--Passive: Moonfury
					calculation.dmgM = calculation.dmgM * 1.1
				end
				if moonfury[calculation.spellName] then
					calculation.critM = calculation.critM + 0.5
				end
			end
		elseif spec == 2 then
			--TODO: Check specialization is active
			if ActiveAuras["Cat Form"] and IsSpellKnown(86530) then
				calculation.agiM = calculation.agiM * 1.05
			end
			calculation.APM = calculation.APM * 1.25
		elseif spec == 3 then
			--TODO: Check specialization is active
			if IsSpellKnown(86530) then
				calculation.intM = calculation.intM * 1.05
			end
			if calculation.healingSpell then
				calculation.dmgM_Add = calculation.dmgM_Add + 0.25
			end
		end
		if calculation.healingSpell then
			--Glyph of Frenzied Regeneration 4.0 (multiplicative - 3.3.3)
			if ActiveAuras["Frenzied Regeneration"] and self:HasGlyph(54810) then
				calculation.dmgM = calculation.dmgM * 1.3
			end
			if ActiveAuras["Tree of Life"] then
				calculation.dmgM = calculation.dmgM * 1.15
			end
		else
			if ActiveAuras["Moonkin Form"] and (calculation.school == "Arcane" or calculation.school == "Nature" or calculation.school == "Spellstorm") then
				calculation.dmgM = calculation.dmgM * 1.1
			end
		end
		if Talents["Master Shapeshifter"] then
			local baseValue = self.BaseTalents["Master Shapeshifter"]
			local talentValue = Talents["Master Shapeshifter"]
			if calculation.healingSpell then
				if (GetShapeshiftForm() == 0 or ActiveAuras["Tree of Life"]) and calculation.spellName ~= "Lifebloom" then
					--Multiplicative - 3.3.3
					calculation.dmgM = calculation.dmgM * 1.04
				end
			else
				if calculation.school == "Physical" then
					if baseValue ~= talentValue then
						if ActiveAuras["Bear Form"] then
							calculation.dmgM = calculation.dmgM / (1 + baseValue * 0.04)
							calculation.dmgM = calculation.dmgM * (1 + talentValue * 0.04)
						elseif ActiveAuras["Cat Form"] and not baseSpell.SpellCrit then
							calculation.critPerc = calculation.critPerc + (talentValue - baseValue) * 4
						end
					end
				else
					if baseValue > 0 and ActiveAuras["Bear Form"] then
						calculation.dmgM = calculation.dmgM / 1.04
					end
					if talentValue > 0 and ActiveAuras["Moonkin Form"] then
						calculation.dmgM = calculation.dmgM * 1.04
					end
				end
			end
		end
	end
--ABILITIES
	local fury_swipes_icon = "|T" .. select(3,GetSpellInfo(48532)) .. ":16:16:1:1|t"
	self.Calculation["Attack"] = function( calculation, ActiveAuras, Talents )
		if Talents["Fury Swipes"] and (ActiveAuras["Cat Form"] or ActiveAuras["Bear Form"]) then
			calculation.requiresForm = 1
			calculation.extraDamage = 0
			calculation.extra_canCrit = true
			calculation.extraWeaponDamage = 3.1
			calculation.extraWeaponDamageM = true
			calculation.extraWeaponDamageChance = Talents["Fury Swipes"]
			calculation.extraName = fury_swipes_icon
		end
	end
	--local tol = GetSpellInfo(48371)
	self.Calculation["Lifebloom"] = function( calculation, ActiveAuras, Talents )
		if UnitIsUnit(calculation.target, "player") then
			if Talents["Master Shapeshifter"] and (GetShapeshiftForm() == 0 or ActiveAuras["Tree of Life"]) then
				calculation.dmgM = calculation.dmgM * 1.04
			end
		else
			if Talents["Master Shapeshifter"] and (GetShapeshiftForm() == 0 or ActiveAuras["Tree of Life"]) then
				calculation.dmgM_dot = calculation.dmgM_dot * 1.04
			end
			--if UnitBuff("target",tol) then
			--	calculation.dmgM_dd = calculation.dmgM_dd * 1.04
			--end
		end
		--Glyph of Lifebloom - 4.0
		if self:HasGlyph(54826) then
			calculation.critPerc = calculation.critPerc + 10
		end
		if self:GetSetAmount("T11 Resto") >= 2 then
			calculation.critPerc_dot = (calculation.critPerc_dot or 0) + 5
		end
	end
	self.Calculation["Entangling Roots"] = function( calculation, ActiveAuras )
		--Glyph of Entangling Roots - 4.0
		if self:HasGlyph(54760) then
			calculation.cooldown = calculation.cooldown + 5
		end
		if ActiveAuras["Tree of Life"] then
			calculation.dmgM = calculation.dmgM * 2
		end		
	end
	self.Calculation["Typhoon"] = function( calculation )
		--Glyph of Monsoon - 4.0
		if self:HasGlyph(63056) then
			calculation.cooldown = calculation.cooldown - 3
		end
	end
	self.Calculation["Nourish"] = function( calculation, ActiveAuras )
		--Nourish bonus if Rejuvenation, Regrowth, Lifebloom, Wild Growth or Tranquility are active on the target
		local hotCount = 0
		if ActiveAuras["Rejuvenation"] then hotCount = hotCount + 1 end
		if ActiveAuras["Regrowth"] then hotCount = hotCount + 1 end
		if ActiveAuras["Lifebloom"] then hotCount = hotCount + 1 end
		if ActiveAuras["Wild Growth"] then hotCount = hotCount + 1 end
		if ActiveAuras["Tranquility"] then hotCount = hotCount + 1 end
		if hotCount > 0 then
			local bonus = 0
			if self:GetSetAmount( "T7 Resto" ) >= 4 then
				bonus = bonus + 0.05 * hotCount
			end
			--Multiplicative - 3.3.3
			calculation.dmgM = calculation.dmgM * (1.2 + bonus)
		end
		if self:GetSetAmount("T9 Resto") >= 2 then
			calculation.critPerc = calculation.critPerc + 5
		end
	end
	self.Calculation["Swiftmend"] = function( calculation, ActiveAuras, Talents )
		if self:GetSetAmount("T8 Resto") >= 2 then
			--Additive/multiplicative?
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
		if Talents["Efflorescence"] then
			calculation.hybridDotDmg = Talents["Efflorescence"] * calculation.maxDam
			calculation.SPBonus_dot = Talents["Efflorescence"] * calculation.SPBonus
			calculation.eDuration = 7
			calculation.sTicks = 1
			calculation.aoe = 3
			calculation.hybridCanCrit = false
			if Talents["Master Shapeshifter"] and (GetShapeshiftForm() == 0 or ActiveAuras["Tree of Life"]) then
				calculation.dmgM_dot = calculation.dmgM_dot * 1.04
			end
		end
	end
	self.Calculation["Rejuvenation"] = function( calculation, ActiveAuras, Talents, spell )
		--Glyph of Rejuvenation - 4.0
		if self:HasGlyph(54754) then
			--Additive - 4.0
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
		if self:GetSetAmount("T8 Resto") >= 4 then
			--Benefits from ToL, MaSh, Emp. Rej. No benefits: Genesis, Imp. rej and GoN
			calculation.extra = calculation.dmgM * 0.5 * (spell[1] + calculation.SPBonus * calculation.SP)
			calculation.extraName = "4T8"
		end
		if self:GetSetAmount("T9 Resto") >= 4 then
			--Additive - 4.0
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
		if Talents["Gift of the Earthmother"] then
			calculation.eDot = false
			calculation.hybridDotDmg = calculation.maxDam
			calculation.SPBonus_dot = calculation.SPBonus
			calculation.dotToDD = Talents["Gift of the Earthmother"]
			calculation.bDmgM = calculation.hits * Talents["Gift of the Earthmother"] * calculation.bDmgM
			calculation.SPBonus = calculation.hits * Talents["Gift of the Earthmother"] * calculation.SPBonus
			calculation.hits = nil
		end
	end
	self.Calculation["Wild Growth"] = function( calculation, ActiveAuras )
		--Glyph of Wild Growth - 4.0
		if self:HasGlyph(62970) then
			calculation.aoe = calculation.aoe + 1
		end
		if self:GetSetAmount("T10 Resto") >= 2 then
			calculation.bDmgM = calculation.bDmgM * (79/70)
		end
		if ActiveAuras["Tree of Life"] then
			calculation.aoe = calculation.aoe + 2
		end
	end
	self.Calculation["Moonfire"] = function( calculation, _, Talents )
		--Glyph of Moonfire - 4.0 (additive - 3.3.3)
		if self:HasGlyph(54829) then
			calculation.dmgM_dot_Add = calculation.dmgM_dot_Add + 0.2
		end
		--if self:GetSetAmount("T9 Moonkin") > = 2 then
		--TODO SET BONUS: Old bonus allows moonfire dot to crit --> what's the new bonus?
		--end
		if self:GetSetAmount("T11 Moonkin") >= 2 then
			calculation.critPerc = calculation.critPerc + 5
		end
	end
	self.Calculation["Starfall"] = function( calculation )
		--Glyph of Focus - 4.0
		if self:HasGlyph(62080) then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
		--Glyph of Starfall - 4.0
		if self:HasGlyph(54828) then
			calculation.cooldown = calculation.cooldown - 30
		end
		if calculation.targets > 1 then
			calculation.hits = 20
		end
	end
	self.Calculation["Wrath"] = function( calculation, ActiveAuras )
		--Glyph of Wrath - 4.0 -- Multiplicative??
		if self:HasGlyph(54756) then
			calculation.dmgM = calculation.dmgM * 1.1
		end
		if self:GetSetAmount("T7 Moonkin") >= 4 then
			calculation.critPerc = calculation.critPerc + 5
		end
		if self:GetSetAmount("T9 Moonkin") >= 4 then
			--Additive - 3.3.3
			calculation.dmgM_Add = calculation.dmgM_Add + 0.04
		end
		if self:GetSetAmount("T10 Moonkin") >= 4 then
			calculation.extraCrit = 0.07
			calculation.extraChanceCrit = true
			calculation.extraTicks = 2
			calculation.extraName = "4T10"
		end
		if ActiveAuras["Tree of Life"] then
			calculation.dmgM = calculation.dmgM * 1.3
		end
	end
	self.Calculation["Starfire"] = function( calculation, ActiveAuras, Talents, spell )
		if self:GetSetAmount("T7 Moonkin") >= 4 then
			calculation.critPerc = calculation.critPerc + 5
		end
		if self:GetSetAmount("T9 Moonkin") >= 4 then
			--Additive - 3.3.3
			calculation.dmgM_Add = calculation.dmgM_Add + 0.04
		end
		if self:GetSetAmount("T10 Moonkin") >= 4 then
			calculation.extraCrit = 0.07
			calculation.extraChanceCrit = true
			calculation.extraTicks = 2
			calculation.extraName = "4T10"
		end
	end
	self.Calculation["Insect Swarm"] = function( calculation )
		--Glyph of Insect Swarm - 4.0 (additive - 3.3.3)
		if self:HasGlyph(54830) then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.3
		end
		if self:GetSetAmount("T7 Moonkin") >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
		if self:GetSetAmount("T11 Moonkin") >= 2 then
			calculation.critPerc = calculation.critPerc + 5
		end
	end
 	self.Calculation["Maul"] = function( calculation, ActiveAuras, Talents, spell )
		if Talents["Rend and Tear"] and (ActiveAuras["Bleeding"] or ActiveAuras["Lacerate"]) then
			--Multiplicative - 3.3.3
			calculation.dmgM = calculation.dmgM * (1 + Talents["Rend and Tear"])
		end
		--Glyph of Maul - 4.0
		if self:HasGlyph(54811) then
			if calculation.targets >= 2 then
				calculation.aoe = 2
				calculation.aoeM = 0.5
			end
		end
	end
	self.Calculation["Ferocious Bite"] = function( calculation, ActiveAuras, Talents )
		if Talents["Rend and Tear"] and (ActiveAuras["Bleeding"] or ActiveAuras["Lacerate"]) then
			calculation.critPerc = calculation.critPerc + Talents["Rend and Tear"]
		end
		if self:GetSetAmount( "T9 Feral" ) >= 4 then
			calculation.critPerc = calculation.critPerc + 5
		end
		local energy = math_min(35,UnitPower("player", 3) - calculation.actionCost)
		--Glyph of Ferocious Bite - 4.0
		if energy > 0 and not self:HasGlyph(67598) then
			calculation.dmgM = calculation.dmgM * (1 + energy/25)
			calculation.actionCost = calculation.actionCost + energy
		end
	end
	self.Calculation["Rip"] = function( calculation )
		--Glyph of Rip - 4.0 - Additive??
		if self:HasGlyph(54818) then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.15
		end
		if self:GetSetAmount( "T7 Feral" ) >= 2 then
			calculation.eDuration = calculation.eDuration + 4
		end
		if self:GetSetAmount( "T9 Feral" ) >= 4 then
			calculation.critPerc = calculation.critPerc + 5
		end
	end
	self.Calculation["Faerie Fire (Feral)"] = function( calculation, ActiveAuras )
		if not ActiveAuras["Bear Form"] then
			calculation.zero = true
		end
	end
	self.Calculation["Mangle (Bear)"] = function( calculation, ActiveAuras )
		if ActiveAuras["Berserk"] then
			calculation.aoe = 3
			calculation.cooldown = 0
		end
		--Glyph of Mangle 4.0 - (multiplicative with Savage Fury - 3.3.3)
		if self:HasGlyph(54813) then
			calculation.dmgM = calculation.dmgM * 1.1
		end
	end
	self.Calculation["Mangle (Cat)"] = function( calculation )
		--Glyph of Mangle 4.0 - (multiplicative with Savage Fury - 3.3.3)
		if self:HasGlyph(54813) then
			calculation.dmgM = calculation.dmgM * 1.1
		end
	end
	--[[
	self.Calculation["Force of Nature"] = function( calculation, ActiveAuras, Talents )
		--Crit: receives no bonus from crit rating or int. Depressed against higher level targets
		--Haste: receives no bonus from haste rating.
		--AP: receives no bonus from AP
		local spd = 1.7 / calculation.haste --1.8 / calculation.haste
		--Assume one second is wasted of the 30 second duration
		calculation.hits = 3 * math_floor((29/spd) + 0.5)
		calculation.APBonus = 0.635/ 14 * 1.7 --1/14 * 1.8
		local SP = calculation.SP
		calculation.AP = math_floor( 642 + 0.57 * SP + 0.5 )
		calculation.critPerc = calculation.critPerc - GetCritChance() + 6.5
		calculation.hitPerc = calculation.hitPerc - GetCombatRatingBonus(6) + 8 * GetCombatRatingBonus(8) / 17
		calculation.expertise = math_floor(26 * GetCombatRatingBonus(8)/17 + 0.5)
		--calculation.armorPen = 0
		calculation.minDam = calculation.minDam + 0.023 * SP
		calculation.maxDam = calculation.maxDam + 0.023 * SP
	end
	--]]
	self.Calculation["Lacerate"] = function( calculation )
		--Glyph of Lacerate - 4.0
		if self:HasGlyph(94382) then
			calculation.critPerc = calculation.critPerc + 5
		end
		if self:GetSetAmount("T7 Feral" ) >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.05
		end
		if self:GetSetAmount("T9 Feral" ) >= 2 then
			calculation.dmgM_Extra_Add = calculation.dmgM_Extra_Add + 0.05
		end
		if self:GetSetAmount("T10 Feral") >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.2
		end
		if self:GetSetAmount("T11 Feral") >= 2 then
			calculation.dmgM_Extra_Add = calculation.dmgM_Extra_Add + 0.1
		end
	end
	self.Calculation["Swipe (Bear)"] = function( calculation )
		if self:GetSetAmount("T10 Feral") >= 2 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.2
		end
	end
	self.Calculation["Rake"] = function( calculation )
		if self:GetSetAmount( "T9 Feral" ) >= 2 then
			calculation.E_eDuration = calculation.E_eDuration + 3
		end
		if self:GetSetAmount("T10 Feral") >= 4 then
			calculation.dmgM_Add = calculation.dmgM_Add + 0.1
		end
		if self:GetSetAmount("T11 Feral") >= 2 then
			calculation.dmgM_Extra_Add = calculation.dmgM_Extra_Add + 0.1
		end
	end
	self.Calculation["Shred"] = function( calculation, ActiveAuras, Talents, _, baseSpell )
		if Talents["Rend and Tear"] and (ActiveAuras["Bleeding"] or ActiveAuras["Lacerate"]) then
			--Multiplicative - 3.3.3
			calculation.dmgM = calculation.dmgM * (1 + Talents["Rend and Tear"])
		end
	end
	self.Calculation["Ravage"] = function( calculation, _, Talents )
		if Talents["Predatory Strikes"] and UnitHealth("target") ~=0 and (UnitHealth("target") / UnitHealthMax("target")) >= 0.80 then
			calculation.critPerc = calculation.critPerc + Talents["Predatory Strikes"]
		end
	end
	self.Calculation["Ravage!"] = self.Calculation["Ravage"]
	self.Calculation["Pulverize"] = function( calculation, ActiveAuras )
		--TODO: Verify
		local bonus = ActiveAuras["Lacerate"] or 0
		calculation.minDam = calculation.minDam * bonus
		calculation.maxDam = calculation.maxDam * bonus
	end
	self.Calculation["Thorns"] = function( calculation )
		if calculation.spec == 2 then
			calculation.APBonus = calculation.SPBonus
			calculation.SPBonus = 0
		end
	end	
--SETS
	self.SetBonuses["T7 Feral"] = { 40471, 40472, 40473, 40493, 40494, 39553, 39554, 39555, 39556, 39557 }
	self.SetBonuses["T7 Moonkin"] = { 40466, 40467, 40468, 40469, 40470, 39544, 39545, 39546, 39547, 39548 }
	self.SetBonuses["T7 Resto"] = { 40460, 40461, 40462, 40463, 40465, 39531, 39538, 39539, 39542, 39543 }
	self.SetBonuses["T8 Moonkin"] = { 46189, 46191, 46192, 46194, 45196, 45351, 45352, 45353, 45354, 46414 }
	self.SetBonuses["T8 Resto"] = { 46183, 46184, 46185, 46186, 46187, 45345, 45346, 45347, 45348, 45349 }
	self.SetBonuses["T9 Feral"] = { 48213, 48214, 48215, 48216, 48217, 48188, 48189, 48190, 48191, 48192, 48193, 48194, 48195, 48196, 48197, 48202, 48201, 48200, 48199, 48198, 48212, 48211, 48210, 48209, 48208, 48203, 48204, 48205, 48206, 48207 }
	self.SetBonuses["T9 Moonkin"] = { 48158, 48159, 48160, 48161, 48162, 48183, 48184, 48185, 48186, 48187, 48164, 48163, 48167, 48165, 48166, 48171, 48172, 48168, 48170, 48169, 48181, 48182, 48178, 48180, 48179, 48174, 48173, 48177, 48175, 48176 }
	self.SetBonuses["T9 Resto"] = { 48102, 48129, 48130, 48131, 48132, 48153, 48154, 48155, 48156, 48157, 48133, 48134, 48135, 48136, 48137, 48142, 48141, 48140, 48139, 48138, 48152, 48151, 48150, 48149, 48148, 48143, 48144, 48145, 48146, 48147 }
	self.SetBonuses["T10 Feral"] = { 50827, 50826, 50825, 50828, 50824, 51295, 51144, 51296, 51143, 51297, 51142, 51298, 51141, 51299, 51140 }
	self.SetBonuses["T10 Moonkin"] = { 50821, 50822, 50819, 50820, 50823, 51290, 51149, 51291, 51148, 51292, 51147, 51293, 51146, 51294, 51145 }
	self.SetBonuses["T10 Resto"] = { 50107, 50108, 50109, 50113, 50106, 51301, 51138, 51302, 51137, 51303, 51136, 51304, 51135, 51300, 51139 }
	self.SetBonuses["T11 Feral"] = { 60286, 60287, 60288, 60289, 60290, 65189, 65190, 65191, 65192, 65193 }
	self.SetBonuses["T11 Moonkin"] = { 60281, 60282, 60283, 60284, 60285, 65199, 65200, 65201, 65202, 65203 }
	self.SetBonuses["T11 Resto"] = { 60276, 60277, 60278, 60279, 60280, 65194, 65195, 65196, 65197, 65198 }
--AURA
--Player
	--Moonkin form - 4.0
	self.PlayerAura[GetSpellInfo(24858)] = { ActiveAura = "Moonkin Form", ID = 25868, NoManual = true }
	--Tree of Life - 4.0
	self.PlayerAura[GetSpellInfo(33891)] = { ActiveAura = "Tree of Life", ID = 33891, NoManual = true }
	--Cat Form - 4.0
	self.PlayerAura[GetSpellInfo(768)] = { ActiveAura = "Cat Form", ID = 768, NoManual = true }
	--Bear Form - 4.0
	self.PlayerAura[GetSpellInfo(5487)] = { ActiveAura = "Bear Form", ID = 5487, NoManual = true }
	--Lunar shower - 4.0 (Moonfire, Sunfire - needs spellIDs to get paired up correctly)
	self.PlayerAura[GetSpellInfo(81006)] = { Spells = { 8921, 93402 }, Apps = 3, Ranks = 3, ID = 81006, Value = 0.15, Multiply = true, ModType = "dmgM_dd", Mods = { ["manaCost"] = -0.1 } }
	--Fury of Stormrage - 4.0
	self.PlayerAura[GetSpellInfo(81093)] = { Update = true, Spells = "Starfire" }
	--Nature's Bounty
	self.PlayerAura[GetSpellInfo(96206)] = { Update = true, Spells = "Nourish" }
	--Rejuvenation - 4.0
	self.PlayerAura[GetSpellInfo(774)] = { Update = true, Spells = "Nourish", ID = 774 }
	--Regrowth - 4.0
	self.PlayerAura[GetSpellInfo(16561)] = { Update = true, Spells = "Nourish", ID = 16561 }
	--Lifebloom - 4.0
	self.PlayerAura[GetSpellInfo(33763)] = { Update = true, Spells = "Nourish", ID = 33763 }
	--Wild Growth - 4.0
	self.PlayerAura[GetSpellInfo(48438)] = { Update = true, Spells = "Nourish", ID = 48438 }
	--Tranquility - 4.0
	self.PlayerAura[GetSpellInfo(21791)] = { Update = true, Spells = "Nourish", ID = 21791 }
	--Frenzied Regeneration - 4.0
	self.PlayerAura[GetSpellInfo(22842)] = { School = "Healing", ActiveAura = "Frenzied Regeneration", ID = 22842 }
	--Elune's Wrath - 4.0 (4p T8 Moonkin)
	self.PlayerAura[GetSpellInfo(64823)] = { Update = true, Spells = "Starfire" }
	--Omen of Doom - 4.0 (2p proc from T10 Moonkin)
	self.PlayerAura[GetSpellInfo(70721)] = { School = { "Nature", "Arcane", "Spellstorm" }, Value = 0.15, ID = 70721, NoManual = true }
	--Astral Alignment - 4.0 (4p proc from T11 Moonkin)
	self.PlayerAura[GetSpellInfo(90164)] = { School = "All", Apps = 3, Value = 33, ModType = "critPerc", ID = 90164, NoManual = true }
	--Savage Roar 4.0
	self.PlayerAura[GetSpellInfo(52610)] = { School = "All", Melee = true, NoManual = true, ModType =
		function( calculation, _, _, index )
			if index then
				--Glyph of Savage Roar - 4.0
				calculation.wDmgM = calculation.wDmgM * (1.8 + (self:HasGlyph(63055) and 0.05 or 0))
				if calculation.spellName == "Attack" then
					calculation.dmgM = calculation.dmgM * (1.8 + (self:HasGlyph(63055) and 0.05 or 0))
				end
			end
		end
	}
	--Tiger's Fury 4.0 - (needs to be divided out of spell modifiers)
	self.PlayerAura[GetSpellInfo(5217)] = { School = "Damage Spells", Multiply = true, ModType = "dmgM_Physical", Value = 0.15, NoManual = true, }
	--Eclipse (Solar) 4.0
	self.PlayerAura[GetSpellInfo(48517)] = { School = { "Nature", "Spellstorm" }, ActiveAura = "Eclipse", ID = 48517, ModType =
		function( calculation, _, Talents )
			--TODO: Additive or multiplicative?
			calculation.dmgM = calculation.dmgM * (1.25 + ((self:GetSetAmount("T8 Moonkin" ) >= 2) and 0.07 or 0))
		end
	}
	--Eclipse (Lunar) 4.0
	self.PlayerAura[GetSpellInfo(48518)] = { School = { "Arcane", "Spellstorm" }, ActiveAura = "Eclipse", ID = 48518, ModType =
		function( calculation, _, Talents )
			--TODO: Additive or multiplicative?
			calculation.dmgM = calculation.dmgM * (1.25 + ((self:GetSetAmount("T8 Moonkin" ) >= 2) and 0.07 or 0))
		end
	}
	--Berserk 4.0
	self.PlayerAura[GetSpellInfo(50334)] = { ActiveAura = "Berserk", ID = 50334, ModType =
		function( calculation, _, _, index )
			if not index and calculation.requiresForm == 3 then
				calculation.actionCost = calculation.actionCost * 0.5
			end
		end
	}
	--Nature's Swiftness 4.1
	self.PlayerAura[GetSpellInfo(17116)] = { Spells = { "Nourish", "Healing Touch", "Regrowth" }, Value = 0.5, ID = 17116, NoManual = true }
	
--Target
	--Rejuvenation - 4.0
	self.TargetAura[GetSpellInfo(774)] = { School = "Healing", ActiveAura = "Rejuvenation", Index = true, SelfCastBuff = true, ID = 774 }
	--Regrowth - 4.0
	self.TargetAura[GetSpellInfo(16561)] = { School = "Healing", ActiveAura = "Regrowth", Index = true, SelfCastBuff = true, ID = 16561 }
	--Lifebloom - 4.0
	self.TargetAura[GetSpellInfo(33763)] = { School = "Healing", ActiveAura = "Lifebloom", SelfCastBuff = true, ID = 33763 }
	--Wild Growth - 4.0
	self.TargetAura[GetSpellInfo(48438)] = { School = "Healing", ActiveAura = "Wild Growth", SelfCastBuff = true, ID = 48438 }
	--Tranquility - 4.0
	self.TargetAura[GetSpellInfo(21791)] = { School = "Healing", ActiveAura = "Tranquility", SelfCastBuff = true, ID = 21791 }
	--Lacerate 4.0
	self.TargetAura[GetSpellInfo(33745)] = { Spells = { "Pulverize", "Shred", "Maul", "Ferocious Bite" }, ActiveAura = "Lacerate", Apps = 3, SelfCast = true, ID = 33745 }

--Bleed effects
	--Deep Wound - 4.0 (TODO: Verify this contains all important ones)
	self.TargetAura[GetSpellInfo(43104)] = 	{ ActiveAura = "Bleeding", Manual = "Bleeding", Spells = { "Shred", "Maul", "Ferocious Bite" }, ID = 59881 }
	--Pounce - 4.0
	self.TargetAura[GetSpellInfo(9005)] = 	self.TargetAura[GetSpellInfo(43104)]
	--Rip - 4.0
	self.TargetAura[GetSpellInfo(1079)] = 	self.TargetAura[GetSpellInfo(43104)]
	--Rake - 4.0
	self.TargetAura[GetSpellInfo(59881)] = 	self.TargetAura[GetSpellInfo(43104)]
	--Rend - 4.0
	self.TargetAura[GetSpellInfo(94009)] = 	self.TargetAura[GetSpellInfo(43104)]
	--Garrote - 4.0
	self.TargetAura[GetSpellInfo(703)] = 	self.TargetAura[GetSpellInfo(43104)]
	--Rupture - 4.0
	self.TargetAura[GetSpellInfo(1943)] = 	self.TargetAura[GetSpellInfo(43104)]
	--Piercing Shots - 4.0
	self.TargetAura[GetSpellInfo(53234)] = 	self.TargetAura[GetSpellInfo(43104)]

	local bear = GetSpellInfo(5487)
	local bear_rank = select(2,GetSpellInfo(33878))
	local cat = GetSpellInfo(768)
	local cat_rank = select(2,GetSpellInfo(33876))
	self.spellInfo = {
		[GetSpellInfo(5176)] = {
			["Name"] = "Wrath",
			["ID"] = 5176,
			["Data"] = { 0.896, 0.12, 0.714, ["ct_min"] = 1500, ["ct_max"] = 2500 },
			[0] = { School = "Nature", },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(16914)] = {
			["Name"] = "Hurricane",
			["ID"] = 16914,
			["Data"] = { 0.327, 0, 0.095 },
			[0] = { School = "Nature", Hits = 10, Channeled = 10, AoE = true, },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(5570)] = {
			["Name"] = "Insect Swarm",
			["ID"] = 5570,
			["Data"] = { 0.138, 0, 0.13 },
			[0] = { School = "Nature", Hits = 6, eDot = true, eDuration = 12, sTicks = 2, },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(8921)] = {
			["Name"] = "Moonfire",
			["ID"] = 8921,
			["Data"] = { 0.221, 0.2, 0.18, 0.095, 0, 0.18 },
			[0] = { School = "Arcane", Hits_dot = 6, eDuration = 12, sTicks = 2, },
			[1] = { 0, 0, hybridDotDmg = 0 },
		},
		[GetSpellInfo(93402)] = {
			--Sunfire
			["Name"] = "Moonfire",
			["ID"] = 93402,
			["Data"] = { 0.221, 0.2, 0.18, 0.095, 0, 0.18 },
			[0] = { School = "Nature", Hits_dot = 6, eDuration = 12, sTicks = 2, },
			[1] = { 0, 0, hybridDotDmg = 0 },
		},
		[GetSpellInfo(2912)] = {
			["Name"] = "Starfire",
			["ID"] = 2912,
			["Data"] = { 1.383, 0.22, 1, ["ct_min"] = 3500, ["ct_max"] = 3200 },
			[0] = { School = "Arcane", },
			[1] = { 0, 0, },
		},
		[GetSpellInfo(467)] = {
			["Name"] = "Thorns",
			["ID"] = 467,
			["Data"] = { 0.181, 0, 0.168 },
			[0] = { School = "Nature", NoCrits = true, NoDPM = true, NoDoom = true, NoDPS = true, NoCasts = true, NoHaste = true, NoMPS = true, NoNextDPS = true, Unresistable = true },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(50516)] = {
			["Name"] = "Typhoon",
			["ID"] = 50516,
			["Data"] = { 1.316, 0, 0.126 },
			[0] = { School = "Nature", Cooldown = 20, AoE = true, },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(48505)] = {
			["Name"] = "Starfall",
			["ID"] = 48505,
			["Data"] = { 0.404, 0.15, 0.247  },
			[0] = { School = "Arcane", Hits = 10, eDot = true, eDuration = 10, AoE = 2, NoPeriod = true, NoDotHaste = true },
			[1] = { 0, 0, },
		},
		[GetSpellInfo(88747)] = {
			["Name"] = "Wild Mushroom",
			["ID"] = 88747,
			["Data"] = { 0.9464, 0.19, 0.6032 },
			[0] = { School = "Nature", AoE = true },
			[1] = { 0, 0, },
		},
		[GetSpellInfo(78674)] = {
			["Name"] = "Starsurge",
			["ID"] = 78674,
			["Data"] = { 1.228, 0.32, 1.228 },
			[0] = { School = "Spellstorm", Double = { "Nature", "Arcane" }, Cooldown = 15 },
			[1] = { 0, 0, },
		},
		[GetSpellInfo(5185)] = {
			["Name"] = "Healing Touch",
			["ID"] = 5185,
			["Data"] = { 7.97, 0.166, 0.806, ["ct_min"] = 1500, ["ct_max"] = 3000  },
			[0] = { School = { "Nature", "Healing", }, },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(774)] = {
			["Name"] = "Rejuvenation",
			["ID"] = 774,
			["Data"] = { 1.325, 0, 0.134 },
			[0] = { School = { "Nature", "Healing", }, Hits = 4, Hits_dot = 4, eDot = true, eDuration = 12, sTicks = 3, },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(8936)] = {
			["Name"] = "Regrowth",
			["ID"] = 8936,
			["Data"] = { 3.628, 0.11, 0.2936, 0.366, 0, 0.0296 },
			[0] = { School = { "Nature", "Healing", }, Hits_dot = 3, eDuration = 6, sTicks = 2, },
			[1] = { 0, 0, hybridDotDmg = 0, },
		},
		[GetSpellInfo(740)] = {
			["Name"] = "Tranquility",
			["ID"] = 740,
			["Data"] = { 3.935, 0, 0.398, 0.348, 0.068  },
			[0] = { School = { "Nature", "Healing", }, Channeled = 8, Hits = 4, Hits_dot = 4, eDuration = 8, sTicks = 2, Cooldown = 480, AoE = 5, HybridAoE = true },
			[1] = { 0, 0, hybridDotDmg = 0 },
		},
		[GetSpellInfo(33763)] = {
			["Name"] = "Lifebloom",
			["ID"] = 33763,
			["Data"] = { 1.87292, 0, 0.284, 0.2314, 0, 0.0234 },
			[0] = { School = { "Nature", "Healing" }, Hits_dot = 10, eDuration = 10, sTicks = 1, DotStacks = 3, },
			[1] = { 0, 0, hybridDotDmg = 0, },
		},
		[GetSpellInfo(48438)] = {
			["Name"] = "Wild Growth",
			["ID"] = 48438,
			["Data"] = { 0.539, 0, 0.0546 },
			[0] = { School = { "Nature", "Healing" }, Hits = 7, eDot = true, eDuration = 7, sTicks = 1, Cooldown = 8, AoE = 5 },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(50464)] = {
			["Name"] = "Nourish",
			["ID"] = 50464,
			["Data"] = { 2.633, 0.15, 0.266 },
			[0] = { School = { "Nature", "Healing" }, },
			[1] = { 0, 0 },
		},
		[GetSpellInfo(18562)] = {
			["Name"] = "Swiftmend",
			["ID"] = 18562,
			["Data"] = { 5.3, 0, 0.536 },
			[0] = { School = { "Nature", "Healing" }, Cooldown = 15, HybridAoE = true, HybridAoE_Only = true },
			[1] = { 0, 0, },
		},
		--Feral
		[GetSpellInfo(16857)] = {
			["Name"] = "Faerie Fire (Feral)",
			["ID"] = 16857,
			--["Data"] = { , },
			[0] = { Melee = true, School = "Nature", SpellCrit = "Nature", SpellHit = true, APBonus = 0.108 },
			[1] = { 1 },
		},
		[GetSpellInfo(1082)] = {
			["Name"] = "Claw",
			["ID"] = 1082,
			["Data"] = { 0.72, ["weaponDamageM"] = true, ["weaponDamage"] = 0.77, ["PPL_start"] = 8, ["PPL"] = 1.084, },
			[0] = { Melee = true, requiresForm = 3, },
			[1] = { 0 },
		},
		[GetSpellInfo(1079)] = {
			["Name"] = "Rip",
			["ID"] = 1079,
			["Data"] = { 0.0576, ["perCombo"] = 0.163 },
			[0] = { Melee = true, APBonus = 0.0207, Hits = 8, ComboPoints = true, requiresForm = 3, eDot = true, eDuration = 16, Ticks = 2, Bleed = true },
			[1] = { 0, PerCombo = 0 },
		},
		[GetSpellInfo(5221)] = {
			["Name"] = "Shred",
			["ID"] = 5221,
			["Data"] = { 0.057, ["weaponDamageM"] = true, ["weaponDamage"] = 4.25, ["PPL_start"] = 46, ["PPL"] = 3.383 },
			[0] = { Melee = true, requiresForm = 3, Bleed = true, Armor = true },
			[1] = { 0 },
		},
		[GetSpellInfo(1822)] = {
			["Name"] = "Rake",
			["ID"] = 1822,
			["Data"] = { 0.057, ["extra"] = 0.057 },
			[0] = { Melee = true, APBonus = 0.0207, Hits_extra = 3, APBonus_extra = 0.378 / 3, E_eDuration = 9, E_Ticks = 3, E_canCrit = true, requiresForm = 3, Bleed = true, BleedExtra = true },
			[1] = { 0, Extra = 0 },
		},
		[GetSpellInfo(22568)] = {
			["Name"] = "Ferocious Bite",
			["ID"] = 22568,
			["Data"] = { 0.383, 0.74, --[[["APBonus"] = 0.109,--]] ["perCombo"] = 0.584, ["c_scale"] = 0.439 },
			[0] = { Melee = true, APBonus = 0.109, ComboPoints = true, requiresForm = 3 },
			[1] = { 0, 0, PerCombo = 0 },
		},
		[GetSpellInfo(6785)] = {
			["Name"] = "Ravage",
			["ID"] = 6785,
			["Data"] = { 0.057, ["weaponDamageM"] = true, ["weaponDamage"] = 6.25, ["PPL_start"] = 22, ["PPL"] = 5.949 },
			[0] = { Melee = true, requiresForm = 3 },
			[1] = { 0 },
		},
		[GetSpellInfo(81170)] = {
			["Name"] = "Ravage!",
			["ID"] = 81170,
			["Data"] = { 0.335, ["weaponDamageM"] = true, ["weaponDamage"] = 5.05, ["PPL_start"] = 22, ["PPL"] = 5.604 },
			[0] = { Melee = true, requiresForm = 3 },
			[1] = { 0 },
		},		
		[GetSpellInfo(9005)] = {
			["Name"] = "Pounce",
			["ID"] = 9005,
			["Data"] = { 0.396 },
			[0] = { Melee = true, APBonus = 0.03, Hits = 6, eDot = true, eDuration = 18, Ticks = 3, Bleed = true, requiresForm = 3, },
			[1] = { 0 },
		},
		--Swipe
		[GetSpellInfo(779)] = {
			[0] = function(rank)
				if rank then
					if rank == bear_rank then
						return self.spellInfo["Swipe (Bear)"][0], self.spellInfo["Swipe (Bear)"]
					elseif rank == cat_rank then
						return self.spellInfo["Swipe (Cat)"][0], self.spellInfo["Swipe (Cat)"]
					end
				end
				if UnitBuff("player", bear) then
					return self.spellInfo["Swipe (Bear)"][0], self.spellInfo["Swipe (Bear)"]
				elseif UnitBuff("player", cat) then
					return self.spellInfo["Swipe (Cat)"][0], self.spellInfo["Swipe (Cat)"]
				end
			end,
		},	
		["Swipe (Bear)"] = {
			["Name"] = "Swipe (Bear)",
			["ID"] = 779,
			["Data"] = { 0.942 },
			[0] = { Melee = true, APBonus = 0.123, requiresForm = 1, AoE = true, Cooldown = 3 },
			[1] = { 0 },
		},
		["Swipe (Cat)"] = {
			["Name"] = "Swipe (Cat)",
			["ID"] = 62078,
			["Data"] = { 0, ["weaponDamage"] = 4.15, ["PPL_start"] = 36, ["PPL"] = 4.210 },
			[0] = { Melee = true, requiresForm = 3, AoE = true },
			[1] = { 0 },
		},		
		--Mangle
		[GetSpellInfo(33878)] = {
			[0] = function(rank)
				if rank then
					if rank == bear_rank then
						return self.spellInfo["Mangle (Bear)"][0], self.spellInfo["Mangle (Bear)"]
					elseif rank == cat_rank then
						return self.spellInfo["Mangle (Cat)"][0], self.spellInfo["Mangle (Cat)"]
					end
				end
				if UnitBuff("player", bear) then
					return self.spellInfo["Mangle (Bear)"][0], self.spellInfo["Mangle (Bear)"]
				elseif UnitBuff("player", cat) then
					return self.spellInfo["Mangle (Cat)"][0], self.spellInfo["Mangle (Cat)"]
				end
			end,
		},
		["Mangle (Bear)"] = {
					["Name"] = "Mangle (Bear)",
					["ID"] = 33878,
					["Data"] = { 1.764, ["weaponDamageM"] = true, ["weaponDamage"] = 0.5, ["PPL_start"] = 10, ["PPL"] = 2.0,  },
					[0] = { Melee = true, requiresForm = 1, Cooldown = 6 },
					[1] = { 0 },
		},
		["Mangle (Cat)"] = {
					["Name"] = "Mangle (Cat)",
					["ID"] = 33876,
					["Data"] = { 0.32, ["weaponDamageM"] = true, ["weaponDamage"] = 2.85, ["PPL_start"] = 10, ["PPL"] = 3.643,  },
					[0] = { Melee = true, requiresForm = 3, },
					[1] = { 0 },
		},
		[GetSpellInfo(6807)] = {
					["Name"] = "Maul",
					["ID"] = 6807,
					--NOTE: Blizzard data tables have set a base damage scaler for some reason
					--["Data"] = { --[[0.521,--]] },
					[0] = { Melee = true, APBonus = 0.19, requiresForm = 1, Bleed = true, Armor = true, Cooldown = 3 },
					[1] = { 7 },
		},		
		--BUG: Blizzard tooltip values for base and combo are too low. Real values seem to be increased by about 155%. Check when Blizzard upates tooltip
		[GetSpellInfo(22570)] = {
					["Name"] = "Maim",
					["ID"] = 22570,
					["Data"] = { 0.115 --[[0.075--]], ["perCombo"] = 0.278 --[[0.179--]], },
					[0] = { Melee = true, WeaponDamage = 1.55, ComboPoints = true, requiresForm = 3, Cooldown = 10 },
					[1] = { 0, 0, PerCombo = 0 },
		},
		[GetSpellInfo(33745)] = {
					["Name"] = "Lacerate",
					["ID"] = 33745,
					["Data"] = { 3.657, ["extra"] = 0.07 },
					[0] = { Melee = true, APBonus = 0.0552, Hits_extra = 5, APBonus_extra = 0.0369, E_eDuration = 15, E_Ticks = 3, E_canCrit = true, BleedExtra = true, requiresForm = 1 },
					[1] = { 0, Extra = 0 },
		},
		[GetSpellInfo(77758)] = {
					["Name"] = "Thrash",
					["ID"] = 77758,
					["Data"] = { 1.056, 0.21, ["extra"] = 0.589 },
					[0] = { Melee = true, APBonus = 0.0982, Hits_extra = 3, APBonus_extra = 0.0167, E_eDuration = 6, E_Ticks = 2, E_canCrit = true, requiresForm = 1, Cooldown = 6, E_AoE = true },
					[1] = { 0, 0, Extra = 0 },
		},
		[GetSpellInfo(80313)] = {
					["Name"] = "Pulverize",
					["ID"] = 80313,
					["Data"] = { 2.743, ["weaponDamageM"] = true, ["weaponDamage"] = 0.6 },
					[0] = { Melee = true, requiresForm = 1, },
					[1] = { 0 },
		},
		--[[
		[GetSpellInfo(33831)] = {
					["Name"] = "Force of Nature",
					["ID"] = 33831,
					--["Data"] = { , , },
					[0] = { Melee = true, eDuration = 30, Cooldown = 180, Armor = true, Avoidable = true, NoGlobalMod = true, NoParry = true, Glancing = true, MeleeHaste = true, CustomHaste = true, NoNext = true },
					[1] = { 905 },
		},
		--]]
	}
	self.talentInfo = {
	--BALANCE:
		--Genesis (additive - 3.3.3)
		[GetSpellInfo(57810)] = {	[1] = { Effect = 0.02, Caster = true, Spells = { "Rejuvenation", "Wild Growth", "Tranquility", "Swiftmend" } },
									[2] = { Effect = 0.02, Caster = true, Spells = { "Lifebloom", "Regrowth" }, ModType = "dmgM_dot_Add" },
									[2] = { Effect = 2, Caster = true, Spells = { "Moonfire", "Insect Swarm" }, ModType = "eDuration" }, },
		--Balance of Power (multiplicative - 4.0?)
		[GetSpellInfo(33592)] = { 	[1] = { Effect = 0.01, Caster = true, Multiply = true, Spells = { "Nature", "Arcane", "Spellstorm" }, Not = "Healing", },
									[2] = { Effect = 0.5, Caster = true, Spells = "All", Not = "Healing", ModType = "Balance of Power" }, NoManual = true },
		--Gale Winds (additive?)
		[GetSpellInfo(48488)] = {	[1] = { Effect = 0.15, Caster = true, Spells = { "Hurricane", "Typhoon" }, }, },
		--Dreamstate
		[GetSpellInfo(33597)] = {	[1] = { Effect = 0.15, Caster = true, Spells = "Innervate", ModType = "Dreamstate" }, },
		--Sunfire
		--[GetSpellInfo(93401)] = {	[1] = { Effect = 1, Caster = true, Spells = "Moonfire", ModType = "Sunfire" }, },
		--Earth and Moon (multiplicative - 4.0?)
		[GetSpellInfo(48506)] = {	[1] = { Effect = 0.02, Caster = true, Spells = { "Nature", "Arcane", "Spellstorm" }, Not = "Healing", Multiply = true }, },

	--FERAL:
		--Predatory Strikes
		[GetSpellInfo(16972)] = { 	[1] = { Effect = 25, Melee = true, Spells = { "Ravage", "Ravage!" }, ModType = "Predatory Strikes" }, },
		--Fury Swipes
		[GetSpellInfo(80553)] = { 	[1] = { Effect = 0.05, Melee = true, Spells = "Attack", ModType = "Fury Swipes" }, },
		--Feral Aggression (additive?)
		[GetSpellInfo(16858)] = { 	[1] = { Effect = 0.05, Melee = true, Spells = "Ferocious Bite", }, },
		--Nurturing Instinct
		[GetSpellInfo(33872)] = { [1] = { Effect = 0.5, Caster = true, Spells = "Healing", ModType = "Nurturing Instinct" }, },
		--Endless Carnage
		[GetSpellInfo(80314)] = { 	[1] = { Effect = 3, Melee = true, Spells = "Rake", ModType = "E_eDuration" }, },
		--Rend and Tear (multiplicative - 3.3.3)
		[GetSpellInfo(48432)] = {	[1] = { Effect = { 0.07, 0.13, 0.20 }, Melee = true, Spells = { "Maul", "Shred" }, ModType = "Rend and Tear", },
									[1] = { Effect = { 8, 17, 25 }, Melee = true, Spells = "Ferocious Bite", ModType = "Rend and Tear", }, },
	--RESTORATION:
		--Blessing of the Grove (additive - 4.0)
		[GetSpellInfo(78785)] = { 	[1] = { Effect = 0.02, Caster = true, Spells = "Rejuvenation" },
									[2] = { Effect = 0.03, Caster = true, Spells = "Moonfire", ModType = "dmgM_dd" }, },
		--Heart of the Wild
		[GetSpellInfo(17003)] = { 	[1] = { Effect = { 0.03, 0.07, 0.1 }, Spells = "All", ModType = "Heart of the Wild" },
									[2] = { Effect = 0.02, Spells = "All", Multiply = true, ModType = "intM" }, NoManual = true, },
		--Master Shapeshifter
		[GetSpellInfo(48411)] = {	[1] = { Effect = 1, Spells = "All", ModType = "Master Shapeshifter", }, Manual = "Master Shapeshifter" },
		--Improved Rejuvenation (additive - 4.0)
		[GetSpellInfo(17111)] = { 	[1] = { Effect = 0.05, Caster = true, Spells = { "Rejuvenation", "Swiftmend" } }, },
		--Nature's Bounty
		[GetSpellInfo(17074)] = { 	[1] = { Effect = 20, Caster = true, Spells = "Regrowth", ModType = "critPerc" }, },
		--Empowered Touch (additive?)
		[GetSpellInfo(33879)] = { 	[1] = { Effect = 0.05, Caster = true, Spells = { "Healing Touch", "Nourish" }, }, 
									[2] = { Effect = 0.05, Caster = true, Spells = "Regrowth", ModType = "dmgM_dd_Add" }, },
		--Efflorescense
		[GetSpellInfo(34151)] = { 	[1] = { Effect = 0.28, Caster = true, Spells = "Swiftmend", ModType = "Efflorescence", }, },
		--Gift of the Earthmother (multiplicative - 4.0)
		[GetSpellInfo(51179)] = { 	[1] = { Effect = 0.05, Caster = true, Spells = "Lifebloom", Multiply = true, ModType = "dmgM_dd" },
									[2] = { Effect = 0.05, Caster = true, Spells = "Rejuvenation", ModType = "Gift of the Earthmother" }, },
		--Swift Rejuvenation
		[GetSpellInfo(33886)] = { 	[1] = { Effect = -0.5, Caster = true, Spells = "Rejuvenation", ModType = "castTime" }, },
	}
end