CREATE DATABASE [AMAA_Project];
GO
USE [AMAA_Project];
GO

-- =====================
-- Table: Drivers
-- =====================
CREATE TABLE Drivers (
    driver_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100),
    phone_num NVARCHAR(20),
    email NVARCHAR(100),
    gender NVARCHAR(10),
    age INT,
    years_of_experience INT,
    avg_rating DECIMAL(3,2),
    status NVARCHAR(20),
    join_date DATE
);

-- =====================
-- Table: Documents
-- =====================
CREATE TABLE Documents (
    document_id INT IDENTITY(1,1) PRIMARY KEY,
    driver_id INT FOREIGN KEY REFERENCES Drivers(driver_id),
    document_type NVARCHAR(50),
    file_url NVARCHAR(255),
    document_number NVARCHAR(50),
    status NVARCHAR(20),
    expires_at DATE,
    created_at DATE,
    reviewed_at DATE
);

-- =====================
-- Table: Vehicles
-- =====================
CREATE TABLE Vehicles (
    vehicle_id INT IDENTITY(1,1) PRIMARY KEY,
    driver_id INT FOREIGN KEY REFERENCES Drivers(driver_id),
    model NVARCHAR(100),
    color NVARCHAR(50),
    year INT,
    fuel_type NVARCHAR(20),
    license_country NVARCHAR(50),
    status NVARCHAR(20)
);

-- =====================
-- Table: Insurance
-- =====================
CREATE TABLE Insurance (
    insurance_id INT IDENTITY(1,1) PRIMARY KEY,
    vehicle_id INT FOREIGN KEY REFERENCES Vehicles(vehicle_id),
    provider_name NVARCHAR(100),
    policy_num NVARCHAR(50),
    expiry_date DATE,
    coverage_type NVARCHAR(50)
);

-- =====================
-- Table: Maintenance
-- =====================
CREATE TABLE Maintenance (
    maintenance_id INT IDENTITY(1,1) PRIMARY KEY,
    vehicle_id INT FOREIGN KEY REFERENCES Vehicles(vehicle_id),
    service_date DATE,
    description NVARCHAR(255),
    cost DECIMAL(10,2),
    workshop_location NVARCHAR(100),
    maintenance_type NVARCHAR(50),
    days_of_work INT
);

-- =====================
-- Table: Customers
-- =====================
CREATE TABLE Customers (
    customer_id INT IDENTITY(1,1) PRIMARY KEY,
    name NVARCHAR(100),
    email NVARCHAR(100),
    phone_num NVARCHAR(20),
    gender NVARCHAR(10),
    age INT,
    country NVARCHAR(50),
    device NVARCHAR(50),
    loyalty_id NVARCHAR(50)
);

-- =====================
-- Table: Trips
-- =====================
CREATE TABLE Trips (
    trip_id INT IDENTITY(1,1) PRIMARY KEY,
    driver_id INT FOREIGN KEY REFERENCES Drivers(driver_id),
    customer_id INT FOREIGN KEY REFERENCES Customers(customer_id),
    vehicle_id INT FOREIGN KEY REFERENCES Vehicles(vehicle_id),
    pickup_id NVARCHAR(50),
    dropoff_id NVARCHAR(50),
    distance DECIMAL(10,2),
    duration INT,
    status NVARCHAR(20),
    start_time DATETIME,
    end_time DATETIME
);

-- =====================
-- Table: Payments_For_Trips
-- =====================
CREATE TABLE Payments_For_Trips (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    trip_id INT FOREIGN KEY REFERENCES Trips(trip_id),
    base_fare DECIMAL(10,2),
    distance_fee DECIMAL(10,2),
    weight_fee DECIMAL(10,2),
    fuel_cost DECIMAL(10,2),
    taxes DECIMAL(10,2),
    org_earning DECIMAL(10,2),
    driver_earning DECIMAL(10,2),
    total_profit DECIMAL(10,2),
    payment_method NVARCHAR(50)
);

-- =====================
-- Table: Ratings
-- =====================
CREATE TABLE Ratings (
    rating_id INT IDENTITY(1,1) PRIMARY KEY,
    trip_id INT FOREIGN KEY REFERENCES Trips(trip_id),
    customer_id INT FOREIGN KEY REFERENCES Customers(customer_id),
    score INT,
    comment NVARCHAR(255),
    date DATE
);

-- =====================
-- Table: Complaints
-- =====================
CREATE TABLE Complaints (
    complaint_id INT IDENTITY(1,1) PRIMARY KEY,
    trip_id INT FOREIGN KEY REFERENCES Trips(trip_id),
    customer_id INT FOREIGN KEY REFERENCES Customers(customer_id),
    description NVARCHAR(255),
    status NVARCHAR(20),
    resolution_date DATE
);

-- =====================
-- Table: Rent_Vehicle
-- =====================
CREATE TABLE Rent_Vehicle (
    rent_id INT IDENTITY(1,1) PRIMARY KEY,
    vehicle_id INT FOREIGN KEY REFERENCES Vehicles(vehicle_id),
    customer_id INT FOREIGN KEY REFERENCES Customers(customer_id),
    insurance_plan NVARCHAR(100),
    start_date DATE,
    end_date DATE,
    days_rented INT,
    status NVARCHAR(20),
    country NVARCHAR(50),
    city NVARCHAR(50),
    rating DECIMAL(3,2)
);

-- =====================
-- Table: Payment_For_Rent
-- =====================
CREATE TABLE Payment_For_Rent (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    rent_id INT FOREIGN KEY REFERENCES Rent_Vehicle(rent_id),
    base_price DECIMAL(10,2),
    driver_cut DECIMAL(10,2),
    org_cut DECIMAL(10,2),
    fuel_cost DECIMAL(10,2),
    taxes DECIMAL(10,2),
    total_profit DECIMAL(10,2),
    payment_method NVARCHAR(50),
    maintenance_cost DECIMAL(10,2),
    tips DECIMAL(10,2)
);

-- =====================
-- Table: Freight
-- =====================
CREATE TABLE Freight (
    freight_id INT IDENTITY(1,1) PRIMARY KEY,
    driver_id INT FOREIGN KEY REFERENCES Drivers(driver_id),
    vehicle_id INT FOREIGN KEY REFERENCES Vehicles(vehicle_id),
    customer_id INT FOREIGN KEY REFERENCES Customers(customer_id),
    pickup_location NVARCHAR(100),
    dropoff_location NVARCHAR(100),
    distance DECIMAL(10,2),
    weight DECIMAL(10,2),
    volume DECIMAL(10,2),
    fragile BIT,
    expected_delivery_time DATETIME,
    created_at DATETIME,
    delivered_at DATETIME,
    status NVARCHAR(20)
);

-- =====================
-- Table: Payments_For_Freight
-- =====================
CREATE TABLE Payments_For_Freight (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,
    freight_id INT FOREIGN KEY REFERENCES Freight(freight_id),
    base_fare DECIMAL(10,2),
    distance_fee DECIMAL(10,2),
    weight_fee DECIMAL(10,2),
    fuel_cost DECIMAL(10,2),
    taxes DECIMAL(10,2),
    org_earning DECIMAL(10,2),
    driver_earning DECIMAL(10,2),
    total_profit DECIMAL(10,2),
    payment_method NVARCHAR(50)
);
GO