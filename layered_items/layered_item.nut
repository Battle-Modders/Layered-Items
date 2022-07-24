::LayeredItems.hookLayeredItem <- function( o )
{
	o.m.LayeredItems <- {
		Layers = [],
		Blocked = [], // not handled at all rn
		Base = "",
		Fresh = false // serialization stuffs
	}

	local create = o.create;
	o.create = function()
	{
		create();
		this.m.LayeredItems.Layers = array(::LayeredItems.Item[this.LayeredItems_getBase()].Layer.len());
		this.m.LayeredItems.Blocked = array(::LayeredItems.Item[this.LayeredItems_getBase()].Layer.len(), false);
	}

	o.LayeredItems_getLayers <- function()
	{
		return this.m.LayeredItems.Layers.filter(@(_idx, _layer) _layer != null);
	}

	o.LayeredItems_getLayerContainer <- function()
	{
		return this.m.LayeredItems.Layers;
	}

	o.LayeredItems_getLayer <- function( _layer )
	{
		return this.LayeredItems_getLayerContainer()[_layer];
	}

	o.LayeredItems_isLayerBlocked <- function( _layer )
	{
		return this.m.LayeredItems.Blocked[_layer];
	}

	o.LayeredItems_isTypeBlocked <- function( _type )
	{
		return this.LayeredItems_isLayerBlocked(::LayeredItems.getLayerFromType(_type));
	}

	o.LayeredItems_setLayerBlocked <- function( _layer, _blocked )
	{
		this.m.LayeredItems.Blocked[_layer] = _blocked;
	}

	o.LayeredItems_getBlockedArray <- function()
	{
		return this.m.LayeredItems.Blocked;
	}

	o.LayeredItems_getBase <- function()
	{
		return this.m.LayeredItems.Base;
	}

	// o.LayeredItems_returnTrueIfAnyTrue <- function( _function, _argsArray )
	// {
	// 	foreach (layer in this.m.LayeredItems.Layers)
	// 	{
	// 		vargv[0] = layer;
	// 		if (layer != null && layer[_function].acall(vargv) == true) return true;
	// 	}
	// 	return false;
	// }

	// local returnTrueIfAnyTrueFunctions = [
	// 	"isNamed"
	// ];

	// foreach (functionName in returnTrueIfAnyTrueFunctions)
	// {
	// 	local oldFunction = ::mods_getMember(o, functionName);
	//  local tempName = functionName;
	// 	o[functionName] <- function( ... )
	// 	{
	// 		vargv.insert(0, this)
	// 		if (oldFunction.acall(vargv) == true) return true;
	// 		return this.LayeredItems_returnTrueIfAnyTrue(tempName, vargv);
	// 	}
	// }

	o.LayeredItems_returnFalseIfAnyFalse <- function( _function, _argsArray )
	{
		foreach (layer in this.LayeredItems_getLayers())
		{
			vargv[0] = layer;
			if (layer[_function].acall(vargv) == false)
			{
				return false;
			}
		}
		return true;
	}

	local returnFalseIfAnyFalseFunctions = [
		"isBought",
		"isSold"
	];

	foreach (functionName in returnFalseIfAnyFalseFunctions)
	{
		local oldFunction = ::mods_getMember(o, functionName);
		local tempName = functionName;
		o[functionName] <- function( ... )
		{
			vargv.insert(0, this);
			if (oldFunction.bindenv(this).acall(vargv) == false) return false;
			return this.LayeredItems_returnFalseIfAnyFalse(tempName, vargv);
		}
	}

	o.LayeredItems_getAddedValue <- function( _function, _base, _argsArray ) // _argsArray assumes 'this' slot exists
	{
		foreach (layer in this.LayeredItems_getLayers())
		{
			_argsArray[0] = layer;
			_base += layer[_function].acall(_argsArray);
		}
		return _base;
	}

	local getCondition = ::mods_getMember(o, "getCondition"); //needed later
	local getConditionMax = ::mods_getMember(o, "getConditionMax"); //needed later

	local addedValueFunctions = [
		"getCondition",
		"getConditionMax",
		"getArmor",
		"getArmorMax",
		"getStaminaModifier",
		"getValue"
	]
	// getDescription?

	foreach (functionName in addedValueFunctions)
	{
		local tempName = functionName;
		local oldFunction = ::mods_getMember(o, tempName);
		o[tempName] <- function( ... )
		{
			vargv.insert(0, this)
			return this.LayeredItems_getAddedValue(tempName, oldFunction.bindenv(this).acall(vargv), vargv);
		}
	}

	o.LayeredItems_callOnFunction <- function( _function, _argsArray ) // _argsArray assumes 'this' slot exists
	{
		foreach (layer in this.LayeredItems_getLayers())
		{
			_argsArray[0] = layer;
			layer[_function].acall(_argsArray);
		}
	}

	local callOnFunctions = [
		"setBought",
		"setSold",
		"setCurrentSlotType",

		"removeSkill",
		"clearSkills",

		"onFactionChanged",
		"onEquip",
		"onUnequip",
		"onPutIntoBag",
		"onRemovedFromBag",
		"onPickedUp",
		"onDrop",
		"onBeforeDamageReceived",
		"onDamageDealt",
		"onShieldHit",
		"onUse",
		"onTotalArmorChanged",
		"onMovementFinished",
		"onCombatStarted",
		"onCombatFinished",
		"onActorDied",
		"onAddedToStash",
		"onRemovedFromStash",

	]

	foreach (functionName in callOnFunctions)
	{
		local oldFunction = ::mods_getMember(o, functionName);
		local tempName = functionName;
		o[functionName] <- function( ... )
		{
			vargv.insert(0, this);
			oldFunction.bindenv(this).acall(vargv);
			this.LayeredItems_callOnFunction(tempName, vargv);
		}
	}

	o.LayeredItems_getUILayers <- function( _forceSmallIcon, _owner )
	{
		return this.LayeredItems_getLayerContainer().map(@(_l) ::UIDataHelper.convertItemToUIData(_l, _forceSmallIcon, _owner));
	}

	o.LayeredItems_attachLayer <- function( _layer, _type = null )
	{
		if (_type == null)
		{
			foreach (type in _layer.LayeredItems_getTypesArray())
			{
				if (this.LayeredItems_hasAttachedType(type) || this.LayeredItems_isTypeBlocked(type)) continue;
				_type = type;
				break;
			}
			// error handling here TODO
		}
		if (_type == null) return false;
		local layer = ::LayeredItems.getLayerFromType(_type);
		if (this.LayeredItems_getLayerContainer()[layer] == null && !this.LayeredItems_isLayerBlocked(layer))
		{
			if (_layer.LayeredItems_attach(this, _type))
			{
				this.LayeredItems_getLayerContainer()[layer] = _layer;
				return true;
			}
		}
		return false;
	}

	o.LayeredItems_detachLayerByType <- function( _type )
	{
		local layer = ::LayeredItems.getLayerFromType(_type);
		local ret = this.LayeredItems_getLayerContainer()[layer];
		this.LayeredItems_getLayerContainer()[layer] = null;
		ret.LayeredItems_detach();
		return ret;
	}

	o.LayeredItems_detachLayer <- function( _layerObject ) // will throw if _layerObject is not attached
	{
		this.LayeredItems_detachLayerByType(_layerObject.LayeredItems_getCurrentType());
	}

	o.LayeredItems_hasAttachedLayer <- function( _layerObject )
	{
		foreach (layer in this.LayeredItems_getLayers())
		{
			if (layer == _layerObject) return true;
		}
		return false;
	}

	o.LayeredItems_hasAttachedType <- function( _type )
	{
		return this.LayeredItems_getLayerContainer()[::LayeredItems.getLayerFromType(_type)] != null;
	}

	local setCondition = ::mods_getMember(o, "setCondition");
	// _a
	o.setCondition <- function( _a )
	{
		if (_a > this.getConditionMax()) _a = this.getConditionMax();
		else if (_a < 0) _a = 0;

		local difference = this.getCondition() - _a;
		local layers = this.LayeredItems_getLayers();
		if (difference == 0) return;
		else if (difference < 0)
		{
			// bottom up
			local currentLayerDifference = ::Math.max(difference, getCondition.bindenv(this)() - getConditionMax.bindenv(this)());
			difference -= currentLayerDifference;
			setCondition.bindenv(this)(getCondition.bindenv(this)() - currentLayerDifference);

			for (local i = 0; i < layers.len(); ++i)
			{
				currentLayerDifference = ::Math.max(difference, layers[i].getCondition() - layers[i].getConditionMax());
				difference -= currentLayerDifference;
				layers[i].setCondition(layers[i].getCondition() - currentLayerDifference);
			}
		}
		else
		{
			local currentLayerDifference;
			// top down
			for (local i = layers.len() - 1; i >= 0; --i)
			{
				currentLayerDifference = ::Math.min(difference, layers[i].getCondition());
				difference -= currentLayerDifference;
				layers[i].setCondition(layers[i].getCondition() - currentLayerDifference);
			}

			currentLayerDifference = ::Math.min(difference, getCondition.bindenv(this)());
			difference -= currentLayerDifference;
			setCondition.bindenv(this)(getCondition.bindenv(this)() - currentLayerDifference);
		}
		if (difference != 0) throw "Difference was not 0"
	}

	o.getTooltip <- function()
	{
		local description = this.getDescription();
		foreach (layer in this.LayeredItems_getLayers())
		{
			description += " " + layer.getDescription();
		}

		local result = [
			{
				id = 1,
				type = "title",
				text = this.getName()
			},
			{
				id = 2,
				type = "description",
				text = description
			},
			{
				id = 66,
				type = "text",
				text = this.getValueString()
			}
		];

		if (this.getIconLarge() != null)
		{
			result.push({
				id = 3,
				type = "image",
				image = this.getIconLarge(),
				isLarge = true
			});
		}
		else
		{
			result.push({
				id = 3,
				type = "image",
				image = this.getIcon()
			});
		}

		result.push({
			id = 4,
			type = "progressbar",
			icon = "ui/icons/armor_body.png",
			value = this.getCondition(),
			valueMax = this.getConditionMax(),
			text = "" + this.getArmor() + " / " + this.getArmorMax() + "",
			style = "armor-body-slim"
		});

		if (this.getStaminaModifier() < 0)
		{
			result.push({
				id = 5,
				type = "text",
				icon = "ui/icons/fatigue.png",
				text = "Maximum Fatigue [color=" + this.Const.UI.Color.NegativeValue + "]" + this.getStaminaModifier() + "[/color]"
			});
		}

		local layerTooltips = {
			id = 6,
			type = "layer",
			data = []
		}
		foreach (layer in this.LayeredItems_getLayers())
		{
			layer.LayeredItems_addLayerTooltip(layerTooltips.data)
		}
		result.push(layerTooltips);
		return result;
	}

	o.setArmor <- function( _a )
	{
		this.setCondition(_a);
	}

	o.updateAppearance <- function() // <1ms
	{
		if (this.getContainer() == null || !this.isEquipped() || !this.m.ShowOnCharacter) return;

		local appearance = this.getContainer().getAppearance();
		if (this.getCondition() / this.getConditionMax() <= ::Const.Combat.ShowDamagedArmorThreshold && this.m.SpriteDamaged != null)
		{
			appearance[this.LayeredItems_getBase()] = this.m.SpriteDamaged;
		}
		else if (this.m.Sprite != null)
		{
			appearance[this.LayeredItems_getBase()] = this.m.Sprite;
		}

		foreach (layer in this.LayeredItems_getLayers())
		{
			layer.updateAppearance();
		}
		this.getContainer().updateAppearance();
	}
	// Dumb overwrites below cuz Raps doesn't use set/getCondition -_- maybe we should fix that in MSU?

	// _damage, _fatalityType, _attacker
	o.onDamageReceived <- function( _damage, _fatalityType, _attacker )
	{
		this.item.onDamageReceived(_damage, _fatalityType, _attacker);

		local originalDamage = _damage;

		foreach (layer in this.LayeredItems_getLayers())
		{
			_damage = layer.onDamageReceived(_damage, _fatalityType, _attacker);
		}

		if (this.getCondition() == 0) return;

		this.setCondition(::Math.max(0, this.getCondition() - _damage) * 1.0);

		if (this.getCondition() == 0 && !this.m.IsIndestructible)
		{
			::Tactical.EventLog.logEx(::Const.UI.getColorizedEntityName(this.getContainer().getActor()) + "\'s " + this.getName() + " is hit for [b]" + ::Math.floor(originalDamage) + "[/b] damage and has been destroyed!");

			if (_attacker != null && _attacker.isPlayerControlled() && !this.getContainer().getActor().isAlliedWithPlayer())
			{
				::Tactical.Entities.addArmorParts(this.getArmorMax());
			}
		}
		else
		{
			::Tactical.EventLog.logEx(::Const.UI.getColorizedEntityName(this.getContainer().getActor()) + "\'s " + this.getName() + " is hit for [b]" + ::Math.floor(originalDamage) + "[/b] damage");
		}

		this.updateAppearance()
	}

	o.isAmountShown <- function()
	{
		return this.getCondition() != this.getConditionMax();
	}

	o.getAmountString <- function()
	{
		return "" + ::Math.floor(this.getCondition() / (this.getConditionMax() * 1.0) * 100) + "%";
	}

	o.getAmountColor <- function()
	{
		return ::Const.Items.ConditionColor[::Math.max(0, ::Math.floor(this.getCondition() / (this.getConditionMax() * 1.0) * (::Const.Items.ConditionColor.len() - 1)))];
	}

	o.LayeredItems_serializeLayers <- function( _out )
	{
		_out.writeU8(this.m.LayeredItems.Layers.len());
		foreach (i, layer in this.m.LayeredItems.Layers)
		{
			if (layer == null)
			{
				_out.writeI32(0);
			}
			else
			{
				_out.writeI32(layer.ClassNameHash);
				layer.onSerialize(_out);
			}
			_out.writeBool(this.m.LayeredItems.Blocked[i]);
		}
	}

	o.LayeredItems_deserializeLayers <- function( _in )
	{
		if (this.m.LayeredItems.Fresh) return;
		local numLayers = _in.readU8();
		for (local i = 0; i < numLayers; ++i) // no handling for decreasing the number of layers (increasing does work)
		{
			local classNameHash = _in.readI32();
			if (classNameHash != 0)
			{
				local layer = ::new(::IO.scriptFilenameByHash(classNameHash));;
				this.LayeredItems_attachLayer(layer);
				layer.onDeserialize(_in);
			}
			this.m.LayeredItems.Blocked[i] = _in.readBool();
		}
	}

	// layered loot drops need work
	// how to handle getSkills
	// setUpgrade should instead attach to the Attachment layer, that should probably be handled in a separate armor hook though
	// need to handle sprites on corpses as well
}
