this.layered_items_connection <- this.inherit("scripts/mods/msu/js_connection", {
	m = {
		ID = "LayeredItemsConnection"
	},

	function loadConfig( _data )
	{
		this.m.JSHandle.asyncCall("loadConfig", _data);
	}
});
