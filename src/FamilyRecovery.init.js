import FamilyRecovery from "./FamilyRecovery.elm";
import MapboxElement from "./MapboxElement";
import ElmDebugger from "elm-debug-transformer";

ElmDebugger.register();

const app = FamilyRecovery.FamilyRecovery.init({
  node: document.getElementById("app"),
  flags: {},
});
