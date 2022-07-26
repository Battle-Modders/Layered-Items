this.layered_armor <- this.inherit("scripts/items/armor/armor", {
	m = {},
	function create()
	{
		this.armor.create();
		::LayeredItems.hookLayeredItem(this, "Armor");
	}

	function setUpgrade( _upgrade )
	{
		if (this.LayeredItems_isLayerBlocked(::LayeredItems.Item.Armor.Layer.Attachment)) return false;
		local currentUpgrade = this.LayeredItems_getLayer(::LayeredItems.Item.Armor.Layer.Attachment);
		local actor = this.getContainer() == null ? null : this.getContainer().getActor();
		if (currentUpgrade != null)
		{
			currentUpgrade.onUnequip();
			currentUpgrade.setCurrentSlotType(::Const.ItemSlot.None);
			local item = this.LayeredItems_detachLayerByType(::LayeredItems.Item.Armor.LayerType.Attachment)
			// needs work, should probably get added to stash or blocked if there aren't enough slots
		}
		local convertedItem = ::new("scripts/items/layered_armor/layers/vanilla_attachment");
		convertedItem.init(_upgrade);
		if (!this.LayeredItems_attachLayer(convertedItem)) return false;
		if (actor != null)
		{
			convertedItem.setCurrentSlotType(this.getSlotType());
			convertedItem.onEquip();
			this.updateAppearance();
		}
		return true;
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
