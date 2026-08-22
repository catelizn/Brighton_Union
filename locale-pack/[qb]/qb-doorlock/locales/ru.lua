local Translations = {
    error = {
        lockpick_fail = "Не получилось",
        door_not_found = "Не получен хэш модели, если дверь прозрачная, цельтесь в раму двери",
        same_entity = "Обе двери не могут быть одним объектом",
        door_registered = "Эта дверь уже зарегистрирована",
        door_identifier_exists = "Дверь с таким идентификатором уже есть в конфиге. (%s)",
    },
    success = {
        lockpick_success = "Успешно"
    },
    general = {
        locked = "Заперто",
        unlocked = "Открыто",
        locked_button = "[E] - Заперто",
        unlocked_button = "[E] - Открыто",
        keymapping_description = "Взаимодействовать с замками дверей",
        keymapping_remotetriggerdoor = "Дистанционно активировать дверь",
        locked_menu = "Заперто",
        pickable_menu = "Можно взломать",
        cantunlock_menu = 'Нельзя открыть',
        hidelabel_menu = 'Скрыть метку двери',
        distance_menu = "Максимальная дистанция",
        item_authorisation_menu = "Доступ по предмету",
        citizenid_authorisation_menu = "Доступ по ID персонажа",
        gang_authorisation_menu = "Доступ по банде",
        job_authorisation_menu = "Доступ по работе",
        jobGrade_authorisation_menu = "Должность (необязательно)",
        gangGrade_authorisation_menu = "Ранг банды (необязательно)",
        doortype_title = "Тип двери",
        doortype_door = "Одинарная дверь",
        doortype_double = "Двойная дверь",
        doortype_sliding = "Одинарная раздвижная дверь",
        doortype_doublesliding = "Двойная раздвижная дверь",
        doortype_garage = "Гараж",
        dooridentifier_title = "Уникальный идентификатор",
        doorlabel_title = "Метка двери",
        configfile_title = "Имя файла конфига",
        submit_text = "Отправить",
        newdoor_menu_title = "Добавить новую дверь",
        newdoor_command_description = "Добавить новую дверь в систему замков",
        doordebug_command_description = "Переключить режим отладки",
        warning = "Предупреждение",
        created_by = "создал",
        warn_no_permission_newdoor = "%{player} (%{license}) пытался добавить новую дверь без прав (source: %{source})",
        warn_no_authorisation = "%{player} (%{license}) пытался открыть дверь без доступа (Sent: %{doorID})",
        warn_wrong_doorid = "%{player} (%{license}) пытался обновить несуществующую дверь (Sent: %{doorID})",
        warn_wrong_state = "%{player} (%{license}) пытался установить недопустимое состояние (Sent: %{state})",
        warn_wrong_doorid_type = "%{player} (%{license}) отправил неверный doorID (Sent: %{doorID})",
        warn_admin_privilege_used = "%{player} (%{license}) открыл дверь, используя права администратора"
    }
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
