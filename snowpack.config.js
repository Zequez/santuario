module.exports = {
  plugins: [
    [
      "@snowpack/plugin-babel",
      {
        input: [".js"],
        transformOptions: {
          presets: ["@babel/preset-env"],
          plugins: [
            ["@babel/plugin-proposal-decorators", { legacy: true }],
            ["@babel/plugin-proposal-class-properties", { legacy: true }],
          ],
        },
      },
    ],
    "@snowpack/plugin-postcss",
    "snowpack-plugin-elm",
  ],
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
