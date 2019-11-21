const gnhomeInterface = require("gnhome-interface");
const fetch = require("node-fetch");

class WeatherWidget extends gnhomeInterface.Widget
{
    constructor()
    {
        const schema = new gnhomeInterface.Widget.Schema(
            [
                new gnhomeInterface.Widget.Schema.GraphQLQuery("getWeather", "Weather", async (a) => {
                    let response = await fetch("http://localhost:8000/mock/api/weather.json");
                    let content = await response.json();
                    return {
                        location: content.liveweer[0].plaats,
                        temperature: content.liveweer[0].temp,
                        image: content.liveweer[0].image,
                    };
                })
            ],
            [],
            [
                new gnhomeInterface.Widget.Schema.GraphQLType("Weather", [
                    "location : String",
                    "temperature : String",
                    "image : String",
                ])
            ]);
        super(344, "Weather (Mock)", "0.0.1", "Get the not-so-actual weather!", new gnhomeInterface.Widget.Size(240, 220), schema);
    }

    get status()
    {
        return this.createResponse(501, "NYI");
    }
}

gnhomeInterface.registerWidget(new WeatherWidget());