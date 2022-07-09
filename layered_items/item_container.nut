::mods_hookNewObject("items/item_container", function (o)
{
	foreach (layer in ::LayeredItems.ArmorLayerSprites)
	{
		this.m.Appearance[layer] <- "";
	}

	foreach (layer in ::LayeredItems.HelmetLayerSprites)
	{
		this.m.Appearance[layer] <- "";
	}
});
