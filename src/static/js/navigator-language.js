function navigatorLanguage() {
   var language = navigator.languages
                            ? navigator.languages[0]
                            : (navigator.language || navigator.userLanguage);

  switch (language.slice(0, 2)) {
    case 'uk':
      return 'uk';
    case 'ru':
      return 'ru';
    case 'es':
      return 'es';
    default:
      return 'en'
  }
}

module.exports = navigatorLanguage;
