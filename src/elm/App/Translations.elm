module App.Translations exposing (Language(..), TranslationId(..), decodeLang, translate)

import App.Utils.Pluralize exposing (..)


type Language
    = English
    | Ukrainian
    | Russian
    | Spanish


type alias TranslationSet =
    { english : String
    , ukrainian : String
    , russian : String
    , spanish : String
    }


type TranslationId
    = InOneWord
    | DescribeIOWText
    | DescribeText
    | WordText
    | HomePageText
    | LoadingText
    | ErrorText String
    | LoadMoreText
    | NotFound
    | ShowText
    | HideText
    | FiltersText
    | CountryText
    | EmotionsText
    | TranslateWordsText
    | TrendingTitle
    | TrendingNowText
    | TrendingNowSubTitle
    | ShowAllTrendingText
    | NumberOfEntriesText Int
    | NumberOfVotesText Int
    | CreateEntryText
    | RandomEntryText
    | MyEntriesText
    | MyEntriesDescText
    | CategoriesText
    | IEText String
    | IEJustText
    | SearchPlaceholder
    | SearchWithTermText String
    | SearchWordPlaceholder
    | AllWorldText
    | ShareText
    | CloseText
    | CancelText
    | ShareDownloadImageText
    | EditText
    | UpdateText
    | ShowMoreText
    | ShowAllText
    | ShowAllWordsText
    | VotesAmountK String
    | VotesReceivedText Int
    | ImageSourceText
    | ImageCaptionText
    | YourWordText
    | NewWordFormWarning
    | ShortWord
    | WordSuccessfullyAdded String
    | VoteIsNotCounted String
    | AlreadyVotedText String
    | WordListEmptyText
    | WordsTabText
    | VotesTabLongText
    | VotesTabShortText
    | CloudTabLongText
    | CloudTabShortText
    | MapTabLongText
    | MapTabShortText
    | IncludeVotesFromText
    | NoVotesText
    | LatestHundredText
    | NVotesOutOfText Int Int
    | GoogleImagesText
    | PageNotFoundText
    | PageNotFoundDescription
    | LogInToastText
    | LanguagesText
    | LogoutText
    | AllText
    | PositiveText
    | NeutralText
    | NegativeText
      -- Log in form
    | LoginText
    | LoginFormHeader
    | LoginFormPrimaryDescr
    | LoginFormSecondaryDescr
    | ContWtFacebookText
    | ContWtGoogleText
    | ContWtVkText
    | ItIsSecureAndReliable
      -- Form texts
    | TitleText
    | TitlePlaceholder
    | SubtitleText
    | CategoryText
    | SelectCategoryText
    | DescriptionText
    | DescriptionPlaceholder
    | ImageUrlText
    | ImageUrlInfoText
    | ImageCaptionFieldText
    | SubmitEntryFormText
      -- Form validation messages
    | TitleMustPresent
    | TitleTooShort
    | TitleTooLong
    | DescriptionMustPresent
    | DescriptionTooLong
    | InvalidImageURL
    | InvalidImageFormat
    | SomethingWentWrong


translate : Language -> TranslationId -> String
translate language translationId =
    let
        translationSet =
            case translationId of
                InOneWord ->
                    { english = "in one word"
                    , ukrainian = "одним словом"
                    , russian = "одним словом"
                    , spanish = "en una palabra"
                    }

                DescribeIOWText ->
                    { english = "Describe in one word"
                    , ukrainian = "Опишіть одним словом"
                    , russian = "Опишите одним словом"
                    , spanish = "Describir en una palabra"
                    }

                DescribeText ->
                    { english = "Describe"
                    , ukrainian = "Описати"
                    , russian = "Описать"
                    , spanish = "Describir"
                    }

                WordText ->
                    { english = "Word"
                    , ukrainian = "Слово"
                    , russian = "Слово"
                    , spanish = "Palabra"
                    }

                HomePageText ->
                    { english = "Home Page"
                    , ukrainian = "Головна сторінка"
                    , russian = "Главная страница"
                    , spanish = "Página De Inicio"
                    }

                LoadingText ->
                    { english = "Loading..."
                    , ukrainian = "Завантаження..."
                    , russian = "Загрузка..."
                    , spanish = "Carga..."
                    }

                ErrorText error ->
                    { english = "Error: " ++ error
                    , ukrainian = "Помилка: " ++ error
                    , russian = "Ошибка: " ++ error
                    , spanish = "Error: " ++ error
                    }

                LoadMoreText ->
                    { english = "Load more..."
                    , ukrainian = "Завантажити більше..."
                    , russian = "Загрузить больше..."
                    , spanish = "Cargar más..."
                    }

                NotFound ->
                    { english = "Not Found"
                    , ukrainian = "Не знайдено"
                    , russian = "Не найдено"
                    , spanish = "No Se Encuentra"
                    }

                ShowText ->
                    { english = "Show"
                    , ukrainian = "Показати"
                    , russian = "Показать"
                    , spanish = "Mostrar"
                    }

                HideText ->
                    { english = "Hide"
                    , ukrainian = "Приховати"
                    , russian = "Скрыть"
                    , spanish = "Ocultar"
                    }

                FiltersText ->
                    { english = "Filters"
                    , ukrainian = "Фільтри"
                    , russian = "Фильтры"
                    , spanish = "Filtros"
                    }

                CountryText ->
                    { english = "Country"
                    , ukrainian = "Країна"
                    , russian = "Страна"
                    , spanish = "País"
                    }

                EmotionsText ->
                    { english = "Emotions"
                    , ukrainian = "Емоції"
                    , russian = "Эмоции"
                    , spanish = "Emociones"
                    }

                TranslateWordsText ->
                    { english = "Translate the words into English"
                    , ukrainian = "Перекласти слова на англійську мову"
                    , russian = "Перевести слова на английский язык"
                    , spanish = "Traducir las palabras en inglés"
                    }

                TrendingTitle ->
                    { english = "Trending"
                    , ukrainian = "Популярне"
                    , russian = "Популярное"
                    , spanish = "Tendencias"
                    }

                TrendingNowText ->
                    { english = "Trending Now"
                    , ukrainian = "Популярне Зараз"
                    , russian = "Популярное сейчас"
                    , spanish = "La Tendencia Ahora"
                    }

                TrendingNowSubTitle ->
                    { english = "Describe the most popular entries"
                    , ukrainian = "Опишіть найпопулярніші записи"
                    , russian = "Опишите самые популярные записи"
                    , spanish = "Describir las entradas más populares"
                    }

                ShowAllTrendingText ->
                    { english = "Show all Trending"
                    , ukrainian = "Показати всі популярні"
                    , russian = "Показать все популярные"
                    , spanish = "Mostrar todos de tendencia"
                    }

                NumberOfEntriesText entriesSize ->
                    { english = pluralize "entry" "entries" entriesSize
                    , ukrainian = pluralizeUk "запис" "записи" "записів" entriesSize
                    , russian = pluralizeRu "запись" "записи" "записей" entriesSize
                    , spanish = pluralizeEs "entrada" "entradas" entriesSize
                    }

                NumberOfVotesText votesSize ->
                    { english = pluralize "vote" "votes" votesSize
                    , ukrainian = pluralizeUk "голос" "голоси" "голосів" votesSize
                    , russian = pluralizeRu "голос" "голоса" "голосов" votesSize
                    , spanish = pluralizeEs "voto" "votos" votesSize
                    }

                CreateEntryText ->
                    { english = "Create Entry"
                    , ukrainian = "Створити Запис"
                    , russian = "Создать Запись"
                    , spanish = "Crear entrada"
                    }

                RandomEntryText ->
                    { english = "Random Entry"
                    , ukrainian = "Випадковий Запис"
                    , russian = "Случайная Запись"
                    , spanish = "Entrada al azar"
                    }

                MyEntriesText ->
                    { english = "My Entries"
                    , ukrainian = "Мої записи"
                    , russian = "Мои записи"
                    , spanish = "Mis Entradas"
                    }

                MyEntriesDescText ->
                    { english = "Entries created by me"
                    , ukrainian = "Записи, створені мною"
                    , russian = "Записи, созданные мной"
                    , spanish = "Entradas creadas por mí"
                    }

                CategoriesText ->
                    { english = "Categories"
                    , ukrainian = "Категорії"
                    , russian = "Категории"
                    , spanish = "Categorías"
                    }

                IEText value ->
                    { english = "i.e., " ++ value
                    , ukrainian = "напр., " ++ value
                    , russian = "напр., " ++ value
                    , spanish = "i.e., " ++ value
                    }

                IEJustText ->
                    { english = "i.e., "
                    , ukrainian = "напр., "
                    , russian = "напр., "
                    , spanish = "i.e., "
                    }

                SearchPlaceholder ->
                    { english = "Search..."
                    , ukrainian = "Пошук..."
                    , russian = "Поиск..."
                    , spanish = "Búsqueda..."
                    }

                SearchWithTermText term ->
                    { english = "Search: " ++ term
                    , ukrainian = "Пошук: " ++ term
                    , russian = "Поиск: " ++ term
                    , spanish = "Búsqueda: " ++ term
                    }

                SearchWordPlaceholder ->
                    { english = "Search a word..."
                    , ukrainian = "Пошук слова..."
                    , russian = "Поиск слова..."
                    , spanish = "Búsqueda de una palabra"
                    }

                AllWorldText ->
                    { english = "All World"
                    , ukrainian = "Весь Світ"
                    , russian = "Весь мир"
                    , spanish = "Todo el mundo"
                    }

                ShareText ->
                    { english = "Share"
                    , ukrainian = "Поділитися"
                    , russian = "Поделиться"
                    , spanish = "Compartir"
                    }

                ShareDownloadImageText ->
                    { english = "Open the Image"
                    , ukrainian = "Відкрити зображення"
                    , russian = "Открыть изображение"
                    , spanish = "Abrir la imagen"
                    }

                EditText ->
                    { english = "Edit"
                    , ukrainian = "Редагувати"
                    , russian = "Редактировать"
                    , spanish = "Editar"
                    }

                UpdateText ->
                    { english = "Update"
                    , ukrainian = "Оновити"
                    , russian = "Обновить"
                    , spanish = "Actualizar"
                    }

                CloseText ->
                    { english = "Close"
                    , ukrainian = "Закрити"
                    , russian = "Закрыть"
                    , spanish = "Cerrar"
                    }

                CancelText ->
                    { english = "Cancel"
                    , ukrainian = "Скасувати"
                    , russian = "Отменить"
                    , spanish = "Cancelar"
                    }

                ShowMoreText ->
                    { english = "Show more"
                    , ukrainian = "Показати більше"
                    , russian = "Показать больше"
                    , spanish = "Mostrar más"
                    }

                ShowAllText ->
                    { english = "Show all"
                    , ukrainian = "Показати всі"
                    , russian = "Показать все"
                    , spanish = "Mostrar todo"
                    }

                ShowAllWordsText ->
                    { english = "Show all words"
                    , ukrainian = "Показати всі слова"
                    , russian = "Показать все слова"
                    , spanish = "Mostrar todas las palabras"
                    }

                VotesAmountK value ->
                    { english = value ++ "k"
                    , ukrainian = value ++ "т"
                    , russian = value ++ "т"
                    , spanish = value ++ "k"
                    }

                VotesReceivedText votesSize ->
                    let
                        text str =
                            String.dropLeft (String.length (toString votesSize)) str
                    in
                    { english = text <| pluralize "vote" "votes" votesSize ++ " received"
                    , ukrainian = text <| pluralizeUk "голос" "голоси" "голосів" votesSize ++ " отримано"
                    , russian = text <| pluralizeRu "голос" "голоса" "голосов" votesSize ++ " получено"
                    , spanish = text <| pluralizeEs "voto" "votos" votesSize ++ " recibidos"
                    }

                ImageSourceText ->
                    { english = "Image source:"
                    , ukrainian = "Джерело зображ.:"
                    , russian = "Источник изображ.:"
                    , spanish = "Fuente de la imagen:"
                    }

                ImageCaptionText ->
                    { english = "Photo:"
                    , ukrainian = "Фото:"
                    , russian = "Фото:"
                    , spanish = "Foto:"
                    }

                YourWordText ->
                    { english = "Your word..."
                    , ukrainian = "Ваше слово..."
                    , russian = "Ваше слово..."
                    , spanish = "Tu palabra..."
                    }

                NewWordFormWarning ->
                    { english = "Prove you are not a Robot - login with your social account"
                    , ukrainian = "Доведіть, що Ви не робот - увійдіть за допомогою соціальних мереж"
                    , russian = "Докажите, что Вы не робот - войдите с помощью социальных сетей"
                    , spanish = "Demostrar que no eres un Robot - iniciar sesión con tu cuenta Social"
                    }

                ShortWord ->
                    { english = "The word is too short."
                    , ukrainian = "Слово надто короткe."
                    , russian = "Слово слишком короткое."
                    , spanish = "La palabra es demasiado corta."
                    }

                WordSuccessfullyAdded word ->
                    { english = "The word '" ++ word ++ "' added successfully."
                    , ukrainian = "Слово '" ++ word ++ "' успішно додано."
                    , russian = "Слово '" ++ word ++ "' успешно добавлено."
                    , spanish = "La palabra '" ++ word ++ "' agregada con éxito."
                    }

                VoteIsNotCounted word ->
                    { english = "Your vote for word '" ++ word ++ "' is not counted."
                    , ukrainian = "Ваш голос за слово '" ++ word ++ "' не враховується."
                    , russian = "Ваш голос за слово '" ++ word ++ "' не учитывается."
                    , spanish = "Su voto por palabra '" ++ word ++ "' no se cuenta."
                    }

                AlreadyVotedText wordName ->
                    { english = "You have already voted for this word (" ++ wordName ++ ")."
                    , ukrainian = "Ви вже голосували за це слово (" ++ wordName ++ ")."
                    , russian = "Вы уже голосовали за это слово (" ++ wordName ++ ")."
                    , spanish = "Ya han votado por esta palabra (" ++ wordName ++ ")."
                    }

                WordListEmptyText ->
                    { english = "The list is empty. Be the first to add the word."
                    , ukrainian = "Список пустий. Будьте першим, хто додав слово."
                    , russian = "Список пуст. Будьте первым, кто добавил слово."
                    , spanish = "La lista está vacía. Sea el primero en añadir la palabra."
                    }

                WordsTabText ->
                    { english = "Words"
                    , ukrainian = "Слова"
                    , russian = "Слова"
                    , spanish = "Palabras"
                    }

                VotesTabLongText ->
                    { english = "Latest Votes"
                    , ukrainian = "Останні Голоси"
                    , russian = "Последние Голоса"
                    , spanish = "Últimos Votos"
                    }

                VotesTabShortText ->
                    { english = "Votes"
                    , ukrainian = "Голоси"
                    , russian = "Голоса"
                    , spanish = "Votos"
                    }

                CloudTabLongText ->
                    { english = "Word Cloud"
                    , ukrainian = "Хмаринка слів"
                    , russian = "Облако слов"
                    , spanish = "Nube de palabra"
                    }

                CloudTabShortText ->
                    { english = "Cloud"
                    , ukrainian = "Хмаринка"
                    , russian = "Облако"
                    , spanish = "Nube"
                    }

                MapTabLongText ->
                    { english = "Votes on Map"
                    , ukrainian = "Голоси на Мапі"
                    , russian = "Голоса на карте"
                    , spanish = "Votos en mapa"
                    }

                MapTabShortText ->
                    { english = "Map"
                    , ukrainian = "Мапа"
                    , russian = "Карта"
                    , spanish = "Mapa"
                    }

                IncludeVotesFromText ->
                    { english = "Include votes from:"
                    , ukrainian = "Враховувати голоси з:"
                    , russian = "Учитывать голоса с:"
                    , spanish = "Incluir votos de:"
                    }

                NoVotesText ->
                    { english = "no votes"
                    , ukrainian = "немає голосів"
                    , russian = "нет голосов"
                    , spanish = "no hay votos"
                    }

                LatestHundredText ->
                    { english = "latest 100"
                    , ukrainian = "останні 100"
                    , russian = "последние 100"
                    , spanish = "últimos 100"
                    }

                NVotesOutOfText a b ->
                    let
                        aStr =
                            toString a

                        bStr =
                            toString b
                    in
                    { english = aStr ++ " out of " ++ bStr ++ " votes"
                    , ukrainian = aStr ++ " із " ++ bStr ++ " голосів"
                    , russian = aStr ++ " из " ++ bStr ++ " голосов"
                    , spanish = aStr ++ " fuera de " ++ bStr ++ " votos"
                    }

                GoogleImagesText ->
                    { english = "Google Images"
                    , ukrainian = "Google Зображення"
                    , russian = "Картинки Google"
                    , spanish = "Imágenes de Google"
                    }

                PageNotFoundText ->
                    { english = "404 - Page not found"
                    , ukrainian = "404 - Сторінка не знайдена"
                    , russian = "404 - Страница не найдена"
                    , spanish = "404 - Página no encontrada"
                    }

                PageNotFoundDescription ->
                    { english = "The page you were looking for doesn't exist."
                    , ukrainian = "Сторінка, яку ви шукали, не існує."
                    , russian = "Страница, которую вы ищете, не существует."
                    , spanish = "La página que buscas no existe."
                    }

                LogInToastText ->
                    { english = "Log in With Your Social Account"
                    , ukrainian = "Увійдіть за допомогою соціальних мереж"
                    , russian = "Войдите с помощью социальных сетей"
                    , spanish = "Iniciar sesión con tu cuenta Social"
                    }

                LanguagesText ->
                    { english = "Languages"
                    , ukrainian = "Мови"
                    , russian = "Языки"
                    , spanish = "Idiomas"
                    }

                LogoutText ->
                    { english = "Log out"
                    , ukrainian = "Вийти"
                    , russian = "Выйти"
                    , spanish = "Cerrar sesión"
                    }

                AllText ->
                    { english = "All"
                    , ukrainian = "Всі"
                    , russian = "Все"
                    , spanish = "Todas"
                    }

                PositiveText ->
                    { english = "Positive"
                    , ukrainian = "Позитивні"
                    , russian = "Позитивные"
                    , spanish = "Positivas"
                    }

                NeutralText ->
                    { english = "Neutral"
                    , ukrainian = "Нейтральні"
                    , russian = "Нейтральные"
                    , spanish = "Neutrales"
                    }

                NegativeText ->
                    { english = "Negative"
                    , ukrainian = "Негативні"
                    , russian = "Негативные"
                    , spanish = "Negativas"
                    }

                -- Log in form
                LoginText ->
                    { english = "Log in"
                    , ukrainian = "Увійти"
                    , russian = "Войти"
                    , spanish = "Entrar"
                    }

                LoginFormHeader ->
                    { english = "Log in with your social account"
                    , ukrainian = "Увійдіть за допомогою соціальних мереж"
                    , russian = "Войдите с помощью социальных сетей"
                    , spanish = "Iniciar sesión con tu cuenta Social"
                    }

                LoginFormPrimaryDescr ->
                    { english = "To prevent cheating votes."
                    , ukrainian = "Для запобігання накрутки голосів."
                    , russian = "Для предотвращения накрутки голосов."
                    , spanish = "Para evitar el engaño votos."
                    }

                LoginFormSecondaryDescr ->
                    { english = "You need to log in to add new entries, words and vote for them. Use one of your social accounts to confirm you are a real person."
                    , ukrainian = "Ви повинні увійти, щоб додавати нові записи, слова і голосувати за них. Використайте один з ваших соціальних облікових записів, щоб підтвердити, що ви є реальною людиною."
                    , russian = "Вы должны войти, чтобы добавлять новые записи, слова и голосовать за них. Используйте один из ваших социальных аккаунтов, чтобы подтвердить, что вы являетесь реальным человеком."
                    , spanish = "Necesita acceder a añadir nuevas entradas, palabras y voten por ellos. Utilice una de sus cuentas sociales para confirmar que usted es una persona real."
                    }

                ContWtFacebookText ->
                    { english = "Сontinue with Facebook"
                    , ukrainian = "Продовжити з Facebook"
                    , russian = "Продолжить с Facebook"
                    , spanish = "Сontinue con Facebook"
                    }

                ContWtGoogleText ->
                    { english = "Сontinue with Google"
                    , ukrainian = "Продовжити з Google"
                    , russian = "Продолжить с Google"
                    , spanish = "Сontinue con Google"
                    }

                ContWtVkText ->
                    { english = "Сontinue with VK"
                    , ukrainian = "Продовжити з VK"
                    , russian = "Продолжить с VK"
                    , spanish = "Сontinue con VK"
                    }

                ItIsSecureAndReliable ->
                    { english = "It's secure and reliable"
                    , ukrainian = "Це безпечно і надійно"
                    , russian = "Это безопасно и надежно"
                    , spanish = "Es seguro y confiable"
                    }

                -- Form texts
                TitleText ->
                    { english = "Title"
                    , ukrainian = "Заголовок"
                    , russian = "Заголовок"
                    , spanish = "Título"
                    }

                TitlePlaceholder ->
                    { english = "Write the title"
                    , ukrainian = "Напишіть заголовок"
                    , russian = "Напишите заголовок"
                    , spanish = "Escribir el título"
                    }

                SubtitleText ->
                    { english = "Subtitle"
                    , ukrainian = "Підзаголовок"
                    , russian = "Подзаголовок"
                    , spanish = "Subtítulo"
                    }

                CategoryText ->
                    { english = "Category"
                    , ukrainian = "Категорія"
                    , russian = "Категория"
                    , spanish = "Categoría"
                    }

                SelectCategoryText ->
                    { english = "Select category from list"
                    , ukrainian = "Виберіть категорію зі списку"
                    , russian = "Выберите категорию из списка"
                    , spanish = "Seleccione la categoría de lista"
                    }

                DescriptionText ->
                    { english = "Description"
                    , ukrainian = "Опис"
                    , russian = "Описание"
                    , spanish = "Descripción"
                    }

                DescriptionPlaceholder ->
                    { english = "Write a short description in 140 characters or less"
                    , ukrainian = "Напишіть короткий опис в межах 140 символів або менше"
                    , russian = "Напишите краткое описание в 140 символов или менее"
                    , spanish = "Escribir una breve descripcion en 140 caracteres o menos"
                    }

                ImageUrlText ->
                    { english = "Image URL"
                    , ukrainian = "URL-адреса зображення"
                    , russian = "URL-адрес изображения"
                    , spanish = "URL de imagen"
                    }

                ImageCaptionFieldText ->
                    { english = "Image Copyright"
                    , ukrainian = "Авторське право зображення"
                    , russian = "Авторское право изображения"
                    , spanish = "Copyright de la imagen"
                    }

                ImageUrlInfoText ->
                    { english = "Paste the image URL address into the field, e.g., picture from "
                    , ukrainian = "Вставте URL-адресу зображення в це поле, напр. з "
                    , russian = "Вставьте URL-адрес изображения в поле, напр. картинку из "
                    , spanish = "Pegue la dirección URL de imagen en el campo, por ejemplo de"
                    }

                SubmitEntryFormText ->
                    { english = "Create new entry"
                    , ukrainian = "Створити новий запис"
                    , russian = "Создать новую запись"
                    , spanish = "Crear nueva entrada"
                    }

                -- Form validation messages
                TitleMustPresent ->
                    { english = "The title can't be empty"
                    , ukrainian = "Заголовок не може бути пустим"
                    , russian = "Заголовок не может быть пустым"
                    , spanish = "El título no puede estar vacío"
                    }

                TitleTooShort ->
                    { english = "Title is too short, please enter more than 2 characters"
                    , ukrainian = "Заголовок занадто короткий, будь ласка, введіть більше 2 символів"
                    , russian = "Заголовок слишком короткий, пожалуйста, введите более 2 символов"
                    , spanish = "Título es demasiado corto, introduce más de 2 caracteres"
                    }

                TitleTooLong ->
                    { english = "Title is too long, please fit in 60 characters"
                    , ukrainian = "Заголовок занадто довгий, будь ласка, використайте не більше 60 символів"
                    , russian = "Название слишком длинное, пожалуйста, используйте не более 60 символов"
                    , spanish = "Título es demasiado largo, por favor caben en 60 caracteres"
                    }

                DescriptionMustPresent ->
                    { english = "Description cannot be empty"
                    , ukrainian = "Опис не може бути пустим"
                    , russian = "Описание не может быть пустым"
                    , spanish = "Descripción no puede estar vacía"
                    }

                DescriptionTooLong ->
                    { english = "Description is too long, please fit in 140 characters"
                    , ukrainian = "Опис занадто довгий, будь ласка, використайте не більше 140 символів"
                    , russian = "Описание слишком длинное, пожалуйста, используйте не более 140 символов"
                    , spanish = "Descripción es demasiado larga, por favor caben en 140 caracteres"
                    }

                InvalidImageURL ->
                    { english = "Invalid URL, it must start with http"
                    , ukrainian = "Неправильний URL-адрес, він повинен починатися з http"
                    , russian = "Недопустимый URL-адрес, он должен начинаться с http"
                    , spanish = "URL no válida, debe empezar por http"
                    }

                InvalidImageFormat ->
                    { english = "Invalid image file format, please use one of this: .jpg, .jpeg, .png, .gif"
                    , ukrainian = "Неправильний формат файлу зображення, будь ласка, використовуйте один з цих: .jpg, .jpeg, .png, .gif"
                    , russian = "Недопустимый формат файла изображения, пожалуйста, используйте один из этих: .jpg, .jpeg, .png, .gif"
                    , spanish = "Formato de archivo de imagen no válido, por favor utilice uno de esto: .jpg, .jpeg, .png, .gif"
                    }

                SomethingWentWrong ->
                    { english = "We're sorry, but something went wrong."
                    , ukrainian = "Вибачте, але щось пішло не так."
                    , russian = "Мы сожалеем, но что-то пошло не так."
                    , spanish = "Lo sentimos, pero algo salió mal."
                    }
    in
    case language of
        English ->
            .english translationSet

        Ukrainian ->
            .ukrainian translationSet

        Russian ->
            .russian translationSet

        Spanish ->
            .spanish translationSet


decodeLang : Language -> String
decodeLang language =
    case language of
        English ->
            "en"

        Ukrainian ->
            "uk"

        Russian ->
            "ru"

        Spanish ->
            "es"
