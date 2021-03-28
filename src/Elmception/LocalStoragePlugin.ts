import { Plugin, ElmceptionConfig } from "./Element";

const VERBOSE = true;

const logger = (config: ElmceptionConfig, text: string, value?: any) =>
  VERBOSE
    ? console.info(
        `[LocalStoragePlugin] [${config.elementName}] ${text}`,
        value
      )
    : null;

const LOCAL_STORAGE_EVENT = "Save";
const localStoragePlugin: Plugin = {
  before: (config, params) => {
    let localStorageValue = localStorage.getItem(config.elementName);
    if (localStorageValue !== null) {
      try {
        localStorageValue = JSON.parse(localStorageValue);
        logger(config, "Found data", localStorageValue);
      } catch (e) {
        logger(config, "No stored data found");
      }
    }

    const newParams = Object.assign({}, params, {
      storage: localStorageValue,
    });
    return newParams;
  },

  after: (config, params, el, eventsReporter) => {
    eventsReporter.subscribe((event) => {
      if (event.event === LOCAL_STORAGE_EVENT) {
        logger(config, "Saving", event.payload);
        localStorage.setItem(config.elementName, JSON.stringify(event.payload));
      }
    });
  },
};

export default localStoragePlugin;
