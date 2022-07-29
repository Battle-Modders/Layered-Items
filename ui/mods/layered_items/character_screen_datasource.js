LayeredItems.CharacterScreenDatasource_notifyEventListener = CharacterScreenDatasource.prototype.notifyEventListener;
CharacterScreenDatasource.prototype.notifyEventListener = function ( _channel, _payload )
{
	if (_channel == ErrorCode.Key && ("layeredItemsActions" in _payload)) return this.LayeredItems_runStashActions(_payload.layeredItemsActions);
	return LayeredItems.CharacterScreenDatasource_notifyEventListener.call(this, _channel, _payload);
}

CharacterScreenDatasource.prototype.LayeredItems_runStashActions = function ( _actionsTable )
{
	if ("updateStashItems" in _actionsTable)
	{
		_actionsTable.updateStashItems.forEach(function (_itemInfo)
		{
			if (_itemInfo.remove) flag = CharacterScreenDatasourceIdentifier.Inventory.StashItemUpdated.Flag.Removed;
			else if (this.mStashList[_itemInfo.idx] === null) flag = CharacterScreenDatasourceIdentifier.Inventory.StashItemUpdated.Flag.Inserted;
			else flag = CharacterScreenDatasourceIdentifier.Inventory.StashItemUpdated.Flag.Updated;

			this.mStashList[_itemInfo.idx] = _itemInfo.item;
			this.notifyEventListener(CharacterScreenDatasourceIdentifier.Inventory.StashItemUpdated.Key, { item: _itemInfo.item, index: _itemInfo.idx, flag: flag });
		}, this);
	}

	if ("updateStashSize" in _actionsTable)
	{
		this.mStashSpaceUsed = _actionsTable.updateStashSize.stashSpaceUsed;
		this.mStashSpaceMax = _actionsTable.updateStashSize.stashSpaceMax;
		this.mInventoryModule.updateSlotsLabel();
	}

	if ("updateBrothers" in _actionsTable)
	{
		_actionsTable.updateBrothers.forEach(function (_brotherData)
		{
			this.updateBrother(_brotherData);
		}, this);
	}
}

CharacterScreenDatasource.prototype.LayeredItems_notifyBackendSplitLayerClicked = function (_itemIdx, _callback)
{
	SQ.call(this.mSQHandle, 'LayeredItems_onSplitLayeredItem', _itemIdx, _callback);
}

CharacterScreenDatasource.prototype.LayeredItems_notifyBackendLayerButtonClicked = function (_brotherId, _sourceItemId, _layer, _callback)
{
	SQ.call(this.mSQHandle, 'LayeredItems_onLayerButtonClicked', [_brotherId, _sourceItemId, _layer], _callback);
};

CharacterScreenDatasource.prototype.LayeredItems_notifyBackendVisionButtonClicked = function (_brotherId, _sourceItemId, _layer, _callback)
{
	SQ.call(this.mSQHandle, 'LayeredItems_onVisionButtonClicked', [_brotherId, _sourceItemId, _layer], _callback);
};
