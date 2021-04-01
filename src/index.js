// Development
import ElmDebugger from "elm-debug-transformer";
if (import.meta.env.ENV === "development") {
  ElmDebugger.register();
}

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

window.setLanguage = setLanguage;

// Sub-apps
import Communities from "./Communities/Main.elm";
import FamilyRecovery from "./FamilyRecovery/Main.elm";
import MetaCards from "./MetaCards/Main.elm";
import Agora from "./Agora/Main.elm";
import KintoStorage from "./KintoStorage/Main.elm";
import Turnos from "./Turnos/Main.elm";

const apps = {
  Communities: Communities.Communities.Main.init,
  FamilyRecovery: FamilyRecovery.FamilyRecovery.Main.init,
  MetaCards: MetaCards.MetaCards.Main.init,
  Agora: Agora.Agora.Main.init,
  KintoStorage: KintoStorage.KintoStorage.Main.init,
  Turnos: Turnos.Turnos.Main.init,
};

const el = document.querySelector("[data-app]");

if (el) {
  apps[el.dataset.app]({
    node: el,
    flags: {},
  });
}
