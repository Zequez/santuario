import registerAgentSignIn from "./Agent/SignIn.Element";
import ElmDebugger from "elm-debug-transformer";

if (import.meta.env.ENV === "development") {
  ElmDebugger.register();
}

registerAgentSignIn();

console.log("Regular ol index");
