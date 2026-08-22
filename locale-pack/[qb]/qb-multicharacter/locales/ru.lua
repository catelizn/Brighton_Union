local Translations = {
    notifications = {
        ["char_deleted"] = "Персонаж удалён!",
        ["deleted_other_char"] = "Вы успешно удалили персонажа с ID %{citizenid}.",
        ["forgot_citizenid"] = "Вы забыли указать ID персонажа!",
    },

    commands = {
        -- /deletechar
        ["deletechar_description"] = "Удаляет персонажа другого игрока",
        ["citizenid"] = "ID персонажа",
        ["citizenid_help"] = "ID персонажа, который вы хотите удалить",

        -- /logout
        ["logout_description"] = "Выйти из персонажа (только для администрации)",

        -- /closeNUI
        ["closeNUI_description"] = "Закрыть меню персонажей"
    },

    misc = {
        ["droppedplayer"] = "Вы отключились от QBCore"
    },

    ui = {
        -- Main
        characters_header = "Мои персонажи",
        emptyslot = "Пустой слот",
        play_button = "Играть",
        create_button = "Создать персонажа",
        delete_button = "Удалить персонажа",

        -- Character Information
        charinfo_header = "Информация о персонаже",
        charinfo_description = "Выберите слот персонажа, чтобы увидеть всю информацию о нём.",
        name = "Имя",
        male = "Мужской",
        female = "Женский",
        firstname = "Имя",
        lastname = "Фамилия",
        nationality = "Национальность",
        gender = "Пол",
        birthdate = "Дата рождения",
        job = "Работа",
        jobgrade = "Должность",
        cash = "Наличные",
        bank = "Банк",
        phonenumber = "Номер телефона",
        accountnumber = "Номер счёта",

        chardel_header = "Регистрация персонажа",

        -- Delete character
        deletechar_header = "Удалить персонажа",
        deletechar_description = "Вы уверены, что хотите удалить своего персонажа?",

        -- Buttons
        cancel = "Отмена",
        confirm = "Подтвердить",

        -- Loading Text
        retrieving_playerdata = "Получение данных игрока",
        validating_playerdata = "Проверка данных игрока",
        retrieving_characters = "Получение персонажей",
        validating_characters = "Проверка персонажей",

        -- Notifications
        ran_into_issue = "Возникла проблема",
        profanity = "Похоже, вы пытаетесь использовать нецензурные слова в имени или национальности!",
        forgotten_field = "Похоже, вы забыли заполнить одно или несколько полей!",
        connection_error = "Ошибка соединения. Попробуйте ещё раз.",
        delete_failed = "Не удалось удалить персонажа. Попробуйте ещё раз.",
        selection_failed = "Не удалось выбрать персонажа. Попробуйте ещё раз.",
        creation_failed = "Не удалось создать персонажа. Попробуйте ещё раз.",
        setup_failed = "Не удалось загрузить персонажей. Попробуйте ещё раз.",
        firstname_too_short = "Имя должно быть не короче 2 символов.",
        firstname_too_long = "Имя не может быть длиннее 16 символов.",
        lastname_too_short = "Фамилия должна быть не короче 2 символов.",
        lastname_too_long = "Фамилия не может быть длиннее 16 символов.",
        invalid_date = "Укажите корректную дату рождения.",
        date = "Дата рождения",
        field = "Поле"
    }
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
