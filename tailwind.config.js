module.exports = {
    purge: {
        mode: 'all', // Removes unused font-awesome fonts and icons
        content: ['./index.html', './dist/app.js'],
    },
    darkMode: false, // or 'media' or 'class'
    theme: {
        fontFamily: {
            'mono': ['JetBrains Mono']
        }
    },
    plugins: [],
}
