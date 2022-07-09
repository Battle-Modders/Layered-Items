LayeredItems.CharacterScreenPaperdollModule_assignItemToSlot = CharacterScreenPaperdollModule.prototype.assignItemToSlot;
CharacterScreenPaperdollModule.prototype.assignItemToSlot = function(_slot, _entityId, _item, _isBlocked)
{
	var ret = LayeredItems.CharacterScreenPaperdollModule_assignItemToSlot.call(this, _slot, _entityId, _item, _isBlocked);
	if (_item === null || !(CharacterScreenIdentifier.Item.Id in _item) || !(CharacterScreenIdentifier.Item.ImagePath in _item)) // remove item
	{
		_slot.Container.data('item').LayeredItems_Icons = null;
	}
	LayeredItems.assignPaperdollLayeredImage.call(_slot.Container, _isBlocked);
	return ret;
}
