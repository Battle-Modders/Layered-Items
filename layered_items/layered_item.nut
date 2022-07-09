::LayeredItems.hookLayeredItem <- function( o )
{
	o.m.LayeredItems_Layers <- {};
	o.m.LayeredItems_BlockedLayers <- []; // array of blocked layers, eg if the layer "Cloth" is blocked, then BlockedLayers would contain an entry with value "Cloth"
	o.m.LayeredItems_Type <- ::LayeredItems.Type.None;

	local create = o.create;
	o.create = function()
	{
		create();
	}

	o.LayeredItems_returnTrueIfAnyTrue <- function( _function, _argsArray )
	{
		foreach (layer in this.m.LayeredItems_Layers)
		{
			vargv[0] = layer;
			if (layer != null && layer[_function].acall(vargv) == true) return true;
		}
		return false;
	}

	local returnTrueIfAnyTrueFunctions = [
		"isNamed"
	];

	foreach (functionName in returnTrueIfAnyTrueFunctions)
	{
		local oldFunction = ::mods_getMember(o, functionName);
		o[functionName] <- function( ... )
		{
			vargv.insert(0, this)
			if (oldFunction.acall(vargv) == true) return true;
			return this.LayeredItems_returnTrueIfAnyTrue(functionName, vargv);
		}
	}

	o.LayeredItems_returnFalseIfAnyFalse <- function( _function, _argsArray )
	{
		foreach (layer in this.m.LayeredItems_Layers)
		{
			vargv[0] = layer;
			if (layer != null && layer[_function].acall(vargv) == false)
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
		o[functionName] <- function( ... )
		{
			vargv.insert(0, this);
			if (oldFunction.acall(vargv) == false) return false;
			return this.LayeredItems_returnFalseIfAnyFalse(functionName, vargv);
		}
	}

	o.LayeredItems_getAddedValue <- function( _function, _base, _argsArray ) // _argsArray assumes 'this' slot exists
	{
		foreach (layer in this.m.LayeredItems_Layers)
		{
			_argsArray[0] = layer;
			if (layer != null) _base += layer[_function].acall(_argsArray);
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

	foreach (functionName in addedValueFunctions)
	{
		local oldFunction = ::mods_getMember(o, functionName);
		o[functionName] <- function( ... )
		{
			vargv.insert(0, this)
			return this.__LayeredItems_getAddedValue(functionName, oldFunction.acall(vargv));
		}
	}

	o.LayeredItems_callOnFunction <- function( _function, _argsArray ) // _argsArray assumes 'this' slot exists
	{
		foreach (layer in this.m.LayeredItems_Layers)
		{
			if (layer != null)
			{
				_argsArray[0] = layer;
				layer[_function].acall(_argsArray);
			}
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
		"onUpdateProperties",
		"onTurnStart",
		"onUse",
		"onTotalArmorChanged",
		"onMovementFinished",
		"onCombatStarted",
		"onCombatFinished",
		"onActorDied",
		"onAddedToStash",
		"onRemovedFromStash",

		// MSU
		"onAfterUpdateProperties"
	]

	foreach (functionName in callOnFunctions)
	{
		local oldFunction = ::mods_getMember(o, functionName);
		o[functionName] <- function( ... )
		{
			vargv.insert(0, this);
			oldFunction.acall(vargv);
			this.LayeredItems_callOnFunction(functionName, vargv);
		}
	}


	o.LayeredItems_getIcons <- function()
	{
		return []; // should be overwritten by children
		// used to stack layers icons
		// needs js hooks for assignItemToSlot in character_screen_paperdoll_module, character_screen_inventory_list_module
		// tactical_combat_result_screen_loot_panel and world_town_screen_shop_dialog_module.

		// also need handling for named layers
	}

	o.LayeredItems_getIconsLarge <- function()
	{
		return []; // should be overwritten by children
	}

	o.LayeredItems_attachLayer <- function( _layer, _type )
	{
		if (this.m.LayeredItems_Layers[_type] == null)
		{
			if (_layer.LayeredItems_attach(this, _type))
			{
				this.m.LayeredItems_Layers[_type] = _layer;
			}
		}
		this.updateAppearance()
	}

	o.setUpgrade <- function( _upgrade )
	{
		this.LayeredItems_attachLayer(_upgrade, "Attachment")
	}

	local setCondition = ::mods_getMember(o, "setCondition");
	// _a
	o.setCondition <- function( ... )
	{
		vargv.insert(0, this);

		local condition = vargv[1];
		if (condition > this.getConditionMax()) condition = this.getConditionMax();
		else if (condition < 0) condition = 0;

		local difference = this.getCondition() - condition;
		if (difference == 0) return;
		else if (difference > 0)
		{
			// bottom up
			local currentLayerDifference = ::Math.min(difference, getConditionMax() - getConidtion());
			difference -= currentLayerDifference;
			vargv[1] = currentLayerDifference + getCondition();
			setCondition.acall(vargv);

			for (local i = 0; i < ::LayeredItems.ArmorLayers.len(); ++i)
			{
				if (difference <= 0) break;
				local layer = this.m.LayeredItems_Layers[::LayeredItems.ArmorLayers[i]];
				if (layer == null) continue;
				currentLayerDifference = ::Math.min(difference, layer.getConditionMax() - layer.getCondition());
				difference -= currentLayerDifference;
				vargv[1] = currentLayerDifference + layer.getCondition();
				layer.setCondition.acall(vargv);
			}
		}
		else
		{
			local currentLayerDifference;
			// top down
			for (local i = ::LayeredItems.ArmorLayers.len() - 1; i > 0; --i)
			{
				if (difference >= 0) break;
				local layer = this.m.LayeredItems_Layers[::LayeredItems.ArmorLayers[i]];
				if (layer == null) continue;
				currentLayerDifference = ::Math.min(difference, layer.getCondition());
				difference -= currentLayerDifference;
				vargv[1] = layer.getCondition() - currentLayerDifference;
				layer.setCondition.acall(vargv);
			}

			currentLayerDifference = ::Math.min(difference, getCondition());
			difference -= currentLayerDifference;
			vargv[1] = getCondition() - currentLayerDifference;
			setCondition.acall(vargv);
		}
		if (difference != 0) throw "Difference was not 0"
	}

	// _a
	o.setArmor <- function( ... )
	{
		vargv.insert(0, this);
		this.setCondition.acall(vargv);
	}

	o.updateAppearance <- function( ... )
	{
		vargv.insert(0, this);
		if (this.getContainer() == null || !this.isEquipped() || ! this.m.ShowOnCharacter) return;

		local appearance = this.getContainer().getAppearance();
		if (this.getCondition() / this.getConditionMax() <= ::Const.Combat.ShowDamagedArmorThreshold && this.m.SpriteDamaged != null)
		{
			appearance[this.m.LayeredItems_Type] = this.m.SpriteDamaged;
		}
		else if (this.m.Sprite != null)
		{
			appearance[this.m.LayeredItems_Type] = this.m.Sprite;
		}

		foreach (layer in this.m.LayeredItems_Layers)
		{
			layer.updateAppearance.acall(vargv);
		}
	}
	// Dumb overwrites below cuz Raps doesn't use set/getCondition -_- maybe we should fix that in MSU?

	// _damage, _fatalityType, _attacker
	o.onDamageReceived <- function( ... )
	{
		vargv.insert(0, this);
		this.item.onDamageReceived.acall(vargv);

		local originalDamage = vargv[1];

		foreach (layer in this.m.LayeredItems_Layers)
		{
			if (layer != null)
			{
				vargv[0] = layer;
				vargv[1] = layer.onDamageReceived.acall(vargv);
			}
		}

		if (this.getCondition() == 0) return;

		this.setCondition(::Math.max(0, this.getCondition() - vargv[1]) * 1.0);

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

	// layered loot drops need work
	// how to handle getSkills
	// setUpgrade should instead attach to the Attachment layer, that should probably be handled in a separate armor hook though
	// need to handle sprites on corpses as well
}
