const gnhomeInterface = require("gnhome-interface");

class ClockWidget extends gnhomeInterface.Widget
{
    constructor()
    {
        const schema = new gnhomeInterface.Widget.Schema([
            new gnhomeInterface.Widget.Schema.GraphQLQuery("getTime", "String", (a) => {
                return (new Date()).toLocaleTimeString();
            }),
        ], 
        [], 
        []);
        super(420691337, "Clock", "1.0.0", "A decent clock!", new gnhomeInterface.Widget.Size(300, 120), schema);
    }

    get status()
    {
        let date = new Date();
        return this.createResponse(200, "OK", date.toLocaleTimeString());
    }
}

gnhomeInterface.registerWidget(new ClockWidget());