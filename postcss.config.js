const postcssElmTailwind = require("postcss-elm-tailwind")({
    tailwindConfig: "./tailwind.config.js", // tell us where your tailwind.config.js lives
    // only the tailwindConfig key is required, the rest are optional:
    elmFile: "src/Tailwind.elm", // change where the generated Elm module is saved
    elmModuleName: "Tailwind", // this must match the file name or Elm will complain
    nameStyle: "snake", // "snake" for snake case, "camel" for camel case
    splitByScreens: true // generate an Elm module for each screen
})

module.exports = {
    plugins: [
        require("tailwindcss"),
        ...(process.env.NODE_ENV === "production" ? [] : [postcssElmTailwind]),
    ]
};