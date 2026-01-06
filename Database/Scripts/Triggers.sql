ALTER AUTHORIZATION ON DATABASE::[AMAA_Project] TO [sa];
-------------------------TRIGGERS-------------------------------------------------------
--1
--Triggr يمنع ادخال رحلات غير صحيحة او غير مكتملة 

CREATE or alter TRIGGER trg_PreventInvalidTrip   
ON Trips
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE driver_id IS NULL OR customer_id IS NULL)
    BEGIN
        RAISERROR ('Trip must have both a Captain and a Customer.
        لابد من ادخال كل البيانات', 16, 1); ----Severity 11–16 → أخطاء ناتجة عن المستخدم (زي إدخال بيانات غلط).
        ROLLBACK TRANSACTION;

    END
    ELSE
    BEGIN
        INSERT INTO Trips (
        driver_id,
        customer_id,
        vehicle_id,
        distance,
        duration,
        status,
        start_time,
        end_time,
        pickup_latitude,
        pickup_longitude,
        dropoff_latitude,
        dropoff_longitude,
        service_type,
        expected_time)
       SELECT 
            driver_id,
            customer_id,
            vehicle_id,
            distance,
            duration,
            status,
            start_time,
            end_time,
            pickup_latitude,
            pickup_longitude,
            dropoff_latitude,
            dropoff_longitude,
            service_type,
            expected_time
        FROM inserted;
    END
END;

--------------------------------test-----------------------
-----------------------------------------------------------
-- اختبار: محاولة إدخال رحلة بدون driver_id
INSERT INTO Trips (
    driver_id,
    customer_id,
    vehicle_id,
    distance,
    duration,
    status,
    start_time,
    end_time,
    pickup_latitude,
    pickup_longitude,
    dropoff_latitude,
    dropoff_longitude,
    service_type,
    expected_time
)
VALUES (
    NULL,
    10,
    3,
    100,
    200,
    'Completed',
    '2025-10-15 14:00',
    '2025-10-15 14:30',
    30.1234,
    31.4567,
    30.5678,
    31.6789,
    'Standard',
    30   -- هنا خليه رقم (مثلاً 30 دقيقة)
);


--   (المفروض ما يدخلش الصف)
SELECT * FROM Trips ORDER BY trip_id DESC;




---------------------------------



---ومعاها كمان هتتلغي عملية الإدخال (مش هتلاقي الرحلة في الجدول).

--------------------------------------------------------------------------


-------------------------------------------------------------------------
--------------------------------------------------------------------------
--2 TRIGGER يمنع حذف الرحلات

CREATE or alter TRIGGER trg_PreventDeleteCompletedOrCancelled
ON Trips
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- التحقق من حالة الرحلة قبل الحذف
    IF EXISTS (
        SELECT 1
        FROM deleted d
        WHERE d.status IN ('Completed', 'Cancelled')
    )
    BEGIN
        RAISERROR (N'⚠️ غير مسموح بحذف الرحلات التي تم تنفيذها أو تم إلغاؤها.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;

    -- في الحالات الأخرى (اللي مش Completed أو Cancelled)، يسمح بالحذف
    DELETE T
    FROM Trips AS T
    JOIN deleted AS d ON T.trip_id = d.trip_id;
END;


-------------------test----------------------------------

DELETE FROM Trips
WHERE trip_id = 101;  

SELECT trip_id, status
FROM Trips;
