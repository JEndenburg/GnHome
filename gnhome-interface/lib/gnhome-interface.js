const Widget = require("./widget");
const Response = require("./response");

/** @type {Object.<string, Widget>} */
let _widgetList = [];

/**
 * @param {Widget} widget
 */
function registerWidget(widget)
{
    if(_widgetList[widget.name] == undefined)
        _widgetList[widget.name] = widget;
    else
        throw `A widget with the name "${name}" already exists!`;
}

/**
 * @returns {Object.<string, Widget>}
 */
function getWidgetList()
{
    return _widgetList;
}

function clearWidgetList() 
{
    _widgetList = [];
}


exports = module.exports = {};

exports.Widget = Widget;
exports.registerWidget = registerWidget;
exports.getWidgetList = getWidgetList;
exports.Response = Response;
exports.clearWidgetList = clearWidgetList;