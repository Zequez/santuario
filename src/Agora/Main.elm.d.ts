type Flags = {};

declare const Elm: {
  Agora: {
    Main: {
      init: ({
        node,
        flags,
      }: {
        node: HTMLElement;
        flags: Flags;
      }) => { ports: { reportEvent: { subscribe: (event: any) => void } } };
    };
  };
};

export default Elm;
