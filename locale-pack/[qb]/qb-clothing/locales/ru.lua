local Translations = {
    store = {
        barber = "Барбершоп",
        surgeon = "Пластический хирург",
        clothing = "Магазин одежды",
        outfitchanger = "Смена наряда"
    },

    outfits = {
        roomOutfits = "Готовые образы",
        myOutfits = "Мои наряды",
        character = "Одежда",
        accessoires = "Аксессуары"
    },

    menu = {
        hair = "Волосы",
        character = "Одежда",
        accessoires = "Аксессуары",
        features = "Черты лица"
    },

    ui = {
        select = "Выбрать",
        delete = "Удалить",
        select_outfit = "Выбрать наряд",
        player_model = "Модель игрока",
        model = "Модель",
        mother = "Мать",
        father = "Отец",
        texture = "Текстура",
        type = "Тип",
        item = "Элемент",
        skin_color = "Цвет кожи",
        parent_mixer = "Смешение родителей",
        shape_mix = "Форма",
        skin_mix = "Кожа",
        arms = "Руки",
        undershirt = "Футболка / Ремни",
        color = "Цвет",
        jacket = "Куртки / Верх",
        vests = "Жилеты",
        decals = "Наклейки",
        acessory = "Аксессуары на шею",
        bags = "Сумки",
        pants = "Штаны",
        shoes = "Обувь",
        eye_color = "Цвет глаз",
        moles = "Родинки / Веснушки",
        opacity = "Непрозрачность",
        nose_width = "Ширина носа",
        width = "Ширина",
        nose_peak_height = "Высота кончика носа",
        height = "Высота",
        nose_peak_length = "Длина кончика носа",
        length = "Длина",
        nose_bone_height = "Высота кости носа",
        nose_peak_lowering = "Опускание кончика носа",
        lowering = "Опускание",
        nose_bone_twist = "Изгиб кости носа",
        twist = "Изгиб",
        eyebrow_height = "Высота бровей",
        eyebrow_depth = "Глубина бровей",
        depth = "Глубина",
        cheeks_height = "Высота щёк",
        cheeks_width = "Ширина щёк",
        cheeks_depth = "Глубина щёк",
        eyes_opening = "Раскрытие глаз",
        opening = "Раскрытие",
        lips_thickness = "Толщина губ",
        thickness = "Толщина",
        jaw_bone_width = "Ширина челюсти",
        jaw_bone_length = "Длина челюсти",
        chin_height = "Высота подбородка",
        chin_width = "Ширина подбородка",
        butt_chin = "Ямочка на подбородке",
        size = "Размер",
        neck_thickness = "Толщина шеи",
        ageing = "Возраст",
        hair = "Волосы",
        eyebrow = "Брови",
        facial_hair = "Растительность на лице",
        lipstick = "Помада",
        blush = "Румяна",
        makeup = "Макияж",
        mask = "Маски",
        hat = "Головные уборы",
        glasses = "Очки",
        ear_accessories = "Аксессуары для ушей",
        watch = "Часы",
        bracelet = "Браслеты",
        btn_confirm = "Подтвердить",
        btn_cancel = "Отмена",
        btn_saveOutfit = "Сохранить наряд",
        outfit_name = "Название наряда"
    },

    notify = {
        error_bracelet = "Вы не можете снять свой электронный браслет ...",
        info_deleteOutfit = "Вы удалили наряд %{outfit}!"
    }
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
