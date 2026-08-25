QBCore.Shared.ForceJobDefaultDutyAtLogin = true -- true: Force duty state to jobdefaultDuty | false: set duty state from database last saved
QBCore.Shared.Jobs = {
	unemployed = { label = 'Civilian', defaultDuty = true, offDutyPay = false, grades = { ['0'] = { name = 'Freelancer', payment = 10 } } },
	bus = { label = 'Bus', defaultDuty = true, offDutyPay = false, grades = { ['0'] = { name = 'Driver', payment = 50 } } },
	judge = { label = 'Honorary', defaultDuty = true, offDutyPay = false, grades = { ['0'] = { name = 'Judge', payment = 100 } } },
	lawyer = { label = 'Law Firm', defaultDuty = true, offDutyPay = false, grades = { ['0'] = { name = 'Associate', payment = 50 } } },
	reporter = { label = 'Reporter', defaultDuty = true, offDutyPay = false, grades = { ['0'] = { name = 'Journalist', payment = 50 } } },
	trucker = { label = 'Trucker', defaultDuty = true, offDutyPay = false, grades = { ['0'] = { name = 'Driver', payment = 50 } } },
	tow = { label = 'Towing', defaultDuty = true, offDutyPay = false, grades = { ['0'] = { name = 'Driver', payment = 50 } } },
	garbage = { label = 'Garbage', defaultDuty = true, offDutyPay = false, grades = { ['0'] = { name = 'Collector', payment = 50 } } },
	vineyard = { label = 'Vineyard', defaultDuty = true, offDutyPay = false, grades = { ['0'] = { name = 'Picker', payment = 50 } } },
	hotdog = { label = 'Hotdog', defaultDuty = true, offDutyPay = false, grades = { ['0'] = { name = 'Sales', payment = 50 } } },

	police = {
		label = 'Law Enforcement',
		type = 'leo',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 50 },
			['1'] = { name = 'Officer', payment = 75 },
			['2'] = { name = 'Sergeant', payment = 100 },
			['3'] = { name = 'Lieutenant', payment = 125 },
			['4'] = { name = 'Chief', isboss = true, payment = 150 },
		},
	},
	ambulance = {
		label = 'EMS',
		type = 'ems',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 50 },
			['1'] = { name = 'Paramedic', payment = 75 },
			['2'] = { name = 'Doctor', payment = 100 },
			['3'] = { name = 'Surgeon', payment = 125 },
			['4'] = { name = 'Chief', isboss = true, payment = 150 },
		},
	},
	realestate = {
		label = 'Real Estate',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 50 },
			['1'] = { name = 'House Sales', payment = 75 },
			['2'] = { name = 'Business Sales', payment = 100 },
			['3'] = { name = 'Broker', payment = 125 },
			['4'] = { name = 'Manager', isboss = true, payment = 150 },
		},
	},
	taxi = {
		label = 'Taxi',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 50 },
			['1'] = { name = 'Driver', payment = 75 },
			['2'] = { name = 'Event Driver', payment = 100 },
			['3'] = { name = 'Sales', payment = 125 },
			['4'] = { name = 'Manager', isboss = true, payment = 150 },
		},
	},
	cardealer = {
		label = 'Vehicle Dealer',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 50 },
			['1'] = { name = 'Showroom Sales', payment = 75 },
			['2'] = { name = 'Business Sales', payment = 100 },
			['3'] = { name = 'Finance', payment = 125 },
			['4'] = { name = 'Manager', isboss = true, payment = 150 },
		},
	},
	mechanic = {
		label = 'LS Customs',
		type = 'mechanic',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 50 },
			['1'] = { name = 'Novice', payment = 75 },
			['2'] = { name = 'Experienced', payment = 100 },
			['3'] = { name = 'Advanced', payment = 125 },
			['4'] = { name = 'Manager', isboss = true, payment = 150 },
		},
	},
	mechanic2 = {
		label = 'LS Customs',
		type = 'mechanic',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 50 },
			['1'] = { name = 'Novice', payment = 75 },
			['2'] = { name = 'Experienced', payment = 100 },
			['3'] = { name = 'Advanced', payment = 125 },
			['4'] = { name = 'Manager', isboss = true, payment = 150 },
		},
	},
	mechanic3 = {
		label = 'LS Customs',
		type = 'mechanic',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 50 },
			['1'] = { name = 'Novice', payment = 75 },
			['2'] = { name = 'Experienced', payment = 100 },
			['3'] = { name = 'Advanced', payment = 125 },
			['4'] = { name = 'Manager', isboss = true, payment = 150 },
		},
	},
	beeker = {
		label = 'Beeker\'s Garage',
		type = 'mechanic',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 50 },
			['1'] = { name = 'Novice', payment = 75 },
			['2'] = { name = 'Experienced', payment = 100 },
			['3'] = { name = 'Advanced', payment = 125 },
			['4'] = { name = 'Manager', isboss = true, payment = 150 },
		},
	},
	bennys = {
		label = 'Benny\'s Original Motor Works',
		type = 'mechanic',
		defaultDuty = true,
		offDutyPay = false,
		grades = {
			['0'] = { name = 'Recruit', payment = 50 },
			['1'] = { name = 'Novice', payment = 75 },
			['2'] = { name = 'Experienced', payment = 100 },
			['3'] = { name = 'Advanced', payment = 125 },
			['4'] = { name = 'Manager', isboss = true, payment = 150 },
		},
	},
	postman = {
		label = 'Почтальон',
		defaultDuty = true,
		offDutyPay = false,
		grades = { ['0'] = { name = 'Почтальон', payment = 0 } },
	},
	lumberjack = {
		label = 'Лесоруб',
		defaultDuty = true,
		offDutyPay = false,
		grades = { ['0'] = { name = 'Лесоруб', payment = 0 } },
	},
	mushroompicker = {
		label = 'Грибник',
		defaultDuty = true,
		offDutyPay = false,
		grades = { ['0'] = { name = 'Грибник', payment = 0 } },
	},
	miner = {
		label = 'Шахтёр',
		defaultDuty = true,
		offDutyPay = false,
		grades = { ['0'] = { name = 'Шахтёр', payment = 0 } },
	},
	oilworker = {
		label = 'Нефтяник',
		defaultDuty = true,
		offDutyPay = false,
		grades = { ['0'] = { name = 'Нефтяник', payment = 0 } },
	},
	butcher = {
		label = 'Мясник',
		defaultDuty = true,
		offDutyPay = false,
		grades = { ['0'] = { name = 'Мясник', payment = 0 } },
	},
	fisherman = {
		label = 'Рыбак',
		defaultDuty = true,
		offDutyPay = false,
		grades = { ['0'] = { name = 'Рыбак', payment = 0 } },
	},
	hunter = {
		label = 'Охотник',
		defaultDuty = true,
		offDutyPay = false,
		grades = { ['0'] = { name = 'Охотник', payment = 0 } },
	},
}

-- Brighton Union: Russian localization overrides
local jobLabels = {
	unemployed = 'Гражданский',
	bus = 'Автобусный парк',
	judge = 'Судебная система',
	lawyer = 'Юридическая фирма',
	reporter = 'Журналист',
	trucker = 'Дальнобойщик',
	tow = 'Эвакуация',
	garbage = 'Вывоз мусора',
	vineyard = 'Виноградник',
	hotdog = 'Продавец хот-догов',
	police = 'Полиция',
	ambulance = 'Скорая помощь',
	realestate = 'Риэлтор',
	taxi = 'Такси',
	cardealer = 'Автодилер',
}

local gradeNames = {
	Freelancer = 'Фрилансер',
	Driver = 'Водитель',
	Judge = 'Судья',
	Associate = 'Помощник',
	Journalist = 'Журналист',
	Collector = 'Сборщик',
	Picker = 'Сборщик',
	Sales = 'Продавец',
	Recruit = 'Стажёр',
	Officer = 'Офицер',
	Sergeant = 'Сержант',
	Lieutenant = 'Лейтенант',
	Chief = 'Шеф',
	Paramedic = 'Парамедик',
	Doctor = 'Врач',
	Surgeon = 'Хирург',
	['House Sales'] = 'Продажи домов',
	['Business Sales'] = 'Продажи бизнеса',
	Broker = 'Брокер',
	Manager = 'Менеджер',
	['Event Driver'] = 'Водитель мероприятий',
	['Showroom Sales'] = 'Продажи в салоне',
	Finance = 'Финансы',
	Novice = 'Новичок',
	Experienced = 'Опытный',
	Advanced = 'Продвинутый',
}

for jobName, job in pairs(QBCore.Shared.Jobs) do
	if jobLabels[jobName] then
		job.label = jobLabels[jobName]
	end
	for _, grade in pairs(job.grades) do
		if gradeNames[grade.name] then
			grade.name = gradeNames[grade.name]
		end
	end
end


-- Brighton Union: государственные структуры
QBCore.Shared.Jobs['fib'] = {
    label = 'FIB',
    defaultDuty = true,
    offDutyPay = false,
    grades = {
        ['0'] = { name = 'Агент', payment = 300 },
        ['1'] = { name = 'Старший агент', payment = 500 },
        ['2'] = { name = 'Специальный агент', payment = 800 },
        ['3'] = { name = 'Заместитель директора', isboss = true, payment = 1200 },
        ['4'] = { name = 'Директор', isboss = true, payment = 1500 }
    }
}

QBCore.Shared.Jobs['weazel'] = {
    label = 'Weazel News',
    defaultDuty = true,
    offDutyPay = false,
    grades = {
        ['0'] = { name = 'Стажёр', payment = 150 },
        ['1'] = { name = 'Журналист', payment = 250 },
        ['2'] = { name = 'Редактор', payment = 400 },
        ['3'] = { name = 'Главный редактор', isboss = true, payment = 600 }
    }
}

-- Brighton Union: пресетные банды (ранги: 0 новичок, 1 боец, 2 ветеран, 3 правая рука, 4 босс)
local gangGrades = {
    ['0'] = { name = 'Новичок', payment = 0 },
    ['1'] = { name = 'Боец', payment = 0 },
    ['2'] = { name = 'Ветеран', payment = 0 },
    ['3'] = { name = 'Правая рука', payment = 0 },
    ['4'] = { name = 'Босс', isboss = true, payment = 0 }
}
for gangName, gangLabel in pairs({ families = 'The Families', ballas = 'Ballas', vagos = 'Vagos', bloods = 'Bloods', marabunta = 'Marabunta' }) do
    QBCore.Shared.Jobs[gangName] = { label = gangLabel, defaultDuty = true, offDutyPay = false, grades = gangGrades }
end

-- Brighton Union: банды — 10 рангов, мафии — 8 рангов
local buGangGrades = {
    ['0'] = { name = 'Рекрут', payment = 0 },
    ['1'] = { name = 'Боец', payment = 0 },
    ['2'] = { name = 'Ветеран', payment = 0 },
    ['3'] = { name = 'Авторитет', payment = 0 },
    ['4'] = { name = 'Бригадир', payment = 0 },
    ['5'] = { name = 'Младший лидер', payment = 0 },
    ['6'] = { name = 'Лидер', payment = 0 },
    ['7'] = { name = 'Правая рука', payment = 0 },
    ['8'] = { name = 'Заместитель', payment = 0 },
    ['9'] = { name = 'Босс', isboss = true, payment = 0 }
}
for gangName, gangLabel in pairs({ families = 'The Families', ballas = 'Ballas', vagos = 'Vagos', bloods = 'Bloods', marabunta = 'Marabunta' }) do
    QBCore.Shared.Jobs[gangName] = { label = gangLabel, defaultDuty = true, offDutyPay = false, grades = buGangGrades }
end

local buMafiaGrades = {
    ['0'] = { name = 'Ассоциат', payment = 0 },
    ['1'] = { name = 'Солдат', payment = 0 },
    ['2'] = { name = 'Капо', payment = 0 },
    ['3'] = { name = 'Консильери', payment = 0 },
    ['4'] = { name = 'Младший босс', payment = 0 },
    ['5'] = { name = 'Заместитель босса', payment = 0 },
    ['6'] = { name = 'Босс', isboss = true, payment = 0 },
    ['7'] = { name = 'Крёстный отец', isboss = true, payment = 0 }
}
for mafiaName, mafiaLabel in pairs({ italian_mafia = 'Итальянская мафия', russian_mafia = 'Русская мафия', mexican_mafia = 'Мексиканская мафия', yakuza = 'Японская мафия' }) do
    QBCore.Shared.Jobs[mafiaName] = { label = mafiaLabel, defaultDuty = true, offDutyPay = false, grades = buMafiaGrades }
end