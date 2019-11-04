const gnhomeInterface = require("gnhome-interface");

let widget = gnhomeInterface("Clock", "1.0.0", "A decent clock!", () => {

});

widget.query = (query) =>
{
    let date = new Date();
    return new gnhomeInterface.Response(200, "OK", date.toLocaleTimeString());
};