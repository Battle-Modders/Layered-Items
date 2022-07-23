::mods_hookNewObjectOnce("ui/screens/tooltip/tooltip_events", function (o)
{
	local onQueryUIItemTooltipData = o.onQueryUIItemTooltipData;
	o.onQueryUIItemTooltipData = function( _entityId, _itemId, _itemOwner )
	{
		if (_itemOwner == "layered-items.layer")
		{
			local entity = ::Tactical.getEntityByID(_entityId);
			local item = entity.getItems().getItemByInstanceID(_itemId);
			local ret = item.getTooltip();
			ret.push({
				id = 1,
				type = "hint",
				icon = "ui/icons/mouse_left_button.png",
				text = "Remove Layer"
			})
			return ret;
		}
		return onQueryUIItemTooltipData(_entityId, _itemId, _itemOwner);
	}
});
