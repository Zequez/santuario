// import ElmComponent from "./SignIn.elm";
import Elm from "../Santuario.elmproj";
import localStoragePlugin from "../Elmception/LocalStoragePlugin";
import elmception from "../Elmception/Element";

export default () =>
  elmception({
    elementName: "agent-signin",
    plugins: [localStoragePlugin],
    component: Elm.Agent.SignIn,
  });
