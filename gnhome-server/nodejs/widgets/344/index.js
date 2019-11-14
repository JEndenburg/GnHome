const gnhomeInterface = require("gnhome-interface");

class WeatherWidget extends gnhomeInterface.Widget
{
    constructor()
    {
        super(344, "Weather (Mock)", "0.0.1", "Get the not-so-actual weather!", new gnhomeInterface.Widget.Size(240, 220));
    }

    get status()
    {
        return this.createResponse(501, "NYI");
    }
}

gnhomeInterface.registerWidget(new WeatherWidget());