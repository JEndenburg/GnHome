GnHome
======
A browser home application featuring widgets, turning your homepage into a sort-of desktop.

### How do I make it work?
First, run `npm install` within the `gnhome-server/nodejs` folder. Then set up a MariaDB database and add a file called `mariadb.credentials` in the `gnhome-server/nodejs/lib/api` folder. This should be a file with JSON contents, containing a `host` string, a `port` integer, a `user` string, a `password` string, a `connectionLimit` integer and a `database` string.

e.g.:
```json
{
    "host": "localhost",
    "port": 8001,
    "user": "myUserName",
    "password": "myPassword",
    "connectionLimit": 5,
    "database": "myDatabaseName"
}
```

Then run the `gnhome-server/compileElm.sh` (you may need to create a `gnhome-server\nodejs\site\static\src\elm` folder first!) to compile and move the elm code.
Run the node application (app.js) within the `gnhome-server/nodejs` folder. You shouldn't need any of the other folders except for the `gnhome-interface` one.

You might need to use `npm link` within the `gnhome-interface` folder and then use `npm link gnhome-interface` within the `gnhome-server/nodejs` folder.

### How do I create a widget?
A widget is composed of two parts: A front-end folder with an `index.html` file, and a back-end folder with an `index.js` file that has a class that extends upon the `gnhome-interface`'s `Widget` class.

When you're done creating your widget, you can upload and install it via the site front-end itself. The back-end and front-end need to have their __*folder contents*__ stored in two, separate `.zip` files. The widget UUID you use in your application and on the site need to be the same. After that, the widget should be available in the widget selection list.

### I'd like to edit the site, but how?
Stylesheets and javascript is stored within the `gnhome-server/nodejs/site` folder under `static/style` and `static/src` respectively. The `site/views` folder contains `.ejs` files. `index.ejs` is mainly a container for the application, whereas anything under the `upload` folder contains status messages regarding the widget uploading system (which is separate from the application itself).

The application's front-end is mainly done within [Elm](https://elm-lang.org/) and stored under `gnhome-server/elm`. There are two bash scripts you can use to automatically compile and copy the current files to the nodejs side. In order to make these work, you need bash, the elm compiler and [Uglify JS](https://www.npmjs.com/package/uglify-js).