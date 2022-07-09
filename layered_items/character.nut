// makes these layer sprites shake together with head/body when character takes damage

foreach (sprite in ::LayeredItems.Armor.Sprite)
{
	::Const.ShakeCharacterLayers[0].push(sprite);
	::Const.ShakeCharacterLayers[2].push(sprite);
}

foreach (sprite in ::LayeredItems.Helmet.Sprite)
{
	::Const.ShakeCharacterLayers[1].push(sprite);
	::Const.ShakeCharacterLayers[2].push(sprite);
}
