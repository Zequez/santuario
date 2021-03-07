const fs = require("fs");

function rawificateFiles(filePaths) {
  filePaths.forEach((filePath) => {
    let content = JSON.stringify(fs.readFileSync(filePath, "utf-8"));
    fs.writeFileSync(filePath + "raw.js", `export default ${content}`);
  });
}

rawificateFiles(["node_modules/mapbox-gl/dist/mapbox-gl.css"]);

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
