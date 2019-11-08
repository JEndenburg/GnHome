const _dm_switch = document.getElementById("dark-mode-switch").querySelector("input");
_dm_switch.checked = (localStorage.getItem("_dm_darkmode") || "false") === "true";

function _dm_onSwitchToggled(event)
{
    _dm_updateMode();
}

function _dm_updateMode()
{
    localStorage.setItem("_dm_darkmode", _dm_switch.checked);
    document.getElementById("color-style").setAttribute("href", 
        _dm_switch.checked ? "../style/colors/light.css" : "../style/colors/dark.css"
    );
}

function _dm_init()
{
    _dm_updateMode();
    _dm_switch.addEventListener("click", _dm_onSwitchToggled);
}

_dm_init();