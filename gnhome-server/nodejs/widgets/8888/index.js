const gnhomeInterface = require("gnhome-interface");

class EsperantoAnalizilojWidget extends gnhomeInterface.Widget
{
    constructor()
    {
        super(8888, "Esperanto-Analizilo", "0.0.1", "Analyze your Esperanto!", new gnhomeInterface.Widget.Size(800, 550));
    }

    get status()
    {
        return this.createResponse(200, "OK", "ok");
    }
}

gnhomeInterface.registerWidget(new EsperantoAnalizilojWidget());