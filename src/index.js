// Development
// import ElmDebugger from "elm-debug-transformer";
// if (import.meta.env.ENV === "development") {
//   ElmDebugger.register();
// }

// Shared custom elements
import registerAgentSignIn from "./Agent/SignIn.Element";
import MapboxElement from "./MapboxElement/MapboxElement";
import registerI18nElement, {
  autoDetectLanguage,
  setLanguage,
} from "./I18n/i18nElement";

autoDetectLanguage();
registerAgentSignIn();
registerI18nElement();

// Sub-apps
import Elm from "./Santuario.elmproj";

const apps = {
  Communities: Elm.Communities.Main.init,
  FamilyRecovery: Elm.FamilyRecovery.Main.init,
  MetaCards: Elm.MetaCards.Main.init,
  Agora: Elm.Agora.Main.init,
  KintoStorage: Elm.KintoStorage.Main.init,
  Turnos: Elm.Turnos.Main.init,
};

const el = document.querySelector("[data-app]");

if (el) {
  apps[el.dataset.app]({
    node: el,
    flags: {},
  });
}
