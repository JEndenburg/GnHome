let _nav_collapsed = (localStorage.getItem("_nav_collapsed") || "true") === "true";

function _nav_onCollapseButtonClicked(event) 
{
    _nav_collapsed = !_nav_collapsed;
    localStorage.setItem("_nav_collapsed", _nav_collapsed);
    _nav_updateNavBar();
}

function _nav_updateNavBar()
{
    const collapseButton = document.getElementById("nav-collapse");
    if(_nav_collapsed)
    {
        document.documentElement.style.setProperty("--nav-offset", "calc(-20vw + 5.25vh)");
        collapseButton.style.setProperty("transform", "rotateY(0deg)");
    }
    else
    {
        document.documentElement.style.setProperty("--nav-offset", "0");
        collapseButton.style.setProperty("transform", "rotateY(180deg)");
    }
}

function _nav_init()
{
    const collapseButton = document.getElementById("nav-collapse");
    collapseButton.addEventListener("click", _nav_onCollapseButtonClicked);
    _nav_updateNavBar();
}

_nav_init();