::mods_hookExactClass("items/armor_upgrades/armor_upgrade", function (o)
{
	local onUse = o.onUse;
	o.onUse = function( _actor, _item = null )
	{
		if (this.isUsed())
		{
			return false;
		}

		local armor = _item == null ? _actor.getItems().getItemAtSlot(::Const.ItemSlot.Body) : _item;
		if (armor != null && armor.LayeredItems_isLayered())
		{
			if (!armor.setUpgrade(this)) return false;
			::Sound.play("sounds/inventory/armor_upgrade_use_01.wav", ::Const.Sound.Volume.Inventory)
			return true;
		}
		return onUse(_actor, _item);
	}
});
