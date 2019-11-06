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
        return this.createResponse(200, "OK", date.toLocaleTimeString());
    }

    get widgetHTML()
    {
        return this.createResponse(200, "OK", this.getFileContent(__dirname + "/index.html").toString());
    }
}

gnhomeInterface.registerWidget(new ClockWidget());