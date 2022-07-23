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
				foreach (item in ::LayeredItems.Item)
				{
					if (item.SpriteName == _sprite)
					{
						foreach (sprite in item.Sprite)
						{
							addSprite(sprite);
						}
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
			foreach (item in ::LayeredItems.Item)
			{
				if (this.hasSprite(item.SpriteName))
				{
					local flip = this.getSprite(item.SpriteName).isFlippedHorizontally();
					foreach (sprite in item.Sprite)
					{
						this.getSprite(sprite).setHorizontalFlipping(flip);
					}
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
		if (!this.m.IsAlive || this.m.IsDying) return;
		local ret = onAppearanceChanged(_appearance, _setDirty);

		foreach (key, item in ::LayeredItems.Item)
		{
			if (!this.hasSprite(item.SpriteName)) continue;
			local parentSprite = this.getSprite(item.SpriteName);
			foreach (sprite in item.Sprite)
			{
				if (!this.hasSprite(sprite)) continue; // should never happen cuz of earlier check but just in case
				local layer = this.getSprite(sprite);
				if (_appearance[sprite] != "")
				{
					layer.setBrush(_appearance[sprite]);
					layer.Color = this.createColor("#ffffff");
					layer.Visible = parentSprite.Visible;
				}
				else
				{
					layer.Visible = false;
				}
			}
		}
		return ret;
	}
});
