this.armor_layer <- this.inherit("scripts/items/armor/armor", {
	m = {},

	function create()
	{
		this.armor.create();
		this.m.LayeredItems.BaseSprite = "Armor";
	}
});
