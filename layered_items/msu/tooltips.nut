::LayeredItems.Mod.Tooltips.setTooltips({
	Layer = ::MSU.Class.CustomTooltip(function(_data)
	{
		local entity = ::Tactical.getEntityByID(_data.entityId);
		local parentItem = entity.getItems().getItemByInstanceID(_data.itemId);
		local item = parentItem.LayeredItems_getLayer(_data.layer);
		if (item != null)
		{
			return item.getTooltip();
		}
		else
		{
			return [
				{
					id = 1,
					type = "title",
					text = ::LayeredItems.Item[parentItem.LayeredItems_getBase()].Name[_data.layer]
				},
				{
					id = 2,
					type = "description",
					text = ::LayeredItems.Item[parentItem.LayeredItems_getBase()].Description[_data.layer]
				}
			]
		}
	})
});
