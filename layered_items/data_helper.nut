::mods_hookNewObjectOnce("ui/global/data_helper", function (o)
{
	local convertItemToUIData = o.convertItemToUIData;
	// _item, _forceSmallIcon, _owner = null
	o.convertItemToUIData = function( ... )
	{
		vargv.insert(0, this)
		local ret = convertItemToUIData.acall(vargv);

		if (::MSU.isIn("LayeredItems_getIcons", vargv[1])) // this check should be better
		{
			if (vargv[2] == false && vargv[1].getIconLarge() != null)
			{
				ret.LayeredItems_Icons <- vargv[1].LayeredItems_getIcons();
			}
			else
			{
				ret.LayeredItems_Icons <- vargv[1].LayeredItems_getIconsLarge();
			}
		}

		return ret;
	}
});
