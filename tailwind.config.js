const colors = require("tailwindcss/colors");

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
    extend: {
      colors: {
        green: colors.lime,
      },
    },
  },
  variants: {
    extend: {},
  },
  plugins: [],
};
