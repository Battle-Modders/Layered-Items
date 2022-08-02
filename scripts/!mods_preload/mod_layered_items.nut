::LayeredItems <- {
	ID = "mod_layered_items",
	Version = "0.1.0",
	Name = "Layered Items",
	Item = {} // Armor, helmet and other go in here
}

::mods_registerMod(::LayeredItems.ID, ::LayeredItems.Version, ::LayeredItems.Name);

::mods_queue(::LayeredItems.ID, "mod_msu", function()
{
	::LayeredItems.Mod <- ::MSU.Class.Mod(::LayeredItems.ID, ::LayeredItems.Version, ::LayeredItems.Name);

	::includeFiles(::IO.enumerateFiles("layered_items"))

	::mods_hookExactClass("items/layered_armor/layered_armor", function (o)
	{
		::LayeredItems.hookLayeredItem(o);
	});

	::mods_hookExactClass("items/layered_armor/layers/armor_layer", function (o)
	{
		::LayeredItems.hookLayer(o);
	});

	::mods_registerJS("layered_items/layered_items.js");
	::mods_registerJS("layered_items/assets.js");
	::mods_registerJS("layered_items/item.js");
	::mods_registerJS("layered_items/paperdoll_item.js");
	::mods_registerJS("layered_items/character_screen_datasource.js");
	::mods_registerJS("layered_items/character_screen_inventory_list_module.js");
	::mods_registerJS("layered_items/character_screen_paperdoll_module.js");
	::mods_registerJS("layered_items/tactical_combat_result_screen_loot_panel.js")
	::mods_registerJS("layered_items/world_town_screen_shop_dialog_module.js")
	::mods_registerCSS("layered_items/button.css");
	::mods_registerCSS("layered_items/item.css");
	::mods_registerCSS("layered_items/paperdoll_item.css");
	::mods_registerCSS("layered_items/character_screen_paperdoll_module.css");
	::mods_registerJS("layered_items/tooltip.js");

	local new = ::new; // big boi dangerous hook
	::new = function( _scriptName )
	{
		foreach (baseName, item in ::LayeredItems.Item)
		{
			if (_scriptName in ::LayeredItems.Item[baseName].Defs)
			{
				return ::LayeredItems.Item[baseName].replaceVanillaItem(_scriptName);
			}
		}
		return new(_scriptName);
	}
});
