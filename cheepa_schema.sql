-- ============================================================
-- DATABASE SCHEMA: CHEEPÁ SYSTEM
-- Generated from the Entity-Relationship Diagram (ERD)
-- ============================================================

-- 1. INDEPENDENT TABLES (Master Dimensions)
-- ============================================================

CREATE TABLE Products (
    Product_ID INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL
);

CREATE TABLE employees (
    Employee_ID INT PRIMARY KEY,
    Employee_name VARCHAR(100) NOT NULL
);

CREATE TABLE Categories (
    Category_ID INT PRIMARY KEY,
    Category VARCHAR(100) NOT NULL
);

CREATE TABLE Contacto (
    Red_ID INT PRIMARY KEY,
    RedName VARCHAR(100) NOT NULL
);

CREATE TABLE Regular (
    Regular_ID INT PRIMARY KEY,
    Regular_value VARCHAR(100) NOT NULL
);

CREATE TABLE shops (
    Shop_ID INT PRIMARY KEY,
    Shop_name VARCHAR(100) NOT NULL
);

CREATE TABLE Ads (
    ID INT PRIMARY KEY,
    StartedDay INT, -- Matches integer type from the diagram
    EndingDate TIMESTAMP,
    Name VARCHAR(100) NOT NULL,
    invested INT
);

-- 2. HISTORICAL AND DEPENDENT TABLES
-- ============================================================

CREATE TABLE CostHistory (
    ID INT PRIMARY KEY,
    ProductID INT,
    StartingDate TIMESTAMP, 
    endingDate TIMESTAMP,
    Cost FLOAT,
    FOREIGN KEY (ProductID) REFERENCES Products(Product_ID)
);

CREATE TABLE PriceHistory (
    ID INT PRIMARY KEY,
    ProductID INT,
    StartingDate TIMESTAMP,
    endingDate TIMESTAMP,
    Price INT,
    FOREIGN KEY (ProductID) REFERENCES Products(Product_ID)
);

CREATE TABLE inventory (
    inventory_ID INT PRIMARY KEY,
    DateTime TIMESTAMP,
    Shop_ID INT,
    FOREIGN KEY (Shop_ID) REFERENCES shops(Shop_ID)
);

-- 3. TRANSACTIONAL TABLES (Facts and Details)
-- ============================================================

CREATE TABLE inventoryDetails (
    inventory_ID INT,
    InventoryDetails_ID INT PRIMARY KEY,
    Quantity INT,
    ProductID INT,
    FOREIGN KEY (inventory_ID) REFERENCES inventory(inventory_ID),
    FOREIGN KEY (ProductID) REFERENCES Products(Product_ID)
);

CREATE TABLE Orders (
    Order_ID INT PRIMARY KEY,
    Date TIMESTAMP,
    CustomerName VARCHAR(100),
    Employee_ID INT,
    Regular_ID INT,
    Category_ID INT,
    Contact_ID INT,
    Address_ID INT, -- Reserved for external address dependencies
    Ads_ID INT,
    Shop_ID INT,
    FOREIGN KEY (Employee_ID) REFERENCES employees(Employee_ID),
    FOREIGN KEY (Regular_ID) REFERENCES Regular(Regular_ID),
    FOREIGN KEY (Category_ID) REFERENCES Categories(Category_ID),
    FOREIGN KEY (Contact_ID) REFERENCES Contacto(Red_ID),
    FOREIGN KEY (Ads_ID) REFERENCES Ads(ID),
    FOREIGN KEY (Shop_ID) REFERENCES shops(Shop_ID)
);

CREATE TABLE OrderDetails (
    OrderDetailsID INT PRIMARY KEY,
    Order_ID INT,
    Product_ID INT,
    Quantity INT,
    Date TIMESTAMP, -- Diagram notes "stamptime"
    Price_ID INT,
    Cost_ID INT,
    FOREIGN KEY (Order_ID) REFERENCES Orders(Order_ID),
    FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID),
    FOREIGN KEY (Price_ID) REFERENCES PriceHistory(ID),
    FOREIGN KEY (Cost_ID) REFERENCES CostHistory(ID)
);