module.exports = function rawCssPlugin(snowpackConfig, options = {}) {
  return {
    name: "plugin-raw-css",
    resolve: {
      input: options.input || ["mapbox-gl.css"],
      output: [".js"],
    },
    async load({ filePath }) {
      const contents = await fs.readFile(filePath, "utf-8");
      return `export default ${JSON.stringify(contents)};`;
    },
  };
};
