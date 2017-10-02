exports.config = {
  directConnect: true,

  // Capabilities to be passed to the webdriver instance.
  capabilities: {
    'browserName': 'chrome',
  },

  specs: ['test/e2e/dist/**/*.ts'],

  plugins: [{
    package: 'aurelia-protractor-plugin'
  }],

  onPrepare: () => {
    require('ts-node')
      .register({
        compilerOptions: { module: 'amd' },
        disableWarnings: true,
        fast: true
      });
  },

  jasmineNodeOpts: {
    showColors: true,
    defaultTimeoutInterval: 30000
  }
};
