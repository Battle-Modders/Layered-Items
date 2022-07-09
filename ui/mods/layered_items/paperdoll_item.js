LayeredItems.createPaperdollItem = $.fn.createPaperdollItem;
$.fn.createPaperdollItem = function(_isBig, _backgroundImage, _classes)
{
	var result = LayeredItems.createPaperdollItem.call(this, _isBig, _backgroundImage, _classes);
	result.find('> .image-layer:first').append($('<div class="layered-item-layer"/>'));
	return result;
}

// $.fn.assignPaperdollItemOverlayImage is the original ish
LayeredItems.assignPaperdollLayeredImage = function(_isBlocked)
{
	var layersLayer = this.find('.image-layer > .layered-item-layer:first');
	layersLayer.empty();
	var itemData = this.data('item');
	if (itemData.LayeredItems_Icons == undefined) return;

	itemData.LayeredItems_Icons.forEach(function (_layerPath)
	{
		if (_layerPath == '')
		{
			console.error("Passed image path with no value to assignPaperdollLayeredImage");
			return;
		}
		var layerImage = $('<img/>');
		layerImage.attr('src', Path.ITEMS + _layerPath);

		if (itemData.isImageSmall === true) layerImage.addClass('is-small');
		if (_isBlocked === true) layerImage.addClass('is-blocked');
		layersLayer.append(layerImage);
	});
}
