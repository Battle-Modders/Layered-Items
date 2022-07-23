LayeredItems.CharacterScreenPaperdollModule_assignItemToSlot = CharacterScreenPaperdollModule.prototype.assignItemToSlot;
CharacterScreenPaperdollModule.prototype.assignItemToSlot = function(_slot, _entityId, _item, _isBlocked)
{
	var ret = LayeredItems.CharacterScreenPaperdollModule_assignItemToSlot.call(this, _slot, _entityId, _item, _isBlocked);
	if (_item !== null && (CharacterScreenIdentifier.Item.Id in _item) && (CharacterScreenIdentifier.Item.ImagePath in _item)) // remove item
	{
		var itemData = _slot.Container.data('item');
		itemData.layeredItems = _item.layeredItems;
		_slot.Container.data('item', itemData);
		LayeredItems.assignPaperdollLayeredImage.call(_slot.Container, _isBlocked);
	}
	return ret;
}

LayeredItems.CharacterScreenPaperdollModule_removeItemFromSlot = CharacterScreenPaperdollModule.prototype.removeItemFromSlot;
CharacterScreenPaperdollModule.prototype.removeItemFromSlot = function(_slot)
{
	var ret = LayeredItems.CharacterScreenPaperdollModule_removeItemFromSlot.call(this, _slot);
	var itemData = _slot.Container.data('item');
	itemData.layeredItems = null;
	_slot.Container.data('item', itemData);
	LayeredItems.assignPaperdollLayeredImage.call(_slot.Container);
	return ret;
}

CharacterScreenPaperdollModule.prototype.LayeredItems_createLayerButtonForEquipmentSlot = function (_slot, _parentDiv, _layer)
{
	var self = this;
	var layout = $('<div class="l-layered-layer-button"/>');
	_parentDiv.append(layout);
	var button = layout.createTextButton(LayeredItems.Items[_slot.SlotType].layers[_layer].jsCharacter, function ()
	{
		var itemData = _slot.Container.data('item')
		self.mDataSource.LayeredItems_notifyBackendLayerButtonClicked(itemData.entityId, itemData.itemId, _layer, function (data)
		{
			if (data === undefined || data == null || typeof (data) !== 'object')
			{
				console.error('ERROR: Failed to drop paperdoll item. Invalid data result.');
				return;
			}

			// check if we have an error
			if (ErrorCode.Key in data)
			{
				self.mDataSource.notifyEventListener(ErrorCode.Key, data[ErrorCode.Key]);
			}
			else
			{
				if ('stashSpaceUsed' in data)
					self.mDataSource.mStashSpaceUsed = data.stashSpaceUsed;

				if ('stashSpaceMax' in data)
					self.mDataSource.mStashSpaceMax = data.stashSpaceMax;

				self.mDataSource.mInventoryModule.updateSlotsLabel();

				if (CharacterScreenIdentifier.QueryResult.Stash in data)
				{
					var stashData = data[CharacterScreenIdentifier.QueryResult.Stash];
					if (stashData !== null && jQuery.isArray(stashData))
					{
						self.mDataSource.updateStash(stashData);
					}
					else
					{
						console.error('ERROR: Failed to equip inventory item. Invalid stash data result.');
					}
				}

				if (CharacterScreenIdentifier.QueryResult.Brother in data)
				{
					var brotherData = data[CharacterScreenIdentifier.QueryResult.Brother];
					if (CharacterScreenIdentifier.Entity.Id in brotherData)
					{
						self.mDataSource.updateBrother(brotherData);
					}
					else
					{
						console.error('ERROR: Failed to equip inventory item. Invalid brother data result.');
					}
				}
			}
		});
	}, "layered-items-button layered-layer-button");
	button.removeClass('button');
	button.on('mouseup', function(_event)
	{
		var disabled = $(this).attr('disabled');
		if (disabled !== null && disabled !== 'disabled' && _event.button == 2)
		{
			var itemData = _slot.Container.data('item');
			self.mDataSource.LayeredItems_notifyBackendVisionButtonClicked(itemData.entityId, itemData.itemId, _layer, function (_data)
			{
				self.mDataSource.updateBrother(_data);
			});
		}
	})
}
LayeredItems.CharacterScreenPaperdollModule_createEquipmentSlot = CharacterScreenPaperdollModule.prototype.createEquipmentSlot;
CharacterScreenPaperdollModule.prototype.createEquipmentSlot = function (_slot, _parentDiv, _screenDiv)
{
	var ret = LayeredItems.CharacterScreenPaperdollModule_createEquipmentSlot.call(this, _slot, _parentDiv, _screenDiv);
	if (_slot.SlotType in LayeredItems.Items)
	{
		_slot.Layers = Array.apply(null, Array(LayeredItems.Items[_slot.SlotType].layers.length)).map(function () {});
		var equipmentSlot = _parentDiv.find('> .l-slot-container.' + _slot.ContainerClasses.replace(" ", ".")).filter(":last");
		var container = $('<div class="layer-container display-none"/>');
		equipmentSlot.prepend(container);
		for (var i = _slot.Layers.length - 1; i >= 0; --i)
		{
			this.LayeredItems_createLayerButtonForEquipmentSlot(_slot, container, i);
		}
	}
	return ret;
}
