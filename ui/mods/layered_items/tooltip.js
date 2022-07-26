LayeredItems.buildFromData = TooltipModule.prototype.buildFromData
TooltipModule.prototype.buildFromData = function(_data, _shouldBeUpdated, _contentType)
{
	var self = this;
	LayeredItems.buildFromData.call(this, _data, _shouldBeUpdated, _contentType);
	$.each(_data, function(idx, value)
	{
		if (value.type == "layer")
		{
			return self.addLayeredArmorDiv(value.data);
		}
	})
}

TooltipModule.prototype.addLayeredArmorDiv = function(_data)
{
	var self = this;
	var contentContainer = this.mContainer.find('.content-container:first');
	var leftContentContainer = contentContainer.find('.left-content-container:first');
	var imageContainer = leftContentContainer.find(".l-image-container:first");

	//set to relative and remove the image so that we can add the layer images here
	imageContainer.css("position", "relative");
	imageContainer.find("img:first").remove();
	for (var idx = _data.length - 1; idx > -1; idx--)
	{
		var layer = _data[idx];
		var container = $('<div class="row content-container"></div>').appendTo(contentContainer);
		container.attr('id', 'tooltip-module-content-layer-container-' + layer.id);

		//top divider for the first one, no bottom divider for the last one
		if (idx != 0)
			container.addClass('ui-control-tooltip-module-bottom-devider')
		if (idx == _data.length - 1)
			container.addClass('ui-control-tooltip-module-top-devider')

		var leftDiv = $('<div class="left-content-container"></div>').appendTo(container);
		var rightDiv = $('<div class="right-content-container"></div>').appendTo(container);
		var main = layer[0];
		var imgDiv = self.addAtmosphericImageDiv(leftDiv, main);

		// add image to the main image, position absolute to stack on top of each other
		var img = imgDiv.find("img:first").clone();
		imageContainer.append(img)
		img.css("position", "absolute");
		img.css("top", "0");
		img.css("left", "0");
		var zIndex = _data.length - 1 == idx ? 0 : idx; //base layer needs to go to bottom
		img.css("z-index", zIndex );

		var nameDiv = $('<div class="layer-item-title-container"></div>').appendTo(rightDiv);
		var text = $('<div class="title title-font-normal font-bold font-color-ink"></div>').appendTo(nameDiv);
		text.attr('id', 'tooltip-module-content-text-999');
		var parsedText = XBBCODE.process({
			text: main.name,
			removeMisalignedTags: false,
			addInLineBreaks: true
		});
		text.html(parsedText.html);

		// add extra content (durability, stamina, effects)
		for(var x = 1; x < layer.length; x++)
		{
			var content = layer[x];
			if (content.type == "text")
				self.addContentTextDiv(rightDiv, content);
			else if (content.type == "progressbar")
				self.addContentProgressbarDiv(rightDiv, content);
		}
	}
};

