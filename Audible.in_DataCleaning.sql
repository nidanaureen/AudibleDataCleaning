
--1. Cleaning author & narrator columns
UPDATE Audible
SET 
  author= SUBSTRING(author, CHARINDEX (':',author)+1, LEN(author)),
  narrator=SUBSTRING(narrator, CHARINDEX(':',narrator)+1, LEN(narrator))
FROM Audible

--2. Standardizing Time Format
UPDATE Audible
SET time = 
    CASE
        WHEN CHARINDEX('hr', time) > 0 AND CHARINDEX('min', time) > 0 THEN
            TRY_CONVERT(TIME, 
                CONCAT(
                    SUBSTRING(time, 1, CHARINDEX(' hr', time) - 1), 
                    ':', 
                    SUBSTRING(time, CHARINDEX('and ', time) + 4, CHARINDEX(' min', time) - CHARINDEX('and ', time) - 4)
                )
            )
        WHEN CHARINDEX('hr', time) = 0 AND CHARINDEX('min', time) > 0 THEN
            TRY_CONVERT(TIME, 
                CONCAT(
                    '00', 
                    ':', 
                    SUBSTRING(time, 1, CHARINDEX(' min', time) - 1)
                )
            )
        WHEN CHARINDEX('hr', time) > 0 AND CHARINDEX('min', time) = 0 THEN
            TRY_CONVERT(TIME, 
                CONCAT(
                    SUBSTRING(time, 1, CHARINDEX(' hr', time) - 1), 
                    ':00'
                )
            )
        ELSE
            '00:00'
    END;
	
--Further Cleaning up time column
UPDATE audible
set 
time=SUBSTRING(time, 1, CHARINDEX('.', time)-1)        

--3. Removing extras & extracting Numerical Ratings:

UPDATE Audible
SET 
 stars= SUBSTRING(stars, PATINDEX('%[0-9]%', stars), CHARINDEX('out of 5',stars)-PATINDEX('%[0-9]%', stars)) 

--4. CLEANING UP THE PRICE COLUMN: getting rid of 'free' values in price column & setting them as 0(false) in the 'Paid' column

ALTER TABLE Audible 
ADD Paid bit;
UPDATE Audible
SET Paid = 
    CASE 
        WHEN price = 'Free' THEN 0 -- Set Paid to 0 for 'Free'
        ELSE 1 -- Set Paid to 1 for non-'Free' prices
    END
WHERE 
    TRY_CONVERT(FLOAT, REPLACE(REPLACE(price, ',', ''), '.00', '')) IS NOT NULL;

UPDATE Audible
SET price = '0.00'
WHERE price = 'Free';

--Removing comma and standardizing the price format
UPDATE Audible
SET price = 
    CASE 
        WHEN price NOT LIKE '%,%' THEN price + '.00' -- Add .00 to values without comma
        ELSE REPLACE(price, ',', '') -- Remove comma
    END;
