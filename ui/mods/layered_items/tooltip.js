console.error("hook runs")
var buildFromData = TooltipModule.prototype.buildFromData
TooltipModule.prototype.buildFromData = function(_data, _shouldBeUpdated, _contentType)
{
	var self = this;
	console.error("runs")
	buildFromData.call(this, _data, _shouldBeUpdated, _contentType);
	var hasLayer = false;
	$.each(_data, function(idx, value)
	{
		if (value.type == "layer")
			return self.addLayeredArmorDiv(value.data);
	})
}

TooltipModule.prototype.addLayeredArmorDiv = function(_data)
{
	var self = this;
	var contentContainer = this.mContainer.find('.content-container:first');
	var extraheight = 0;
	$.each(_data, function(_idx, layer)
	{
		var container = $('<div class="row content-container"></div>');
		container.attr('id', 'tooltip-module-content-layer-container-' + layer.id);
		if (_idx != _data.length-1)
			container.addClass('ui-control-tooltip-module-bottom-devider')
		contentContainer.append(container);

		var leftDiv = $('<div class="left-content-container"></div>').appendTo(container);
		var rightDiv = $('<div class="right-content-container"></div>').appendTo(container);
		var main = layer[0];
		self.addAtmosphericImageDiv(leftDiv, main);
		// container.css("outline", "2px solid blue")
		// leftDiv.css("outline", "2px solid green")
		// rightDiv.css("outline", "2px solid red")

		var nameDiv = $('<div class="layer-item-title-container"></div>').appendTo(rightDiv);
		var text = $('<div class="title title-font-normal font-bold font-color-ink"></div>').appendTo(nameDiv);
		text.attr('id', 'tooltip-module-content-text-999');
		var parsedText = XBBCODE.process({
			text: main.name,
			removeMisalignedTags: false,
			addInLineBreaks: true
		});
		text.html(parsedText.html);

		for(var x = 1; x < layer.length; x++)
		{
			var content = layer[x];
			if (content.type == "text")
				self.addContentTextDiv(rightDiv, content);
			else if (content.type == "progressbar")
				self.addContentProgressbarDiv(rightDiv, content);
		}
	})
};

