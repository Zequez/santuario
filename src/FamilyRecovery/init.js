import Elm from "./Main.elm";
import MapboxElement from "./MapboxElement";

import ElmDebugger from "elm-debug-transformer";
ElmDebugger.register();

console.log(Elm);

const app = Elm.FamilyRecovery.Main.init({
  node: document.getElementById("app"),
  flags: {},
});
