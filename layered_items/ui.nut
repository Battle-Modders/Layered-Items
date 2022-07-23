::LayeredItems.JSConnection <- ::new("scripts/mods/layered_items/layered_items_connection");
::MSU.UI.registerConnection(::LayeredItems.JSConnection);
::MSU.UI.addOnConnectCallback(function()
{
	local config = {};
	foreach (baseName, item in ::LayeredItems.Item)
	{
		config[item.JSSlotName] <- {
			layers = []
		};
		foreach (idx, layerName in item.Name)
		{
			config[item.JSSlotName].layers.push({
				jsCharacter = item.JSCharacter[idx],
			})
		}
	}
	::LayeredItems.JSConnection.loadConfig(config);
});
