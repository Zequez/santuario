const VERBOSE = true;

export type ElmceptionConfig = {
  plugins: Plugin[];
  elementName: string;
  useShadowDom?: boolean | null;
  component: {
    init: (args: { flags: any; node: HTMLElement }) => ElmElement;
  };
};

export type ElmElement = {
  ports: {
    reportEvent: EventsReporter;
  };
};

export type Plugin = {
  before: (config: ElmceptionConfig, params: any) => any;
  after: (
    config: ElmceptionConfig,
    params: any,
    el: HTMLElement,
    eventReporter: EventsReporter
  ) => void;
};

export type ElmEvent = { event: string; payload: any };

export type EventsReporter = {
  subscribe: (callback: (event: ElmEvent) => void) => void;
};

const camelize = (str: string) => {
  // adapted from https://stackoverflow.com/questions/2970525/converting-any-string-into-camel-case#2970667
  return str
    .toLowerCase()
    .replace(/[-_]+/g, " ")
    .replace(/[^\w\s]/g, "")
    .replace(/ (.)/g, (firstChar) => firstChar.toUpperCase())
    .replace(/ /g, "");
};

const getProps = (el: HTMLElement) => {
  const props: any = {};

  for (let i = 0; i < el.attributes.length; i++) {
    const attribute = el.attributes[i];
    const name = camelize(attribute.name);
    props[name] = attribute.value;
  }
  return props;
};

const loggerGenerator = (namespace: string, elementName: string) => {
  return (extraText: string, ...values: any[]) =>
    VERBOSE
      ? console.info(
          `%c[${namespace}] %c<${elementName}> %c${extraText}`,
          "color: lightseagreen;",
          "color: teal;",
          "color: inherit;",
          ...values
        )
      : null;
};

export default (config: ElmceptionConfig) => {
  const logger = loggerGenerator("Elmception", config.elementName);

  class ElmceptionElement extends HTMLElement {
    connectedCallback() {
      try {
        let props = getProps(this);
        if (Object.keys(props).length === 0) props = undefined;

        const parentDiv = config.useShadowDom
          ? this.attachShadow({ mode: "open" })
          : this;

        const elmDiv = document.createElement("div");

        parentDiv.innerHTML = "";
        parentDiv.appendChild(elmDiv);

        props = config.plugins.reduce((props, plugin) => {
          return plugin.before(config, props);
        }, props);

        const elmElement = config.component.init({
          flags: props,
          node: elmDiv,
        });

        const eventsReporter = elmElement.ports.reportEvent;

        eventsReporter.subscribe((event: ElmEvent) => {
          logger(`[Event] [${event.event}]`, event.payload);
          parentDiv.dispatchEvent(
            new CustomEvent(event.event, { detail: event.payload })
          );
        });

        config.plugins.forEach((plugin) => {
          plugin.after(config, props, parentDiv as HTMLElement, eventsReporter);
        });

        logger(`Initialized`);

        // parentDiv.addEventListener("AgentKeys", (ev) => console.log("WHAT", ev));

        // setupPorts(elmElement.ports);
      } catch (error) {
        console.error(
          `Error from elm-web-components registering agent-signin`,
          error
        );
      }
    }

    disconnectedCallback() {
      logger(`Dettaching from DOM`);
    }
  }

  customElements.define(config.elementName, ElmceptionElement);
};
