-- =========================================
--  Company Profitability Summary
-- Includes Trips, Freight, Rent & Maintenance Costs
-- =========================================

SELECT
    -- Individual system profits
    (SELECT SUM(total_profit) FROM Payment_For_Trips) AS trip_profit,
    (SELECT SUM(total_profit) FROM Payment_For_Freight) AS freight_profit,
    (SELECT SUM(total_profit) FROM Payment_For_Rent) AS rent_profit,

    -- Maintenance costs
    (SELECT SUM(cost) FROM Maintenance) AS total_maintenance_cost,

    --  Total gross profit before costs
    (
        ISNULL((SELECT SUM(total_profit) FROM Payment_For_Trips), 0) +
        ISNULL((SELECT SUM(total_profit) FROM Payment_For_Freight), 0) +
        ISNULL((SELECT SUM(total_profit) FROM Payment_For_Rent), 0)
    ) AS total_gross_profit,

    --  Final net profit after deducting maintenance
    (
        (
            ISNULL((SELECT SUM(total_profit) FROM Payment_For_Trips), 0) +
            ISNULL((SELECT SUM(total_profit) FROM Payment_For_Freight), 0) +
            ISNULL((SELECT SUM(total_profit) FROM Payment_For_Rent), 0)
        ) -
        ISNULL((SELECT SUM(cost) FROM Maintenance), 0)
    ) AS net_profit_after_maintenance;
GO