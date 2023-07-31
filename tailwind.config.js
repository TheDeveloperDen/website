module.exports = {
    purge: {
        mode: 'all', // Removes unused font-awesome fonts and icons
        content: ['./index.html', './dist/elm.js'],
    },
    darkMode: 'media', // or 'media' or 'class'
    theme: {
        fontFamily: {
            'montserrat': ['Montserrat', 'sans-serif'],
            'cascadia': ['Cascadia Code', 'monospace'],
        },
        extend: {
            colors: {
                'deep-blue': '#171834',
                'teal': '#00afc3',
                'pink': '#ff52f9',
                'indigo': '#8099ff'
            }
        }
    },
    plugins: [],
}
