module.exports = {
  plugins: ["@snowpack/plugin-postcss", "snowpack-plugin-elm"],
  packageOptions: {},
  devOptions: {
    open: "none",
  },
  buildOptions: {},
  routes: [],
  mount: {
    src: "/dist",
    public: "/",
  },
  alias: {},
};
