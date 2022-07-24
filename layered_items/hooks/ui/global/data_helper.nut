::mods_hookNewObjectOnce("ui/global/data_helper", function (o)
{
	local convertItemToUIData = o.convertItemToUIData;
	o.convertItemToUIData = function( _item, _forceSmallIcon, _owner = null )
	{
		local ret = convertItemToUIData(_item, _forceSmallIcon, _owner);
		if (ret == null) return;

		if (_item.LayeredItems_isLayered())
		{
			ret.layeredItems <- {
				layers = _item.LayeredItems_getUILayers(_forceSmallIcon, _owner),
				blocked = _item.LayeredItems_getBlockedArray(),
				type = "layered" // should be a const value automatically shared with JS
			};
		}
		else if (_item.LayeredItems_isLayer())
		{
			ret.layeredItems <- {
				visible = _item.LayeredItems_isVisible(),
				type = "layer",
				layer = ::LayeredItems.getLayerFromType(_item.LayeredItems_getType()),
				baseItem = ::LayeredItems.Item[_item.LayeredItems_getBase()].JSSlotName
			}
		}

		return ret;
	}
});
