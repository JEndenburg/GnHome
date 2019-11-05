const gnhomeInterface = require("gnhome-interface");

class ClockWidget extends gnhomeInterface.Widget
{
    constructor()
    {
        super("Clock", "1.0.0", "A decent clock!");
    }

    get status()
    {
        let date = new Date();
        return new gnhomeInterface.Response(200, "OK", date.toLocaleTimeString());
    }
}

gnhomeInterface.registerWidget(new ClockWidget());