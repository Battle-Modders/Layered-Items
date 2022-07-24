var buildFromData = TooltipModule.prototype.buildFromData
TooltipModule.prototype.buildFromData = function(_data, _shouldBeUpdated, _contentType)
{
	buildFromData.call(this, _data, _shouldBeUpdated, _contentType);
	var hasLayer = false;
	$.each(_data, function(idx, value)
	{
		if (value.type == "layer")
			return addLayeredArmorDiv(value.data); 
	})
}

TooltipModule.prototype.addLayeredArmorDiv = function(_data)
{
	var self = this;
	var currentTooltip = this.mContainer;
	var contentContainer = this.mContainer.find('.content-container:first');
	$.each(_data, function(_idx, layer)
	{
		self.addContentTextDiv(self.contentContainer, layer)
	})
};