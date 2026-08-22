local Translations = {
    error = {
        ["no_keys"] = "У вас нет ключей от дома...",
        ["not_in_house"] = "Вы не в доме!",
        ["out_range"] = "Вы вышли из зоны действия",
        ["no_key_holders"] = "Владельцы ключей не найдены..",
        ["invalid_tier"] = "Неверный класс дома",
        ["no_house"] = "Рядом нет дома",
        ["no_door"] = "Вы недостаточно близко к двери..",
        ["locked"] = "Дом заперт!",
        ["no_one_near"] = "Рядом никого нет!",
        ["not_owner"] = "Этот дом вам не принадлежит.",
        ["no_police"] = "Поблизости нет полиции..",
        ["already_open"] = "Этот дом уже открыт..",
        ["failed_invasion"] = "Не получилось, попробуйте ещё раз",
        ["inprogress_invasion"] = "Кто-то уже возится с дверью..",
        ["no_invasion"] = "Эта дверь не взломана..",
        ["realestate_only"] = "Эта команда доступна только риэлтору",
        ["emergency_services"] = "Это доступно только экстренным службам!",
        ["already_owned"] = "Этот дом уже куплен!",
        ["not_enough_money"] = "У вас недостаточно денег..",
        ["remove_key_from"] = "Ключи изъяты у %{firstname} %{lastname}",
        ["already_keys"] = "У этого человека уже есть ключи от дома!",
        ["something_wrong"] = "Что-то пошло не так, попробуйте ещё раз!",
        ["nobody_at_door"] = 'За дверью никого нет...'
    },
    success = {
        ["unlocked"] = "Дом открыт!",
        ["home_invasion"] = "Дверь теперь открыта.",
        ["lock_invasion"] = "Вы снова заперли дом..",
        ["recieved_key"] = "Вы получили ключи от %{value}!",
        ["house_purchased"] = "Вы успешно купили дом!"
    },
    info = {
        ["door_ringing"] = "Кто-то звонит в дверь!",
        ["speed"] = "Скорость: %{value}",
        ["added_house"] = "Вы добавили дом: %{value}",
        ["added_garage"] = "Вы добавили гараж: %{value}",
        ["exit_camera"] = "Выйти из камеры",
        ["house_for_sale"] = "Дом на продажу",
        ["decorate_interior"] = "Обустроить интерьер",
        ["create_house"] = "Создать дом (только риэлтор)",
        ["price_of_house"] = "Цена дома",
        ["tier_number"] = "Класс дома",
        ["add_garage"] = "Добавить гараж к дому (только риэлтор)",
        ["ring_doorbell"] = "Позвонить в дверь"
    },
    menu = {
        ["house_options"] = "Меню дома",
        ["close_menu"] = "⬅ Закрыть меню",
        ["enter_house"] = "Войти в дом",
        ["give_house_key"] = "Выдать ключ от дома",
        ["exit_property"] = "Покинуть недвижимость",
        ["front_camera"] = "Камера у входа",
        ["back"] = "Назад",
        ["remove_key"] = "Забрать ключ",
        ["open_door"] = "Открыть дверь",
        ["view_house"] = "Осмотреть дом",
        ["ring_door"] = "Позвонить в дверь",
        ["exit_door"] = "Покинуть недвижимость",
        ["open_stash"] = "Открыть хранилище",
        ["stash"] = "Хранилище",
        ["change_outfit"] = "Сменить наряд",
        ["outfits"] = "Наряды",
        ["change_character"] = "Сменить персонажа",
        ["characters"] = "Персонажи",
        ["enter_unlocked_house"] = "Войти в открытый дом",
        ["lock_door_police"] = "Запереть дверь"
    },
    target = {
        ["open_stash"] = "[E] Открыть хранилище",
        ["outfits"] = "[E] Сменить наряд",
        ["change_character"] = "[E] Сменить персонажа",
    },
    log = {
        ["house_created"] = "Дом создан:",
        ["house_address"] = "**Адрес**: %{label}\n\n**Цена**: %{price}\n\n**Класс**: %{tier}\n\n**Агент**: %{agent}",
        ["house_purchased"] = "Дом куплен:",
        ["house_purchased_by"] = "**Адрес**: %{house}\n\n**Цена покупки**: %{price}\n\n**Покупатель**: %{firstname} %{lastname}"
    }
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
