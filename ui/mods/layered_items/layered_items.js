var LayeredItems = {
	ID : "mod_layered_items",
	LayerOwner : 'layered-items.layer',
	Connection : null,
	Items : null
}

LayeredItems.Connection = function()
{
	MSUBackendConnection.call(this);
}

LayeredItems.Connection.prototype = Object.create(MSUBackendConnection.prototype);
Object.defineProperty(LayeredItems.Connection.prototype, 'constructor', {
	value: LayeredItems.Connection,
	enumerable: false,
	writable: true
});

LayeredItems.Connection.prototype.loadConfig = function( _data )
{
	LayeredItems.Items = _data;
}

registerScreen("LayeredItemsConnection", new LayeredItems.Connection());
