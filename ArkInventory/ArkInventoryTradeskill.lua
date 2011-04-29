local TradeskillTranslationData = { -- temporary table for item to spell translations.
-- see ArkInventoryCompanion.xls (sourced from wowhead and user feedback)

-- [itemid] = { }
-- if itemid not a number then it's not learnt from an item, eg achievement reward, trainer, etc
-- id = spell id


}


-- build pets and mounts array
local key = nil
for item, spell in pairs( TradeskillTranslationData ) do
	
	if type( item ) == "number" and type( spell.id ) == "number" then
		
		-- item to spell
		key = string.format( "item:%s", item )
		if not ArkInventory.Const.ItemSpellCrossReference[key] then
			ArkInventory.Const.ItemSpellCrossReference[key] = { }
		end
		ArkInventory.Const.ItemSpellCrossReference[key][string.format( "spell:%s", spell.id )] = true
		
		-- spell to item(s)
		key = string.format( "spell:%s", spell.id )
		if not ArkInventory.Const.ItemSpellCrossReference[key] then
			ArkInventory.Const.ItemSpellCrossReference[key] = { }
		end
		ArkInventory.Const.ItemSpellCrossReference[key][string.format( "item:%s", item )] = true
		
	end
	
end

wipe( TradeskillTranslationData )
TradeskillTranslationData = nil
