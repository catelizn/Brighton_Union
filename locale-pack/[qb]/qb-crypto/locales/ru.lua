local Translations = {
    error = {
        you_dont_have_a_cryptostick = 'У вас нет криптофлешки',
        cryptostick_malfunctioned = 'Криптофлешка неисправна'
    },
    success = {
        you_have_exchanged_your_cryptostick_for = 'Вы обменяли криптофлешку на: %{amount} QBit(ов)'
    },
    credit = {
        there_are_amount_credited = 'Вам начислено %{amount} Qbit(ов)!',
        you_have_qbit_purchased = 'Вы купили %{dataCoins} Qbit(ов)!'
    },
    debit = {
        you_have_sold = 'Вы продали %{dataCoins} Qbit(ов)!'
    },
    text = {
        enter_usb = '[E] - Вставить USB',
        system_is_rebooting = 'Система перезагружается - %{rebootInfoPercentage} %',
        you_have_not_given_a_new_value = 'Вы не ввели новое значение ... Текущее значение: %{crypto}',
        this_crypto_does_not_exist = 'Такая криптовалюта не существует, доступно: Qbit',
        you_have_not_provided_crypto_available_qbit = 'Вы не указали криптовалюту, доступно: Qbit',
        the_qbit_has_a_value_of = 'Курс Qbit: %{crypto}',
        you_have_with_a_value_of = 'У вас %{playerPlayerDataMoneyCrypto} QBit(ов) на сумму: %{mypocket},-'
    }
}

if GetConvar('qb_locale', 'en') == 'ru' then
    Lang = Locale:new({
        phrases = Translations,
        warnOnMissing = true,
        fallbackLang = Lang,
    })
end
