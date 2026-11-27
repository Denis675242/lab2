-- Лабораторная работа №2: Создание запросов
-- Вариант 17. База данных: Lab1
-- Таблицы: disciplines, workload
-- Скрипт выполняйте по порядку, сверху вниз.

-- =========================================================
-- Подготовка. В исходных данных нет дисциплин, название
-- которых начинается со слова «Основы», поэтому запрос 4
-- ничего бы не добавил. Добавляем две тестовые дисциплины
-- (без записей в «Нагрузке», чтобы их не было в запросе 2).
-- =========================================================
INSERT INTO disciplines (discipline_name, description, standard_year)
SELECT 'Основы права', 'Правовые основы профессиональной деятельности', 2019
WHERE NOT EXISTS (SELECT 1 FROM disciplines WHERE discipline_name = 'Основы права');

INSERT INTO disciplines (discipline_name, description, standard_year)
SELECT 'Основы электротехники', 'Базовые понятия электротехники', 2016
WHERE NOT EXISTS (SELECT 1 FROM disciplines WHERE discipline_name = 'Основы электротехники');


-- =========================================================
-- Запрос 1 (выборка). Все дисциплины, стандарт на которые
-- был введен более 5 лет назад.
-- =========================================================
SELECT *
FROM disciplines
WHERE standard_year < EXTRACT(YEAR FROM CURRENT_DATE) - 5;


-- =========================================================
-- Запрос 2 (выборка). Дисциплины, которые читают
-- преподаватели с почасовой оплатой.
-- =========================================================
SELECT DISTINCT d.*
FROM disciplines d
JOIN workload w ON d.discipline_id = w.discipline_id
WHERE w.hourly_pay > 0;


-- =========================================================
-- Запрос 3 (создание таблицы). Таблица с данными запроса 2:
-- код, название, описание и год введения дисциплин.
-- DROP позволяет запускать скрипт повторно.
-- =========================================================
DROP TABLE IF EXISTS hourly_disciplines;

CREATE TABLE hourly_disciplines AS
SELECT DISTINCT d.discipline_id,
       d.discipline_name,
       d.description,
       d.standard_year
FROM disciplines d
JOIN workload w ON d.discipline_id = w.discipline_id
WHERE w.hourly_pay > 0;

SELECT * FROM hourly_disciplines ORDER BY discipline_id;


-- =========================================================
-- Запрос 4 (Insert Select). Добавить дисциплины, название
-- которых состоит из нескольких слов и начинается
-- со слова «основы». NOT EXISTS исключает дубли по коду.
-- =========================================================
INSERT INTO hourly_disciplines
    (discipline_id, discipline_name, description, standard_year)
SELECT d.discipline_id,
       d.discipline_name,
       d.description,
       d.standard_year
FROM disciplines d
WHERE d.discipline_name ILIKE 'основы %'
  AND NOT EXISTS (
      SELECT 1
      FROM hourly_disciplines h
      WHERE h.discipline_id = d.discipline_id
  );

SELECT * FROM hourly_disciplines ORDER BY discipline_id;


-- =========================================================
-- Запрос 5 (Update). Изменить год введения на 2009
-- всем дисциплинам с четным кодом.
-- =========================================================
UPDATE hourly_disciplines
SET standard_year = 2009
WHERE discipline_id % 2 = 0;

SELECT * FROM hourly_disciplines ORDER BY discipline_id;


-- =========================================================
-- Запрос 6 (Delete). Удалить записи для всех дисциплин,
-- в названии которых встречается слово «математика».
-- =========================================================
DELETE FROM hourly_disciplines
WHERE discipline_name ILIKE '%математика%';

SELECT * FROM hourly_disciplines ORDER BY discipline_id;


-- =========================================================
-- Запрос 7 (групповой). Количество вводимых дисциплин
-- за каждые 5 лет, начиная с 1990 года.
-- =========================================================
SELECT
    1990 + ((standard_year - 1990) / 5) * 5 AS period_start,
    COUNT(*) AS discipline_count
FROM disciplines
WHERE standard_year >= 1990
GROUP BY period_start
ORDER BY period_start;


-- =========================================================
-- Встроенные функции:
--   EXTRACT(YEAR FROM ...) — извлекает год из даты;
--   CURRENT_DATE — возвращает текущую дату.
-- Агрегативные функции:
--   COUNT(*) — считает количество строк в группе.
-- =========================================================
