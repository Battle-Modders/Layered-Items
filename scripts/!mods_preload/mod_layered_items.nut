::LayeredItems <- {
	ID = "mod_layered_items",
	Version = "0.1.0",
	Name = "Layered Items",
	rawNew = ::new,
	Armor = {
		Layer = {
			Chain = 0,
			Plate = 1,
			Cloak = 2,
			Tabard = 3,
			Attachment = 4
		},
		LayerType = {
			Chain = 1,
			Plate = 2,
			Cloak = 4,
			Tabard = 8,
			Attachment = 16
		},
		Sprite = [
			"LayeredItems_Armor_Chain",
			"LayeredItems_Armor_Plate",
			"LayeredItems_Armor_Cloak",
			"LayeredItems_Armor_Tabard",
			"LayeredItems_Armor_Attachment"
		],
		Name = [
			"Chain",
			"Plate",
			"Cloak",
			"Tabard",
			"Attachment"
		] // might wanna add a description array as well ?
		Defs = {}
		function addLayer( _name )
		{
			// should be filled in
		}
	}
	Helmet = {
		Layer = {
			Top = 0,
			Vanity = 1
		}
		LayerType = {
			Top = 1,
			Vanity = 2
		}
		Sprite = {
			Top = "LayeredItems_Helmet_Top",
			Vanity = "LayeredItems_Helmet_Vanity"
		}
		Name = [
			"Top",
			"Vanity",
		]
		function addLayer( _name )
		{
			// should be filled in
		}
	}
	function getLayerFromType( _type )
	{
		return (log(_type) / log(2)).tointeger();
	}
	function getTypeFromLayer( _layer )
	{
		return ::Math.pow(2, _layer).tointeger();
	}
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
	::mods_registerJS("layered_items/item.js");
	::mods_registerJS("layered_items/paperdoll_item.js");
	::mods_registerJS("layered_items/character_screen_datasource.js");
	::mods_registerJS("layered_items/character_screen_inventory_list_module.js");
	::mods_registerJS("layered_items/character_screen_paperdoll_module.js");
	::mods_registerJS("layered_items/tactical_combat_result_screen_loot_panel.js")
	::mods_registerJS("layered_items/world_town_screen_shop_dialog_module.js")
	::mods_registerCSS("layered_items/button.css");
	::mods_registerCSS("layered_items/character_screen_paperdoll_module.css");

	local new = ::new;
	::new = function( _scriptName )
	{
		if (_scriptName in ::LayeredItems.Armor.Defs)
		{
			local ret = ::LayeredItems.newArmorItem(_scriptName);
			return ret;
		}
		local ret = new(_scriptName);
		return ret;
	}
});
