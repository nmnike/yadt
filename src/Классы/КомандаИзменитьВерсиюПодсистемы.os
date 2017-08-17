
///////////////////////////////////////////////////////////////////////////////////////////////////
// Прикладной интерфейс

Перем Лог;
Перем ИспользуемаяВерсияПлатформы;

Процедура ЗарегистрироватьКоманду(Знач ИмяКоманды, Знач Парсер) Экспорт
	
	ОписаниеКоманды = Парсер.ОписаниеКоманды(ИмяКоманды, "Изменяет версию подсистемы в конфигурации");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-storage-path",
		"Адрес хранилища конфигурации");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-storage-user",
		"Пользователь хранилища конфигурации");
	
	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-storage-pwd",
		"Пароль пользователя хранилища конфигурации");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-ver-tmplt",
		"Имя общего макета, в котором храниться версия подсистемы");

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-ver-mask",
		"Маска версии в виде x.x.x.x, где x может принимать значения:"
		+ Символы.ПС + Символы.Таб + Символы.Таб + "# - оставить значение без изменения"
		+ Символы.ПС + Символы.Таб + Символы.Таб + "* - увеличить значение на 1"
		+ Символы.ПС + Символы.Таб + Символы.Таб + "$ - сбросить номер версии на 0 (для последнего числа на 1)"
		+ Символы.ПС + Символы.Таб + Символы.Таб + "<любые символы> - вставить указанные символы"
		+ Символы.ПС + Символы.Таб + "по умолчанию - ""#.#.#.*"""
		+ Символы.ПС);

	Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
		"-ver-comment",
		"Комментарий при помещении изменения версии в хранилище,"
		+ Символы.ПС + Символы.Таб + Символы.Таб + "по умолчанию: ""Изменена версия <Номер новой версии>"""
		+ Символы.ПС + Символы.Таб + "для подстановки номера новой версии может использоваться символ подстановки %version%"
		+ Символы.ПС);

    Парсер.ДобавитьИменованныйПараметрКоманды(ОписаниеКоманды, 
    	"-v8version",
    	"Версия платформы 1С");

    Парсер.ДобавитьКоманду(ОписаниеКоманды);

КонецПроцедуры

Функция ВыполнитьКоманду(Знач ПараметрыКоманды) Экспорт
    
	Хранилище_Адрес					= ПараметрыКоманды["-storage-path"];
	Хранилище_Пользователь			= ПараметрыКоманды["-storage-user"];
	Хранилище_ПарольПользователя	= ПараметрыКоманды["-storage-pwd"];
	МакетВерсии						= ПараметрыКоманды["-ver-tmplt"];
	МаскаВерсии						= ПараметрыКоманды["-ver-mask"];
	КомментарийВерсии				= ПараметрыКоманды["-ver-comment"];
	ИспользуемаяВерсияПлатформы		= ПараметрыКоманды["-v8version"];

	ВозможныйРезультат = МенеджерКомандПриложения.РезультатыКоманд();

	Если ПустаяСтрока(Хранилище_Адрес) Тогда
		Лог.Ошибка("Не указан адрес хранилища конфигурации");
		Возврат ВозможныйРезультат.НеверныеПараметры;
	КонецЕсли;

	Если ПустаяСтрока(Хранилище_Пользователь) Тогда
		Лог.Ошибка("Не указан пользователь хранилища конфигурации");
		Возврат ВозможныйРезультат.НеверныеПараметры;
	КонецЕсли;

	Если ПустаяСтрока(МакетВерсии) Тогда
		Лог.Ошибка("Не указано имя общего макета, содержащего версию подсистемы");
		Возврат ВозможныйРезультат.НеверныеПараметры;
	КонецЕсли;

	Если ПустаяСтрока(МаскаВерсии) Тогда
		МаскаВерсии = "#.#.#.*";
	КонецЕсли;

	Если ПустаяСтрока(КомментарийВерсии) Тогда
		КомментарийВерсии = "Изменена версия %version%";
	КонецЕсли;

	Лог.Информация("Начало изменения макета """ + МакетВерсии + """ версии подсистемы в хранилище");

	Попытка
		ОбновитьВерсиюПодсистемы(Хранилище_Адрес
							   , Хранилище_Пользователь
							   , Хранилище_ПарольПользователя
							   , МакетВерсии
							   , МаскаВерсии
							   , КомментарийВерсии
							   , ИспользуемаяВерсияПлатформы);

		Возврат ВозможныйРезультат.Успех;
	Исключение
		Лог.Ошибка(ОписаниеОшибки());
		Возврат ВозможныйРезультат.ОшибкаВремениВыполнения;
	КонецПопытки;

КонецФункции

// Выгружает общий макет конфигурации, содержащий версию подсистемы
//	и подготавливает служебные файлы для изменения конфигурации в хранилище
//   
// Параметры:
//   ТекущаяВерсия 	- Строка - Текущая версия для изменения
//   МаскаВерсии 	- Строка - Маска версии в виде x.x.x.x, где x может принимать значения:
//									# - оставить значение без изменения
//									* - увеличить значение на 1
//									$ - сбросить номер версии на 0 (для последнего числа на 1)
//									<любые символы> - вставить указанные символы
// Возвращаемое значение:
//		Структура			- Пути к файлам выгрузки макета и служебным файлам для изменения конфигурации
//			КаталогВыгрузки		- Строка - Каталог выгрузки файлов конфигурации
//			Макет				- Строка - Путь к файлу выгрузки содержимого макета конфигурации
//			Описание			- Строка - Путь к файлу выгрузки описания макета конфигурации
//			ФайлВыгрузки		- Строка - Путь к файлу списка выгружаемых объектов
//			ФайлИзменений		- Строка - Путь к файлу списка изменяемых объектов конфигурации (для захвата/помещения в хранилище)
//			ФайлЗагрузки		- Строка - Путь к файлу списка загружаемых файлов конфигурации
//
Функция ВыгрузитьМакетВерсии(Конфигуратор, РабочийКаталог, МакетВерсии)

	ФайлСписокВыгрузки = ОбъединитьПути(РабочийКаталог, "object_list_dump.txt");
	ТекстСписокВыгрузки = Новый ТекстовыйДокумент();
	ТекстСписокВыгрузки.ДобавитьСтроку("ОбщийМакет." + МакетВерсии);
	ТекстСписокВыгрузки.Записать(ФайлСписокВыгрузки);

	КаталогВыгрузки = ОбъединитьПути(РабочийКаталог, "cf");

	ПараметрыЗапуска = Конфигуратор.ПолучитьПараметрыЗапуска();
	ПараметрыЗапуска.Добавить(СтрШаблон("/DumpConfigToFiles %1", ЗапускПриложений.ОбернутьВКавычки(КаталогВыгрузки)));
	ПараметрыЗапуска.Добавить(СтрШаблон("-listFile %1", ФайлСписокВыгрузки));
	Конфигуратор.ВыполнитьКоманду(ПараметрыЗапуска);

	ПутьКМакетуВерсии = ОбъединитьПути(КаталогВыгрузки, "CommonTemplates", МакетВерсии, "Ext\Template.txt");
	ПутьКОписаниюМакетаВерсии = ОбъединитьПути(КаталогВыгрузки, "CommonTemplates", МакетВерсии + ".xml");

	ФайлСписокИзменений = ОбъединитьПути(РабочийКаталог, "object_list_lock.xml");
	ТекстСписокИзменений = Новый ТекстовыйДокумент();
	ТекстСписокИзменений.ДобавитьСтроку("<Objects xmlns=""http://v8.1c.ru/8.3/config/objects"" version=""1.0"">");
	ТекстСписокИзменений.ДобавитьСтроку("    <Object fullName = ""ОбщийМакет." + МакетВерсии + """ includeChildObjects= ""false"" />");
	ТекстСписокИзменений.ДобавитьСтроку("</Objects>");
	ТекстСписокИзменений.Записать(ФайлСписокИзменений);

	ФайлСписокЗагрузки = ОбъединитьПути(РабочийКаталог, "object_list_restore.txt");
	ТекстСписокЗагрузки = Новый ТекстовыйДокумент();
	ТекстСписокЗагрузки.ДобавитьСтроку(ПутьКОписаниюМакетаВерсии);
	ТекстСписокЗагрузки.Записать(ФайлСписокЗагрузки);

	ПутиКФайламВерсии = Новый Структура("КаталогВыгрузки, Макет, Описание, ФайлВыгрузки, ФайлИзменений, ФайлЗагрузки",
										КаталогВыгрузки,
										ПутьКМакетуВерсии,
										ПутьКОписаниюМакетаВерсии,
										ФайлСписокВыгрузки,
										ФайлСписокИзменений,
										ФайлСписокЗагрузки);

	Возврат ПутиКФайламВерсии;

КонецФункции //ВыгрузитьМакетВерсии()

// Выполняет изменение версии подсистемы конфигурации в хранилище конфигурации
//   
// Параметры:
//   Хранилище_Адрес				- Строка - Адрес хранилища конфигурации
//   Хранилище_ИмяПользователя	 	- Строка - Пользователь хранилища конфигурации
//   Хранилище_ПарольПользователя 	- Строка - Пароль пользователя хранилища конфигурации
//   МакетВерсии			 		- Строка - Имя общего макета конфигурации, содержащего версию подсистемы
//   МаскаВерсии			 		- Строка - Маска версии в виде x.x.x.x, где x может принимать значения:
//													# - оставить значение без изменения
//													* - увеличить значение на 1
//													$ - сбросить номер версии на 0 (для последнего числа на 1)
//													<любые символы> - вставить указанные символы
//	КомментарийВерсии				- Строка - Комментарий при помещении изменений в хранилище
//	ИспользуемаяВерсияПлатформы		- Строка - Используемая версия платформы
//
Процедура ОбновитьВерсиюПодсистемы(Хранилище_Адрес
								 , Хранилище_ИмяПользователя
								 , Хранилище_ПарольПользователя
								 , МакетВерсии
								 , МаскаВерсии
								 , КомментарийВерсии
								 , ИспользуемаяВерсияПлатформы)
	
	РабочийКаталог = ОбъединитьПути(КаталогВременныхФайлов(), ПолучитьИмяВременногоФайла(""));

	Конфигуратор = ЗапускПриложений.НастроитьКонфигуратор(РабочийКаталог, , , , ИспользуемаяВерсияПлатформы);
	
	Лог.Информация("Создана временная база");

	Конфигуратор.ПодключитьсяКХранилищу(Хранилище_Адрес
									  , Хранилище_ИмяПользователя
									  , Хранилище_ПарольПользователя
									  , Истина);

	Лог.Информация("Выполнено подключение к хранилищу");

	ПутиКФайламВерсии = ВыгрузитьМакетВерсии(Конфигуратор, РабочийКаталог, МакетВерсии);
	Лог.Информация("Выгружен макет версии подсистемы """ + МакетВерсии + """");

	//Изменяем макет версии
	ТекстМакетВерсии = Новый ТекстовыйДокумент();
	ТекстМакетВерсии.Прочитать(ПутиКФайламВерсии.Макет);
	
	ТекущаяВерсия = ТекстМакетВерсии.ПолучитьСтроку(1);

	НоваяВерсия = ПолучитьНовуюВерсию(ТекущаяВерсия, МаскаВерсии);

	ТекстМакетВерсии.УстановитьТекст(НоваяВерсия);
	ТекстМакетВерсии.Записать(ПутиКФайламВерсии.Макет);
	
	Лог.Информация("Изменена версия подсистемы " + ТекущаяВерсия + " -> " + НоваяВерсия);

	Конфигуратор.ЗахватитьОбъектыВХранилище(Хранилище_Адрес, Хранилище_ИмяПользователя, Хранилище_ПарольПользователя, ПутиКФайламВерсии.ФайлИзменений);

	Лог.Информация("Захвачен макет версии подсистемы в хранилище");

	Конфигуратор.ЗагрузитьКонфигурациюИзФайлов(ПутиКФайламВерсии.КаталогВыгрузки, ПутиКФайламВерсии.ФайлЗагрузки);

	Лог.Информация("Загружен макет версии подсистемы");

	Конфигуратор.ПоместитьИзмененияОбъектовВХранилище(Хранилище_Адрес, Хранилище_ИмяПользователя, Хранилище_ПарольПользователя, ПутиКФайламВерсии.ФайлИзменений, СтрЗаменить(КомментарийВерсии, "%version%", НоваяВерсия));

	Лог.Информация("Макет версии подсистемы помещен в хранилище");

	ЗапускПриложений.УдалитьРабочийКаталог(РабочийКаталог);

КонецПроцедуры //ОбновитьВерсиюПодсистемы()

// Возвращает новую версию преобразуя переданную версию в соответствии с маской
//   
// Параметры:
//   ТекущаяВерсия 	- Строка - Текущая версия для изменения
//   МаскаВерсии 	- Строка - Маска версии в виде x.x.x.x, где x может принимать значения:
//									# - оставить значение без изменения
//									* - увеличить значение на 1
//									$ - сбросить номер версии на 0 (для последнего числа на 1)
//									<любые символы> - вставить указанные символы
// Возвращаемое значение:
//		Строка		- Новая версия
//
Функция ПолучитьНовуюВерсию(ТекущаяВерсия, МаскаВерсии)

	МассивВерсия = СтрРазделить(ТекущаяВерсия, ".", Ложь);
	МассивМаскаВерсии = СтрРазделить(МаскаВерсии, ".", Ложь);

	Для й = 0 По МассивМаскаВерсии.ВГраница() Цикл
		Если МассивМаскаВерсии[й] = "*" Тогда
			Попытка
				ВерсияЧислом = Число(МассивВерсия[й]);
			Исключение
				Лог.Ошибка("Ошибка изменения версии "" + МассивВерсия[й] + "":" + ОписаниеОшибки());
			КонецПопытки;

			МассивВерсия[й] = ВерсияЧислом + 1;
		ИначеЕсли МассивМаскаВерсии[й] = "#" Тогда
			МассивВерсия[й] = МассивВерсия[й];
		ИначеЕсли МассивМаскаВерсии[й] = "$" Тогда
			МассивВерсия[й] = ?(МассивМаскаВерсии.ВГраница() = й, 1, 0);
		Иначе
			МассивВерсия[й] = МассивМаскаВерсии[й];
		КонецЕсли;
	КонецЦикла;

	НоваяВерсия = "";

	Для й = 0 По МассивВерсия.ВГраница() Цикл
		НоваяВерсия = НоваяВерсия + ?(НоваяВерсия = "", "", ".") + МассивВерсия[й];
	КонецЦикла;

	Возврат НоваяВерсия;

КонецФункции //ПолучитьНовуюВерсию()

Лог = Логирование.ПолучитьЛог("ktb.app.yadt");