::mods_hookBaseClass("items/item", function (o)
{
	o = o[o.SuperName];

	o.LayeredItems_isLayered <- function()
	{
		return ::MSU.isIn("LayeredItems", this.m, true) && "Layers" in this.m.LayeredItems;
	}

	o.LayeredItems_isLayer <- function()
	{
		return ::MSU.isIn("LayeredItems", this.m, true) && "Type" in this.m.LayeredItems;
	}

	o.LayeredItems_isNamed <- function()
	{
		return this.isItemType(::Const.Items.ItemType.Named);
	}

	o.LayeredItems_isLegendary <- function()
	{
		return this.isItemType(::Const.Items.ItemType.Legendary);
	}
});
