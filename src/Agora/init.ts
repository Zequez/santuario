import Elm from "./Main.elm";
// import MapboxElement from "../MapboxElement/MapboxElement";

const app = (Elm as any).Agora.Main.init({
  node: document.getElementById("app"),
  flags: {},
});
