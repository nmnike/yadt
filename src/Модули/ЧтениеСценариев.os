#Использовать json

Перем мЧтениеJSON;
Перем Лог;

// Читает сценарии из переданного объекта
//
// Параметры:
//  пОбъектЧтения  - Строка, Файл, Массив, Структура, Соответствие из строк и файлов - перечень путей к файлу или файлов
//					 из которых нужно прочитать параметры
//
// Возвращаемое значение:
//   Соответствие   - Параметры, прочитанные в соответствие
//
Функция ПрочитатьСценарии(Знач ФайлыСценариев = Неопределено) Экспорт
	
	МассивПутейКСценариям = СтрРазделить(ФайлыСценариев, ";");

	массивФайловДляЧтения = Новый Массив;

	ПрочитатьОбъектСФайламиРекурсивно(МассивПутейКСценариям, массивФайловДляЧтения);

	мЧтениеJSON = Новый ПарсерJSON;
	мПрочитанныеСценарии = Новый Массив;

	Для каждого цИмяФайл Из массивФайловДляЧтения Цикл
		
		Сценарий = ПрочитатьФайл(цИмяФайл);

		Если НЕ ЗначениеЗаполнено(Сценарий) Тогда
			ВызватьИсключение СтрШаблон("Не удалось прочитать файл ""%1""", цИмяФайл);
		КонецЕсли;

		мПрочитанныеСценарии.Добавить(Новый Структура("ПутьКФайлу, Сценарий", цИмяФайл, Сценарий));
		
	КонецЦикла;

	//ВыполнитьПодстановки();

	Возврат мПрочитанныеСценарии;	
	
КонецФункции

Процедура ПрочитатьОбъектСФайламиРекурсивно(Знач пОбъектЧтения, пМассивПрочитанныхЗначений)
	
	Если ТипЗнч(пОбъектЧтения) = Тип("Строка") Тогда

		ДобавитьВМассив(пМассивПрочитанныхЗначений, пОбъектЧтения);

	ИначеЕсли ТипЗнч(пОбъектЧтения) = Тип("Файл") Тогда

		ДобавитьВМассив(пМассивПрочитанныхЗначений, пОбъектЧтения.ПолноеИмя);

	ИначеЕсли ТипЗнч(пОбъектЧтения) = Тип("Массив") Тогда

		Для каждого цЭлемент Из пОбъектЧтения Цикл
			ПрочитатьОбъектСФайламиРекурсивно(цЭлемент, пМассивПрочитанныхЗначений);
		КонецЦикла;

	ИначеЕсли ТипЗнч(пОбъектЧтения) = Тип("Структура")
		ИЛИ ТипЗнч(пОбъектЧтения) = Тип("Соответствие") Тогда

		Для каждого цЭлемент Из пОбъектЧтения Цикл
			ПрочитатьОбъектСФайламиРекурсивно(цЭлемент.Значение, пМассивПрочитанныхЗначений);
		КонецЦикла;

	ИначеЕсли Не ЗначениеЗаполнено(пОбъектЧтения) Тогда

		Для каждого цЭлемент Из НайтиФайлы(ПапкаПоискаПоУмолчанию(), МаскаПоискаФайлаПоУмолчанию(), Ложь) Цикл
			ПрочитатьОбъектСФайламиРекурсивно(цЭлемент, пМассивПрочитанныхЗначений);
		КонецЦикла;

	КонецЕсли;

КонецПроцедуры //ПрочитатьОбъектСФайламиРекурсивно()

Процедура ДобавитьВМассив(пМассив, Знач пЗначение, Знач пТолькоУникальныеЗначения = Истина)
	
	Если пТолькоУникальныеЗначения Тогда
		
		Если пМассив.Найти(пЗначение) = Неопределено Тогда
			пМассив.Добавить(пЗначение);
		КонецЕсли;

	Иначе
		пМассив.Добавить(пЗначение);
	КонецЕсли;
	
КонецПроцедуры //ДобавитьВМассив()

Функция ПрочитатьФайл(Знач пПолныйПутьКЧитаемомуФайлу)
	
	Лог.Информация("Чтение файла ""%1""", пПолныйПутьКЧитаемомуФайлу);

	Если Не ФайлСуществует(пПолныйПутьКЧитаемомуФайлу) Тогда			
		Лог.Ошибка("Файл ""%1"" не существует.", пПолныйПутьКЧитаемомуФайлу);
		Возврат Неопределено;			
	КонецЕсли;
	
	Попытка
		текстФайла = ПолучитьТекстИзФайла(пПолныйПутьКЧитаемомуФайлу);
	Исключение
		Лог.Ошибка("Не удалось прочитать файл ""%1"": %2", пПолныйПутьКЧитаемомуФайлу, ОписаниеОшибки());
		Возврат Неопределено;
	КонецПопытки;
	
	Попытка
		текстФайлаБезКомментариев = ВырезатьКомментарии(текстФайла);
		параметрыИзФайла = мЧтениеJSON.ПрочитатьJSON(текстФайлаБезКомментариев, , , Истина);
	Исключение
		Лог.Ошибка("Ошибка чтения JSON из файла ""%1"": %2", пПолныйПутьКЧитаемомуФайлу, ОписаниеОшибки());
		Возврат Неопределено;
	КонецПопытки;

	ОбработатьПараметрыРекурсивно(параметрыИзФайла, пПолныйПутьКЧитаемомуФайлу);
	
	Возврат параметрыИзФайла;

КонецФункции //ПрочитатьФайл()

Процедура ОбработатьПараметрыРекурсивно(Знач пПараметры, Знач пПолныйПутьКЧитаемомуФайлу)
	
	ИзменяемыеПараметры = Новый Соответствие();

	Для каждого цЭлемент Из пПараметры Цикл

		Если ТипЗнч(цЭлемент.Значение) = Тип("Строка") Тогда
			
			НовоеЗначение = ПрочитатьФайлИзЗначенияПараметра(цЭлемент.Значение, пПолныйПутьКЧитаемомуФайлу);
			Если НЕ НовоеЗначение = цЭлемент.Значение Тогда
				ИзменяемыеПараметры.Вставить(цЭлемент.Ключ, НовоеЗначение);
			КонецЕсли;
			
		КонецЕсли;
		
		Если ТипЗнч(цЭлемент.Значение) = Тип("Структура")
			ИЛИ ТипЗнч(цЭлемент.Значение) = Тип("Соответствие") Тогда
			
			ОбработатьПараметрыРекурсивно(цЭлемент.Значение, пПолныйПутьКЧитаемомуФайлу);
			
		КонецЕсли;

	КонецЦикла;
	
	Если ТипЗнч(пПараметры) = Тип("Структура")
		ИЛИ ТипЗнч(пПараметры) = Тип("Соответствие") Тогда
		Для Каждого ТекПараметр Из ИзменяемыеПараметры Цикл
			пПараметры.Вставить(ТекПараметр.Ключ, ТекПараметр.Значение);
		КонецЦикла;			
	КонецЕсли;

КонецПроцедуры //ОбработатьПараметрыРекурсивно()

Функция ПрочитатьФайлИзЗначенияПараметра(Знач пЗначение, Знач пПолныйПутьКРодительскомуФайлу = "")
	
	Если Не СтрНачинаетсяС(ВРег(пЗначение), ВРег(Префикс_ПрочитатьФайл())) Тогда
		Возврат пЗначение;
	КонецЕсли;
	
	пЗначение = Сред(пЗначение, СтрДлина(Префикс_ПрочитатьФайл()) + 1);

	Если СтрНачинаетсяС(пЗначение, ".")
		И Не пПолныйПутьКРодительскомуФайлу = "" Тогда
		
		файл = Новый Файл(пПолныйПутьКРодительскомуФайлу);
		путьКФайлу = ОбъединитьПути(файл.Путь, пЗначение);
		
	Иначе

		путьКФайлу = пЗначение;

	КонецЕсли;
	
	Возврат ПрочитатьФайл(путьКФайлу);
	
КонецФункции //ПрочитатьФайлИзЗначенияПараметра()

Функция Префикс_ПрочитатьФайл()
	Возврат "scen://";
КонецФункции

Функция ПапкаПоискаПоУмолчанию()
	Возврат ТекущийКаталог();
КонецФункции

Функция МаскаПоискаФайлаПоУмолчанию()
	Возврат "scen*.json";
КонецФункции

Функция ФайлСуществует(Знач пПутьКФайлу)
	
	файл = Новый Файл(пПутьКФайлу);
	Возврат файл.Существует() И файл.ЭтоФайл();

КонецФункции

Функция ПолучитьТекстИзФайла(Знач пИмяФайла)
	
	прочитанныйТекст = "";
	чтениеТекста = Новый ЧтениеТекста(пИмяФайла, КодировкаТекста.UTF8);
	прочитанныйТекст = чтениеТекста.Прочитать();
	чтениеТекста.Закрыть();
	Возврат прочитанныйТекст;

КонецФункции

// Удаляет все комментарии // и блоки /* */
Функция ВырезатьКомментарии(Знач пТекст)
	
	регулярноеВыражение = Новый РегулярноеВыражение( "(@(?:""[^""]*"")+|""(?:[^""\n\\]+|\\.)*""|'(?:[^'\n\\]+|\\.)*')|//.*|/\*(?s:.*?)\*/" );
	
	ЗначениеБезКомментариев = регулярноеВыражение.Заменить(пТекст, "$1" );

	Возврат ЗначениеБезКомментариев;

КонецФункции //ВырезатьКомментарии()

Лог = Логирование.ПолучитьЛог("ktb.app.yadt");