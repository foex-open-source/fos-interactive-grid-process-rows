window.FOS = window.FOS || {};
FOS.interactiveGrid = FOS.interactiveGrid || {};

FOS.interactiveGrid.processRows = function(da, config){

    var pluginName = 'FOS - Interactive Grid - Process Rows';

    apex.debug.info(pluginName, 'da', da);
    apex.debug.info(pluginName, 'config', config);

    var regionId = config.regionId;
    var ajaxId = config.ajaxId;

    var region = apex.region(regionId);

    if(!region || region.type != 'InteractiveGrid'){
        throw new Error('The affected element of plug-in "' + pluginName + '" must be an Interactive Grid region.');
    }

    var f01;

    if(config.submitSelectedRecords){
        var selectedRecords = region.call('getSelectedRecords');

        if(selectedRecords.length == 0){
            apex.debug.info('No selected records. Continuing without server call.');

            var errorOccurred = false;
            apex.da.resume(da.resumeCallback, errorOccurred);
            return;
        }

        var model = region.call('getViews', 'grid').model;
        var selection = {
            recordKeys: selectedRecords.map(function(record){
                return model._getPrimaryKey(record);
            })
        };

        f01 = apex.server.chunk(JSON.stringify(selection));
    }

    var result = apex.server.plugin(ajaxId, {
        f01: f01,
        pageItems: config.itemsToSubmit
    });

    result.done(function(data){
        var errorOccurred;

        if(data.status == 'success'){
            errorOccurred = false;
            if(data.itemsToReturn){
                for(var i = 0; i<data.itemsToReturn.length; i++){
                    apex.item(data.itemsToReturn[i].name).setValue(data.itemsToReturn[i].value);
                }
            }
        } else {
            errorOccurred = true;
        }

        apex.da.resume(da.resumeCallback, errorOccurred);

    }).fail(function(jqXHR, textStatus, errorThrown){
        apex.da.handleAjaxErrors(jqXHR, textStatus, errorThrown, da.resumeCallback);
    });
};


