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
				type = "layered" // should be a const value automatically shared with JS
			};
		}
		else if (_item.LayeredItems_isLayer())
		{
			ret.layeredItems <- {
				visible = _item.LayeredItems_isVisible(),
				type = "layer"
			}
		}

		return ret;
	}
});