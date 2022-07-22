::LayeredItems.setArmorDef <- function( _name, _layeredDefOrLayeredDefArray )
{
	::LayeredItems.Armor.Defs[_name] <- ::LayeredItems.parseItemDef(_layeredDefOrLayeredDefArray); // no merging
}

::LayeredItems.setArmorDefs <- function( _armorDefs )
{
	foreach (armorString, armorDef in _armorDefs)
	{
		::LayeredItems.setArmorDef(armorString, armorDef);
	}
}

::LayeredItems.parseItemDef <- function( _layeredDefOrLayeredDefArray )
{
	local ret = ::MSU.Class.WeightedContainer();
	if (typeof _layeredDefOrLayeredDefArray == "table") _layeredDefOrLayeredDefArray = [[1, _layeredDefOrLayeredDefArray]];
	foreach (layeredDefPair in _layeredDefOrLayeredDefArray)
	{
		local layeredDef = {};
		foreach (key, value in layeredDefPair[1])
		{
			if (value.len() != 0) layeredDef[key] <- ::MSU.Class.WeightedContainer(value);
		}
		if (!("Base" in layeredDef)) throw "Layered item def needs a defined base";
		ret.add(layeredDef, layeredDefPair[0]);
	}
	return ret;
}

::LayeredItems.newArmorItem <- function( _scriptName )
{
	return ::LayeredItems.createItemFromDef(::LayeredItems.Armor.Defs[_scriptName]);
}

::LayeredItems.createItemFromDef <- function( _weightedContainerDef )
{
	local outfit = _weightedContainerDef.roll();
	local ret = ::new(outfit.Base.roll());
	foreach (key, value in outfit)
	{
		if (key == "Base") continue;
		local layer = value.roll();
		if (layer == null) continue;
		ret.LayeredItems_attachLayer(::new(layer), ::LayeredItems[ret.LayeredItems_getBaseSprite()].LayerType[key]);
	}
	ret.m.LayeredItems.Fresh = true;
	return ret;
}

::LayeredItems.setArmorDefs({
	"scripts/items/armor/gambeson" : {
		Base = [
			[1, "scripts/items/layered_armor/layered_gambeson"]
		],
		Chain = [
			[1, "scripts/items/layered_armor/layers/chain_upgrade_layer"]
		],
	},
});

// ::LayeredArmor.setArmorDefs(
// {
// 	"scripts/items/armor/vanillaArmor1" : [
// 		::MSU.Class.WeightedContainer([
// 			[1, "scripts/items/layered_armor_cloth1s"]
// 		]), // 1/cloth (required not empty)
// 		::MSU.Class.WeightedContainer(), // 2/chain
// 		::MSU.Class.WeightedContainer(), // 3/plate
// 		::MSU.Class.WeightedContainer(), // 4/cloak
// 		::MSU.Class.WeightedContainer(), // 5/tabard
// 		::MSU.Class.WeightedContainer()  // 6/attachment
// 	],
// 	"scripts/items/armor/vanillaArmor2" : [
// 		[
// 			[1, "scripts/items/layered_armor_cloth1s"]
// 		],
// 		[],
// 		[],
// 		[],
// 		[],
// 		[],
// 	]
// 	"scripts/items/armor/vanillaArmor2" : [
// 		Cloth = [
// 			[1, "scripts/items/layered_armor_cloth1s"]
// 		],
// 		Chain = [],
// 		Plate = [],
// 		Cloak = [],
// 		Tabard = [],
// 		Attachment = [],
// 	]
// 	"scripts/items/armor/vanillaArmor1" : {
// 		Cloth = ::MSU.Class.WeightedContainer([
// 			[1, "scripts/items/layered_armor_cloth1s"]
// 		]),
// 		Chain = ::MSU.Class.WeightedContainer(),
// 		Plate = ::MSU.Class.WeightedContainer(),
// 		Cloak = ::MSU.Class.WeightedContainer(),
// 		Tabard = ::MSU.Class.WeightedContainer(),
// 		Attachment = ::MSU.Class.WeightedContainer(),
// 	}
// })
