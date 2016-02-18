module.exports = function(config) {
  config.set({
    plugins: [
      'karma-coffee-preprocessor',
      'karma-jasmine',
      'karma-phantomjs-launcher',
      'karma-spec-reporter'
    ],

    preprocessors: {
      './app/javascripts/*.coffee': ['coffee'],
      './spec/*.coffee': ['coffee']
    },

    browsers: ['PhantomJS'],
    frameworks: ['jasmine'],
    reporters: ['spec'],

    coffeePreprocessor: {
      options: { bare: true, sourceMap: false },
      transformPath: function(path) { return path.replace(/\.coffee$/, '.js') }
    },

    files: [
      'https://cdnjs.cloudflare.com/ajax/libs/underscore.js/1.8.3/underscore-min.js',
      './app/javascripts/*.coffee',
      './spec/*.coffee'
    ]
  });
}
