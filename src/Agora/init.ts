import Elm from "./Main.elm";
import MapboxElement from "../MapboxElement/MapboxElement";
import registerAgentSignIn from "../Agent/SignIn.Element";

registerAgentSignIn();

import ElmDebugger from "elm-debug-transformer";
ElmDebugger.register();

const app = (Elm as any).Agora.Main.init({
  node: document.getElementById("app"),
  flags: {},
});
