LayeredItems.WorldTownScreenShopDialogModule_assignItemToSlot = WorldTownScreenShopDialogModule.prototype.assignItemToSlot;
WorldTownScreenShopDialogModule.prototype.assignItemToSlot = function(_owner, _slot, _item)
{
	var remove = !('id' in _item) || !('imagePath' in _item)
    if(!remove)
	{
		var itemData = _slot.data('item');
		itemData.layeredItems = _item.layeredItems;
		_slot.data('item', itemData);
	}
	var ret = LayeredItems.WorldTownScreenShopDialogModule_assignItemToSlot.call(this, _owner, _slot, _item)
	if (!remove) LayeredItems.assignListItemLayeredImage.call(_slot);
	return ret;
}

LayeredItems.WorldTownScreenShopDialogModule_removeItemFromSlot = WorldTownScreenShopDialogModule.prototype.removeItemFromSlot;
WorldTownScreenShopDialogModule.prototype.removeItemFromSlot = function(_slot)
{
	var itemData = _slot.data('item');
	itemData.layeredItems = null;
	_slot.data('item', itemData);
	var ret = LayeredItems.WorldTownScreenShopDialogModule_removeItemFromSlot.call(this, _slot);
	LayeredItems.assignListItemLayeredImage.call(_slot);
	return ret;
}
