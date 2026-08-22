const { ref } = Vue

// Customize language for dialog menus and carousels here

const load = Vue.createApp({
  setup () {
    return {
      CarouselText1: 'Предметы, транспорт, работы и банды настраиваются в папке shared.',
      CarouselSubText1: 'Photo captured by: Markyoo#8068',
      CarouselText2: 'Дополнительные данные игроков добавляются через файл qb-core/player.lua.',
      CarouselSubText2: 'Photo captured by: ihyajb#9723',
      CarouselText3: 'Все настройки сервера находятся в файлах config.lua.',
      CarouselSubText3: 'Photo captured by: FLAPZ[INACTIV]#9925',
      CarouselText4: 'Нужна помощь? Заходите в наше сообщество: discord.gg/qbcore',
      CarouselSubText4: 'Photo captured by: Robinerino#1312',

      DownloadTitle: 'Загрузка Brighton Union',
      DownloadDesc: "Скачиваем ресурсы и файлы, необходимые для игры на Brighton Union. \n\nКогда загрузка завершится, вы окажетесь на сервере, и этот экран исчезнет. Пожалуйста, не выходите и не выключайте компьютер. ",

      SettingsTitle: 'Настройки',
      AudioTrackDesc1: 'Если выключить, текущий аудиотрек остановится.',
      AutoPlayDesc2: 'Если выключить, слайды карусели перестанут листаться.',
      PlayVideoDesc3: 'Если выключить, видео остановится и встанет на паузу.',

      KeybindTitle: 'Управление',
      Keybind1: 'Инвентарь',
      Keybind2: 'Смена дальности голоса',
      Keybind3: 'Телефон',
      Keybind4: 'Ремень безопасности',
      Keybind5: 'Меню взаимодействия',
      Keybind6: 'Радиальное меню',
      Keybind7: 'Меню HUD',
      Keybind8: 'Говорить по рации',
      Keybind9: 'Таблица игроков',
      Keybind10: 'Замки машины',
      Keybind11: 'Двигатель',
      Keybind12: 'Жест указания',
      Keybind13: 'Слоты клавиш',
      Keybind14: 'Руки вверх',
      Keybind15: 'Использовать слоты',
      Keybind16: 'Круиз-контроль',

      firstap: ref(true),
      secondap: ref(true),
      thirdap: ref(true),
      firstslide: ref(1),
      secondslide: ref('1'),
      thirdslide: ref('5'),
      audioplay: ref(true),
      playvideo: ref(true),
      download: ref(true),
      settings: ref(false),
    }
  }
})

load.use(Quasar, { config: {} })
load.mount('#loading-main')

var audio = document.getElementById("audio");
audio.volume = 0.05;

function audiotoggle() {
    var audio = document.getElementById("audio");
    if (audio.paused) {
        audio.play();
    } else {
        audio.pause();
    }
}

function videotoggle() {
    var video = document.getElementById("video");
    if (video.paused) {
        video.play();
    } else {
        video.pause();
    }
}

let count = 0;
let thisCount = 0;

const handlers = {
    startInitFunctionOrder(data) {
        count = data.count;
    },

    initFunctionInvoking(data) {
        document.querySelector(".thingy").style.left = "0%";
        document.querySelector(".thingy").style.width = (data.idx / count) * 100 + "%";
    },

    startDataFileEntries(data) {
        count = data.count;
    },

    performMapLoadFunction(data) {
        ++thisCount;

        document.querySelector(".thingy").style.left = "0%";
        document.querySelector(".thingy").style.width = (thisCount / count) * 100 + "%";
    },
};

window.addEventListener("message", function (e) {
    (handlers[e.data.eventName] || function () {})(e.data);
});
