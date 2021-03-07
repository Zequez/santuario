module.exports = {
  purge: [
    "./src/**/*.elm",
    "./src/**/*.js",
    "./src/**/*.ts",
    "./routes/**/*.pug",
    "./routes/**/*.njk",
  ],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {},
  },
  variants: {
    extend: {},
  },
  plugins: [],
};
