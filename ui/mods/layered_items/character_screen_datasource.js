CharacterScreenDatasource.prototype.LayeredItems_notifyBackendLayerButtonClicked = function (_brotherId, _sourceItemId, _layer, _callback)
{
	SQ.call(this.mSQHandle, 'LayeredItems_onLayerButtonClicked', [_brotherId, _sourceItemId, _layer], _callback);
};

CharacterScreenDatasource.prototype.LayeredItems_notifyBackendVisionButtonClicked = function (_brotherId, _sourceItemId, _layer, _callback)
{
	SQ.call(this.mSQHandle, 'LayeredItems_onVisionButtonClicked', [_brotherId, _sourceItemId, _layer], _callback);
};
