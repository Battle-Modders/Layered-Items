::LayeredItems.hookLayeredArmor <- function( o )
{
	o.LayeredItems_getIcons <- function()
	{
		local ret = this.layered_item.LayeredItems_getIcons();
		foreach (layerName in ::LayeredItems.HelmetLayers)
		{
			if (!(layerName in this.m.LayeredItems_Layers)) continue;
			local icon = this.m.LayeredItems_Layers[layerName].getIcon()
			if (icon != null) ret.push(icon);
		}
		return ret;
		// used to stack layers icons
		// needs js hooks for assignItemToSlot in character_screen_paperdoll_module, character_screen_inventory_list_module
		// tactical_combat_result_screen_loot_panel and world_town_screen_shop_dialog_module.

		// also need handling for named layers
	}

	o.LayeredItems_getIconsLarge <- function()
	{
		local ret = this.layered_item.LayeredItems_getIconsLarge();
		foreach (layerName in ::LayeredItems.HelmetLayers)
		{
			if (!(layerName in this.m.LayeredItems_Layers)) continue;
			local icon = this.m.LayeredItems_Layers[layerName].getIconLarge()
			if (icon != null) ret.push(icon);
		}
		return ret;
	}
}
