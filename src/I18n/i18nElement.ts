import en from "./translations/en.yaml";
import es from "./translations/es.yaml";

const DEFAULT_LANG = "en";

type I18nObject = { [key: string]: LangObject };
type LangObject = { [key: string]: string };

const i18n: I18nObject = { en, es };

const getProps = (el: HTMLElement) => {
  const props: any = {};

  for (let i = 0; i < el.attributes.length; i++) {
    const attribute = el.attributes[i];
    const name = attribute.name;
    props[name] = attribute.value;
  }

  return props;
};

let currentLang = "";
export function autoDetectLanguage() {
  const preferredLang = localStorage.getItem("lang");
  if (preferredLang) {
    setLanguage(preferredLang);
  } else {
    const languageNotDetected = Object.keys(i18n).every((langCode) => {
      if (new RegExp(`^${langCode}`).test(navigator.language)) {
        setLanguage(langCode);
        return false;
      }
      return true;
    });
    if (languageNotDetected) {
      setLanguage(DEFAULT_LANG);
    }
  }
}

let subscriptions: Callback[] = [];
export function setLanguage(langCode: string) {
  const langObject = i18n[langCode];
  if (langObject) {
    currentLang = langCode;
    localStorage.setItem("lang", langCode);
    subscriptions.forEach((cb) => {
      cb(langCode, langObject);
    });
  } else {
    console.error(`No language with lang code ${langCode}`);
  }
}

type Callback = (langCode: string, langObject: LangObject) => void;

function languageChangeStream(cb: Callback) {
  subscriptions.push(cb);
  return () => {
    subscriptions.splice(subscriptions.indexOf(cb), 1);
  };
}

export function getLang() {
  return localStorage.getItem("lang") || DEFAULT_LANG;
}

export function getI18n() {
  return i18n[getLang()];
}

class I18nElement extends HTMLElement {
  props: { [key: string]: string } = {};
  key: string = "";
  unsubscribe: () => void = () => {};

  setText(langObject: LangObject) {
    const text = langObject[this.key];
    if (!text) {
      console.error(
        `%c [I18n] No translation key found for: %c ${langObject._} -> ${this.key}`,
        "color: red;",
        "color: lightblue;"
      );
      this.innerText = `{${this.key}}`;
    } else {
      this.innerText = text;
    }
  }

  connectedCallback() {
    this.props = getProps(this);
    this.key = this.props.key;
    this.setText(getI18n());
    this.unsubscribe = languageChangeStream((langCode, langObject) =>
      this.setText(langObject)
    );
  }
}

function updateActive(lang: string) {
  document.querySelectorAll("[data-set-lang]").forEach((el) => {
    console.log(el);

    el.classList.toggle("active", (el as any).dataset.setLang === lang);
  });
}

export default () => {
  document.documentElement.addEventListener("click", (ev) => {
    let dataset = (ev.target as any).dataset;
    if (dataset && dataset.setLang) {
      setLanguage(dataset.setLang);
      updateActive(dataset.setLang);
    }
  });

  updateActive(getLang());

  customElements.define("st-i18n", I18nElement);
};
