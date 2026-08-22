const { ref } = Vue

// Customize language for dialog menus and carousels here

const load = Vue.createApp({
  setup () {
    return {
      CarouselText1: 'Добро пожаловать на Brighton Union! Ролевой сервер, где каждый сам пишет свою историю.',
      CarouselSubText1: '',
      CarouselText2: 'Устраивайтесь на работу, покупайте недвижимость и машины — живите полной жизнью.',
      CarouselSubText2: '',
      CarouselText3: 'Общайтесь голосом с другими игроками: чем дальше собеседник, тем громче нужно говорить.',
      CarouselSubText3: '',
      CarouselText4: 'Уважайте других игроков и соблюдайте правила штата. Приятной игры!',
      CarouselSubText4: '',

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
