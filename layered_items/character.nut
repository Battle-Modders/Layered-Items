// makes these layer sprites shake together with head/body when character takes damage

foreach (layer in ::LayeredItems.ArmorLayers)
{
	::Const.ShakeCharacterLayers[0].push("LayeredItems_Armor_" + layer);
	::Const.ShakeCharacterLayers[2].push("LayeredItems_Armor_" + layer);
}

foreach (layer in ::LayeredItems.HelmetLayers)
{
	::Const.ShakeCharacterLayers[1].push("LayeredItems_Helmet_" + layer);
	::Const.ShakeCharacterLayers[2].push("LayeredItems_Helmet_" + layer);
}
