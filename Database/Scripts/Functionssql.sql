--------------------FUNCTIONS---------------1111111
-------------------------------------------------------------------
-----------------------------------------------------------------------
--1
--function بتعرض جدول يوضح بدايه ونهاية  وقت الرحلة
CREATE OR ALTER FUNCTION dbo.GetTripTimes (@trip_id INT)
   
  -- نوع البيانات لازم يكون زي نوع العمود في جدول Trips

RETURNS TABLE
AS
RETURN
(
    SELECT 
        trip_id,
        start_time,
        end_time
    FROM Trips
    WHERE  trip_id = @trip_id
);

SELECT * FROM  dbo.GetTripTimes(5);

-------------------------------------------------------------------------------
--2
--function تعرض حالة السائق سواء مشغول ام متاح


CREATE OR ALTER FUNCTION dbo.GetDriverStatus(@DriverID INT)
RETURNS NVARCHAR(50)
AS
begin
declare @DriverStatus NVARCHAR(50);
SELECT @DriverStatus = d.status
FROM Drivers d
WHERE d.driver_id = @DriverID
RETURN @DriverStatus;
end

select dbo.GetDriverStatus(33)AS Driver_Status

SELECT * FROM Drivers

----------------------------------------------------------------
--3
--function تعرض سعر الرحلة بناءا علي ال id
CREATE OR ALTER FUNCTION dbo.Gettrip_price(@TripID INT)
RETURNS NVARCHAR(50)
AS
begin
declare @Trip_price NVARCHAR(50);
SELECT @Trip_price = T.base_fare
FROM Payments_For_Trips T
WHERE T.trip_id = @TripID
RETURN @Trip_price;
end

select  dbo.Gettrip_price(27) AS Trip_Price

SELECT * FROM Payments_For_Trips T

----------------------------------------------------------
--4
--function ترجع أعلى 5 عملاء طلبوا رحلات

CREATE OR ALTER FUNCTION dbo.Top5Customers()
RETURNS @TopCustomers TABLE
(
    customerID INT,
    Customer_Name NVARCHAR(100),
    TotalTrips INT
)
AS
BEGIN
    INSERT INTO @TopCustomers
    SELECT TOP 5 
        c.customer_id,
        c.name,
        COUNT(t.trip_id) AS Total_Trips
    FROM Customers c
    INNER JOIN Trips t ON c.customer_id = t.customer_id
    GROUP BY c.customer_id, c.name
    ORDER BY COUNT(t.trip_id) DESC;

    RETURN;
END;


SELECT * FROM dbo.Top5Customers();

-------------------------------------------------------------
--------------------------------------------------------------------
--5 
--function نحسب إجمالي الأرباح لأي فترة زمنية (من تاريخ إلى تاريخ)،
CREATE OR ALTER FUNCTION dbo.TotalProfitByDateRange
(
    @StartDate DATE,
    @EndDate DATE
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @TotalProfit DECIMAL(18,2);

    SELECT 
        @TotalProfit = SUM(total_profit)
    FROM Payments_For_Trips pt

    inner join dbo.Trips T ON T.trip_id = pt.trip_id
    
    WHERE 
        end_time BETWEEN @StartDate AND @EndDate
        AND status = 'Completed'; -- نحسب بس الرحلات المنتهية

    RETURN ISNULL(@TotalProfit, 0);
END;

SELECT dbo.TotalProfitByDateRange('2025-10-01', '2025-10-31') AS OctoberProfit;

---------------------------------------------------------------------------------------
---6
--function تعرض متوسط تقييم السائق في جدول يعرض ال id , name, avg score, count of ratting id

CREATE OR ALTER FUNCTION dbo.GetDriverRatingDetails (@DriverID INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        d.driver_id,
        d.name,
        AVG(r.score) AS AverageScore,
        COUNT(r.rating_id) AS RatedTripsCount
    FROM Drivers d
    INNER JOIN Trips t ON d.driver_id = t.driver_id
    INNER JOIN Ratings r ON t.trip_id = r.trip_id
    WHERE d.driver_id = @DriverID
    GROUP BY d.driver_id, d.name
);

SELECT * FROM dbo.GetDriverRatingDetails(3);

