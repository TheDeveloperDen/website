/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.elm"],
  theme: {
    extend: {
      colors: {
        dd: {
          deepblue: 'var(--color-den-deepblue)',
          teal: 'var(--color-den-teal)',
          pink: 'var(--color-den-pink)',
          indigo: 'var(--color-den-indigo)',
        }
      }
    },
  },
  variants: [],
  plugins: [],
}

