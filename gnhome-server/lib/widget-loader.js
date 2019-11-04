module.exports = {
    loadWidgets,
};

const fs = require("fs");


function loadWidgets(path)
{
    let fsEntries = fs.readdirSync(path);
    return searchWidgets(path, fsEntries);
}

/**
 * 
 * @param {string[]} paths 
 */
function searchWidgets(mainPath, paths)
{
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
        return require(path + "/index.js");
    }
    catch(exception)
    {
        console.error(exception);
        return null;
    }
}