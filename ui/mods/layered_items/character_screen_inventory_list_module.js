LayeredItems.CharacterScreenInventoryListModule_assignItemToSlot = CharacterScreenInventoryListModule.prototype.assignItemToSlot;
CharacterScreenInventoryListModule.prototype.assignItemToSlot = function(_entityId, _owner, _slot, _item)
{
	var ret = LayeredItems.CharacterScreenInventoryListModule_assignItemToSlot.call(this, _entityId, _owner, _slot, _item);
	if ((CharacterScreenIdentifier.Item.Id in _item) && (CharacterScreenIdentifier.Item.ImagePath in _item)) // not remove item
	{
		LayeredItems.assignListItemLayeredImage.call(_slot);
	}
	return ret;
}

LayeredItems.CharacterScreenInventoryListModule_removeItemFromSlot = CharacterScreenInventoryListModule.prototype.removeItemFromSlot;
CharacterScreenInventoryListModule.prototype.removeItemFromSlot = function(_slot)
{
	LayeredItems.CharacterScreenInventoryListModule_removeItemFromSlot.call(this, _slot);
	_slot.data('item').LayeredItems_Icons = null;
	LayeredItems.assignListItemLayeredImage.call(_slot);
}
