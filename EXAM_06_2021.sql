CREATE TABLE `addresses`(
`id` INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
`name` VARCHAR(100) NOT NULL
);

CREATE TABLE `categories`(
`id` INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
`name` VARCHAR(10) NOT NULL
);

CREATE TABLE `clients`(
`id` INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
`full_name` VARCHAR(50) NOT NULL,
`phone_number` VARCHAR(20) NOT NULL
);

CREATE TABLE `drivers`(
`id` INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
`first_name` VARCHAR(30) NOT NULL,
`last_name` VARCHAR(30) NOT NULL,
`age` INT NOT NULL,
`rating` FLOAT DEFAULT 5.5
);

CREATE TABLE `cars`(
`id` INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
`make` VARCHAR(20) NOT NULL,
`model` VARCHAR(20),
`year` INT NOT NULL DEFAULT 0,
`mileage` INT DEFAULT 0,
`condition` CHAR NOT NULL,
`category_id` INT NOT NULL,
CONSTRAINT fk_category_id
FOREIGN KEY(`category_id`)
REFERENCES `categories`(`id`)
);

CREATE TABLE `courses`(
`id` INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
`from_address_id` INT NOT NULL,
`start` DATETIME NOT NULL,
`bill` DECIMAL(10,2) DEFAULT 10,
`car_id` INT NOT NULL,
`client_id` INT NOT NULL,
CONSTRAINT fk_address_id
FOREIGN KEY(`from_address_id`)
REFERENCES `addresses`(`id`),
CONSTRAINT fk_car_id
FOREIGN KEY(`car_id`)
REFERENCES `cars`(`id`),
CONSTRAINT fk_client_id
FOREIGN KEY(`client_id`)
REFERENCES `clients`(`id`)
);

CREATE TABLE `cars_drivers`(
`car_id` INT NOT NULL,
`driver_id` INT NOT NULL,
PRIMARY KEY (`car_id`, `driver_id`),
CONSTRAINT fk_car_driver_id
FOREIGN KEY(`car_id`)
REFERENCES `cars`(`id`),
CONSTRAINT fk_drivers_cars_id
FOREIGN KEY(`driver_id`)
REFERENCES `drivers`(`id`)
);

-- 2
INSERT INTO `clients` (`full_name`, `phone_number`)
SELECT CONCAT(`first_name`, ' ', `last_name`), CONCAT('(088) 9999',`id`*2) FROM `drivers` AS d
WHERE d.`id` BETWEEN 10 AND 20;

-- 3
UPDATE `cars`
SET `condition` = 'C'
WHERE `mileage`>= 800000 
OR `mileage` IS NULL 
AND `year`<= 2010 
AND `make` NOT IN('Mercedes-Benz');

-- 4
DELETE FROM `clients`
WHERE `id` NOT IN(SELECT `client_id` FROM `courses`)
AND CHAR_LENGTH(`full_name`)>3;

-- 5
SELECT `make`, `model`, `condition` FROM `cars`
ORDER BY `id`;

-- 6
SELECT d.`first_name`, d.`last_name`, c.`make`, c.`model`, c.`mileage` FROM `drivers` AS d
JOIN `cars_drivers` AS cd ON d.`id` = cd.`driver_id`
JOIN `cars` AS c ON cd.`car_id` = c.`id`
WHERE c.`mileage` IS NOT NULL
ORDER BY c.`mileage` DESC, d.`first_name`;

-- 7
SELECT c.`id` AS 'car_id', c.`make`,c.`mileage`,COUNT(co.`id`) AS 'count_of_courses', ROUND(AVG(co.`bill`),2) AS 'avg_bill'
FROM cars AS c
LEFT JOIN `courses` AS co ON c.`id`= co.`car_id`
GROUP BY c.`id`
HAVING count_of_courses<>2
ORDER by count_of_courses DESC, c.`id`;


-- 8
SELECT c.`full_name`, COUNT(`client_id`) AS 'count_of_cars', SUM(`bill`) AS 'total_sum' FROM `courses` AS co
JOIN `clients` AS c ON co.`client_id` = c.`id`
GROUP BY co.`client_id`
HAVING LOCATE("a", c.`full_name`) = 2  AND count_of_cars >1
ORDER BY `full_name`;

-- 9
SELECT a.`name`,IF(HOUR(co.`start`) BETWEEN 6 AND 20, 'Day', 'Night') AS 'day_time' , co.`bill`, cl.`full_name`, c.`make`, c.`model`, ca.`name` 
FROM `courses` AS co
JOIN `addresses` AS a ON co.`from_address_id` = a.`id`
JOIN `clients` AS cl ON co.`client_id` = cl.`id`
JOIN `cars` AS c ON co.`car_id` = c.`id`
JOIN `categories` AS ca ON c.`category_id` = ca.`id`
ORDER BY co.`id`;

-- 10
DELIMITER //
CREATE FUNCTION udf_courses_by_client (phone_number VARCHAR(20))
RETURNS INT DETERMINISTIC
BEGIN
DECLARE `count` INT;
SET `count` := 
(SELECT COUNT(cl.`id`) FROM `clients` AS cl
JOIN `courses` AS co ON cl.`id` = co.`client_id`
WHERE cl.`phone_number` = phone_number);
RETURN `count`;
END //
DELIMITER ; 

SELECT udf_courses_by_client('(803) 6386812');

-- 11
DELIMITER //
CREATE PROCEDURE udp_courses_by_address(address_name VARCHAR(100))
BEGIN
SELECT a.`name`, cl.`full_name`, (
    CASE 
        WHEN co.`bill`<20 THEN 'Low'
        WHEN co.`bill`<30 THEN 'Medium'
                ELSE 'High'
    END)  AS 'level_of_bill', c.`make`, c.`condition`, ca.`name` AS 'cat_name' FROM `addresses` AS a
JOIN `courses` AS co ON co.`from_address_id` = a.`id`
JOIN `cars` AS c ON co.`car_id` = c.`id`
JOIN `clients` AS cl ON co.`client_id`= cl.`id`
JOIN `categories` AS ca ON c.`category_id` = ca.`id`
WHERE a.`name` =  address_name
ORDER BY c.`make`, cl.`full_name`;
END //
DELIMITER ; 

CALL udp_courses_by_address('700 Monterey Avenue');



