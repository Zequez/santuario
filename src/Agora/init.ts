import Elm from "./Main.elm";
import MapboxElement from "../MapboxElement/MapboxElement";

import ElmDebugger from "elm-debug-transformer";
ElmDebugger.register();

const app = (Elm as any).Agora.Main.init({
  node: document.getElementById("app"),
  flags: {},
});
