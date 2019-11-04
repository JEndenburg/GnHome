const gnhomeInterface = require("gnhome-interface");

let widget = gnhomeInterface("Clock", "1.0.0", "A decent clock!", () => {

});

widget.onQuery = (query) =>
{
    let date = new Date();
    return date.toLocaleTimeString();
};