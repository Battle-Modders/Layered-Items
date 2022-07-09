::LayeredItems.hookLayer <- function( o )
{
	o.m.LayeredItems <- {
		Type = null,
		Parent = null,
		BaseSprite = "",
		CurrentType = null,
		IsVisible = true
	}

	o.getContainer <- function()
	{
		if (this.m.LayeredItems.Parent == null) return null;
		return this.m.LayeredItems.Parent.getContainer();
	}

	o.LayeredItems_addLayerTooltip <- function( _result )
	{
		if (this.getIconLarge() != null)
		{
			_result.push({
				id = 4,
				type = "image",
				image = this.getIconLarge(),
				isLarge = true
			});
		}
		else
		{
			_result.push({
				id = 4,
				type = "image",
				image = this.getIcon()
			});
		}
		if (this.getConditionMax() != 0)
		{
			_result.push({
				id = 5,
				type = "progressbar",
				value = this.getCondition(),
				valueMax = this.getConditionMax(),
				text = this.Math.floor(this.getCondition()) + " / " + this.Math.floor(this.getConditionMax()),
				style = "armor-body-slim"
			})
		}
	}

	o.LayeredItems_getCurrentType <- function()
	{
		return this.m.LayeredItems.CurrentType;
	}

	o.LayeredItems_getType <- function()
	{
		return this.m.LayeredItems.Type;
	}

	o.LayeredItems_getBaseSprite <- function()
	{
		return this.m.LayeredItems.BaseSprite;
	}

	o.LayeredItems_isVisible <- function()
	{
		return this.m.LayeredItems.IsVisible;
	}

	o.LayeredItems_setVisible <- function( _visible )
	{
		this.m.LayeredItems.IsVisible = _visible;
		this.updateAppearance();
		this.getContainer().updateAppearance();
	}

	o.LayeredItems_getTypesArray <- function()
	{
		local ret = [];
		local type = this.LayeredItems_getType();
		local tempType;
		while (type != 0)
		{
			tempType = ::LayeredItems.getTypeFromLayer(::LayeredItems.getLayerFromType(type));
			ret.push(tempType);
			type -= tempType;
		}
		ret.reverse();
		return ret;
	}

	o.LayeredItems_attach <- function( _parent, _type )
	{
		if (this.LayeredItems_canAttachToType(_type))
		{
			this.m.LayeredItems.CurrentType = _type;
			this.m.LayeredItems.Parent = _parent;
			this.m.LayeredItems.IsVisible = true;
			return true;
		}
		return false;
	}

	o.LayeredItems_detach <- function()
	{
		this.m.LayeredItems.CurrentType = null;
		this.m.LayeredItems.Parent = null;
	}

	o.LayeredItems_canAttachToType <- function( _type )
	{
		return (_type & this.m.LayeredItems.Type) != 0;
	}

	// overwrite required :/
	o.updateAppearance <- function()
	{
		if (this.getContainer() == null || !this.isEquipped() || !this.m.ShowOnCharacter) return;

		local appearance = this.getContainer().getAppearance();

		if (!this.LayeredItems_isVisible())
		{
			appearance[::LayeredItems[this.m.LayeredItems.BaseSprite].Sprite[::LayeredItems.getLayerFromType(this.LayeredItems_getCurrentType())]] = "";
			return;
		}

		if (this.getCondition() / this.getConditionMax() <= ::Const.Combat.ShowDamagedArmorThreshold && this.m.SpriteDamaged != null)
		{
			appearance[::LayeredItems[this.m.LayeredItems.BaseSprite].Sprite[::LayeredItems.getLayerFromType(this.LayeredItems_getCurrentType())]] = this.m.SpriteDamaged; // needs to be improved
		}
		else if (this.m.Sprite != null)
		{
			appearance[::LayeredItems[this.m.LayeredItems.BaseSprite].Sprite[::LayeredItems.getLayerFromType(this.LayeredItems_getCurrentType())]] = this.m.Sprite; // needs to be improved
		}
	}

	o.onUnequip <- function()
	{
		if (this.m.ShowOnCharacter)
		{
			local app = this.getContainer().getAppearance();
			app[::LayeredItems[this.m.LayeredItems.BaseSprite].Sprite[::LayeredItems.getLayerFromType(this.LayeredItems_getCurrentType())]] = "";
			this.getContainer().updateAppearance() // this is really inefficient when unequipping the whole layered item. Maybe make a separate function that doesn't call this based on param?
		}
		this.item.onUnequip();
	}

	// overwrite required so it doesn't write to log
	o.onDamageReceived <- function( _damage, _fatalityType, _attacker )
	{
		this.item.onDamageReceived(_damage, _fatalityType, _attacker);
		return _damage;
	}
}
