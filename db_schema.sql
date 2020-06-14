CREATE TABLE presentations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    presentation_name varchar(256),
);

CREATE TABLE slides (
    id INT PRIMARY KEY AUTO_INCREMENT,
    presentation_id INT,
    title VARCHAR(256),
    start_sec INT
);

ALTER TABLE slides
ADD FOREIGN KEY (presentation_id) REFERENCES presentations(id);