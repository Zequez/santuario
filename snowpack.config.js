const fs = require("fs");
const fg = require("fast-glob");
const { env } = require("process");
const yaml = require("js-yaml");
const BundleAnalyzerPlugin = require("webpack-bundle-analyzer")
  .BundleAnalyzerPlugin;

const i18n = {
  en: yaml.load(fs.readFileSync("./src/I18n/translations/en.yaml", "utf8")),
  es: yaml.load(fs.readFileSync("./src/I18n/translations/es.yaml", "utf8")),
};

function excludeEverythingButEntryPoints(entryPoints) {
  return env.NODE_ENV === "development"
    ? []
    : fg
        .sync("src/**/*.elm", {
          ignore: entryPoints.map((v) => `**/${v}`),
        })
        .map((v) => v.replace(/^src\//, "**/"));
}

function rawificateFiles(filePaths) {
  filePaths.forEach((filePath) => {
    let content = JSON.stringify(fs.readFileSync(filePath, "utf-8"));
    fs.writeFileSync(filePath + "raw.js", `export default ${content}`);
  });
}

rawificateFiles(["node_modules/mapbox-gl/dist/mapbox-gl.css"]);

// const htmlToDirectoriesSnowpackPlugin = {
//   name: "@zequez/snowpack-plugin-html-to-directories",
//   resolve: {
//     input: [".html"],
//     output: [".html"],
//   },
// };
// function htmlToDirectoriesSnowpackPlugin(config, args = {}) {}

// const elmProjectSnowpackplugin = {
//   module.exports = (snowpackConfig, userPluginOptions) => {
//     const elmModules = new Map();
//     const options = sanitizeOptions(userPluginOptions);
//     const allEntryPoints =

//     return {
//       name: "elm-project-snowpack-plugin"
//       , resolve: {input: ['.js', '.elm', '.elmproj'], output: ['.js']}
//     }
// }

module.exports = {
  env: {
    ENV: env.NODE_ENV,
  },
  plugins: [
    // [
    //   "@snowpack/plugin-babel",
    //   {
    //     input: [".js"],
    //     transformOptions: {
    //       presets: [["@babel/preset-env", { useBuiltIns: "usage" }]],
    //       plugins: [
    //         ["@babel/plugin-proposal-decorators", { legacy: true }],
    //         ["@babel/plugin-proposal-class-properties", { legacy: true }],
    //         ["@babel/plugin-transform-runtime", { regenerator: true }],
    //       ],
    //     },
    //   },
    // ],
    "@snowpack/plugin-postcss",
    [
      "snowpack-plugin-elm",
      {
        verbose: false,
      },
    ],
    [
      "@marlonmarcello/snowpack-plugin-pug",
      { data: { translations: i18n, env: env.NODE_ENV } },
    ],
    [
      "@snowpack/plugin-webpack",
      {
        extendConfig: (config) => {
          config.plugins.push(
            new BundleAnalyzerPlugin({
              generateStatsFile: true,
              openAnalyzer: false,
            })
          );
          return config;
        },
      },
    ],
    ["snowpack-plugin-yaml"],
    // ["@snowpack/plugin-optimize"],
  ],
  packageOptions: {},
  devOptions: {
    open: "none",
    port: 3000,
    output: "stream",
    hmr: false,
  },
  buildOptions: {},
  exclude: excludeEverythingButEntryPoints([
    "Main.elm",
    "MetaCards.elm",
    "MetaCards2.elm",
    "SignIn.elm",
  ]).concat(["**/_helpers/**", "routes.yml"]),
  routes: [],
  mount: {
    src: "/dist",
    public: "/",
    routes: "/",
  },
  alias: {},
};
