::mods_hookDescendants("entity/tactical/actor", function (o)
{
	local onInit = ::mods_getMember(o, "onInit");
	// sprites seem to only be added during oninit so I'm gonna assume everyone does this
	o.onInit <- function( ... ) // not a huge fan of this approach but it's better than doing this shit manually
	{
		vargv.insert(0, this)
		local addSprite = this.addSprite;
		this.addSprite = function(_sprite)
		{
			if (_sprite == "helmet")
			{
				foreach (layer in ::LayeredItems.HelmetLayerSprites)
				{
					addSprite(layer);
				}
			}
			else if (_sprite == "armor")
			{
				foreach (layer in ::LayeredItems.ArmorLayerSprites)
				{
					addSprite(layer);
				}
			}
			addSprite(_sprite);
		}

		local ret = onInit.acall(vargv);
		this.addSprite = addSprite;
		return ret;
	}

	local onFactionChanged = ::mods_getMember(o, "onFactionChanged");
	o.onFactionChanged <- function( ... )
	{
		vargv.insert(0, this);
		local ret = onFactionChanged.acall(vargv);

		if (this.hasSprite("helmet"))
		{
			local flip = this.getSprite("helmet").isFlippedHorizontally();
			foreach (layer in ::LayeredItems.HelmetLayerSprites)
			{
				layer.setHorizontalFlipping(flip)
			}
		}

		if (this.hasSprite("armor"))
		{
			local flip = this.getSprite("armor").isFlippedHorizontally();
			foreach (layer in ::LayeredItems.ArmorLayerSprites)
			{
				layer.setHorizontalFlipping(flip)
			}
		}

		return ret;
	}
});

::mods_hookExactClass("entity/tactical/actor", function (o)
{
	local onAppearanceChanged = o.onAppearanceChanged;
	// _appearance, _setDirty = true
	o.onAppearanceChanged = function( ... )
	{
		vargv.insert(0, this);

		if (!this.m.IsAlive || this.m.IsDying)
		{
			return;
		}

		foreach (layer in ::LayeredItems.HelmetLayerSprites)
		{
			if (this.hasSprite(layer))
			{
				if (vargv[1][layer] != "" && !this.m.IsHidingHelmet)
				{
					local helmet = this.getSprite(layer);
					helmet.setBrush(vargv[1][layer]);
					helmet.Color = vargv[1].HelmetColor;
					helmet.Visible = true;
				}
				else
				{
					this.getSprite(layer).Visible = false;
				}
			}
		}

		foreach (layer in ::LayeredItems.ArmorLayerSprites)
		{
			if (this.hasSprite(layer))
			{
				if (vargv[1][layer] != "")
				{
					local helmet = this.getSprite(layer);
					helmet.setBrush(vargv[1][layer]);
					helmet.Color = vargv[1].ArmorColor;
					helmet.Visible = true;
				}
				else
				{
					this.getSprite(layer).Visible = false;
				}
			}
		}

		return onAppearanceChanged.acall(vargv);
	}
}
