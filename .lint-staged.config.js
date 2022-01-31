module.exports = {
  'src/**/*.sol': ['yarn fmt', 'yarn lint'],
  'out/**/*': [() => 'yarn fmt:output'],
};
