-- Initial Set Up Script. Expect this to change a lot.  Garbage company
 
 
 -- Schema: dev (repeat for modelOffice as needed)
CREATE SCHEMA dev;

-- Product Dimension
CREATE TABLE dev.Product (
    ProductID INT PRIMARY KEY,
    ProductName VARCHAR(50) NOT NULL,
    ProductType VARCHAR(20) NOT NULL, -- 'Food' or 'Drink'
    Price DECIMAL(6,2) NOT NULL
);

-- Store Dimension
CREATE TABLE dev.Store (
    StoreID INT PRIMARY KEY,
    StoreName VARCHAR(50) NOT NULL,
    Location VARCHAR(50) NOT NULL,
    RegionID INT NOT NULL
);

-- Customer Dimension
CREATE TABLE dev.Customer (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(50),
    RegionID INT NOT NULL
);

-- Region Dimension
CREATE TABLE dev.Region (
    RegionID INT PRIMARY KEY,
    RegionName VARCHAR(50)
);

-- Fact Table: Sale
CREATE TABLE dev.Sale (
    SaleID INT PRIMARY KEY,
    SaleDate DATE NOT NULL,
    StoreID INT NOT NULL,
    ProductID INT NOT NULL,
    CustomerID INT NOT NULL,
    Quantity INT NOT NULL,
    TotalPrice DECIMAL(8,2) NOT NULL,
    FOREIGN KEY (StoreID) REFERENCES dev.Store(StoreID),
    FOREIGN KEY (ProductID) REFERENCES dev.Product(ProductID),
    FOREIGN KEY (CustomerID) REFERENCES dev.Customer(CustomerID)


-- Populate Dimensions

-- Regions
INSERT INTO dev.Region (RegionID, RegionName) VALUES
(1, 'North'),
(2, 'South'),
(3, 'East'),
(4, 'West');

-- Stores
INSERT INTO dev.Store (StoreID, StoreName, Location, RegionID) VALUES
(1, 'Burger Palace', 'Main Street', 1),
(2, 'Pizza World', 'Downtown', 2),
(3, 'Nugget Point', 'Mall Avenue', 3);

-- Products (Fast Foods & Drinks)
INSERT INTO dev.Product (ProductID, ProductName, ProductType, Price) VALUES
(1, 'Burger', 'Food', 5.00),
(2, 'Pizza', 'Food', 8.00),
(3, 'Fries', 'Food', 2.50),
(4, 'Chicken Nuggets', 'Food', 4.00),
(5, 'Cola', 'Drink', 1.50),
(6, 'Orange Juice', 'Drink', 2.00);

-- Customers
INSERT INTO dev.Customer (CustomerID, CustomerName, RegionID) VALUES
(1, 'Alice Smith', 1),
(2, 'Bob Jones', 2),
(3, 'Charlie Lee', 3),
(4, 'Dana Patel', 4);

);

--Populate FactTables

-- Sales: SaleID, SaleDate, StoreID, ProductID, CustomerID, Quantity, TotalPrice
INSERT INTO dev.Sale VALUES
(1, '2025-05-21', 1, 1, 1, 2, 10.00),    -- 2 Burgers by Alice
(2, '2025-05-21', 2, 2, 2, 1, 8.00),     -- 1 Pizza by Bob
(3, '2025-05-21', 3, 4, 3, 3, 12.00),    -- 3 Chicken Nuggets by Charlie
(4, '2025-05-21', 1, 3, 4, 1, 2.50),     -- 1 Fries by Dana
(5, '2025-05-21', 2, 5, 1, 2, 3.00),     -- 2 Cola by Alice
(6, '2025-05-21', 3, 6, 2, 1, 2.00);     -- 1 OJ by Bob
