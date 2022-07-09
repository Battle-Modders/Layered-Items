::LayeredItems.hookLayer <- function( o )
{
	o.m.LayeredItems_Type <- null; // one of the items in ::LayeredItems_Armor/HelmetLayers
	o.m.LayeredItems_Parent <- null;

	o.getContainer <- function( ... )
	{
		if (this.m.LayeredItems_Parent == null) return null;
		return this.m.LayeredItems_Parent.getContainer();
	}

	o.LayeredItems_attach <- function( _parent, _type )
	{
		if (this.LayeredItems_canAttachToSlot(_type))
		{
			this.m.LayeredItems_Parent = _parent;
			return true;
		}
		return false;
	}

	o.LayeredItems_canAttachToSlot <- function( _type )
	{
		return _type == this.m.LayeredItems_Type;
	}

	// overwrite required :/
	o.updateAppearance <- function( ... )
	{
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
	}

	// overwrite required so it doesn't write to log
	// _damage, _fatalityType, _attacker
	o.onDamageReceived <- function( ... )
	{
		vargv.insert(0, this);
		this.item.onDamageReceived.acall(vargv);
	}
}
