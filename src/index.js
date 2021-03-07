import ElmDebugger from "elm-debug-transformer";
import Elm from "./Main.elm";
import MapboxElement from "./MapboxElement";

ElmDebugger.register();

const app = Elm.Main.init({
  node: document.getElementById("app"),
  flags: {},
});
