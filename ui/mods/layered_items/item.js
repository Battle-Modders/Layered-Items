LayeredItems.createListItem = $.fn.createListItem;
$.fn.createListItem = function(_withPriceLayer, _backgroundImage, _classes)
{
	var result = LayeredItems.createListItem.call(this, _withPriceLayer, _backgroundImage, _classes);
	var imageLayer = result.find('> .image-layer').filter(':first');
	imageLayer.append($('<div class="layered-item-layer"/>'));
	imageLayer.append($('<div class="layered-item-type title-font font-color-title font-bottom-shadow font-bold">'));
	return result;
}

LayeredItems.assignListItemLayeredImage = function()
{
	var imageLayer = this.find('> .image-layer');
	var layersLayer = imageLayer.find('> .layered-item-layer').filter(':first');
	var layerTypeLayer = imageLayer.find('> .layered-item-type').filter(':first');
	layersLayer.empty();
	layerTypeLayer.text('')
	var itemData = this.data('item');
	if (itemData.layeredItems == undefined) return;

	if (itemData.layeredItems.type == "layered")
	{
		itemData.layeredItems.layers.forEach(function (_layer)
		{
			if (_layer == null || !_layer.layeredItems.visible) return;
			var layerImage = $('<img/>');
			layerImage.attr('src', Path.ITEMS + _layer.imagePath);

			if (itemData.isImageSmall === true) layerImage.addClass('is-small');
			layersLayer.append(layerImage);
		});
	}
	else if (itemData.layeredItems.type == "layer")
	{
		layerTypeLayer.text(LayeredItems.Items[itemData.layeredItems.baseItem].layers[itemData.layeredItems.layer].jsCharacter);
	}
}
