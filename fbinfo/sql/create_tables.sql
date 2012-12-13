CREATE TABLE uids (id integer PRIMARY KEY SERIAL, uid integer)
CREATE TABLE names (id integer PRIMARY KEY SERIAL, name varchar(255), uid integer FOREIGN KEY)
CREATE TABLE birthdays (id integer PRIMARY KEY SERIAL, birthday varchar(255), uid integer FOREIGN KEY)
CREATE TABLE usernames (id integer PRIMARY KEY SERIAL, username varchar(255), uid integer FOREIGN KEY)
CREATE TABLE genders (id integer PRIMARY KEY SERIAL, gender varchar(255), uid integer FOREIGN KEY)
CREATE TABLE locales (id integer PRIMARY KEY SERIAL, locale varchar(255), uid integer FOREIGN KEY)
CREATE TABLE addresses ( id integer PRIMARY KEY SERIAL, address varchar(255), uid integer FOREIGN KEY)


