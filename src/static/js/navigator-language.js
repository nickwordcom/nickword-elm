function navigatorLanguage() {
   var language = navigator.languages
                            ? navigator.languages[0]
                            : (navigator.language || navigator.userLanguage);

  switch (language.slice(0, 2)) {
    case 'uk':
      return 'Ukrainian';
    case 'ru':
      return 'Russian';
    case 'es':
      return 'Spanish';
    default:
      return 'English'
  }
}

module.exports = navigatorLanguage;
