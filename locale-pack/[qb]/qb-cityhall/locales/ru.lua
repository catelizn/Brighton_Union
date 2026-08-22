local Translations = {
    error = {
        not_in_range = 'Слишком далеко от мэрии'
    },
    success = {
        recived_license = 'Вы получили %{value} за $50'
    },
    info = {
        new_job_app = 'Ваша заявка отправлена боссу (%{job})',
        bilp_text = 'Городские услуги',
        city_services_menu = '~g~E~w~ - Меню городских услуг',
        id_card = 'Удостоверение личности',
        driver_license = 'Водительское удостоверение',
        weaponlicense = 'Лицензия на оружие',
        new_job = 'Поздравляем с новой работой! (%{job})',
    },
    email = {
        jobAppSender = "%{job}",
        jobAppSub = "Спасибо за заявку в %(job).",
        jobAppMsg = "Здравствуйте, %{gender} %{lastname}<br /><br />Организация %{job} получила вашу заявку.<br /><br />Босс рассматривает ваш запрос и свяжется с вами для собеседования в ближайшее время.<br /><br />Ещё раз спасибо за вашу заявку.",
        mr = 'Г-н',
        mrs = 'Г-жа',
        sender = 'Мэрия',
        subject = 'Запрос на уроки вождения',
        message = 'Здравствуйте, %{gender} %{lastname}<br /><br />Мы получили сообщение, что кто-то хочет пройти уроки вождения<br />Если вы готовы преподавать, свяжитесь с нами:<br />Имя: <strong>%{firstname} %{lastname}</strong><br />Номер телефона: <strong>%{phone}</strong><br/><br/>С уважением,<br />Мэрия Лос-Сантоса'
    }
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
