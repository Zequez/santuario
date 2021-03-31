const colors = require("tailwindcss/colors");

module.exports = {
  purge: [
    "./src/**/*.elm",
    "./src/**/*.js",
    "./src/**/*.ts",
    "./routes/**/*.pug",
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
    extend: {
      opacity: ["disabled"],
      ringWidth: ["hover"],
      ringOpacity: ["hover", "active"],
      borderRadius: ["last", "first"],
    },
  },
  plugins: [],
};
