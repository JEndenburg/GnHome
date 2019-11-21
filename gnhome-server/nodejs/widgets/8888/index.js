const gnhomeInterface = require("gnhome-interface");

class EsperantoAnalizilojWidget extends gnhomeInterface.Widget
{
    constructor()
    {
        const schema = new gnhomeInterface.Widget.Schema([], [], []);
        super(8888, "Esperanto-Analizilo", "0.0.1", "Analyze your Esperanto!", new gnhomeInterface.Widget.Size(800, 550), schema);
    }

    get status()
    {
        return this.createResponse(200, "OK", "ok");
    }
}

gnhomeInterface.registerWidget(new EsperantoAnalizilojWidget());