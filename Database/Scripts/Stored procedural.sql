--(Stored procedural)

CREATE OR ALTER PROC usp_add_customer
  @name       NVARCHAR(100),
  @phone_num  NVARCHAR(20),
  @email      NVARCHAR(100),
  @gender     NVARCHAR(10),
  @age        INT,
  @city       NVARCHAR(50),
  @device     NVARCHAR(50)
AS
BEGIN
  SET NOCOUNT ON;

  INSERT INTO Customers
    (name, phone_num, email, gender, age, city, device, join_date)
  VALUES
    (@name, @phone_num, @email, @gender, @age, @city, @device, CAST(GETDATE() AS DATE));
END

EXEC usp_add_customer
  @name       = 'Ahmed Sabry',
  @phone_num  = '+20-1793238770',
  @email      = 'customer9352@amaa.com',
  @gender     = 'Female',
  @age        = 53,
  @city       = 'Suez',
  @device     = 'Android';

  --------------------------------------------------------------------------------------------
CREATE OR ALTER PROC usp_create_trip
  @customer_id  INT,
  @pickup_lat   DECIMAL(9,6),
  @pickup_lon   DECIMAL(9,6),
  @drop_lat     DECIMAL(9,6),
  @drop_lon     DECIMAL(9,6),
  @service_type NVARCHAR(50)
AS
BEGIN

  INSERT INTO dbo.Trips (
    customer_id, status,
    pickup_latitude, pickup_longitude,
    dropoff_latitude, dropoff_longitude,
    service_type
  )
  VALUES (
    @customer_id, 'Pending',
    @pickup_lat, @pickup_lon,
    @drop_lat, @drop_lon,
    @service_type
  )

  SELECT CAST(SCOPE_IDENTITY() AS INT) AS NewTripId, N'created' AS msg;
END




 
 EXEC usp_create_trip
  @customer_id   = 6122,
  @pickup_lat    = 30.050100,
  @pickup_lon    = 31.234500,
  @drop_lat      = 30.061200,
  @drop_lon      = 31.220900,
  @service_type  = 'Standard'

  --------------------------------------------------------------
 CREATE OR ALTER PROC dbo.usp_assign_driver_to_trip
  @trip_id    INT,
  @driver_id  INT,
  @vehicle_id INT
AS
BEGIN

  UPDATE dbo.Trips
    SET driver_id = @driver_id,
        vehicle_id = @vehicle_id,
        status = 'Assigned'
  WHERE trip_id = @trip_id
    AND status  = 'Pending';

  IF @@ROWCOUNT = 0
  BEGIN
    SELECT 'not_pending' AS msg;
    RETURN;
  END;

  SELECT 'assigned' AS msg, @trip_id AS TripId
END


  EXEC dbo.usp_assign_driver_to_trip
  @trip_id    = 20001,
  @driver_id  = 3,
  @vehicle_id = 7;
     
  -------------------------------------------------------------------
 CREATE OR ALTER PROC usp_rate_trip
  @trip_id     INT,
  @customer_id INT,
  @score       INT,
  @comment     NVARCHAR(255) 
AS
BEGIN

  INSERT INTO Ratings (trip_id, customer_id, score, comment, [date])
  VALUES (@trip_id, @customer_id, @score, @comment, CAST(GETDATE() AS DATE));

  SELECT 'rated' AS msg, @trip_id AS TripId, @score AS Score;
END;


EXEC usp_rate_trip
  @trip_id     = 20001,
  @customer_id = 6122,
  @score       = 5,
  @comment     = 'The trip was excellent and the driver was very respectful.';
  ----------------------------------------------------------------------------------
  CREATE OR ALTER PROC usp_add_complaint
  @trip_id     INT,
  @customer_id INT,
  @description NVARCHAR(255)
AS
BEGIN

  INSERT INTO Complaints (trip_id, customer_id, description, status, resolution_date)
  VALUES (@trip_id, @customer_id, @description, 'Open', CAST(GETDATE() AS DATE));

  SELECT SCOPE_IDENTITY() AS ComplaintId, 'created' AS msg;
END;



EXEC usp_add_complaint
  @trip_id = 5,
  @customer_id = 6122,
  @description = 'The driver was about 15 minutes late.';
  ----------------------------------------------------------------------------
CREATE OR ALTER PROC usp_cancel_trip
  @trip_id INT
AS
BEGIN

  UPDATE dbo.Trips
  SET status = 'Cancelled'
  WHERE trip_id = @trip_id
    AND status  IN ('Pending', 'Assigned');

  IF @@ROWCOUNT = 0
  BEGIN
    SELECT 'not_found' AS msg;
    RETURN;
  END;

  SELECT 'cancelled' AS msg, @trip_id AS TripId;
END;



EXEC usp_cancel_trip
  @trip_id = 20001;
-----------------------------------------------------------------------------------
CREATE OR ALTER PROC usp_count_trips_per_driver  
AS
BEGIN
  SELECT d.driver_id, d.name, COUNT(t.trip_id) AS total_trips
  FROM Drivers d
  LEFT JOIN Trips t ON d.driver_id = t.driver_id
  GROUP BY d.driver_id, d.name
  ORDER BY total_trips DESC;
END

EXEC usp_count_trips_per_driver

-------------------------------------------------------------------------------------------
CREATE OR ALTER PROC usp_driver_earnings    
AS
BEGIN
  SELECT t.driver_id, d.name, SUM(p.driver_earning) AS total_earning
  FROM Trips t
  JOIN Drivers d ON t.driver_id = d.driver_id
  JOIN Payment_For_Trips p ON t.trip_id = p.trip_id
  GROUP BY t.driver_id, d.name
  ORDER BY total_earning DESC;
END

EXEC usp_driver_earnings;
----------------------------------------------------------------------------------------------
CREATE OR ALTER PROC usp_get_open_complaints  
AS
BEGIN
  SELECT complaint_id, trip_id, customer_id, description, status
  FROM Complaints
  WHERE status = 'Open'
  ORDER BY complaint_id DESC;
END

EXEC usp_get_open_complaints;

---------------------------------------------------------------------------------------------------
CREATE OR ALTER PROC usp_daily_org_profit   --(≈Ã„«·Ì «·√—»«Õ «·ÌÊ„Ì… ··‘—ﬂ…)
AS
BEGIN
  SELECT CAST(t.end_time AS DATE) AS trip_date,
         SUM(p.org_earning) AS total_profit
  FROM Trips t
  JOIN Payment_For_Trips p ON t.trip_id = p.trip_id
  WHERE t.status = 'Completed'
  GROUP BY CAST(t.end_time AS DATE)
  ORDER BY trip_date DESC;
END

EXEC usp_daily_org_profit
----------------------------------------------------------------------------------------------------
CREATE OR ALTER PROC usp_update_driver_status  
  @driver_id INT,
  @new_status NVARCHAR(20)
AS
BEGIN
  UPDATE Drivers SET status = @new_status WHERE driver_id = @driver_id;
  SELECT 'status_updated' AS msg;
END

EXEC usp_update_driver_status
  @driver_id = 3,
  @new_status = 'Inactive';
------------------------------------------------------------------------------------------------------
CREATE OR ALTER PROC usp_delete_complaint   
  @complaint_id INT
AS
BEGIN
  DELETE FROM Complaints WHERE complaint_id = @complaint_id;
  SELECT 'deleted' AS msg;
END

EXEC usp_delete_complaint
  @complaint_id = 12;
  -------------------------------------------------------------------------------------------------------
  CREATE OR ALTER PROC usp_rent_add_payment
  @rent_id        INT,
  @base_price     DECIMAL(10,2),
  @driver_cut     DECIMAL(10,2),
  @org_cut        DECIMAL(10,2),
  @fuel_cost      DECIMAL(10,2) = 0,
  @taxes          DECIMAL(10,2) = 0,
  @tips           DECIMAL(10,2) = 0,
  @payment_method NVARCHAR(50)
AS
BEGIN

  DECLARE @total_price DECIMAL(12,2) = @base_price + @fuel_cost + @taxes + @tips;
  DECLARE @total_profit DECIMAL(12,2) = @org_cut;  

  INSERT INTO dbo.Payment_For_Rent (rent_id, base_price, driver_cut, org_cut, fuel_cost, taxes,
                                    total_profit, payment_method, tips, total_price)
  VALUES (@rent_id, @base_price, @driver_cut, @org_cut, @fuel_cost, @taxes,
          @total_profit, @payment_method, @tips, @total_price);

  SELECT CAST(SCOPE_IDENTITY() AS INT) AS PaymentId, @total_price AS total_price, @total_profit AS total_profit, N'created' AS msg;
END;



EXEC usp_rent_add_payment
  @rent_id        = 10,
  @base_price     = 350.00,
  @driver_cut     = 220.00,
  @org_cut        = 130.00,
  @fuel_cost      = 25.00,
  @taxes          = 15.00,
  @tips           = 10.00,
  @payment_method = 'Cash';
  -----------------------------------------------------------------------------------------------------
  CREATE OR ALTER PROC usp_rent_complete
  @rent_id INT,
  @rating  INT = NULL
AS
BEGIN

  UPDATE dbo.Rent_Vehicle
  SET end_date    = SYSDATETIME(),
      days_rented = DATEDIFF(DAY, start_date, SYSDATETIME()),
      rating      = @rating,
      status      = 'Completed'
  WHERE rent_id = @rent_id AND status = 'Active';

  IF @@ROWCOUNT = 0 SELECT 'not_started' AS msg; ELSE SELECT N'completed' AS msg, @rent_id AS RentId;
END;

EXEC usp_rent_complete
  @rent_id = 105;

 


  -------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------
--(Indexs)


CREATE NONCLUSTERED INDEX Trips_Driver_StartTime  --(⁄—÷ —Õ·«  «·”«∆ﬁ)
ON dbo.Trips(driver_id, start_time DESC)
INCLUDE (status, trip_id, distance, duration, end_time, customer_id, vehicle_id);

-----------------------------------------------------------------------------------------------
CREATE UNIQUE NONCLUSTERED INDEX PayTrips_Trip   --(··√—»«Õ)
ON dbo.Payments_For_Trips(trip_id);

---------------------------------------------------------------------
CREATE NONCLUSTERED INDEX Trips_Pending
ON dbo.Trips(trip_id)
INCLUDE (customer_id, driver_id, vehicle_id)
WHERE status = 'Pending';
