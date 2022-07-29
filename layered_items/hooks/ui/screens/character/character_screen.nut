::mods_hookNewObjectOnce("ui/screens/character/character_screen", function (o)
{
	local helper_dropItemIntoStash = o.helper_dropItemIntoStash; // this should really be done JS side to prevent stutter but is very complex due to drag event handlers
	o.helper_dropItemIntoStash = function( _data )
	{
		if (_data.targetItemIdx != null && _data.targetItem != null && _data.targetItem.LayeredItems_isLayer())
		{
			return this.helper_convertErrorToUIData(this.Const.CharacterScreen.ErrorCode.FailedToEquipStashItem);
		}
		return helper_dropItemIntoStash(_data);
	}

	local general_onEquipStashItem = o.general_onEquipStashItem;
	o.general_onEquipStashItem = function( _data )
	{
		local data = this.helper_queryStashItemData(_data);
		if ("error" in data) return data;
		local targetItems = this.helper_queryEquipmentTargetItems(data.inventory, data.sourceItem);
		local allowed = this.helper_isActionAllowed(data.entity, [
			data.sourceItem,
			targetItems.firstItem,
			targetItems.secondItem
		], false);
		if (allowed != null) return allowed;

		if ((::Tactical.isActive() || !data.sourceItem.isUsable() || data.stash.isResizable() || !(data.stash.getNumberOfEmptySlots() < targetItems.slotsNeeded - 1)) && targetItems.firstItem != null && data.sourceItem.LayeredItems_isLayer() && targetItems.firstItem.LayeredItems_isLayered()) // this is very long but not one lining it makes it a huge pain
		{
			local lastLayer;
			foreach (type in data.sourceItem.LayeredItems_getTypesArray())
			{
				lastLayer = targetItems.firstItem.LayeredItems_getLayerContainer()[::LayeredItems.getLayerFromType(type)];
				if (lastLayer == null) break;
			}

			if (lastLayer != null) data.inventory.unequip(lastLayer);
			if (data.inventory.equip(data.sourceItem))
			{
				data.stash.removeByIndex(data.sourceIndex);
				data.sourceItem.playInventorySound(::Const.Items.InventoryEventType.Equipped);
				if (lastLayer != null) data.stash.insert(lastLayer, data.sourceIndex);

				return ::UIDataHelper.convertStashAndEntityToUIData(data.entity, null, false, this.m.InventoryFilter);
			}
			else
			{
				data.inventory.equip(lastLayer)
			}
		}
		return general_onEquipStashItem(_data)
	}

	o.LayeredItems_updateStashItem <- function( _actionTable, _item, _idx, _remove = false )
	{
		if (!("updateStashItems" in _actionTable)) _actionTable.updateStashItems <- [];
		_actionTable.updateStashItems.push({
			item = ::UIDataHelper.convertItemToUIData(_item, true),
			idx = _idx,
			remove = _remove
		});
	}

	o.LayeredItems_updateBrother <- function( _actionTable, _brother )
	{
		if (!("updateBrother" in _actionTable)) _actionTable.updateBrother <- [];
		_actionTable.updateBrother.push(::UIDataHelper.convertEntityToUIData(_brother));
	}

	o.LayeredItems_updateStashSize <- function( _actionTable )
	{
		_actionTable.updateStashSize <- {
			stashSpaceUsed = ::World.Assets.getStash().getNumberOfFilledSlots(),
			stashSpaceMax = ::World.Assets.getStash().getCapacity()
		};
	}

	o.LayeredItems_wrapActionTableInError <- function( _actionTable )
	{
		return {
			error = {
				layeredItemsActions = _actionTable
			}
		};
	}

	local general_onSwapInventoryItem = o.general_onSwapInventoryItem;
	o.general_onSwapInventoryItem = function( _data )
	{
		local data = this.helper_queryStashItemDataByIndex(_data[0], _data[1]);
		if (data.targetItem != null)
		{
			data.targetItem = data.targetItem.item;
			if (data.sourceItem.LayeredItems_isLayer() && data.targetItem.LayeredItems_isLayered() && ::LayeredItems.Mod.Keybinds.isKeybindPressed("MergeLayer"))
			{
				if (data.targetItem.LayeredItems_attachLayer(data.sourceItem))
				{
					data.stash.removeByIndex(data.sourceIndex);
					data.sourceItem.playInventorySound(::Const.Items.InventoryEventType.Equipped);
					local actionTable = {};
					this.LayeredItems_updateStashItem(actionTable, data.sourceItem, data.sourceIndex, true);
					this.LayeredItems_updateStashItem(actionTable, data.targetItem, data.targetIndex);
					this.LayeredItems_updateStashSize(actionTable);
					return this.LayeredItems_wrapActionTableInError(actionTable);
				}
			}
		}
		return general_onSwapInventoryItem(_data);
	}

	o.LayeredItems_onSplitLayeredItem <- function ( _itemIndex )
	{
		local item = ::World.Assets.getStash().getItemAtIndex(_itemIndex).item;
		if (item == null || !item.LayeredItems_isLayered()) return null;
		local layers = item.LayeredItems_getLayers();
		if (layers.len() > ::World.Assets.getStash().getNumberOfEmptySlots()) return null;
		local actionTable = {};
		foreach (layer in layers)
		{
			item.LayeredItems_detachLayer(layer);
			this.LayeredItems_updateStashItem(actionTable, layer, ::World.Assets.getStash().add(layer));
		}
		this.LayeredItems_updateStashItem(actionTable, item, _itemIndex);
		item.playInventorySound(::Const.Items.InventoryEventType.PlacedInStash);
		this.LayeredItems_updateStashSize(actionTable);
		return actionTable;
	}

	// _data = [_brotherId, _sourceItem, _layer]
	o.LayeredItems_onLayerButtonClicked <- function ( _data )
	{
		local brother = ::Tactical.getEntityByID(_data[0]);
		local items = brother.getItems();
		local parentItem = items.getItemByInstanceID(_data[1]);
		if (::World.Assets.getStash().hasEmptySlot() && parentItem.LayeredItems_hasAttachedType(::LayeredItems.getTypeFromLayer(_data[2])))
		{
			local removedLayer = parentItem.LayeredItems_getLayerContainer()[_data[2]]
			if (items.unequip(removedLayer))
			{
				::World.Assets.getStash().add(removedLayer);
				removedLayer.playInventorySound(::Const.Items.InventoryEventType.Equipped);
				return ::UIDataHelper.convertStashAndEntityToUIData(brother, null, false, this.m.InventoryFilter); // should be optimized as it is perceptibly laggy and we only need to update one slot and one stash idx
			}
			else
			{
				return ::Const.CharacterScreen.ErrorCode.FailedToRemoveItemFromSourceSlot;
			}
		}
		else
		{
			return ::Const.CharacterScreen.ErrorCode.FailedToEquipStashItem;
		}
	}

	o.LayeredItems_onVisionButtonClicked <- function( _data )
	{
		local brother = ::Tactical.getEntityByID(_data[0]);
		local items = brother.getItems();
		local parentItem = items.getItemByInstanceID(_data[1]);
		local myitem = parentItem.LayeredItems_getLayer(_data[2]);
		myitem.LayeredItems_setVisible(!myitem.LayeredItems_isVisible());
		return ::UIDataHelper.convertEntityToUIData(brother, null); // update the whole brother (could be optimized more but imo this is fine)
	}
});
