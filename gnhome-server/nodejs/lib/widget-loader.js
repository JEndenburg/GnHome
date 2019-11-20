module.exports = {
    loadWidgets,
    clear,
};

const fs = require("fs");
let widgetCacheNames = [];


function loadWidgets(path)
{
    let fsEntries = fs.readdirSync(path);
    return searchWidgets(path, fsEntries);
}

function clear()
{
    for(let cacheName of widgetCacheNames)
    {
        require.cache[require.resolve(cacheName)] = null;
    }
}

/**
 * @param {string} mainPath
 * @param {string[]} paths 
 */
function searchWidgets(mainPath, paths)
{
    widgetCacheNames = [];
    let widgets = [];
    let wi = 0;
    for(let fi = 0; fi < paths.length; fi++)
    {
        if(fs.statSync(mainPath + "/" + paths[fi]).isDirectory())
        {
            let loadedWidget = loadWidget(mainPath + "/" + paths[fi]);
            if(loadedWidget != null)
            {
                widgets[wi] = loadedWidget;
                wi++;
            }
        }
    }

    return widgets;
}

function loadWidget(path)
{
    try
    {
        const req = require(path + "/index.js");
        widgetCacheNames.push(path + "/index.js");
        return req;
    }
    catch(exception)
    {
        console.error(exception);
        return null;
    }
}