///////////////////////////////////////////////////////////////////
//
// Тестирование основной функциональности пакета
// Проверка на соответствие выгрузки эталону
//
// (с) BIA Technologies, LLC	
//
///////////////////////////////////////////////////////////////////

#Использовать logos
#Использовать asserts
#Использовать tempfiles
#Использовать 1commands
#Использовать ".."

///////////////////////////////////////////////////////////////////

Перем Лог;
Перем МенеджерВременныхФайлов;
Перем РасширениеПуть;
Перем РодительПуть;
Перем ПоставкаПуть;
Перем Парсер;

///////////////////////////////////////////////////////////////////
// Программный интерфейс
///////////////////////////////////////////////////////////////////

Функция ПолучитьСписокТестов(Знач ЮнитТестирование) Экспорт
	
	МассивТестов = Новый Массив;
	МассивТестов.Добавить("ТестПарсера_ПолучитьПрефиксРасширения");
	МассивТестов.Добавить("ТестПарсера_ВыполнитьЧтениеМетодовМодуля");
	МассивТестов.Добавить("ТестПарсера_ПолучитьПереопределенныеОбъекты");
	МассивТестов.Добавить("ТестПарсера_ПрочитатьМетодыОсновнойКонфигурации");
	МассивТестов.Добавить("ТестПриложения_ПолучитьРезультатСравнения");
	МассивТестов.Добавить("ТестПриложения_СохранитьРезультатСравнения");

	МассивТестов.Добавить("ТестПриложения_ПолучитьРезультатСравненияОбъектов");
	
	Возврат МассивТестов;
	
КонецФункции

Процедура ПередЗапускомТеста() Экспорт
	
	// служебные переменные
	РасширениеПуть = ОбъединитьПути("tests", "fixtures", "exts", "ADDTST");
	РодительПуть = ОбъединитьПути("tests", "fixtures", "configuration");
	ПоставкаПуть = ОбъединитьПути("tests", "fixtures", "release");

	ОбъектНастроек = ПараметрыПриложения;

	// Логирование
	Лог = Логирование.ПолучитьЛог(ОбъектНастроек.ИмяЛогаСистемы());
	Лог.УстановитьРаскладку(ОбъектНастроек);

	Парсер = Новый ПарсерМодулейРасширения(РасширениеПуть);

	МенеджерВременныхФайлов = Новый МенеджерВременныхФайлов;

КонецПроцедуры

Процедура ПослеЗапускаТеста() Экспорт
	
	МенеджерВременныхФайлов.Удалить();
	
КонецПроцедуры

///////////////////////////////////////////////////////////////////
// Шаги
///////////////////////////////////////////////////////////////////

Процедура ТестПарсера_ПолучитьПрефиксРасширения() Экспорт

	ФайлКонфигурации = ОбъединитьПути(РасширениеПуть, "Configuration.xml");
	Префикс = Парсер.ПрочитатьПрефиксРасширения(ФайлКонфигурации);

	Утверждения.ПроверитьРавенство("ADDTST", Префикс);

КонецПроцедуры

Процедура ТестПарсера_ВыполнитьЧтениеМетодовМодуля() Экспорт

	ФайлКонфигурации = ОбъединитьПути(РасширениеПуть, "Configuration.xml");
	Префикс = Парсер.ПрочитатьПрефиксРасширения(ФайлКонфигурации);

	ТипОбъектов = "Documents";

	Объекты = Парсер.ПолучитьФайлыОбъектов(ТипОбъектов); // Получаем документы
	Модули =  Парсер.ПолучитьФайлыМодулей(ТипОбъектов, Объекты[0].ИмяБезРасширения); // Получаем модули

	Методы = Парсер.ПрочитатьМетодыМодуля(Модули[0], Префикс);

	Утверждения.ПроверитьБольше(Методы.Количество(), 0);

КонецПроцедуры

Процедура ТестПарсера_ПолучитьПереопределенныеОбъекты() Экспорт

	Объекты = Парсер.ПолучитьПереопределенныеОбъекты();

	Утверждения.ПроверитьБольше(Объекты.Количество(), 0);

КонецПроцедуры

Процедура ТестПарсера_ПрочитатьМетодыОсновнойКонфигурации() Экспорт

	ФайлКонфигурации = ОбъединитьПути(РасширениеПуть, "Configuration.xml");
	Префикс = Парсер.ПрочитатьПрефиксРасширения(ФайлКонфигурации);

	ТипыКонфигурации = Парсер.ПолучитьПереопределенныеОбъекты();

	ОбъектыЕсть = Ложь;
	Для каждого ТипРасширения Из ТипыКонфигурации Цикл
		Если ТипРасширения.Объекты.Количество() Тогда

			ОбъектыЕсть = Истина;

			ОбъектРасширения = ТипРасширения.Объекты[0];
			ФайлМодуля = ОбъектРасширения.Модули[0]; // и первый модуль
			МодульОбъекта = ФайлМодуля.ФайлМодуля;
			ФайлМодуля.Вставить("Методы", Парсер.ПрочитатьМетодыМодуля(МодульОбъекта, Префикс)); // заполняем методы

			Парсер.ПрочитатьМетодыОсновнойКонфигурации(МодульОбъекта, ФайлМодуля, РодительПуть, "Родитель"); // сопоставляем с родительской конфигурацией

			Прервать;

		КонецЕсли;
	КонецЦикла;

	Утверждения.ПроверитьИстину(ОбъектыЕсть, "методы не обнаружены");

КонецПроцедуры

Процедура ТестПриложения_ПолучитьРезультатСравнения() Экспорт

	РезультатСравнения = РезультатСравненияРасширения.ПолучитьРезультатСравнения(
		РодительПуть, 
		ПоставкаПуть, 
		РасширениеПуть, 
		Лог);

	Утверждения.ПроверитьБольше(РезультатСравнения.Типы.Количество(), 0, "нет типов в результате сравнения");

КонецПроцедуры

Процедура ТестПриложения_СохранитьРезультатСравнения() Экспорт

	ФайлРезультатИмя = МенеджерВременныхФайлов.СоздатьФайл("HTML");

	РезультатСравнения = РезультатСравненияРасширения.ПолучитьРезультатСравнения(
		РодительПуть, 
		ПоставкаПуть, 
		РасширениеПуть, 
		Лог);

	Генератор = Новый ГенераторОтчета;
	Генератор.СохранитьРезультат(РезультатСравнения, ФайлРезультатИмя, Лог, "HTML");

	ТекстРезультат = Новый ТекстовыйДокумент();
	ТекстРезультат.Прочитать(ФайлРезультатИмя, КодировкаТекста.UTF8NoBOM);

	Утверждения.ПроверитьВхождение(ТекстРезультат.ПолучитьТекст(), "<!DOCTYPE HTML>", "текст не соответствует шаблону");

КонецПроцедуры

///////////////////////////////////////////////////////////////////

Процедура ТестПриложения_ПолучитьРезультатСравненияОбъектов() Экспорт

	РезультатСравнения = АнализаторОбъектов.ВыполнитьСравнениеОбъектов(РодительПуть, ПоставкаПуть, Лог);

	Утверждения.ПроверитьБольше(РезультатСравнения.Типы.Количество(), 0, "нет типов в результате сравнения");

КонецПроцедуры

///////////////////////////////////////////////////////////////////
// Служебный функционал
///////////////////////////////////////////////////////////////////

