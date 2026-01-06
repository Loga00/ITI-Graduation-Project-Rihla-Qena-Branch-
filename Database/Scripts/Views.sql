use AMAA_Project

select * from Payment_For_Rent

use AMAA_Project

CREATE VIEW vw_HR_Drivers AS
SELECT 
    d.driver_id,
    d.name AS DriverName,
    d.phone_num AS PhoneNumber,
    d.join_date AS HireDate,
    d.status AS EmploymentStatus,
    d.avg_rating AS AvgRating,
    COUNT(t.trip_id) AS TotalTrips,
    v.model AS AssignedVehicle,
    v.plate_number AS VehiclePlate
FROM Drivers d
LEFT JOIN Trips t ON d.driver_id = t.driver_id
LEFT JOIN Vehicles v ON d.driver_id = v.driver_id
GROUP BY 
    d.driver_id, d.name, d.phone_num, d.join_date, d.status, d.avg_rating, 
    v.model, v.plate_number;

   SELECT * FROM vw_HR_Drivers;



CREATE VIEW vw_HR_Licenses AS
SELECT 
    d.driver_id,
    d.name AS DriverName,
    l.License_number,
    l.license_type,
    l.created_at,
    l.expires_at,
    CASE 
        WHEN l.expires_at < GETDATE() THEN 'Expired'
        WHEN DATEDIFF(DAY, GETDATE(), l.expires_at) <= 30 THEN 'Expiring Soon'
        ELSE 'Valid'
    END AS LicenseStatus
FROM Drivers d
INNER JOIN Licenses l ON d.driver_id = l.driver_id;


select * from vw_HR_Licenses 




CREATE VIEW vw_CS_Customers AS
SELECT 
    c.customer_id,
    c.name AS CustomerName,
    c.phone_num AS PhoneNumber,
    c.email,
    COUNT(t.trip_id) AS TotalTrips,
    AVG(t.distance) AS AvgDistance,
    AVG(t.duration) AS AvgDuration,
    CASE 
        WHEN COUNT(t.trip_id) = 0 THEN 'Inactive'
        ELSE 'Active'
    END AS CustomerStatus
FROM Customers c
LEFT JOIN Trips t ON c.customer_id = t.customer_id
GROUP BY 
    c.customer_id, c.name, c.phone_num, c.email;


    select * from  vw_CS_Customers



    CREATE VIEW vw_Operations_Trips AS
SELECT
    t.trip_id,
    t.driver_id,
    d.name AS DriverName,
    t.customer_id,
    c.name AS CustomerName,
    t.vehicle_id,
    v.model AS VehicleModel,
    v.plate_number AS VehiclePlate,
    t.distance,
    t.duration,
    t.service_type,
    t.status AS TripStatus,
    t.start_time,
    t.end_time,
    p.total_profit,
    p.payment_method
FROM Trips t
LEFT JOIN Drivers d ON t.driver_id = d.driver_id
LEFT JOIN Customers c ON t.customer_id = c.customer_id
LEFT JOIN Vehicles v ON t.vehicle_id = v.vehicle_id
LEFT JOIN Payment_For_Trips p ON t.trip_id = p.trip_id;

select * from vw_Operations_Trips



CREATE VIEW vw_Operations_Freight AS
SELECT
    f.freight_id,
    f.driver_id,
    d.name AS DriverName,
    f.customer_id,
    c.name AS CustomerName,
    f.vehicle_id,
    v.model AS VehicleModel,
    v.plate_number AS VehiclePlate,
    f.distance,
    f.weight,
    f.volume,
    f.fragile,
    f.status AS FreightStatus,
    f.created_at AS StartDate,
    f.delivered_at AS EndDate,
    f.expected_delivery_time,
    p.total_profit,
    p.payment_method
FROM Freight f
LEFT JOIN Drivers d ON f.driver_id = d.driver_id
LEFT JOIN Customers c ON f.customer_id = c.customer_id
LEFT JOIN Vehicles v ON f.vehicle_id = v.vehicle_id
LEFT JOIN Payment_For_Freight p ON f.freight_id = p.freight_id;

select * from  vw_Operations_Freight



CREATE VIEW vw_Finance_Trips AS
SELECT
    p.payment_id,
    p.trip_id,
    t.driver_id,
    d.name AS DriverName,
    t.customer_id,
    c.name AS CustomerName,
    p.payment_method,
    p.total_profit AS Amount,
    t.service_type,
    t.status AS TripStatus
FROM Payment_For_Trips p
LEFT JOIN Trips t ON p.trip_id = t.trip_id
LEFT JOIN Drivers d ON t.driver_id = d.driver_id
LEFT JOIN Customers c ON t.customer_id = c.customer_id;

select * from  vw_Finance_Trips



CREATE VIEW vw_Finance_Freight AS
SELECT
    p.payment_id,
    p.freight_id,
    f.driver_id,
    d.name AS DriverName,
    f.customer_id,
    c.name AS CustomerName,
    p.payment_method,
    p.total_profit AS Amount,
    f.status AS FreightStatus
FROM Payment_For_Freight p
LEFT JOIN Freight f ON p.freight_id = f.freight_id
LEFT JOIN Drivers d ON f.driver_id = d.driver_id
LEFT JOIN Customers c ON f.customer_id = c.customer_id;


select * from vw_Finance_Freight


CREATE VIEW vw_Finance_Rent AS
SELECT
    p.payment_id,
    p.rent_id,
    r.customer_id,
    c.name AS CustomerName,
    r.vehicle_id,
    v.model AS VehicleModel,
    v.plate_number AS VehiclePlate,
    p.payment_method,
    p.total_profit AS Amount,
    r.start_date,
    r.end_date,
    r.status AS RentStatus
FROM Payment_For_Rent p
LEFT JOIN Rent_Vehicle r ON p.rent_id = r.rent_id
LEFT JOIN Customers c ON r.customer_id = c.customer_id
LEFT JOIN Vehicles v ON r.vehicle_id = v.vehicle_id;



select * from vw_Finance_Rent



CREATE VIEW vw_MN_Maintenance AS
SELECT
    v.vehicle_id,
    v.model AS VehicleModel,
    v.plate_number AS VehiclePlate,
    v.status AS VehicleStatus,
    m.maintenance_id,
    m.maintenance_type,
    m.cost AS MaintenanceCost,
    i.insurance_id,
    i.provider_name AS InsuranceProvider,
    i.policy_num,
    i.expiry_date AS InsuranceEnd
     FROM Vehicles v
LEFT JOIN Maintenance m ON v.vehicle_id = m.vehicle_id
LEFT JOIN Insurance i ON v.vehicle_id = i.vehicle_id;

select * from vw_MN_Maintenance