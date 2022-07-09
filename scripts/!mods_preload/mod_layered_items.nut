::LayeredItems <- {
	ID = "mod_layered_items",
	Version = "0.1.0",
	Name = "Layered Items",
	rawNew = ::new,
	ArmorDefs = {},
	ArmorLayers = ["Chain", "Plate", "Cloak", "Tabard", "Attachment"],
	ArmorLayerSprites = null,
	function updateArmorLayerSprites()
	{
		this.ArmorLayerSprites = this.ArmorLayers.map(function(_layerName)
		{
			return "LayeredItems_Armor_" + _layerName;
		});
	}
	HelmetLayers = ["Top", "Vanity"];
	HelmetLayerSprites = null,
	function updateHelmetLayerSprites()
	{
		this.HelmetLayerSprites = this.HelmetLayers.map(function(_layerName)
		{
			return "LayeredItems_Helmet_", + _layerName;
		});
	}
	setArmorDef = function(_scriptName, _arrayOfArraysWeightedContainers)
	{
		this.ArmorDefs[_scriptName] <- _arrayOfArraysWeightedContainers;
	},
	setArmorDefs = function(_table)
	{
		foreach (key, value in _table)
		{
			this.setarmorDef(key, value);
		}
	}
}

::LayeredItems.updateHelmetLayerSprites();
::LayeredItems.updateArmorLayerSprites();

::mods_registerMod(::LayeredItems.ID, ::LayeredItems.Version, ::LayeredItems.Name);

::mods_queue(::LayeredItems.ID, "mod_msu", function()
{
	::LayeredItems.Mod <- ::MSU.Class.Mod(::LayeredItems.ID, ::LayeredItems.Version, ::LayeredItems.Name);

	::includeFiles(::IO.enumerateFiles("layered_items"))

	::mods_hookExactClass("scripts/items/layered_armor/layered_armor", function (o)
	{
		::LayeredItems.hookLayeredItem(o);
		::LayeredItems.hookLayeredArmor(o);
	});

	::mods_hookExactClass("scripts/items/layered_armors/layers/armor_layer", function (o)
	{
		::LayeredItems.hookLayer(o);
	});

	::mods_registerJS("layered_items/layered_items.js");
	::mods_registerJS("layered_items/items.js");
	::mods_registerJS("layered_items/paperdoll_item.js");
	::mods_registerJS("layered_items/character_screen_inventory_list_module.js");
	::mods_registerJS("layered_items/character_screen_paperdoll_module.js");
});
