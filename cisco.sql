-- phpMyAdmin SQL Dump
-- version 4.9.1
-- https://www.phpmyadmin.net/
--
-- Хост: localhost
-- Время создания: Июл 15 2021 г., 19:14
-- Версия сервера: 10.3.27-MariaDB-0+deb10u1
-- Версия PHP: 5.6.40-50+0~20210501.52+debian10~1.gbpf9383b

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `cisco`
--

-- --------------------------------------------------------

--
-- Структура таблицы `cisco_modes`
--

CREATE TABLE `cisco_modes` (
  `id_mode` int(11) NOT NULL,
  `name` varchar(32) NOT NULL,
  `description` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Дамп данных таблицы `cisco_modes`
--

INSERT INTO `cisco_modes` (`id_mode`, `name`, `description`) VALUES
(1, '>', 'Пользовательский режим'),
(2, '#', 'Привилегированный режим'),
(3, '(config)#', 'Режим конфигурирования'),
(4, '(config-if)#', 'Режим конфигурирования интерфейса'),
(5, '(config-subif)#', 'Режим конфигурирования подинтерфейса'),
(6, '(config-line)#', 'Режим конфигурирования линии'),
(7, '(config-router)#', 'Режим конфигурирования протокола маршрутизации'),
(8, '(config-dhcp)#', 'Режим конфигурирования DHCP-сервера'),
(9, '*', 'Затрагивает все режимы');

-- --------------------------------------------------------

--
-- Структура таблицы `commands`
--

CREATE TABLE `commands` (
  `id_command` int(11) NOT NULL,
  `id_table` int(11) NOT NULL,
  `command` varchar(100) NOT NULL,
  `mode` int(11) NOT NULL,
  `description` varchar(1000) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Структура таблицы `comments_table`
--

CREATE TABLE `comments_table` (
  `id_comments` int(11) NOT NULL,
  `id_table` int(11) NOT NULL,
  `comment` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Структура таблицы `notes`
--

CREATE TABLE `notes` (
  `id_notes` int(11) NOT NULL,
  `id_table` int(11) NOT NULL,
  `note` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL COMMENT '{}'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Структура таблицы `section`
--

CREATE TABLE `section` (
  `id_section` int(11) NOT NULL,
  `name` varchar(32) NOT NULL,
  `name_ru` varchar(32) NOT NULL,
  `href` varchar(60) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Структура таблицы `subsection`
--

CREATE TABLE `subsection` (
  `id_subsection` int(11) NOT NULL,
  `id_section` int(11) NOT NULL,
  `name` varchar(32) NOT NULL,
  `name_ru` varchar(32) NOT NULL,
  `href` varchar(60) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Структура таблицы `tables`
--

CREATE TABLE `tables` (
  `id_table` int(11) NOT NULL,
  `id_section` int(11) NOT NULL,
  `id_subsection` int(11) DEFAULT NULL,
  `table_name` varchar(64) NOT NULL,
  `default_columns` tinyint(1) NOT NULL DEFAULT 1 COMMENT '0 - not use; 1 - use',
  `columns` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `view_SecAndSub`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `view_SecAndSub` (
`sec_name` varchar(32)
,`sub_name` varchar(32)
,`sub_name_ru` varchar(32)
,`sub_href` varchar(60)
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `view_TableAndCommands`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `view_TableAndCommands` (
`table_name` varchar(64)
,`command` varchar(100)
,`description` varchar(1000)
,`mode` varchar(32)
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `view_TableAndComments`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `view_TableAndComments` (
`table_name` varchar(64)
,`comment` text
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `view_TableAndSection`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `view_TableAndSection` (
`section` varchar(32)
,`subsection` varchar(32)
,`id_table` int(11)
,`table_name` varchar(64)
,`default_columns` tinyint(1)
,`columns` longtext
,`comment` text
);

-- --------------------------------------------------------

--
-- Дублирующая структура для представления `view_TableAndSub`
-- (См. Ниже фактическое представление)
--
CREATE TABLE `view_TableAndSub` (
`subsection` varchar(32)
,`table_name` varchar(64)
,`default_columns` tinyint(1)
,`columns` longtext
);

-- --------------------------------------------------------

--
-- Структура для представления `view_SecAndSub`
--
DROP TABLE IF EXISTS `view_SecAndSub`;

CREATE ALGORITHM=UNDEFINED DEFINER=`pymysql`@`localhost` SQL SECURITY DEFINER VIEW `view_SecAndSub`  AS  select `section`.`name` AS `sec_name`,`subsection`.`name` AS `sub_name`,`subsection`.`name_ru` AS `sub_name_ru`,`subsection`.`href` AS `sub_href` from (`section` join `subsection` on(`section`.`id_section` = `subsection`.`id_section`)) ;

-- --------------------------------------------------------

--
-- Структура для представления `view_TableAndCommands`
--
DROP TABLE IF EXISTS `view_TableAndCommands`;

CREATE ALGORITHM=UNDEFINED DEFINER=`pymysql`@`localhost` SQL SECURITY DEFINER VIEW `view_TableAndCommands`  AS  select `tables`.`table_name` AS `table_name`,`commands`.`command` AS `command`,`commands`.`description` AS `description`,`cisco_modes`.`name` AS `mode` from ((`tables` join `commands` on(`tables`.`id_table` = `commands`.`id_table`)) join `cisco_modes` on(`cisco_modes`.`id_mode` = `commands`.`mode`)) ;

-- --------------------------------------------------------

--
-- Структура для представления `view_TableAndComments`
--
DROP TABLE IF EXISTS `view_TableAndComments`;

CREATE ALGORITHM=UNDEFINED DEFINER=`pymysql`@`localhost` SQL SECURITY DEFINER VIEW `view_TableAndComments`  AS  select `tables`.`table_name` AS `table_name`,`comments_table`.`comment` AS `comment` from (`tables` join `comments_table` on(`tables`.`id_table` = `comments_table`.`id_table`)) ;

-- --------------------------------------------------------

--
-- Структура для представления `view_TableAndSection`
--
DROP TABLE IF EXISTS `view_TableAndSection`;

CREATE ALGORITHM=UNDEFINED DEFINER=`pymysql`@`localhost` SQL SECURITY DEFINER VIEW `view_TableAndSection`  AS  select `section`.`name` AS `section`,`subsection`.`name` AS `subsection`,`tables`.`id_table` AS `id_table`,`tables`.`table_name` AS `table_name`,`tables`.`default_columns` AS `default_columns`,`tables`.`columns` AS `columns`,`comments_table`.`comment` AS `comment` from (((`tables` left join `section` on(`tables`.`id_section` = `section`.`id_section`)) left join `subsection` on(`tables`.`id_subsection` = `subsection`.`id_subsection`)) left join `comments_table` on(`comments_table`.`id_table` = `tables`.`id_table`)) ;

-- --------------------------------------------------------

--
-- Структура для представления `view_TableAndSub`
--
DROP TABLE IF EXISTS `view_TableAndSub`;

CREATE ALGORITHM=UNDEFINED DEFINER=`pymysql`@`localhost` SQL SECURITY DEFINER VIEW `view_TableAndSub`  AS  select `subsection`.`name` AS `subsection`,`tables`.`table_name` AS `table_name`,`tables`.`default_columns` AS `default_columns`,`tables`.`columns` AS `columns` from (`tables` join `subsection` on(`subsection`.`id_subsection` = `tables`.`id_subsection`)) ;

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `cisco_modes`
--
ALTER TABLE `cisco_modes`
  ADD PRIMARY KEY (`id_mode`);

--
-- Индексы таблицы `commands`
--
ALTER TABLE `commands`
  ADD PRIMARY KEY (`id_command`),
  ADD KEY `mode` (`mode`),
  ADD KEY `id_table` (`id_table`);

--
-- Индексы таблицы `comments_table`
--
ALTER TABLE `comments_table`
  ADD PRIMARY KEY (`id_comments`),
  ADD KEY `id_table` (`id_table`);

--
-- Индексы таблицы `notes`
--
ALTER TABLE `notes`
  ADD PRIMARY KEY (`id_notes`),
  ADD KEY `id_table` (`id_table`);

--
-- Индексы таблицы `section`
--
ALTER TABLE `section`
  ADD PRIMARY KEY (`id_section`),
  ADD UNIQUE KEY `href` (`href`);

--
-- Индексы таблицы `subsection`
--
ALTER TABLE `subsection`
  ADD PRIMARY KEY (`id_subsection`),
  ADD KEY `id_section` (`id_section`);

--
-- Индексы таблицы `tables`
--
ALTER TABLE `tables`
  ADD PRIMARY KEY (`id_table`),
  ADD KEY `id_section` (`id_section`),
  ADD KEY `id_subsection` (`id_subsection`);

--
-- AUTO_INCREMENT для сохранённых таблиц
--

--
-- AUTO_INCREMENT для таблицы `cisco_modes`
--
ALTER TABLE `cisco_modes`
  MODIFY `id_mode` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT для таблицы `commands`
--
ALTER TABLE `commands`
  MODIFY `id_command` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `comments_table`
--
ALTER TABLE `comments_table`
  MODIFY `id_comments` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `notes`
--
ALTER TABLE `notes`
  MODIFY `id_notes` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `section`
--
ALTER TABLE `section`
  MODIFY `id_section` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `subsection`
--
ALTER TABLE `subsection`
  MODIFY `id_subsection` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT для таблицы `tables`
--
ALTER TABLE `tables`
  MODIFY `id_table` int(11) NOT NULL AUTO_INCREMENT;

--
-- Ограничения внешнего ключа сохраненных таблиц
--

--
-- Ограничения внешнего ключа таблицы `commands`
--
ALTER TABLE `commands`
  ADD CONSTRAINT `commands_ibfk_1` FOREIGN KEY (`mode`) REFERENCES `cisco_modes` (`id_mode`),
  ADD CONSTRAINT `commands_ibfk_2` FOREIGN KEY (`id_table`) REFERENCES `tables` (`id_table`);

--
-- Ограничения внешнего ключа таблицы `comments_table`
--
ALTER TABLE `comments_table`
  ADD CONSTRAINT `comments_table_ibfk_1` FOREIGN KEY (`id_table`) REFERENCES `tables` (`id_table`);

--
-- Ограничения внешнего ключа таблицы `notes`
--
ALTER TABLE `notes`
  ADD CONSTRAINT `notes_ibfk_1` FOREIGN KEY (`id_table`) REFERENCES `tables` (`id_table`);

--
-- Ограничения внешнего ключа таблицы `subsection`
--
ALTER TABLE `subsection`
  ADD CONSTRAINT `subsection_ibfk_1` FOREIGN KEY (`id_section`) REFERENCES `section` (`id_section`);

--
-- Ограничения внешнего ключа таблицы `tables`
--
ALTER TABLE `tables`
  ADD CONSTRAINT `tables_ibfk_1` FOREIGN KEY (`id_section`) REFERENCES `section` (`id_section`),
  ADD CONSTRAINT `tables_ibfk_2` FOREIGN KEY (`id_subsection`) REFERENCES `subsection` (`id_subsection`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
