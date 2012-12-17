CREATE TABLE fuids (id SERIAL PRIMARY KEY, fuid varchar(255))
CREATE TABLE names (id SERIAL, name varchar(255), uid integer references fuids(id))
CREATE TABLE birthdays (id SERIAL, birthday varchar(255), uid integer references fuids(id))
CREATE TABLE usernames (id SERIAL, username varchar(255), uid integer references fuids(id))
CREATE TABLE genders (id SERIAL, gender varchar(255), uid integer references fuids(id))
CREATE TABLE locales (id SERIAL, locale varchar(255), uid integer references fuids(id))
CREATE TABLE addresses ( id SERIAL, address varchar(255), uid integer references fuids(id))