LayeredItems.CharacterScreenInventoryListModule_assignItemToSlot = CharacterScreenInventoryListModule.prototype.assignItemToSlot;
CharacterScreenInventoryListModule.prototype.assignItemToSlot = function(_entityId, _owner, _slot, _item)
{
	var remove = !(CharacterScreenIdentifier.Item.Id in _item) && (CharacterScreenIdentifier.Item.ImagePath in _item)
	if (!remove)
	{
		var itemData = _slot.data('item');
		itemData.layeredItems = _item.layeredItems;
		_slot.data('item', itemData);
	}
	var ret = LayeredItems.CharacterScreenInventoryListModule_assignItemToSlot.call(this, _entityId, _owner, _slot, _item);
	if (!remove) LayeredItems.assignListItemLayeredImage.call(_slot);
	return ret;
}

LayeredItems.CharacterScreenInventoryListModule_removeItemFromSlot = CharacterScreenInventoryListModule.prototype.removeItemFromSlot;
CharacterScreenInventoryListModule.prototype.removeItemFromSlot = function(_slot)
{
	var itemData = _slot.data('item');
	itemData.layeredItems = null;
	_slot.data('item', itemData);
	var ret = LayeredItems.CharacterScreenInventoryListModule_removeItemFromSlot.call(this, _slot);
	LayeredItems.assignListItemLayeredImage.call(_slot);
	return ret;
}

LayeredItems.CharacterScreenInventoryListModule_createItemSlot = CharacterScreenInventoryListModule.prototype.createItemSlot;
CharacterScreenInventoryListModule.prototype.createItemSlot = function ( _withPriceLayer, _backgroundImage, _classes )
{
	var ret = LayeredItems.CharacterScreenInventoryListModule_createItemSlot.call(this, _withPriceLayer, _backgroundImage, _classes);
	var self = this;
	ret.bindFirst("mousedown", function(_event)
	{
		if (MSU.Keybinds.isMousebindPressed(LayeredItems.ID, "SplitLayeredItem", _event))
		{
			_event.stopImmediatePropagation();
			self.mDataSource.LayeredItems_notifyBackendSplitLayerClicked($(this).data('item').index, function (_data)
			{
				if (_data === null) return
				self.mDataSource.LayeredItems_runStashActions(_data);
			})
			return false;
		}
	});
	return ret;
}
