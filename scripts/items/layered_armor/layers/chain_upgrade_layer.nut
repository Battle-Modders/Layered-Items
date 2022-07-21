this.chain_upgrade_layer <- this.inherit("scripts/items/layered_armor/layers/armor_layer", {
	m = {},
	function create()
	{
		this.armor_layer.create();
		this.m.ID = "armor_layer.chain_upgrade";
		this.m.Name = "Mail Patch";
		this.m.Description = "A large patch of mail that can be added to any armor to further protect the most vulnerable areas.";
		this.m.SlotType = this.Const.ItemSlot.Body;
		this.m.Icon = "armor_upgrades/icon_upgrade_09.png";
		this.m.IconLarge = "armor_upgrades/inventory_upgrade_09.png";
		this.m.Sprite = "upgrade_09_back";
		this.m.SpriteDamaged = "upgrade_09_back_damaged";

		// this.m.SpriteFront = null;
		// this.m.SpriteBack = "upgrade_09_back";
		// this.m.SpriteDamagedFront = null;
		// this.m.SpriteDamagedBack = "upgrade_09_back_damaged";
		// this.m.SpriteCorpseFront = null;
		// this.m.SpriteCorpseBack = "upgrade_09_back_dead";
		this.m.Value = 200;
		this.m.Condition = 20;
		this.m.ConditionMax = 20;
		this.m.StaminaModifier = -2;
		this.m.LayeredItems.Type = ::LayeredItems.Armor.LayerType.Chain | ::LayeredItems.Armor.LayerType.Attachment;
	}
});
