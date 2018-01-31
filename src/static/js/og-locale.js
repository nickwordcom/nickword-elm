var ogLocale = function (locale) {
  switch (locale) {
    case 'uk':
      return 'uk_UA';
      break;
    case 'ru':
      return 'ru_RU';
      break;
    case 'es':
      return 'es_ES';
      break;
    default:
      return 'en_US';
  }
}

module.exports = ogLocale;
