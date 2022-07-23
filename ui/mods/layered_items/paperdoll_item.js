LayeredItems.createPaperdollItem = $.fn.createPaperdollItem;
$.fn.createPaperdollItem = function(_isBig, _backgroundImage, _classes)
{
	var result = LayeredItems.createPaperdollItem.call(this, _isBig, _backgroundImage, _classes);
	result.find('> .image-layer').filter(':first').append($('<div class="layered-item-layer"/>'));
	return result;
}

// $.fn.assignPaperdollItemOverlayImage is the original ish
LayeredItems.assignPaperdollLayeredImage = function(_isBlocked)
{
	var layersLayer = this.find('> .image-layer > .layered-item-layer').filter(':first');
	layersLayer.empty();
	var itemData = this.data('item');
	var layerContainer = this.parent().find('> .layer-container');
	var layerButtons = layerContainer.find('> .l-layered-layer-button > .layered-layer-button');
	layerButtons.unbindTooltip();
	if (itemData.layeredItems == undefined || itemData.layeredItems.type != "layered")
	{
		layerContainer.removeClass('display-block').addClass('display-none')
		return;
	}
	layerContainer.addClass('display-block').removeClass('display-none');

	itemData.layeredItems.layers.forEach(function (_layer, _idx)
	{
		var button = $(layerButtons[itemData.layeredItems.layers.length - _idx - 1]);
		if (itemData.layeredItems.blocked[_idx]) button.removeClass('display-block').addClass('display-none');
		else button.removeClass('display-none').addClass('display-block');
		button.attr('disabled', _layer == null);
		if (_layer == null)
		{
			button.bindTooltip({
				contentType : 'msu-generic',
				modId : LayeredItems.ID,
				elementId : "Layer",
				layer : _idx,
				entityId : itemData.entityId,
				itemId : itemData.itemId // should be renamed to parentId
			});
		}
		else
		{
			button.bindTooltip({
				contentType : 'ui-item',
				entityId : itemData.entityId,
				itemId : _layer.id,
				itemOwner : LayeredItems.LayerOwner
			});

			if (_layer.layeredItems.visible)
			{
				var layerImage = $('<img/>');
				layerImage.attr('src', Path.ITEMS + _layer.imagePath);

				if (itemData.isImageSmall === true) layerImage.addClass('is-small');
				if (_isBlocked === true) layerImage.addClass('is-blocked');
				layersLayer.append(layerImage);
				button.removeClass('invisible-layer');
			}
			else
			{
				button.addClass('invisible-layer')
			}
		}
	});
}
