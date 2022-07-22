this.armor_layer <- this.inherit("scripts/items/armor/armor", {
	m = {},

	function create()
	{
		this.armor.create();
		this.m.LayeredItems.BaseSprite = "Armor";
		this.m.SlotType = ::Const.ItemSlot.Body;
	}

	function updateVariant() // need to do this or else armor.nut updateVariant fires on deserialize which breaks sprites and icons
	{
	}

	function onSerialize( _out )
	{
		this.armor.onSerialize(_out);
		this.LayeredItems_serializeLayer(_out);
	}

	function onDeserialize( _in )
	{
		this.armor.onDeserialize(_in);
		this.LayeredItems_deserializeLayer(_in);
	}
});
