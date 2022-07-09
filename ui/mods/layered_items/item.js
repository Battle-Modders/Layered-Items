LayeredItems.createListItem = $.fn.createListItem;
$.fn.createListItem = function(_withPriceLayer, _backgroundImage, _classes)
{
	var result = LayeredItems.createListItem.call(this, _withPriceLayer, _backgroundImage, _classes);
	result.find('> .image-layer:first').append($('<div class="layered-item-layer"/>'));
	return result;
}

LayeredItems.assignListItemLayeredImage = function()
{
	var layersLayer = this.find('.image-layer > .layered-item-layer:first');
	layersLayer.empty();
	var itemData = this.data('item');
	if (itemData.LayeredItems_Icons == undefined) return;

	itemData.LayeredItems_Icons.forEach(function (_layerPath)
	{
		if (_layerPath == '')
		{
			console.error("Passed image path with no value to assignListItemLayeredImage");
			return;
		}
		var layerImage = $('<img/>');
		layerImage.attr('src', Path.ITEMS + _layerPath);

		if (itemData.isImageSmall === true) layerImage.addClass('is-small');
		layersLayer.append(layerImage);
	});
}
