::mods_hookDescendants("entity/tactical/actor", function (o)
{
	local onInit = ::mods_getMember(o, "onInit");
	// sprites seem to only be added during oninit so I'm gonna assume everyone does this
	o.onInit <- function() // not a huge fan of this approach but it's better than doing this shit manually
	{
		local hookedHere = false;
		local addSprite = this.addSprite;
		if (!::MSU.isIn("LayeredItems_HookOnce", this.m))
		{
			this.m.LayeredItems_HookOnce <- true;
			hookedHere = true;
			this.addSprite = function(_sprite)
			{
				local ret = addSprite(_sprite);
				if (_sprite == "helmet")
				{
					foreach (sprite in ::LayeredItems.Helmet.Sprite)
					{
						addSprite(sprite);
					}
				}
				else if (_sprite == "armor")
				{
					foreach (sprite in ::LayeredItems.Armor.Sprite)
					{
						addSprite(sprite);
					}
				}
				return ret;
			}
		}

		local ret = onInit();

		if (hookedHere)
		{
			delete this.m.LayeredItems_HookOnce;
			this.addSprite = addSprite;
		}

		return ret;
	}

	local onFactionChanged = ::mods_getMember(o, "onFactionChanged");
	o.onFactionChanged <- function()
	{
		local hookedHere = false;
		if (!::MSU.isIn("LayeredItems_HookOnce", this.m))
		{
			hookedHere = true;
			this.m.LayeredItems_HookOnce <- true;
		}

		local ret = onFactionChanged();

		if (hookedHere)
		{
			if (this.hasSprite("helmet"))
			{
				local flip = this.getSprite("helmet").isFlippedHorizontally();
				foreach (sprite in ::LayeredItems.Helmet.Sprite)
				{
					this.getSprite(sprite).setHorizontalFlipping(flip)
				}
			}

			if (this.hasSprite("armor"))
			{
				local flip = this.getSprite("armor").isFlippedHorizontally();
				foreach (sprite in ::LayeredItems.Armor.Sprite)
				{
					this.getSprite(sprite).setHorizontalFlipping(flip)
				}
			}

			delete this.m.LayeredItems_HookOnce;
		}

		return ret;
	}
});

::mods_hookExactClass("entity/tactical/actor", function (o)
{
	local onAppearanceChanged = o.onAppearanceChanged;
	o.onAppearanceChanged = function( _appearance, _setDirty = true )
	{
		if (!this.m.IsAlive || this.m.IsDying)
		{
			return;
		}

		foreach (sprite in ::LayeredItems.Helmet.Sprite)
		{
			if (this.hasSprite(sprite))
			{
				if (_appearance[sprite] != "" && !this.m.IsHidingHelmet)
				{
					local layer = this.getSprite(sprite);
					layer.setBrush(_appearance[sprite]);
					layer.Color = _appearance.HelmetColor;
					layer.Visible = true;
				}
				else
				{
					this.getSprite(sprite).Visible = false;
				}
			}
		}

		foreach (sprite in ::LayeredItems.Armor.Sprite)
		{
			if (this.hasSprite(sprite))
			{
				if (_appearance[sprite] != "")
				{
					local layer = this.getSprite(sprite);
					layer.setBrush(_appearance[sprite]);
					layer.Color = _appearance.ArmorColor;
					layer.Visible = true;
				}
				else
				{
					this.getSprite(sprite).Visible = false;
				}
			}
		}

		return onAppearanceChanged(_appearance, _setDirty);
	}
});
