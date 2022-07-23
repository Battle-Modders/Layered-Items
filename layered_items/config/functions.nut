::LayeredItems.getLayerFromType <- function( _type )
{
	return (log(_type) / log(2)).tointeger();
}

::LayeredItems.getTypeFromLayer <- function( _layer )
{
	return ::Math.pow(2, _layer).tointeger();
}

::LayeredItems.parseItemDef <- function( _defOrDefArray )
{
	local ret = ::MSU.Class.WeightedContainer();
	if (typeof _defOrDefArray == "table") _defOrDefArray = [[1, _defOrDefArray]];
	foreach (layeredDefPair in _defOrDefArray)
	{
		local layeredDef = {};
		foreach (key, value in layeredDefPair[1])
		{
			if (value.len() != 0) layeredDef[key] <- ::MSU.Class.WeightedContainer(value);
		}
		if (!("Base" in layeredDef)) throw "Layered item def needs a defined base";
		ret.add(layeredDef, layeredDefPair[0]);
	}
	return ret;
}

::LayeredItems.createItemFromDef <- function( _weightedContainerDef )
{
	local outfit = _weightedContainerDef.roll();
	local ret = ::new(outfit.Base.roll());
	foreach (key, value in outfit)
	{
		if (key == "Base") continue;
		local layer = value.roll();
		if (layer == null) continue;
		ret.LayeredItems_attachLayer(::new(layer), ::LayeredItems.Item[ret.LayeredItems_getBase()].LayerType[key]);
	}
	ret.m.LayeredItems.Fresh = true;
	return ret;
}

::LayeredItems.addLayeredItem <- function( _baseNameInItemContainer, _spriteName, _JSSlotName )
{
	::LayeredItems.Item[_baseNameInItemContainer] <- { // maybe make this into a class at some point?
		Layer = {},
		LayerType = {},
		Sprite = [],
		Name = [],
		JSCharacter = [],
		Description = [],
		Defs = {},
		SpriteName = _spriteName,
		JSSlotName = _JSSlotName,
		replaceVanillaItem = function( _scriptName )
		{
			return ::LayeredItems.createItemFromDef(this.Defs[_scriptName]);
		},
		setDef = function( _name, _defOrDefArray)
		{
			this.Defs[_name] <- ::LayeredItems.parseItemDef(_defOrDefArray);
		},
		setDefs = function( _defs )
		{
			foreach (string, def in _defs)
			{
				this.setDef(string, def);
			}
		}
	}
}

::LayeredItems.addLayerToItem <- function( _baseName, _layerName, _description, _JSCharacter )
{
	local idx = ::LayeredItems.Item[_baseName].Layer.len();
	::LayeredItems.Item[_baseName].Layer[_layerName] <- idx;
	::LayeredItems.Item[_baseName].LayerType[_layerName] <- ::LayeredItems.getTypeFromLayer(idx);
	::LayeredItems.Item[_baseName].Sprite.push("LayeredItems_" + _baseName + "_" + _layerName);
	::LayeredItems.Item[_baseName].Name.push(_layerName);
	::LayeredItems.Item[_baseName].JSCharacter.push(_JSCharacter);
	::LayeredItems.Item[_baseName].Description.push(_description);
}
