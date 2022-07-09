LayeredItems.createListItem = $.fn.createListItem;
$.fn.createListItem = function(_withPriceLayer, _backgroundImage, _classes)
{
	var result = LayeredItems.createListItem.call(this, _withPriceLayer, _backgroundImage, _classes);
	result.children('.image-layer:first').append($('<div class="layered-item-layer"/>'));
	return result;
}

LayeredItems.assignListItemLayeredImage = function()
{
	var layersLayer = this.find('> .image-layer > .layered-item-layer:first');
	layersLayer.empty();
	var itemData = this.data('item');
	if (itemData.layeredItems == undefined || itemData.layeredItems.type != "layered") return;

	itemData.layeredItems.layers.forEach(function (_layer)
	{
		if (_layer == null || !_layer.layeredItems.visible) return;
		var layerImage = $('<img/>');
		layerImage.attr('src', Path.ITEMS + _layer.imagePath);

		if (itemData.isImageSmall === true) layerImage.addClass('is-small');
		layersLayer.append(layerImage);
	});
}
