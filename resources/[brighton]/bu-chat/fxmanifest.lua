fx_version 'cerulean'
game 'gta5'

author 'Brighton Union'
description 'Тёмная тема системного чата Brighton Union: только текст, без ярких плашек'
version '1.0.0'

file 'style.css'

chat_theme 'brighton' {
    styleSheet = 'style.css',
    msgTemplates = {
        default = '<b>{0}</b><span>{1}</span>'
    }
}
