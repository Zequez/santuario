import Elm from "./MetaCards2.elm";

import ElmDebugger from "elm-debug-transformer";
ElmDebugger.register();

const app = Elm.MetaCards2.MetaCards2.init({
  node: document.getElementById("app"),
  flags: {},
});
