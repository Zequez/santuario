import Elm from "./Main.elm";
import { registerCustomElement, registerPorts } from "elm-mapbox";
import "mapbox-gl/dist/mapbox-gl.css";

const token =
  "pk.eyJ1IjoiemVxdWV6IiwiYSI6ImNrbHZueG1qMTB1d3Iyd2xveW1xZmZlYmgifQ.83Kf-ZweJHKFnPrlrSHP9Q";

registerCustomElement({
  token,
  onMount: (mapbox) => {
    console.log("Instantiated MapBox!", mapbox);
  },
});

const app = Elm.Main.init({
  node: document.getElementById("app"),
  flags: {},
});

// registerPorts(app);
