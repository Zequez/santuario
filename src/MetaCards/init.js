import Elm from "./MetaCards.elm";

import ElmDebugger from "elm-debug-transformer";
ElmDebugger.register();

const app = Elm.MetaCards.MetaCards.init({
  node: document.getElementById("app"),
  flags: {},
});
