const gnhomeInterface = require("gnhome-interface");

class ChatWidget extends gnhomeInterface.Widget
{
    constructor()
    {
        const schema = new gnhomeInterface.Widget.Schema([], [], []);
        super(528324727, "WebChat", "0.0.1", "Find new friends, talk with old ones.", new gnhomeInterface.Widget.Size(500, 400), schema);
    }

    get status()
    {
        return this.createResponse(200, "OK", {});
    }
}

gnhomeInterface.registerWidget(new ChatWidget());