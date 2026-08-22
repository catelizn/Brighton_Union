local Translations ={
    ["not_on_radio"] = "Вы не подключены к каналу",
    ["joined_to_radio"] = "Вы подключены к: %{channel}",
    ["restricted_channel_error"] = "Вы не можете подключиться к этой частоте!",
    ["invalid_radio"] = "Эта частота недоступна.",
    ["you_on_radio"] = "Вы уже подключены к этому каналу",
    ["you_leave"] = "Вы покинули канал.",
    ['volume_radio'] = 'Новая громкость %{value}',
    ['decrease_radio_volume'] = 'Громкость радио уже максимальна',
    ['increase_radio_volume'] = 'Громкость радио уже минимальна',
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
