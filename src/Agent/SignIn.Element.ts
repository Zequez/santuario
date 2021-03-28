import ElmComponent from "./SignIn.elm";
import localStoragePlugin from "../Elmception/LocalStoragePlugin";
import elmception from "../Elmception/Element";

export default () =>
  elmception({
    elementName: "agent-signin",
    plugins: [localStoragePlugin],
    component: ElmComponent.Agent.SignIn,
  });
