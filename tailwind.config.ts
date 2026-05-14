/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.elm"],
  theme: {
    extend: {
      colors: {
        dd: {
          deepblue: 'var(--color-den-deepblue)',
          deepblueLighter: 'var(--color-den-deepblue-lighter)',
          teal: 'var(--color-den-teal)',
          pink: 'var(--color-den-pink)',
          indigo: 'var(--color-den-indigo)',
        }
      },
      fontFamily: {
        mono: ['Cascadia Code Variable', 'monospace'],
        sans: ['Montserrat', 'sans-serif'],
      }
    },
  },
  variants: [],
  plugins: [],
}

