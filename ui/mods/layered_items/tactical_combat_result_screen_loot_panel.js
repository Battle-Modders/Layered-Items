LayeredItems.TacticalCombatResultScreenLootPanel_assignItemToSlot = TacticalCombatResultScreenLootPanel.prototype.assignItemToSlot;
TacticalCombatResultScreenLootPanel.prototype.assignItemToSlot = function(_owner, _slot, _item)
{
	var ret = LayeredItems.TacticalCombatResultScreenLootPanel_assignItemToSlot.call(this, _owner, _slot, _item);
	if ((TacticalCombatResultScreenIdentifier.Item.Id in _item) && (TacticalCombatResultScreenIdentifier.Item.ImagePath in _item)) // not remove
	{
		var itemData = _slot.data('item');
		itemData.layeredItems = _item.layeredItems;
		_slot.data('item', itemData);
		LayeredItems.assignListItemLayeredImage.call(_slot);
	}
	return ret;
}

LayeredItems.TacticalCombatResultScreenLootPanel_removeItemFromSlot = TacticalCombatResultScreenLootPanel.prototype.removeItemFromSlot;
TacticalCombatResultScreenLootPanel.prototype.removeItemFromSlot = function(_slot)
{
	var ret = LayeredItems.TacticalCombatResultScreenLootPanel_removeItemFromSlot.call(this, _slot);
	var itemData = _slot.data('item');
	itemData.layeredItems = null;
	_slot.data('item', itemData);
	LayeredItems.assignListItemLayeredImage.call(_slot);
	return ret;
}
