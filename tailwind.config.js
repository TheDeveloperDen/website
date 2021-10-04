module.exports = {
    purge: {
        enabled: true,
        mode: 'all', // Removes unused font-awesome fonts and icons
        content: ['./index.html', './src/**/*.elm'],
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
