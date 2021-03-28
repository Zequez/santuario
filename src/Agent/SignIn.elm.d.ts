type Flags = {
  kintoKeys: string;
  storage: {
    user: string;
    password: string;
  };
};

declare const Elm: {
  Agent: {
    SignIn: {
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
