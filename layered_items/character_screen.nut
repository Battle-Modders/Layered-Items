::mods_hookNewObjectOnce("ui/screens/character/character_screen", function (o)
{
	local general_onEquipStashItem = o.general_onEquipStashItem;
	o.general_onEquipStashItem = function( _data ) // fully overwriting for now cuz it's a lot easier
	{
		local data = this.helper_queryStashItemData(_data);

		if ("error" in data)
		{
			return data;
		}

		local targetItems = this.helper_queryEquipmentTargetItems(data.inventory, data.sourceItem);
		local allowed = this.helper_isActionAllowed(data.entity, [
			data.sourceItem,
			targetItems.firstItem,
			targetItems.secondItem
		], false);

		if (allowed != null)
		{
			return allowed;
		}

		if (!this.Tactical.isActive() && data.sourceItem.isUsable())
		{
			if (data.sourceItem.onUse(data.inventory.getActor()))
			{
				data.stash.removeByIndex(data.sourceIndex);
				data.inventory.getActor().getSkills().update();
				return this.UIDataHelper.convertStashAndEntityToUIData(data.entity, null, false, this.m.InventoryFilter);
			}
			else
			{
				return this.helper_convertErrorToUIData(this.Const.CharacterScreen.ErrorCode.FailedToEquipStashItem);
			}
		}

		if (!data.stash.isResizable() && data.stash.getNumberOfEmptySlots() < targetItems.slotsNeeded - 1)
		{
			return this.helper_convertErrorToUIData(this.Const.CharacterScreen.ErrorCode.NotEnoughStashSpace);
		}

		if (targetItems.firstItem != null)
		{
			// added
			if (data.sourceItem.LayeredItems_isLayer() && targetItems.firstItem.LayeredItems_isLayered())
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

			// end added

			if (!targetItems.firstItem.isInBag() && !data.inventory.unequip(targetItems.firstItem) || targetItems.firstItem.isInBag() && !data.inventory.removeFromBag(targetItems.firstItem))
			{
				return this.helper_convertErrorToUIData(this.Const.CharacterScreen.ErrorCode.FailedToRemoveItemFromTargetSlot);
			}

			if (targetItems.secondItem != null)
			{
				if (data.inventory.unequip(targetItems.secondItem) == false)
				{
					data.inventory.equip(targetItems.firstItem);
					return this.helper_convertErrorToUIData(this.Const.CharacterScreen.ErrorCode.FailedToRemoveItemFromTargetSlot);
				}
			}
		}

		if (data.stash.removeByIndex(data.sourceIndex) == null)
		{
			if (targetItems != null && targetItems.firstItem != null)
			{
				data.inventory.equip(targetItems.firstItem);

				if (targetItems.secondItem != null)
				{
					data.inventory.equip(targetItems.secondItem);
				}
			}

			return this.helper_convertErrorToUIData(this.Const.CharacterScreen.ErrorCode.FailedToRemoveItemFromSourceSlot);
		}

		if (data.inventory.equip(data.sourceItem) == false)
		{
			data.stash.insert(data.sourceItem, data.sourceIndex);

			if (targetItems != null && targetItems.firstItem != null)
			{
				data.inventory.equip(targetItems.firstItem);

				if (targetItems.secondItem != null)
				{
					data.inventory.equip(targetItems.secondItem);
				}
			}

			return this.helper_convertErrorToUIData(this.Const.CharacterScreen.ErrorCode.FailedToEquipBagItem);
		}

		if (targetItems != null && targetItems.firstItem != null)
		{
			local firstItemIdx = data.sourceIndex;

			if (data.swapItem == true)
			{
				data.stash.insert(targetItems.firstItem, data.sourceIndex);
			}
			else
			{
				firstItemIdx = data.stash.add(targetItems.firstItem);

				if (firstItemIdx == null)
				{
					data.inventory.unequip(data.sourceItem);
					data.stash.insert(data.sourceItem, data.sourceIndex);
					data.inventory.equip(targetItems.firstItem);

					if (targetItems.secondItem != null)
					{
						data.inventory.equip(targetItems.secondItem);
					}

					return this.helper_convertErrorToUIData(this.Const.CharacterScreen.ErrorCode.FailedToPutItemIntoBag);
				}
			}

			local secondItemIdx = data.stash.add(targetItems.secondItem);

			if (targetItems.secondItem != null && secondItemIdx == null)
			{
				data.stash.removeByIndex(firstItemIdx);
				data.inventory.unequip(data.sourceItem);
				data.stash.insert(data.sourceItem, data.sourceIndex);
				data.inventory.equip(targetItems.firstItem);

				if (targetItems.secondItem != null)
				{
					data.inventory.equip(targetItems.secondItem);
				}

				return this.helper_convertErrorToUIData(this.Const.CharacterScreen.ErrorCode.FailedToPutItemIntoBag);
			}
		}

		data.sourceItem.playInventorySound(this.Const.Items.InventoryEventType.Equipped);
		this.helper_payForAction(data.entity, [
			data.sourceItem,
			targetItems.firstItem,
			targetItems.secondItem
		]);

		if (this.Tactical.isActive())
		{
			return this.UIDataHelper.convertStashAndEntityToUIData(data.entity, this.Tactical.TurnSequenceBar.getActiveEntity(), false, this.m.InventoryFilter);
		}
		else
		{
			return this.UIDataHelper.convertStashAndEntityToUIData(data.entity, null, false, this.m.InventoryFilter);
		}
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
