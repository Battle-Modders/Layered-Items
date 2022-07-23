this.vanilla_attachment <- this.inherit("scripts/items/layered_armor/layers/armor_layer", {
	m = {},

	function create()
	{
		this.armor_layer.create();
		this.armor_upgrade <- ::new("scripts/items/armor_upgrades/armor_upgrade");
		this.armor_upgrade.setdelegate(this.item);
		this.armor_upgrade.item = this.item;
		this.armor_upgrade.m.setdelegate(this.item.m);
		this.m.LayeredItems.VanillaClassNameHash <- null;
		this.m.LayeredItems.Type = ::LayeredItems.Item.Armor.LayerType.Attachment;
	}

	function init( _vanillaItem )
	{
		this.m.LayeredItems.VanillaClassNameHash = _vanillaItem.ClassNameHash;
		this.m.ID = "vanilla_attachment." + _vanillaItem.m.ID;
		this.m.Name = _vanillaItem.m.Name;
		this.m.Description = _vanillaItem.m.Description;
		this.m.Value = _vanillaItem.m.Value;
		this.m.SlotType = ::Const.ItemSlot.Body;

		this.m.Icon = _vanillaItem.m.OverlayIcon;
		this.m.IconLarge = _vanillaItem.m.OverlayIconLarge;
		this.m.Sprite = _vanillaItem.m.SpriteFront != null ? _vanillaItem.m.SpriteFront : _vanillaItem.m.SpriteBack;
		this.m.SpriteDamaged = _vanillaItem.m.SpriteDamagedFront != null ? _vanillaItem.m.SpriteDamagedFront : _vanillaItem.m.SpriteDamagedBack;
		this.m.SpriteCorpse = _vanillaItem.m.SpriteCorpseFront != null ? _vanillaItem.m.SpriteCorpseFront : _vanillaItem.m.SpriteCorpseBack;

		this.m.Condition = _vanillaItem.m.ConditionModifier != 0 ? _vanillaItem.m.ConditionModifier : 1;
		this.m.ConditionMax = _vanillaItem.m.ConditionModifier != 0 ? _vanillaItem.m.ConditionModifier : 1; // if this is 0 we get div by 0
		this.m.StaminaModifier = -_vanillaItem.m.StaminaModifier;

		foreach (key, value in _vanillaItem)
		{
			if (typeof value == "function" && !(key in this)) this[key] <- value.bindenv(this);
		}

		foreach (key, value in _vanillaItem.m)
		{
			if (!(key in this)) this.m[key] <- value;
		}
	}

	function getTooltip()
	{
		local ret = this.armor_layer.getTooltip();
		if ("onArmorTooltip" in this)
		{
			this.onArmorTooltip(ret);
		}
		return ret;
	}

	function onSerialize( _out )
	{
		_out.writeI32(this.m.LayeredItems.VanillaClassNameHash);
		this.armor_layer.onSerialize(_out);
	}

	function onDeserialize( _in )
	{
		local vanillaItem = ::new(::IO.scriptFilenameByHash(_in.readI32()));
		this.init(vanillaItem);
		this.armor_layer.onDeserialize(_in);
	}

});
