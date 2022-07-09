::mods_hookBaseClass("items/item", function (o)
{
	o = o[o.SuperName];

	o.LayeredItems_isLayered <- function()
	{
		return ::MSU.isIn("LayeredItems", this.m, true) && ::MSU.isIn("Layers", this.m.LayeredItems);
	}

	o.LayeredItems_isLayer <- function()
	{
		return ::MSU.isIn("LayeredItems", this.m, true) && ::MSU.isIn("Type", this.m.LayeredItems);
	}
});
