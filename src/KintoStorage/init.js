import Elm from "./Main.elm";

import ElmDebugger from "elm-debug-transformer";
ElmDebugger.register();

const app = Elm.KintoStorage.Main.init({
  node: document.getElementById("app"),
  flags: {},
});
