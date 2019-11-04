const Widget = require("./widget");
const Response = require("./response");

/** @type {Object.<string, Widget>} */
let _widgetList = [];

/**
 * 
 * @param {string} name 
 * @param {string} version 
 * @param {string} description 
 * @param {Function} execution 
 */
function createWidget(name, version, description, execution)
{
    let newWidget = new Widget(name, version, description, execution);
    
    if(_widgetList[name] == undefined)
        _widgetList[name] = newWidget;
    else
        throw `A widget with the name "${name}" already exists!`;
    
    return newWidget;
}

/**
 * @returns {Object.<string, Widget>}
 */
function getWidgetList()
{
    return _widgetList;
}


exports = module.exports = createWidget;

exports.getWidgetList = getWidgetList;
exports.Response = Response;