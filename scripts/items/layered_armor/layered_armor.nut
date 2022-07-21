this.layered_armor <- this.inherit("scripts/items/armor/armor", {
	m = {},
	function create()
	{
		this.armor.create();
		this.m.LayeredItems.BaseSprite = "Armor";
	}

	function onSerialize( _out )
	{
		this.armor.onSerialize(_out);
		this.LayeredItems_serializeLayers(_out);
	}

	function onDeserialize( _in )
	{
		this.armor.onDeserialize(_in);
		this.LayeredItems_deserializeLayers(_in);
	}
});
