LayeredItems.createPaperdollItem = $.fn.createPaperdollItem;
$.fn.createPaperdollItem = function(_isBig, _backgroundImage, _classes)
{
	var result = LayeredItems.createPaperdollItem.call(this, _isBig, _backgroundImage, _classes);
	var imageLayer = result.find('> .image-layer').filter(':first');
	imageLayer.before($('<div class="layered-item-glow"/>'));
	imageLayer.append($('<div class="layered-item-layer"/>'));
	return result;
}

LayeredItems.assignPaperdollItemImage = $.fn.assignPaperdollItemImage;
$.fn.assignPaperdollItemImage = function(_imagePath, _imageIsSmall, _isBlocked)
{
	var ret = LayeredItems.assignPaperdollItemImage.call(this, _imagePath, _imageIsSmall, _isBlocked);
	var glowLayer = this.find('> .layered-item-glow').filter(':first');
	glowLayer.empty();
	var itemData = this.data('item');
	if (itemData.layeredItems == undefined) return ret;
	if (itemData.layeredItems.legendary)
	{
		if (_imageIsSmall) glowLayer.append('<img src="' + Path.GFX + LayeredItems.Assets.LegendaryGlow + '"/>');
		else glowLayer.append('<img src="' + Path.GFX + LayeredItems.Assets.LegendaryGlowLarge + '"/>');
	}
	if (itemData.layeredItems.named)
	{
		if (_imageIsSmall) glowLayer.append('<img src="' + Path.GFX + LayeredItems.Assets.NamedGlow + '"/>');
		else glowLayer.append('<img src="' + Path.GFX + LayeredItems.Assets.NamedGlowLarge + '"/>');
	}
	return ret;
}

// $.fn.assignPaperdollItemOverlayImage is the original ish
LayeredItems.assignPaperdollLayeredImage = function(_isBlocked)
{
	var layersLayer = this.find('> .image-layer > .layered-item-layer').filter(':first');
	layersLayer.empty();
	var itemData = this.data('item');
	var layerContainer = this.parent().find('> .layer-container');
	var layerButtons = layerContainer.find('> .l-layered-layer-button > .layered-layer-button');
	var layerShowHideButtons = layerContainer.find('> .l-layered-layer-button > .layered-items-eye-button');
	layerButtons.unbindTooltip();
	layerShowHideButtons.unbindTooltip();
	if (itemData.layeredItems == undefined || itemData.layeredItems.type != "layered")
	{
		layerContainer.removeClass('display-block').addClass('display-none')
		return;
	}
	layerContainer.addClass('display-block').removeClass('display-none');

	itemData.layeredItems.layers.forEach(function (_layer, _idx)
	{
		var invertedIdx = itemData.layeredItems.layers.length - _idx - 1;
		var button = $(layerButtons[invertedIdx]);
		var showHideButton = $(layerShowHideButtons[invertedIdx]);
		if (itemData.layeredItems.blocked[_idx])
		{
			button.removeClass('display-block').addClass('display-none');
			showHideButton.removeClass('display-block').addClass('display-none');
			return;
		}
		else
		{
			button.removeClass('display-none').addClass('display-block');
		}
		button.attr('disabled', _layer == null);
		if (_layer == null)
		{
			showHideButton.removeClass('display-block').addClass('display-none');
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
			showHideButton.removeClass('display-none').addClass('display-block');
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
				showHideButton.removeClass('invisible-layer');
				showHideButton.bindTooltip({
					contentType : 'msu-generic',
					modId : LayeredItems.ID,
					elementId : "Visible.True"
				});
			}
			else
			{
				showHideButton.addClass('invisible-layer');
				showHideButton.bindTooltip({
					contentType : 'msu-generic',
					modId : LayeredItems.ID,
					elementId : "Visible.False"
				});
			}
		}
	});
}
