const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim,liquid}',
    './app/components/**/*.{erb,haml,html,slim,rb}',
    './config/initializers/simple_form.rb',
  ],
  safelist: [
    {
      pattern: /^ts-/,
    },
    "cm-scroller"
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
      colors: {
        primary: '#2A7BF7',
        'primary-hover': '#4D91F7',
        'primary-selected': '#1E6CE3',
        'gray-background': '#F3F4F6',
        'gray-border': '#E6E6E7',
        'gray-background-highlight': '#E6E6E6',
        'search-highlight': '#FFE085'
      }
    },
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/typography'),
  ]
}
