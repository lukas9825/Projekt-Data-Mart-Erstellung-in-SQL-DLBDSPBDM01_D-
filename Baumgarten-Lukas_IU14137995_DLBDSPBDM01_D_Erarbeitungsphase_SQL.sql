/*
Hinweis zur Verwendung von KI:
Die Dummy-Daten sind teilweise KI generiert, dies betrifft die Relationen: User, Review, Book, Author, Genre, Publisher, Author_Book, Item und TimeSlot.
Alles Andere, die Kommentare, die Struktur des Textes, Testfälle, Trigger etc. sind ohne Zuhilfenahme von KI entstanden.
*/

CREATE DATABASE bookmart;
USE bookmart;


-- Erstelle Relation "Address"
CREATE TABLE Address (
  ID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  Country VARCHAR(50) NOT NULL,
  City VARCHAR(50) NOT NULL,
  ZIPCode VARCHAR(10) NOT NULL,
  Street VARCHAR(100) NOT NULL
 );


-- Füge Dummy-Daten in Address ein
INSERT INTO Address VALUES
  (NULL, 'Deutschland', 'Berlin', '10779', 'Barbarossastraße 24'),
  (NULL, 'Deutschland', 'Berlin', '10779', 'Barbarossastraße 26'),
  (NULL, 'Deutschland', 'Berlin', '10779', 'Münchener Str. 45'),
  (NULL, 'Deutschland', 'Berlin', '10779', 'Münchener Str. 11'),
  (NULL, 'Deutschland', 'Berlin', '10825', 'Münchener Str. 25 a'),
  (NULL, 'Deutschland', 'Berlin', '10825', 'Münchener Str. 25 b'),
  (NULL, 'Deutschland', 'Potsdam', '14482', 'Turnstraße 28'),
  (NULL, 'Deutschland', 'Potsdam', '14482', 'Turnstraße 29'),
  (NULL, 'Deutschland', 'Magdeburg', '39128', 'Grünewaldweg 21'),
  (NULL, 'Polen', 'Szczecin', '71-157', 'Księdza Grzegorza Piramowicza 5')
;


-- Zeige Dummy-Daten in Address
SELECT * FROM Address;


-- Erstelle Relation "User"
CREATE TABLE User (
  ID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  Username VARCHAR(30) NOT NULL,
  FullName VARCHAR(100) NOT NULL,
  AddressID INT UNSIGNED NOT NULL,
  PhoneNumber VARCHAR(30),
  Email VARCHAR(50),
  Password BLOB(32) NOT NULL,
  FOREIGN KEY (AddressID) REFERENCES Address (ID)
);


-- Erstelle Relation "UserStats"
CREATE OR REPLACE TABLE UserStats (
  UserID INT UNSIGNED PRIMARY KEY,
  BooksBorrowed INT UNSIGNED DEFAULT 0,
  OnTimeReturns INT UNSIGNED DEFAULT 0,
  BooksLended INT UNSIGNED DEFAULT 0,
  ReviewsWritten INT UNSIGNED DEFAULT 0,
  FOREIGN KEY (UserID) REFERENCES User (ID)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);


-- Erstelle Trigger, welcher UserStats Entitäten für erstellte User Entitäten erstellt
CREATE OR REPLACE TRIGGER UserInsert_UserStats
AFTER INSERT ON User FOR EACH ROW
INSERT INTO UserStats (UserID) VALUES (NEW.ID);


-- Füge Dummy-Daten in User ein
INSERT INTO User VALUES
  (NULL, 'anna.schmidt', 'Anna Schmidt', 1, '+49 170 1234501', 'anna.schmidt@example.com', 'b2f6e9ba526bad0f8fe12b94ade8002243877a3be636b4f21c2a37074ae67f5c'),
  (NULL, 'max.mueller', 'Max Müller', 2, '+49 171 1234502', 'max.mueller@example.com', 'a2c582923fa7567767a95d8b54b8df95dbc2ba8f5c3c30d3a9a3c78d075636d1'),
  (NULL, 'lena.weber', 'Lena Weber', 3, '+49 172 1234503', 'lena.weber@example.com', '06f9b693fd6d91b34aad22ecdd02ff999bec244122f25f8aac57e8a45890d573'),
  (NULL, 'jonas.fischer', 'Jonas Fischer', 4, '+49 173 1234504', 'jonas.fischer@example.com', 'ff0220acb80401e0040b0eec262f302e0e030ac93e1db91a21e49566292faf24'),
  (NULL, 'sophie.wagner', 'Sophie Wagner', 5, '+49 174 1234505', 'sophie.wagner@example.com', '0aacc8f042d5fdf39574825a3a805610b54af08b39561f2807352475342473ad'),
  (NULL, 'felix.becker', 'Felix Becker', 6, '+49 175 1234506', 'felix.becker@example.com', '0dd64c19951e8726d97e90ae1e8e99427db5ad876ca6b27ac34c5750bf52a423'),
  (NULL, 'marie.hoffmann', 'Marie Hoffmann', 7, '+49 176 1234507', 'marie.hoffmann@example.com', '15b13bf2eae0635344966ced8cb279dc6636e09527e0216a6351bdba9162eb23'),
  (NULL, 'lukas.koch', 'Lukas Koch', 8, '+49 177 1234508', 'lukas.koch@example.com', 'ea8a72f60bc27419136f2c7b9e89284155332bb5d27230ca0ed0201bd28020cc'),
  (NULL, 'emma.schulz', 'Emma Schulz', 9, '+49 178 1234509', 'emma.schulz@example.com', '42c20eafcdb9a69c67b53e55187eba25f5a2d89e4df1f1e38c0a0d2f6069c3aa'),
  (NULL, 'paul.richter', 'Paul Richter', 10, '+49 179 1234510', 'paul.richter@example.com', '2a89e5eaf767b74772d9db4e7ab49eb3164ed6e2c2cb6f48deb63adc92a07356')
;


-- Zeige Auszug der Dummy-Daten in User
SELECT * FROM User ORDER BY Username ASC LIMIT 3;


-- Testfall User: Prüfe, ob das Löschen einer verwendeten Address ordnungsgemäß Fehlschlägt
DELETE FROM Address WHERE ID = (SELECT AddressID FROM User LIMIT 1);


-- Erstelle Trigger, welcher Address Entitäten Löscht, wenn sie nicht referenziert werden
DELIMITER //
CREATE TRIGGER UserDeleted_Address
AFTER UPDATE OR DELETE ON User FOR EACH ROW
BEGIN
  IF ((SELECT COUNT(*) FROM User WHERE AddressID = OLD.AddressID) = 0) THEN
    DELETE FROM Address WHERE ID = OLD.AddressID;
  END IF;
END;
//
DELIMITER ;


-- Testfall Address: Prüfe, ob unreferenzierte Address Entitäten ordnungsgemäß gelöscht werden
DELIMITER //
CREATE OR REPLACE PROCEDURE test_address()
MODIFIES SQL DATA
BEGIN
  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
    ROLLBACK;
  START TRANSACTION;
    INSERT INTO Address VALUES
      (NULL, 'Schweiz', 'Zürich', '123456', 'Bsp. Weg A'),
      (NULL, 'Schweiz', 'Zürich', '123456', 'Bsp. Weg B')
      ;
    INSERT INTO User VALUES
      (NULL, 'Test A', 'Test Name', LAST_INSERT_ID(), NULL, NULL, 'abcdefgh'),
      (NULL, 'Test B', 'Test Name', LAST_INSERT_ID()+1, NULL, NULL, 'abcdefgh')
      ;
    DELETE FROM User WHERE Username = 'Test A';
    UPDATE User SET AddressID = 10 WHERE Username = 'Test B';
    COMMIT;
  SELECT * FROM Address WHERE NOT ID IN (SELECT AddressID FROM User);
  DELETE FROM User WHERE ID = LAST_INSERT_ID()+1;
END;
//
DELIMITER ;
CALL test_address();


-- Erstelle Relation 'Publisher'
CREATE TABLE Publisher (
  ID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  Name VARCHAR(500) NOT NULL,
  Used BOOL DEFAULT 1
);


-- Füge Dummy-Daten in Publisher ein
INSERT INTO Publisher (ID, Name) VALUES
  (NULL, 'Fischer Verlag'),
  (NULL, 'Rowohlt Verlag'),
  (NULL, 'Suhrkamp Verlag'),
  (NULL, 'dtv'),
  (NULL, 'Heyne Verlag'),
  (NULL, 'Piper Verlag'),
  (NULL, 'Diogenes Verlag'),
  (NULL, 'Klett-Cotta'),
  (NULL, 'Carlsen Verlag'),
  (NULL, 'Random House')
;


-- Zeige Auszug der Dummy-Daten in Publisher
SELECT * FROM Publisher ORDER BY ID ASC LIMIT 3;


-- Erstelle Relation 'Genre'
CREATE TABLE Genre (
  ID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  Genre VARCHAR(200) NOT NULL,
  Used BOOL DEFAULT 1
);


-- Füge Dummy-Daten in Genre ein
INSERT INTO Genre (ID, Genre) VALUES
  (NULL, 'Roman'),
  (NULL, 'Fantasy'),
  (NULL, 'Science-Fiction'),
  (NULL, 'Krimi'),
  (NULL, 'Thriller'),
  (NULL, 'Horror'),
  (NULL, 'Biografie'),
  (NULL, 'Sachbuch'),
  (NULL, 'Kinderbuch'),
  (NULL, 'Lyrik')
;


-- Zeige Auszug der Dummy-Daten in Genre
SELECT * FROM Genre ORDER BY ID ASC LIMIT 3;


-- Erstelle Relation "Author"
CREATE TABLE Author (
  ID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  FirstName VARCHAR(50),
  Surname VARCHAR(100) NOT NULL,
  Used BOOL DEFAULT 1
);


-- Füge Dummy-Daten in Author ein
INSERT INTO Author (ID, FirstName, Surname) VALUES
  (NULL, 'Thomas', 'Bergmann'),
  (NULL, 'Julia', 'Neumann'),
  (NULL, 'Michael', 'Krüger'),
  (NULL, 'Sarah', 'Vogel'),
  (NULL, 'Laura', 'Hartmann'),
  (NULL, 'Stefan', 'Lindner'),
  (NULL, 'Nina', 'Berger'),
  (NULL, 'Christian', 'Wolf'),
  (NULL, 'Katharina', 'Stein'),
  (NULL, NULL, 'Brandt'),
  (NULL, NULL, 'Meyer')
;


-- Zeige Auszug der Dummy-Daten in Author
SELECT * FROM Author ORDER BY ID ASC LIMIT 3;


-- Erstelle Relation 'Language'
CREATE TABLE Language (
  ID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  Language VARCHAR(200) NOT NULL,
  Used BOOL DEFAULT 1
);


-- Füge Dummy-Daten in Language ein
INSERT INTO Language (ID, Language) VALUES (NULL, 'Deutsch'), (NULL, 'English');


-- Zeige Dummy-Daten in Language
SELECT * FROM Language;


-- Erstelle Relation 'Book'
CREATE TABLE Book (
  ID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  Title VARCHAR(500) NOT NULL,
  GenreID INT UNSIGNED,
  PublisherID INT UNSIGNED,
  ReleaseDate DATE,
  LanguageID INT UNSIGNED NOT NULL,
  FOREIGN KEY (GenreID) REFERENCES Genre (ID),
  FOREIGN KEY (PublisherID) REFERENCES Publisher (ID),
  FOREIGN KEY (LanguageID) REFERENCES Language (ID)  
);


-- Füge Dummy-Daten in Book ein
INSERT INTO Book VALUES
  (NULL, 'Der stille Wald', 1, 1, '2015-03-12', 1),
  (NULL, 'Drachenfeuer', 2, 5, '2018-07-01', 1),
  (NULL, 'Sternenexil', 3, 5, '2020-11-20', 1),
  (NULL, 'Der letzte Zeuge', 4, 6, '2019-05-15', 1),
  (NULL, 'Cold Case', 5, 7, '2021-09-09', 1),
  (NULL, 'Schattenhaus', 6, 2, '2017-10-31', 1),
  (NULL, 'Mein Leben zwischen zwei Welten', 7, 3, '2016-02-28', 1),
  (NULL, 'Die Kunst des klaren Denkens', 8, 4, '2014-01-10', 1),
  (NULL, 'Die Abenteuer von Lumi', 9, 9, '2022-04-05', 1),
  (NULL, 'Verse im Wind', 10, 8, '2013-06-18', 1)
;


-- Zeige Auszug der Dummy-Daten in Book
SELECT * FROM Book ORDER BY Title ASC LIMIT 3;


-- Testfall Book: Prüfe ob Tabellen Korrekt Verknüpft sind
SELECT Title, Genre.Genre, Publisher.Name, Language.Language FROM Book LEFT JOIN Genre ON Book.GenreID = Genre.ID LEFT JOIN Publisher ON Book.PublisherID = Publisher.ID LEFT JOIN Language ON Book.LanguageID = Language.ID ORDER BY Title ASC LIMIT 3;


-- Erstelle Trigger, welcher Language, Genre und Publisher Entitäten markiert, wenn sie nicht referenziert werden
DELIMITER //
CREATE OR REPLACE TRIGGER BookDeleted_language_genre_publisher
AFTER UPDATE OR DELETE ON Book FOR EACH ROW
BEGIN
  IF ((SELECT COUNT(*) FROM Book WHERE LanguageID = OLD.LanguageID) = 0) THEN
    UPDATE Language SET Used = 0 WHERE ID = OLD.LanguageID;
  END IF;
  IF ((SELECT COUNT(*) FROM Book WHERE GenreID = OLD.GenreID) = 0) THEN
    UPDATE Genre SET Used = 0 WHERE ID = OLD.GenreID;
  END IF;
  IF ((SELECT COUNT(*) FROM Book WHERE PublisherID = OLD.PublisherID) = 0) THEN
    UPDATE Publisher SET Used = 0 WHERE ID = OLD.PublisherID;
  END IF;
END;
//
DELIMITER ;


-- Testfall Language, Genre, Publisher: Prüfe, ob unreferenzierte Entitäten ordungsgemäß markiert werden
DELIMITER //
CREATE OR REPLACE PROCEDURE test_langPubGen()
MODIFIES SQL DATA
BEGIN
  DECLARE langIDa, langIDb, genIDa, genIDb, pubIDa, pubIDb TYPE OF Language.ID;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION, SQLWARNING
    ROLLBACK;
  START TRANSACTION;
    INSERT INTO Language VALUES (NULL, 'Bsp. Language A', 1), (NULL, 'Bsp. Language B', 1);
    SET langIDa = LAST_INSERT_ID();
    SET langIDb = LAST_INSERT_ID()+1;
    INSERT INTO Genre VALUES (NULL, 'Bsp. Genre A', 1), (NULL, 'Bsp. Genre B', 1);
    SET genIDa = LAST_INSERT_ID();
    SET genIDb = LAST_INSERT_ID()+1;
    INSERT INTO Publisher VALUES (NULL, 'Bsp. Publisher A', 1), (NULL, 'Bsp. Publisher B', 1);
    SET pubIDa = LAST_INSERT_ID();
    SET pubIDb = LAST_INSERT_ID()+1;
    INSERT INTO Book VALUES
      (NULL, 'Bsp Titel A', genIDa, pubIDa, NULL, langIDa),
      (NULL, 'Bsp Titel B', genIDb, pubIDb, NULL, langIDb)
    ; 

    UPDATE Book SET GenreID = 1, PublisherID = 1, LanguageID = 1 WHERE ID = LAST_INSERT_ID();
    DELETE FROM Book WHERE ID = LAST_INSERT_ID()+1;
  COMMIT;
  SELECT * FROM Publisher WHERE ID NOT IN (SELECT PublisherID FROM Book);
  SELECT * FROM Genre WHERE ID NOT IN (SELECT GenreID FROM Book);
  SELECT * FROM Language WHERE ID NOT IN (SELECT LanguageID FROM Book);
  
  DELETE FROM Book WHERE ID = LAST_INSERT_ID();
  DELETE FROM Publisher WHERE ID IN (pubIDa, pubIDb);
  DELETE FROM Genre WHERE ID IN (genIDa, genIDb);
  DELETE FROM Language WHERE ID IN (langIDa, langIDb);
END;
//
DELIMITER ;
CALL test_langPubGen();


-- Erstelle Relation 'Author_Book'
CREATE TABLE Author_Book (
  AuthorID INT UNSIGNED,
  BookID INT UNSIGNED,
  PRIMARY KEY (AuthorID, BookID),
  FOREIGN KEY (AuthorID) REFERENCES Author (ID),
  FOREIGN KEY (BookID) REFERENCES Book (ID)
    ON UPDATE CASCADE
);


-- Füge Dummy-Daten in Author_Book ein
INSERT INTO Author_Book VALUES
  (1, 1),
  (2, 2),
  (3, 3),
  (4, 4),
  (5, 5),
  (6, 6),
  (7, 7),
  (8, 8),
  (9, 9),
  (10, 10),
  (11, 9)
;


-- Zeige Auszug der Dummy-Daten in Author-Book
SELECT * FROM Author_Book ORDER BY BookID DESC LIMIT 3;


-- Erstelle Trigger, welcher für Author_Book "ON DELETE CASCADE" für Löschungen in Book nachbildet (da ON DELETE keine Trigger auslöst)
CREATE OR REPLACE TRIGGER BookDeleted_AuthorBook
BEFORE DELETE ON Book FOR EACH ROW
  DELETE FROM Author_Book WHERE BookID = OLD.ID;


-- Erstelle Trigger, welcher unreferenzierte Einträge in Author markiert
DELIMITER //
CREATE OR REPLACE TRIGGER markUnused_author
AFTER UPDATE OR DELETE ON Author_Book FOR EACH ROW
BEGIN
  IF ((SELECT COUNT(*) FROM Author_Book WHERE AuthorID = OLD.AuthorID) = 0) THEN
    UPDATE Author SET Used = 0 WHERE ID = OLD.AuthorID;
  END IF;
END;
//
DELIMITER ;


-- Testfall Author_Book: Prüfe, ob Änderungen in Book übernommen werden
-- Testfall Author: Prüfe, ob unreferenzierte Einträge in Author ordnungsgemäß markiert werden
DELIMITER //
CREATE OR REPLACE PROCEDURE test_authorBook()
MODIFIES SQL DATA
BEGIN
  DECLARE bID, aID TYPE OF Book.ID;

  INSERT INTO Book VALUES
    (NULL, 'Book A', NULL, NULL, NULL, 1),
    (NULL, 'Book B', NULL, NULL, NULL, 1)
  ;
  SET bID = LAST_INSERT_ID();
  INSERT INTO Author VALUES
    (NULL, NULL, 'Author A', 1),
    (NULL, NULL, 'Author B', 1)
  ;
  SET aID = LAST_INSERT_ID();
  INSERT INTO Author_Book VALUES
    (aID, bID),
    (aID+1, bID+1)
  ;

  UPDATE Book SET ID = bID+2 WHERE ID = bID;
  UPDATE Author_Book SET AuthorID = 1 WHERE BookID = bID+2;
  DELETE FROM Book WHERE ID = bID+1;

  SELECT * FROM Author WHERE ID NOT IN (SELECT AuthorID FROM Author_Book);
  SELECT * FROM Author_Book WHERE BookID IN (bID+1, bID+2);

  DELETE FROM Book WHERE ID = biD+2;
  DELETE FROM Author WHERE ID IN (aID, aID+1);
END;
//
DELIMITER ;
CALL test_authorBook();


-- Erstelle Relation "HasRead"
CREATE OR REPLACE TABLE HasRead (
  UserID INT UNSIGNED,
  BookID INT UNSIGNED,
  PRIMARY KEY (UserID, BookID),
  FOREIGN KEY (UserID) REFERENCES User (ID)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY (BookID) REFERENCES Book (ID)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);


-- Füge Dummy-Daten in HasRead ein
INSERT INTO HasRead VALUES
  (2, 2),
  (2, 3),
  (2, 4),
  (4, 3),
  (5, 2),
  (6, 2),
  (7, 9),
  (10, 6),
  (9, 8),
  (3, 5)
;


-- Zeige Dummy-Daten in HasRead
SELECT * FROM HasRead ORDER BY UserID ASC LIMIT 3;


-- Testfall HasRead: Zeige die korrekte Verknüpfung von User und Book
SELECT User.Username, Book.Title FROM HasRead LEFT JOIN User ON User.ID = HasRead.UserID LEFT JOIN Book ON Book.ID = HasRead.BookID LIMIT 3;


-- Erstelle Relation "Review"
CREATE OR REPLACE TABLE Review (
  ID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  BookID INT UNSIGNED,
  UserId INT UNSIGNED,
  Rating TINYINT UNSIGNED NOT NULL,
  Text TEXT,
  FOREIGN KEY (BookID) REFERENCES Book (ID),
  FOREIGN KEY (UserID) REFERENCES User (ID),
  CONSTRAINT ratingRange CHECK (Rating BETWEEN 0 AND 10),
  UNIQUE INDEX (BookID, UserID)
);


-- Erstelle Trigger, welcher ReviewsWritten für UserStats aktualisiert
DELIMITER //
CREATE OR REPLACE TRIGGER ReviewInsert_UserStats
AFTER INSERT OR DELETE ON Review FOR EACH ROW
BEGIN
  DECLARE refUserID INT UNSIGNED;
  IF INSERTING THEN SET refUserID = NEW.UserID;
  ELSE SET refUserID = OLD.UserID;
  END IF;
  UPDATE UserStats SET ReviewsWritten = (SELECT COUNT(*) FROM Review WHERE UserID = refUserID) WHERE UserID = refUserID;
END //
DELIMITER ;


-- Füge Dummy-Daten in Review ein
INSERT INTO Review VALUES
  (NULL, 1, 3, 8, 'Ein wunderschön geschriebenes Buch, das mich von der ersten bis zur letzten Seite gefesselt hat.'),
  (NULL, 2, 7, 9, 'Fantastische Welt, tolle Charaktere! Ich konnte es kaum aus der Hand legen.'),
  (NULL, 3, 1, 6, 'Solide Science-Fiction, auch wenn manche Wendungen etwas vorhersehbar waren. Trotzdem unterhaltsam.'),
  (NULL, 4, 5, 4, 'Der Krimi konnte mich leider nicht ganz überzeugen. Der Spannungsbogen hat mir gefehlt.'),
  (NULL, 5, 9, 10, 'Super!!'),
  (NULL, 6, 2, 7, 'Düster und atmosphärisch, genau mein Geschmack. Ein paar Längen im Mittelteil, aber insgesamt sehr gut.'),
  (NULL, 7, 10, 9, 'Bewegende und ehrliche Lebensgeschichte. Hat mich mehrfach zum Nachdenken gebracht.'),
  (NULL, 8, 4, 5, 'Interessante Ansätze, aber streckenweise zu trocken geschrieben.'),
  (NULL, 9, 6, 10, 'Meine Kinder lieben dieses Buch! Wird bei uns jeden Abend vorgelesen.'),
  (NULL, 10, 8, 7, 'Schöne Sprache und berührende Bilder. Nicht jeder Vers hat mich gleich stark angesprochen, aber insgesamt lesenswert.')
;


-- Zeige Dummy-Daten in Review
SELECT * FROM Review ORDER BY LENGTH(Text) ASC LIMIT 3;


-- Testfall Review: Zeige alle Rezensionen zu einem Buch
SELECT User.Username, Book.Title, Rating, Text FROM Review LEFT JOIN User ON User.ID = Review.UserID LEFT JOIN Book ON Book.ID = Review.BookID WHERE BookID = 1;


-- Erstelle Relation "Item"
CREATE OR REPLACE TABLE Item (
  ID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  UserID INT UNSIGNED NOT NULL,
  BookID INT UNSIGNED NOT NULL,
  Quality VARCHAR(200),
  MaximumLendDuration INT UNSIGNED DEFAULT 30,
  Shippable BOOL,
  AddressID INT UNSIGNED NOT NULL,
  Lending ENUM('disabled', 'restricted', 'free') NOT NULL,
  FOREIGN KEY (UserID) REFERENCES User (ID)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  FOREIGN KEY (BookID) REFERENCES Book (ID)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  FOREIGN KEY (AddressID) REFERENCES Address (ID)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);


-- Füge Dummy-Daten in Item ein
INSERT INTO Item VALUES
  (NULL, 1, 3, 'Wie neu', 21, 1, 10, 'free'),
  (NULL, 2, 7, 'Gut erhalten, leichte Gebrauchsspuren', 30, 0, 1, 'restricted'),
  (NULL, 3, 1, 'Neuwertig, kaum gelesen', 14, 1, 2, 'free'),
  (NULL, 4, 9, 'Einband leicht verknickt', 45, 1, 3, 'free'),
  (NULL, 5, 2, 'Stark abgenutzt, aber vollständig lesbar', 56, 0, 4, 'disabled'),
  (NULL, 6, 5, 'Wie neu', 18, 1, 5, 'free'),
  (NULL, 7, 10, 'Ecken leicht bestoßen', 28, 1, 6, 'free'),
  (NULL, 8, 4, 'Gebrauchsspuren am Cover, Seiten sauber', 35, 0, 7, 'restricted'),
  (NULL, 9, 6, 'Sehr guter Zustand', 21, 1, 8, 'free'),
  (NULL, 10, 8, 'Vergilbte Seiten, sonst intakt', 42, 1, 9, 'free'),
  (NULL, 1, 7, 'Neuwertig', 14, 1, 10, 'free'),
  (NULL, 3, 2, 'Leichte Knicke im Einband', 49, 0, 2, 'disabled'),
  (NULL, 5, 9, 'Gut erhalten', 25, 1, 4, 'free'),
  (NULL, 7, 3, 'Wie neu, ungelesen', 20, 1, 6, 'free'),
  (NULL, 9, 1, 'Abnutzung am Buchrücken', 38, 0, 8, 'restricted')
;


-- Zeige Dummy-Daten in Item
SELECT * FROM Item LIMIT 3;


-- Erstelle Trigger, welcher für Item "ON DELETE CASCADE" für Löschungen in User nachbildet (da ON DELETE keine Trigger auslöst)
CREATE OR REPLACE TRIGGER UserDeleted_Item
BEFORE DELETE ON User FOR EACH ROW
  DELETE FROM Item WHERE UserID = OLD.ID;


-- Erstelle Trigger, welcher für Item "ON DELETE CASCADE" für Löschungen in Book nachbildet (da ON DELETE keine Trigger auslöst)
CREATE OR REPLACE TRIGGER BookDeleted_Item
BEFORE DELETE ON Book FOR EACH ROW
  DELETE FROM Item WHERE BookID = OLD.ID;


-- Testfall Item: Zeige, dass Löschungen in User oder Book zur Löschung des Items führen
DELIMITER //
CREATE OR REPLACE PROCEDURE test_Item()
MODIFIES SQL DATA
BEGIN
  DECLARE uID, bID TYPE OF Item.ID;
  
  INSERT INTO User VALUES (NULL, 'Bsp. User', 'Name', 1, NULL, NULL, 'abcdef');
  SET uID = LAST_INSERT_ID();
  INSERT INTO Item VALUES (NULL, uID, 1, NULL, 98, 0, 1, 'free');
  INSERT INTO Book VALUES (NULL, 'Bsp. Title', NULL, NULL, NULL, 1);
  SET bID = LAST_INSERT_ID();
  INSERT INTO Item VALUES (NULL, 1, bID, NULL, 99, 0, 1, 'free');

  DELETE FROM User WHERE ID = uID;
  DELETE FROM Book WHERE ID = bID;

  SELECT * FROM Item WHERE ID IN (LAST_INSERT_ID(), LAST_INSERT_ID()+1);
END;
//
DELIMITER ;
CALL test_Item();


-- Erstelle Relation "TimeSlot"
CREATE OR REPLACE TABLE TimeSlot (
  ID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  startDate DATE NOT NULL,
  endDate DATE NOT NULL,
  UNIQUE INDEX (startDate, endDate),
  CONSTRAINT dates CHECK (endDate > startDate)
);


-- Füge Dummy-Daten in TimeSlot ein
INSERT INTO TimeSlot VALUES
  (NULL, '2026-01-05', '2026-01-19'),
  (NULL, '2026-02-10', '2026-03-03'),
  (NULL, '2026-03-15', '2026-04-12'),
  (NULL, '2026-04-20', '2026-04-30'),
  (NULL, '2026-05-01', '2026-05-29'),
  (NULL, '2026-06-08', '2026-06-22'),
  (NULL, '2026-07-01', '2026-07-25'),
  (NULL, '2026-08-03', '2026-08-17'),
  (NULL, '2026-08-20', '2026-09-10'),
  (NULL, '2026-09-01', '2026-09-24'),
  (NULL, '2026-08-27', '2026-09-25'),
  (NULL, '2026-09-25', '2026-10-16'),
  (NULL, '2026-10-01', '2026-10-29'),
  (NULL, '2026-10-15', '2026-11-05'),
  (NULL, '2026-11-01', '2026-11-22'),
  (NULL, '2026-11-10', '2026-12-08'),
  (NULL, '2026-12-01', '2026-12-15'),
  (NULL, '2026-12-20', '2027-01-10'),
  (NULL, '2027-01-05', '2027-02-02'),
  (NULL, '2027-02-01', '2027-02-28')
;


-- Zeige Dummy-Daten in TimeSlot
SELECT * FROM TimeSlot LIMIT 3;


-- Erstelle Relation "Item_TimeSlot"
CREATE OR REPLACE TABLE Item_TimeSlot (
  ItemID INT UNSIGNED,
  TimeSlotID INT UNSIGNED,
  PRIMARY KEY (ItemID, TimeSlotID),
  FOREIGN KEY (ItemID) REFERENCES Item (ID)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  FOREIGN KEY (TimeSlotID) REFERENCES TimeSlot (ID)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);


-- Erstelle Trigger, welcher für Item_TimeSlot "ON DELETE CASCADE" für Löschungen in Item nachbildet (da ON DELETE keine Trigger auslöst)
CREATE OR REPLACE TRIGGER ItemDeleted_ItemTimeSlot
BEFORE DELETE ON Item FOR EACH ROW
  DELETE FROM Item_TimeSlot WHERE ItemID = OLD.ID;


-- Erstelle Trigger, um Überschneidungen der TimeSlots in Item_TimeSlot zu verhindern
DELIMITER //
CREATE OR REPLACE TRIGGER ItemTimeSlotInsert_TimeSlot
BEFORE INSERT OR UPDATE ON Item_TimeSlot FOR EACH ROW
BEGIN
  DECLARE varItemID TYPE OF Item.ID;
  DECLARE varStart, varEnd TYPE OF TimeSlot.startDate;
  DECLARE conflicts INT;
  SELECT ID INTO varItemID FROM Item WHERE ID = NEW.ItemID;
  SELECT startDate, endDate INTO varStart, varEnd FROM TimeSlot WHERE ID = NEW.TimeSlotID;
  SELECT COUNT(*) INTO conflicts FROM Item_TimeSlot AS it
  RIGHT JOIN TimeSlot AS t ON it.TimeSlotID = t.ID
  RIGHT JOIN Item AS i ON it.ItemID = i.ID
  WHERE i.ID = varItemID AND
  ((varStart BETWEEN t.startDate AND t.endDate) OR
  (varEnd BETWEEN t.startDate AND t.endDate));

  IF (conflicts > 0) THEN
    SIGNAL SQLSTATE '45001' SET
    MYSQL_ERRNO=30002,
    MESSAGE_TEXT='Tried to insert references to overlapping TimeSlots';
  END IF;
END //
DELIMITER ;


-- Füge Dummy-Daten in Item_TimeSlot ein
INSERT INTO Item_TimeSlot VALUES
  (1, 3),
  (2, 7),
  (3, 1),
  (4, 9),
  (8, 4),
  (9, 6),
  (10, 8),
  (11, 12),
  (13, 16),
  (1, 15),
  (9, 13)
;


-- Zeige Dummy-Daten in Item_TimeSlot
SELECT * FROM Item_TimeSlot LIMIT 3;


-- Erstelle Relation "Reservation"
CREATE OR REPLACE TABLE Reservation (
  ID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  UserID INT UNSIGNED NOT NULL,
  ItemID INT UNSIGNED NOT NULL,
  FOREIGN KEY (UserID) REFERENCES User (ID)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  FOREIGN KEY (ItemID) REFERENCES Item (ID)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);


-- Erstelle Trigger, welcher für Reservation "ON DELETE CASCADE" für Löschungen in User nachbildet (da ON DELETE keine Trigger auslöst)
CREATE OR REPLACE TRIGGER UserDeleted_Reservation
BEFORE DELETE ON User FOR EACH ROW FOLLOWS UserDeleted_Item
  DELETE FROM Reservation WHERE UserID = OLD.ID;


-- Erstelle Trigger, welcher für Reservation "ON DELETE CASCADE" für Löschungen in Item nachbildet (da ON DELETE keine Trigger auslöst)
CREATE OR REPLACE TRIGGER ItemDeleted_Reservation
BEFORE DELETE ON Item FOR EACH ROW FOLLOWS ItemDeleted_ItemTimeSlot
  DELETE FROM Reservation WHERE ItemID = OLD.ID;


-- Füge Dummy-Daten in Reservation ein
INSERT INTO Reservation VALUES
  (NULL, 1, 1),
  (NULL, 1, 2),
  (NULL, 2, 3),
  (NULL, 3, 4),
  (NULL, 3, 5),
  (NULL, 4, 6),
  (NULL, 5, 7),
  (NULL, 6, 8),
  (NULL, 8, 9),
  (NULL, 8, 10)
;


-- Zeige Dummy-Daten in Reservation
SELECT * FROM Reservation LIMIT 3;


-- Erstelle Relation "Reservation_TimeSlot"
CREATE OR REPLACE TABLE Reservation_TimeSlot (
  ReservationID INT UNSIGNED,
  TimeSlotID INT UNSIGNED,
  PRIMARY KEY (ReservationID, TimeSlotID),
  FOREIGN KEY (ReservationID) REFERENCES Reservation (ID)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  FOREIGN KEY (TimeSlotID) REFERENCES TimeSlot (ID)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
  );


-- Erstelle Trigger, welcher für Reservation_TimeSlot "ON DELETE CASCADE" für Löschungen in Reservation nachbildet (da ON DELETE keine Trigger auslöst)
CREATE OR REPLACE TRIGGER ReservationDeleted_ReservationTimeSlot
BEFORE DELETE ON Reservation FOR EACH ROW
  DELETE FROM Reservation_TimeSlot WHERE ReservationID = OLD.ID;


-- Erstelle Trigger, welcher Einträge in Reservation_TimeSlot verhindert, wenn ein Item mehrmals für einen TimeSlot reserviert werden soll 
DELIMITER //
CREATE OR REPLACE TRIGGER ReservationTimeSlotInsert_Item
BEFORE INSERT OR UPDATE ON Reservation_TimeSlot FOR EACH ROW
BEGIN
  IF ((SELECT ItemID FROM Reservation WHERE ID = NEW.ReservationID) IN
  (SELECT r.ItemID FROM Reservation_TimeSlot AS rt LEFT JOIN Reservation
  AS r ON rt.ReservationID = r.ID WHERE rt.TimeSlotID = NEW.TimeSlotID AND NOT
  rt.ReservationID = NEW.ReservationID)) THEN
    SIGNAL SQLSTATE '45000' SET
    MYSQL_ERRNO=30001,
    MESSAGE_TEXT='Tried inserting entries with duplicate itemIDs for specified timeslot';
  END IF;
END;
//
DELIMITER ;


-- Erstelle Trigger, um Überschneidungen der TimeSlots in Reservation_TimeSlot zu verhindern
DELIMITER //
CREATE OR REPLACE TRIGGER ReservationTimeSlotInsert_TimeSlot
BEFORE INSERT OR UPDATE ON Reservation_TimeSlot FOR EACH ROW FOLLOWS ReservationTimeSlotInsert_Item
BEGIN
  DECLARE varItemID TYPE OF Reservation.ItemID;
  DECLARE varStart, varEnd TYPE OF TimeSlot.startDate;
  DECLARE conflicts INT;
  SELECT ItemID INTO varItemID FROM Reservation WHERE ID = NEW.ReservationID;
  SELECT startDate, endDate INTO varStart, varEnd FROM TimeSlot WHERE ID = NEW.TimeSlotID;
  SELECT COUNT(*) INTO conflicts FROM Reservation_TimeSlot AS rt
  RIGHT JOIN TimeSlot AS t ON rt.TimeSlotID = t.ID
  RIGHT JOIN Reservation AS r ON rt.ReservationID = r.ID
  WHERE r.ItemID = varItemID AND
  ((varStart BETWEEN t.startDate AND t.endDate) OR
  (varEnd BETWEEN t.startDate AND t.endDate));

  IF (conflicts > 0) THEN
    SIGNAL SQLSTATE '45001' SET
    MYSQL_ERRNO=30002,
    MESSAGE_TEXT='Tried to insert references to overlapping TimeSlots';
  END IF;
END //
DELIMITER ;
  

-- Füge Dummy-Daten in Reservation_TimeSlot ein
INSERT INTO Reservation_TimeSlot VALUES
  (1, 3),
  (2, 7),
  (3, 1),
  (4, 9),
  (1, 2),
  (8, 5),
  (7, 1),
  (8, 4),
  (9, 6),
  (10, 8)
;


-- Testfall Reservation_TimeSlot: Prüfe, ob sich überschneidende TimeSlots korrekt verhindert werden
DELIMITER //
CREATE OR REPLACE PROCEDURE test_ReservationTimeSlot_TimeSlot ()
BEGIN 
  DECLARE tsA, tsB, tsC TYPE OF TimeSlot.ID;
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;
  START TRANSACTION;

  INSERT INTO TimeSlot VALUES (NULL, '2000-01-01', '2000-01-10'), (NULL, '2000-01-01', '2000-01-5'), (NULL, '2000-01-09', '2000-01-12');
  SET tsA = LAST_INSERT_ID(), tsB = LAST_INSERT_ID()+1, tsC = LAST_INSERT_ID()+2;
  INSERT INTO Reservation VALUES (NULL, 1, 1), (NULL, 2, 1);

  INSERT INTO Reservation_TimeSlot VALUES (LAST_INSERT_ID(), tsA), (LAST_INSERT_ID()+1, tsB), (LAST_INSERT_ID(), tsC);

  ROLLBACK;
END //
DELIMITER ;
CALL test_ReservationTimeSlot_TimeSlot();


-- Zeige Dummy-Daten in Reservation_TimeSlot
SELECT * FROM Reservation_TimeSlot LIMIT 3;


-- Erstelle Relation "Handover"
CREATE OR REPLACE TABLE Handover (
  ID INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  ReservationID INT UNSIGNED NOT NULL,
  Type BOOL,
  FOREIGN KEY (ReservationID) REFERENCES Reservation (ID)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
);


-- Testfall Reservation_TimeSlot: Prüfe, ob fehlerhafte Mehrfacheinträge korrekt verhindert werden
DELIMITER //
CREATE OR REPLACE PROCEDURE test_ReservationTimeSlot_Item()
MODIFIES SQL DATA
BEGIN
  DECLARE rIDa, rIDb, tID INT UNSIGNED;
  DECLARE errorCount TINYINT DEFAULT 0;
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
  BEGIN
    ROLLBACK;
    RESIGNAL;
  END;

  START TRANSACTION;
  INSERT INTO Reservation VALUES (NULL, 1, 1), (NULL, 1, 1);
  SET rIDa = LAST_INSERT_ID();
  SET rIDb = LAST_INSERT_ID()+1;
  DELETE FROM TimeSlot WHERE startDate = '1000-01-01';
  INSERT INTO TimeSlot VALUES (NULL, '1000-01-01', '1000-01-02');
  SET tID = LAST_INSERT_ID();

  INSERT INTO Reservation_TimeSlot VALUES (rIDa, tID);
  INSERT INTO Reservation_TimeSlot VALUES (rIDb, tID);
  SELECT * FROM Reservation_TimeSlot WHERE ReservationID IN (rIDa, rIDb);

  DELETE FROM Reservation_TimeSlot WHERE ReservationID = rIDa AND TimeSlotID = tID;
  DELETE FROM Handover WHERE ReservationID IN (rIDa, rIDb);
  DELETE FROM Reservation WHERE ID IN (rIDa, rIDb);
  DELETE FROM TimeSlot WHERE ID = tID;
  ROLLBACK;

END;
//
DELIMITER ;
CALL test_ReservationTimeSlot_Item();


-- Erstelle Trigger, welcher unreferenzierte Einträge in TimeSlot löscht
DELIMITER //
CREATE OR REPLACE FUNCTION check_TimeSlot (tID INT UNSIGNED)
RETURNS INTEGER
BEGIN
  RETURN ((
    (SELECT COUNT(*) FROM Item_TimeSlot WHERE TimeSlotID = tID) +
    (SELECT COUNT(*) FROM Reservation_TimeSlot WHERE TimeSlotID = tID))
    = 0);
END;
//

CREATE OR REPLACE TRIGGER ItemTimeSlot_DeleteUpdate
AFTER UPDATE OR DELETE ON Item_TimeSlot FOR EACH ROW
BEGIN
  IF check_TimeSlot(OLD.TimeSlotID) THEN
    DELETE FROM TimeSlot WHERE ID = OLD.TimeSlotID;
  END IF;
END;
//

CREATE OR REPLACE TRIGGER ReservationTimeSlot_DeleteUpdate
AFTER UPDATE OR DELETE ON Reservation_TimeSlot FOR EACH ROW
BEGIN
  IF check_TimeSlot(OLD.TimeSlotID) THEN
    DELETE FROM TimeSlot WHERE ID = OLD.TimeSlotID;
  END IF;
END;
//
DELIMITER ;


-- Testfall TimeSlot: Zeige, dass unreferenzierte TimeSlot Entitäten ordnungsgemäß gelöscht werden
DELIMITER //
CREATE OR REPLACE PROCEDURE test_TimeSlot()
MODIFIES SQL DATA
BEGIN
  DECLARE tID INT UNSIGNED;
  INSERT INTO TimeSlot VALUES (NULL, '1000-01-01', '1000-01-02');
  SET tID = LAST_INSERT_ID();
  INSERT INTO Item_TimeSlot VALUES (1, tID);
  INSERT INTO Reservation_TimeSlot VALUES (1, tID);
  DELETE FROM Item_TimeSlot WHERE TimeSlotID = tID;
  SELECT * FROM TimeSlot WHERE ID = tID;
  DELETE FROM Reservation_TimeSlot WHERE TimeSlotID = tID;
  SELECT * FROM TimeSlot WHERE ID = tID;
END;
//
DELIMITER ;
CALL test_TimeSlot();


-- Erstelle Trigger, welcher Handover Entitäten bei Reservation Erstellung erstellt
CREATE OR REPLACE TRIGGER ReservationInsert_Handover
AFTER INSERT ON Reservation FOR EACH ROW
  INSERT INTO Handover VALUES (NULL, NEW.ID, 0), (NULL, NEW.ID, 1);


-- Erstelle Trigger, welcher für Handover "ON DELETE CASCADE" für Löschungen in Reservation nachbildet (da ON DELETE keine Trigger auslöst)
CREATE OR REPLACE TRIGGER ReservationDeleted_Handover
BEFORE DELETE ON Reservation FOR EACH ROW FOLLOWS ReservationDeleted_ReservationTimeSlot
  DELETE FROM Handover WHERE ReservationID = OLD.ID;


-- Erstelle Relation "Confirmation"
CREATE OR REPLACE TABLE Confirmation (
  HandoverID INT UNSIGNED,
  UserID INT UNSIGNED,
  conDateTime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (HandoverID, UserID),
  FOREIGN KEY (UserID) REFERENCES User (ID)
    ON UPDATE CASCADE
    ON DELETE CASCADE,
  FOREIGN KEY (HandoverID) REFERENCES Handover (ID)
    ON UPDATE CASCADE
    ON DELETE CASCADE
);


-- Erstelle Trigger, welcher sicherstellt, dass nur die jeweils beteiligten User bestätigen
DELIMITER //
CREATE OR REPLACE TRIGGER ConfirmationInsertUpdate_Confirmation
BEFORE INSERT OR UPDATE ON Confirmation FOR EACH ROW
BEGIN  
  IF NOT EXISTS (
  SELECT 1 FROM Handover as h
  RIGHT JOIN Reservation AS r ON h.ReservationID = r.ID
  RIGHT JOIN Item AS i ON r.ItemID = i.ID
  WHERE h.ID = NEW.HandoverID AND NEW.UserID IN (i.userID, r.UserID)) THEN
    SIGNAL SQLSTATE '45002' SET
    MYSQL_ERRNO=30003,
    MESSAGE_TEXT='Tried to insert confirmation with unrelated user';
  END IF;
END //
DELIMITER ;


-- Erstelle Trigger, welcher BooksBorrowed, BooksLended und OnTimeReturns für UserStats aktualisiert
DELIMITER //
CREATE OR REPLACE TRIGGER ConfirmationInsert_UserStats
AFTER INSERT OR UPDATE ON Confirmation FOR EACH ROW
BEGIN
  DECLARE sType, sBorrower INT UNSIGNED;
  DECLARE sEnd TIMESTAMP;

  SELECT h.Type, r.UserID INTO sType, sBorrower FROM Handover AS h JOIN Reservation AS r
  ON r.ID = h.ReservationID WHERE h.ID = NEW.HandoverID;

  IF sType = 0 THEN
    IF sBorrower = NEW.UserID THEN
      UPDATE UserStats SET BooksBorrowed = COALESCE(BooksBorrowed, 0)+1 WHERE UserID = NEW.UserID;
    ELSE
      UPDATE UserStats SET BooksLended = COALESCE(BooksLended, 0)+1 WHERE UserID = NEW.UserID;
    END IF;
  ELSEIF sBorrower = NEW.UserID THEN
    SELECT MAX(t.endDate) INTO sEnd FROM Handover AS h INNER JOIN Reservation_TimeSlot AS rt
    ON rt.ReservationID = h.ReservationID INNER JOIN TimeSlot AS t ON t.ID = rt.TimeSlotID
    WHERE h.ID = NEW.HandoverID;

    IF sEnd >= NEW.conDateTime THEN
      UPDATE UserStats SET OnTimeReturns = COALESCE(OnTimeReturns, 0)+1 WHERE UserID = NEW.UserID;
    END IF;
  END IF;
END;
//
DELIMITER ;


-- Füge Dummy-Daten in Handover und Confirmation ein
DELIMITER //
CREATE OR REPLACE PROCEDURE insertDummiesHandoverConfirmation()
BEGIN
  DECLARE rID INT UNSIGNED;
  INSERT INTO Reservation VALUES
    (NULL, 1, 9),
    (NULL, 5, 4),
    (NULL, 5, 3),
    (NULL, 9, 5),
    (NULL, 9, 6)
  ;
  SET rID = LAST_INSERT_ID();
  INSERT INTO Reservation_TimeSlot VALUES
    (LAST_INSERT_ID(), 1),
    (LAST_INSERT_ID()+1, 4),
    (LAST_INSERT_ID()+2, 12),
    (LAST_INSERT_ID()+3, 16),
    (LAST_INSERT_ID()+4, 20)
  ;

  -- Ausleihe, Besitzer
  INSERT INTO Confirmation (HandoverID, UserID, conDateTime)
  SELECT x.HandoverID, x.Lender AS UserID, x.startDate AS conDateTime FROM (
    SELECT i.UserID AS Lender, r.UserID AS Borrower, h.ID AS HandoverID, h.Type,
    t.startDate, t.endDate FROM Handover AS h LEFT JOIN Reservation AS r ON h.ReservationID = r.ID
    LEFT JOIN Item AS i ON r.ItemID = i.ID LEFT JOIN Reservation_TimeSlot AS rt ON
    r.ID = rt.ReservationID LEFT JOIN TimeSlot AS t ON rt.TimeSlotID = t.ID WHERE r.ID IN
    (rID, rID+1, rID+2, rID+3, rID+4)
    AND h.Type = 0) AS x;

  -- Ausleihe, Ausleiher
  INSERT INTO Confirmation (HandoverID, UserID, conDateTime)
  SELECT x.HandoverID, x.Borrower AS UserID, x.startDate AS conDateTime FROM (
    SELECT i.UserID AS Lender, r.UserID AS Borrower, h.ID AS HandoverID, h.Type,
    t.startDate, t.endDate FROM Handover AS h LEFT JOIN Reservation AS r ON h.ReservationID = r.ID
    LEFT JOIN Item AS i ON r.ItemID = i.ID LEFT JOIN Reservation_TimeSlot AS rt ON
    r.ID = rt.ReservationID LEFT JOIN TimeSlot AS t ON rt.TimeSlotID = t.ID WHERE r.ID IN
    (rID, rID+1, rID+2, rID+3, rID+4)
    AND h.Type = 0) AS x;

  -- Rückgabe, Ausleiher
  INSERT INTO Confirmation (HandoverID, UserID, conDateTime)
  SELECT x.HandoverID, x.Borrower AS UserID, x.endDate AS conDateTime FROM (
    SELECT i.UserID AS Lender, r.UserID AS Borrower, h.ID AS HandoverID, h.Type,
    t.startDate, t.endDate FROM Handover AS h LEFT JOIN Reservation AS r ON h.ReservationID = r.ID
    LEFT JOIN Item AS i ON r.ItemID = i.ID LEFT JOIN Reservation_TimeSlot AS rt ON
    r.ID = rt.ReservationID LEFT JOIN TimeSlot AS t ON rt.TimeSlotID = t.ID WHERE r.ID IN
    (rID, rID+1, rID+2, rID+3, rID+4)
    AND h.Type = 1) AS x;

  -- Rückgabe, Besitzer
  INSERT INTO Confirmation (HandoverID, UserID, conDateTime)
  SELECT x.HandoverID, x.Lender AS UserID, x.endDate AS conDateTime FROM (
    SELECT i.UserID AS Lender, r.UserID AS Borrower, h.ID AS HandoverID, h.Type,
    t.startDate, t.endDate FROM Handover AS h LEFT JOIN Reservation AS r ON h.ReservationID = r.ID
    LEFT JOIN Item AS i ON r.ItemID = i.ID LEFT JOIN Reservation_TimeSlot AS rt ON
    r.ID = rt.ReservationID LEFT JOIN TimeSlot AS t ON rt.TimeSlotID = t.ID WHERE r.ID IN
    (rID, rID+1, rID+2, rID+3, rID+4)
    AND h.Type = 1) AS x;

END //
DELIMITER ;
CALL insertDummiesHandoverConfirmation();

-- Testcase Confirmation: Zeige, dass nur beteiligte User bestätigen können
DELIMITER //
CREATE OR REPLACE PROCEDURE test_Confirmation()
BEGIN
  DECLARE varHandoverID, varBorrower, varLender INT UNSIGNED;
  SELECT h.ID, i.UserID, r.UserID INTO varHandoverID, varLender, varBorrower FROM Handover as h
   RIGHT JOIN Reservation AS r ON h.ReservationID = r.ID
   RIGHT JOIN Item AS i ON r.ItemID = i.ID
   WHERE h.ID = (SELECT ID FROM Handover LIMIT 1);
  INSERT INTO Confirmation VALUES (
   varHandoverID,
   (SELECT ID FROM User WHERE ID NOT IN (varLender, varBorrower) LIMIT 1),
   NULL);
END //
DELIMITER ;
CALL test_Confirmation();


-- Testcase UserStats: Zeige, dass BookBorrowed und BookLended korrekt aktualisiert werden
DELIMITER //
CREATE OR REPLACE PROCEDURE test_UserStats()
MODIFIES SQL DATA
BEGIN
  DECLARE lendingUserID, varItemID, varReservationID, varTimeSlotID INT UNSIGNED;
  START TRANSACTION;
    SET lendingUserID = (SELECT UserID FROM Item WHERE NOT UserID = 1 LIMIT 1);
    SET varItemID = (SELECT ID FROM Item WHERE UserID = lendingUserID LIMIT 1);
    SELECT UserID, BooksLended, BooksBorrowed, OnTimeReturns FROM UserStats WHERE UserID IN (1, lendingUserID);

    INSERT INTO Reservation VALUES (NULL, 1, varItemID);
    SET varReservationID = LAST_INSERT_ID();
    INSERT INTO TimeSlot VALUES (NULL, '2000-01-01', '2000-01-10');
    SET varTimeSlotID = LAST_INSERT_ID();
    INSERT INTO Reservation_TimeSlot VALUES (varReservationID, varTimeSlotID);

    INSERT INTO Confirmation (HandoverID, UserID) VALUES 
      ((SELECT ID FROM Handover WHERE ReservationID = varReservationID AND Type = 0), lendingUserID),
      ((SELECT ID FROM Handover WHERE ReservationID = varReservationID AND Type = 0), (SELECT UserID FROM Reservation WHERE ID = varReservationID));
    INSERT INTO Confirmation (HandoverID, UserID, conDateTime) VALUES 
      ((SELECT ID FROM Handover WHERE ReservationID = varReservationID AND Type = 1),
      (SELECT UserID FROM Reservation WHERE ID = varReservationID),
      (SELECT endDate + INTERVAL 1 DAY FROM TimeSlot WHERE ID = varTimeSlotID));
    SELECT UserID, BooksLended, BooksBorrowed, OnTimeReturns FROM UserStats WHERE UserID IN (1, lendingUserID);

    DELETE FROM Confirmation WHERE HandoverID = (SELECT ID FROM Handover WHERE ReservationID = varReservationID AND Type = 1);
    INSERT INTO Confirmation (HandoverID, UserID, conDateTime) VALUES 
      ((SELECT ID FROM Handover WHERE ReservationID = varReservationID AND Type = 1),
      (SELECT UserID FROM Reservation WHERE ID = varReservationID),
      (SELECT endDate FROM TimeSlot WHERE ID = varTimeSlotID));
    SELECT UserID, BooksLended, BooksBorrowed, OnTimeReturns FROM UserStats WHERE UserID IN (1, lendingUserID);

 ROLLBACK;
END //
DELIMITER ;
CALL test_userStats();


-- Zeige Dummy-Daten in UserStats
SELECT * FROM UserStats ORDER BY OnTimeReturns DESC LIMIT 4;


-- Zeige Dummy-Daten in Handover
SELECT * FROM Handover ORDER BY ReservationID DESC LIMIT 4;


-- Zeige Dummy-Daten in Confirmation
SELECT * FROM Confirmation ORDER BY HandoverID DESC LIMIT 4;