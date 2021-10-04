module.exports = {
  purge: {
    mode: 'all', // Removes unused font-awesome fonts and icons
    content: ['./index.html', './dist/elm.js'],
  },
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {},
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
