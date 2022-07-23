::mods_hookNewObject("items/item_container", function (o)
{
	foreach (item in ::LayeredItems.Item)
	{
		foreach (sprite in item.Sprite)
		{
			o.m.Appearance[sprite] <- "";
		}
	}

	local equip = o.equip;
	o.equip = function( _item )
	{
		if (_item.LayeredItems_isLayer())
		{
			local parentItem = this.m.Items[_item.getSlotType()][0]; // means we can't handle bag slots
			if (parentItem == null || !parentItem.LayeredItems_isLayered()) return false;

			foreach (type in _item.LayeredItems_getTypesArray())
			{
				if (parentItem.LayeredItems_hasAttachedType(type)) continue;

				if (_item.getContainer() != null)
				{
					_item.getContainer().unequip(_item);
				}

				parentItem.LayeredItems_attachLayer(_item, type);

				_item.setCurrentSlotType(_item.getSlotType());

				if (_item.getSlotType() == this.Const.ItemSlot.Bag)
				{
					_item.onPutIntoBag();
				}
				else
				{
					_item.onEquip();
				}

				this.m.Actor.getSkills().update();
				this.updateAppearance()
				return true;
			}
			return false;
		}
		else
		{
			return equip(_item);
		}
	}

	local unequip = o.unequip;
	o.unequip = function( _item )
	{
		if (_item != null && _item != -1 && _item.LayeredItems_isLayer())
		{
			if (_item.getCurrentSlotType() == ::Const.ItemSlot.None || _item.getCurrentSlotType() == ::Const.ItemSlot.Bag)
			{
				this.logWarning("Attempted to unequip item " + _item.getName() + ", but is not equipped");
				return false;
			}

			local parentItem = this.m.Items[_item.getSlotType()][0] // means we can't handle bag slots
			if (parentItem == null || !parentItem.LayeredItems_isLayered() || !parentItem.LayeredItems_hasAttachedLayer(_item)) return false;

			_item.onUnequip();
			_item.setCurrentSlotType(::Const.ItemSlot.None);
			parentItem.LayeredItems_detachLayer(_item);

			if (this.m.Actor != null && !this.m.Actor.isNull() && this.m.Actor.isAlive())
			{
				this.m.Actor.getSkills().update();
			}

			return true;
		}
		else
		{
			return unequip(_item);
		}
	}

	local getItemByInstanceID = o.getItemByInstanceID;
	o.getItemByInstanceID = function( _instanceID )
	{
		local ret = getItemByInstanceID(_instanceID);
		if (ret != null) return ret;
		for( local i = 0; i < this.Const.ItemSlot.COUNT; i = ++i )
		{
			for( local j = 0; j < this.Const.ItemSlotSpaces[i]; j = ++j )
			{
				if (this.m.Items[i][j] == null || this.m.Items[i][j] == -1 || !this.m.Items[i][j].LayeredItems_isLayered()) continue;
				foreach (layer in this.m.Items[i][j].LayeredItems_getLayers())
				{
					if (layer.getInstanceID() == _instanceID)
					{
						return layer;
					}
				}
			}
		}
		return null;
	}
});
