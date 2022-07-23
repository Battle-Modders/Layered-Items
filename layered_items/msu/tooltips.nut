::LayeredItems.Mod.Tooltips.setTooltips({
	Layer = ::MSU.Class.CustomTooltip(function(_data)
	{
		local entity = ::Tactical.getEntityByID(_data.entityId);
		local parentItem = entity.getItems().getItemByInstanceID(_data.itemId);
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
	})
	Visible = {
		True = ::MSU.Class.BasicTooltip("Hide Layer", "Click to hide the layer"),
		False = ::MSU.Class.BasicTooltip("Show Layer", "Click to show the layer")
	}
});
