-- ============================================================
--  FinWealth Advisors -- Data Warehouse DDL Script
--  Database  : finwealth-dw (Azure SQL)
--  Purpose   : Create ALL tables before running ADF pipelines
--  Run order : 1) Staging tables  2) Dimension tables  3) Fact tables
--  Author    : Generated from actual CSV source data
-- ============================================================

USE [finwealth-dw];
GO

-- ============================================================
--  SECTION 1 : STAGING TABLES  (stg_*)
--  These are raw landing tables. ADF Copy Activity writes here
--  first. No surrogate keys, no constraints -- mirrors CSV exactly.
--  The Data Flow will read from these and load DWH tables.
-- ============================================================

-- Drop staging tables if they already exist (safe re-run)
IF OBJECT_ID('stg_Performance',  'U') IS NOT NULL DROP TABLE stg_Performance;
IF OBJECT_ID('stg_Prices',       'U') IS NOT NULL DROP TABLE stg_Prices;
IF OBJECT_ID('stg_Holdings',     'U') IS NOT NULL DROP TABLE stg_Holdings;
IF OBJECT_ID('stg_Trades',       'U') IS NOT NULL DROP TABLE stg_Trades;
IF OBJECT_ID('stg_Cashflows',    'U') IS NOT NULL DROP TABLE stg_Cashflows;
IF OBJECT_ID('stg_Fees',         'U') IS NOT NULL DROP TABLE stg_Fees;
IF OBJECT_ID('stg_Benchmarks',   'U') IS NOT NULL DROP TABLE stg_Benchmarks;
IF OBJECT_ID('stg_Accounts',     'U') IS NOT NULL DROP TABLE stg_Accounts;
IF OBJECT_ID('stg_Clients',      'U') IS NOT NULL DROP TABLE stg_Clients;
IF OBJECT_ID('stg_Securities',   'U') IS NOT NULL DROP TABLE stg_Securities;
IF OBJECT_ID('stg_Advisors',     'U') IS NOT NULL DROP TABLE stg_Advisors;
GO

-- ------------------------------------------------------------
--  stg_Advisors
--  Source: Advisors.csv  |  350 rows
--  Columns: AdvisorID, AdvisorName, Region, JoinDate, ExperienceYears
-- ------------------------------------------------------------
CREATE TABLE stg_Advisors (
    AdvisorID        VARCHAR(20)   NULL,   -- e.g. ADV0001   (max 7 chars in data)
    AdvisorName      VARCHAR(100)  NULL,   -- e.g. Advisor 0001
    Region           VARCHAR(50)   NULL,   -- e.g. Europe, APAC, Americas
    JoinDate         DATE          NULL,   -- e.g. 2022-03-03
    ExperienceYears  INT           NULL    -- e.g. 5
);
GO

-- ------------------------------------------------------------
--  stg_Clients
--  Source: Clients.csv  |  8,000 rows
--  Columns: ClientID, ClientName, Segment, RiskProfile,
--           PrimaryAdvisorID, ClientSince, Country
-- ------------------------------------------------------------
CREATE TABLE stg_Clients (
    ClientID          VARCHAR(20)   NULL,   -- e.g. CL000001
    ClientName        VARCHAR(100)  NULL,   -- e.g. Client 000001
    Segment           VARCHAR(50)   NULL,   -- e.g. Mass Affluent, HNW, UHNW
    RiskProfile       VARCHAR(50)   NULL,   -- e.g. Balanced, Aggressive, Conservative
    PrimaryAdvisorID  VARCHAR(20)   NULL,   -- FK to Advisors.AdvisorID
    ClientSince       DATE          NULL,   -- e.g. 2021-08-25
    Country           VARCHAR(50)   NULL    -- e.g. Brazil, USA, India
);
GO

-- ------------------------------------------------------------
--  stg_Accounts
--  Source: Accounts.csv  |  12,000 rows
--  Columns: AccountID, ClientID, AccountType, OpenDate,
--           BaseCurrency, Status
-- ------------------------------------------------------------
CREATE TABLE stg_Accounts (
    AccountID     VARCHAR(20)  NULL,   -- e.g. AC0000001
    ClientID      VARCHAR(20)  NULL,   -- FK to Clients.ClientID
    AccountType   VARCHAR(50)  NULL,   -- e.g. Joint, Individual, Retirement
    OpenDate      DATE         NULL,   -- e.g. 2016-06-26
    BaseCurrency  VARCHAR(10)  NULL,   -- e.g. USD, EUR, GBP
    Status        VARCHAR(20)  NULL    -- e.g. Active, Closed
);
GO

-- ------------------------------------------------------------
--  stg_Securities
--  Source: Securities.csv  |  3,000 rows
--  Columns: SecurityID, Ticker, SecurityName, AssetClass,
--           Sector, Currency, Region
-- ------------------------------------------------------------
CREATE TABLE stg_Securities (
    SecurityID    VARCHAR(20)   NULL,   -- e.g. SEC000001
    Ticker        VARCHAR(20)   NULL,   -- e.g. T00001
    SecurityName  VARCHAR(100)  NULL,   -- e.g. Bond-000001
    AssetClass    VARCHAR(50)   NULL,   -- e.g. Bond, Equity, ETF
    Sector        VARCHAR(100)  NULL,   -- e.g. Telecom, Healthcare, Energy
    Currency      VARCHAR(10)   NULL,   -- e.g. USD, EUR
    Region        VARCHAR(50)   NULL    -- e.g. APAC, Europe, Americas
);
GO

-- ------------------------------------------------------------
--  stg_Benchmarks
--  Source: Benchmarks.csv  |  4,020 rows
--  Columns: BenchmarkCode, Description, Currency,
--           IndexValueDate, IndexValue
-- ------------------------------------------------------------
CREATE TABLE stg_Benchmarks (
    BenchmarkCode   VARCHAR(20)    NULL,   -- e.g. SP500, MSCI_WORLD
    Description     VARCHAR(100)   NULL,   -- e.g. US Equity Broad
    Currency        VARCHAR(10)    NULL,   -- e.g. USD
    IndexValueDate  DATE           NULL,   -- e.g. 2024-01-01
    IndexValue      DECIMAL(18,4)  NULL    -- e.g. 856.88
);
GO

-- ------------------------------------------------------------
--  stg_Holdings
--  Source: Holdings.csv  |  96,027 rows
--  Columns: AccountID, SecurityID, Quantity, ValuationDate, MarketValue
-- ------------------------------------------------------------
CREATE TABLE stg_Holdings (
    AccountID     VARCHAR(20)    NULL,   -- FK to Accounts.AccountID
    SecurityID    VARCHAR(20)    NULL,   -- FK to Securities.SecurityID
    Quantity      DECIMAL(18,4)  NULL,   -- e.g. 75.56  (units held)
    ValuationDate DATE           NULL,   -- e.g. 2025-10-31
    MarketValue   DECIMAL(18,2)  NULL    -- e.g. 9050.98  (in BaseCurrency)
);
GO

-- ------------------------------------------------------------
--  stg_Trades
--  Source: Trades.csv  |  100,400 rows
--  Columns: TradeID, AccountID, SecurityID, TradeDate,
--           SettleDate, Side, Price, Quantity, Amount
-- ------------------------------------------------------------
CREATE TABLE stg_Trades (
    TradeID     VARCHAR(20)    NULL,   -- e.g. TRD0000001
    AccountID   VARCHAR(20)    NULL,   -- FK to Accounts.AccountID
    SecurityID  VARCHAR(20)    NULL,   -- FK to Securities.SecurityID
    TradeDate   DATE           NULL,   -- e.g. 2024-11-29
    SettleDate  DATE           NULL,   -- e.g. 2024-12-02
    Side        VARCHAR(10)    NULL,   -- BUY or SELL
    Price       DECIMAL(18,4)  NULL,   -- e.g. 314.58
    Quantity    DECIMAL(18,4)  NULL,   -- e.g. 153.00
    Amount      DECIMAL(18,2)  NULL    -- e.g. -48130.74 (negative = sell proceeds)
);
GO

-- ------------------------------------------------------------
--  stg_Cashflows
--  Source: Cashflows.csv  |  30,000 rows
--  Columns: CashflowID, AccountID, CashflowDate, Type, Amount
-- ------------------------------------------------------------
CREATE TABLE stg_Cashflows (
    CashflowID    VARCHAR(20)    NULL,   -- e.g. CF0000001
    AccountID     VARCHAR(20)    NULL,   -- FK to Accounts.AccountID
    CashflowDate  DATE           NULL,   -- e.g. 2023-09-22
    Type          VARCHAR(50)    NULL,   -- e.g. Deposit, Withdrawal, Dividend
    Amount        DECIMAL(18,2)  NULL    -- e.g. 8603.68
);
GO

-- ------------------------------------------------------------
--  stg_Fees
--  Source: Fees.csv  |  18,000 rows
--  Columns: FeeID, AccountID, FeeDate, FeeType, Amount
-- ------------------------------------------------------------
CREATE TABLE stg_Fees (
    FeeID    VARCHAR(20)    NULL,   -- e.g. FEE000001
    AccountID VARCHAR(20)   NULL,   -- FK to Accounts.AccountID
    FeeDate  DATE           NULL,   -- e.g. 2025-04-08
    FeeType  VARCHAR(50)    NULL,   -- e.g. Transaction, Management, Advisory
    Amount   DECIMAL(18,2)  NULL    -- e.g. 307.80
);
GO

-- ------------------------------------------------------------
--  stg_Prices
--  Source: Prices.csv  |  301,500 rows
--  Columns: SecurityID, PriceDate, ClosePrice
-- ------------------------------------------------------------
CREATE TABLE stg_Prices (
    SecurityID  VARCHAR(20)    NULL,   -- FK to Securities.SecurityID
    PriceDate   DATE           NULL,   -- e.g. 2024-01-01
    ClosePrice  DECIMAL(18,4)  NULL    -- e.g. 126.77
);
GO

-- ------------------------------------------------------------
--  stg_Performance
--  Source: Performance.csv  |  110,000 rows
--  Columns: AccountID, MonthStart, ReturnPct, BenchmarkCode,
--           BenchmarkReturnPct, ExcessReturnPct, CumulativeReturnPct
-- ------------------------------------------------------------
CREATE TABLE stg_Performance (
    AccountID            VARCHAR(20)    NULL,   -- FK to Accounts.AccountID
    MonthStart           DATE           NULL,   -- e.g. 2024-01-01 (first day of month)
    ReturnPct            DECIMAL(18,6)  NULL,   -- e.g. -0.003700  (raw decimal, not %)
    BenchmarkCode        VARCHAR(20)    NULL,   -- FK to Benchmarks.BenchmarkCode
    BenchmarkReturnPct   DECIMAL(18,6)  NULL,   -- e.g. -0.036500
    ExcessReturnPct      DECIMAL(18,6)  NULL,   -- ReturnPct - BenchmarkReturnPct
    CumulativeReturnPct  DECIMAL(18,6)  NULL    -- rolling cumulative return
);
GO


-- ============================================================
--  SECTION 2 : DIMENSION TABLES  (Dim_*)
--  Star Schema dimensions with IDENTITY surrogate keys.
--  ADF Data Flow joins staging tables into these.
--  Must be created BEFORE Fact tables (FK dependency).
-- ============================================================

-- Drop dimensions (in safe order -- no FK from dim to dim)
IF OBJECT_ID('Fact_Performance', 'U') IS NOT NULL DROP TABLE Fact_Performance;
IF OBJECT_ID('Fact_Holdings',    'U') IS NOT NULL DROP TABLE Fact_Holdings;
IF OBJECT_ID('Fact_Trades',      'U') IS NOT NULL DROP TABLE Fact_Trades;
IF OBJECT_ID('Fact_Fees',        'U') IS NOT NULL DROP TABLE Fact_Fees;
IF OBJECT_ID('Fact_Cashflows',   'U') IS NOT NULL DROP TABLE Fact_Cashflows;
IF OBJECT_ID('Dim_Benchmark',    'U') IS NOT NULL DROP TABLE Dim_Benchmark;
IF OBJECT_ID('Dim_Security',     'U') IS NOT NULL DROP TABLE Dim_Security;
IF OBJECT_ID('Dim_Account',      'U') IS NOT NULL DROP TABLE Dim_Account;
IF OBJECT_ID('Dim_Client',       'U') IS NOT NULL DROP TABLE Dim_Client;
IF OBJECT_ID('Dim_Advisor',      'U') IS NOT NULL DROP TABLE Dim_Advisor;
GO

-- ------------------------------------------------------------
--  Dim_Advisor
--  Grain: One row per advisor
--  Surrogate key: AdvisorKey (IDENTITY)
-- ------------------------------------------------------------
CREATE TABLE Dim_Advisor (
    AdvisorKey       INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    AdvisorID        VARCHAR(20)   NOT NULL,   -- natural/business key
    AdvisorName      VARCHAR(100)  NULL,
    Region           VARCHAR(50)   NULL,
    JoinDate         DATE          NULL,
    ExperienceYears  INT           NULL,
);
GO

-- ------------------------------------------------------------
--  Dim_Client
--  Grain: One row per client
-- ------------------------------------------------------------
CREATE TABLE Dim_Client (
    ClientKey         INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    ClientID          VARCHAR(20)   NOT NULL,
    ClientName        VARCHAR(100)  NULL,
    Segment           VARCHAR(50)   NULL,       -- Mass Affluent / HNW / UHNW
    RiskProfile       VARCHAR(50)   NULL,       -- Conservative / Balanced / Aggressive
    PrimaryAdvisorID  VARCHAR(20)   NULL,       -- kept as natural key for join flexibility
    ClientSince       DATE          NULL,
    Country           VARCHAR(50)   NULL,
);
GO

-- ------------------------------------------------------------
--  Dim_Account
--  Grain: One row per account
-- ------------------------------------------------------------
CREATE TABLE Dim_Account (
    AccountKey    INT          NOT NULL IDENTITY(1,1) PRIMARY KEY,
    AccountID     VARCHAR(20)  NOT NULL,
    ClientID      VARCHAR(20)  NULL,            -- natural key to Clients
    AccountType   VARCHAR(50)  NULL,            -- Joint / Individual / Retirement
    OpenDate      DATE         NULL,
    BaseCurrency  VARCHAR(10)  NULL,
    Status        VARCHAR(20)  NULL,            -- Active / Closed
);
GO

-- ------------------------------------------------------------
--  Dim_Security
--  Grain: One row per security/instrument
-- ------------------------------------------------------------
CREATE TABLE Dim_Security (
    SecurityKey   INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    SecurityID    VARCHAR(20)   NOT NULL,
    Ticker        VARCHAR(20)   NULL,
    SecurityName  VARCHAR(100)  NULL,
    AssetClass    VARCHAR(50)   NULL,           -- Bond / Equity / ETF / Cash
    Sector        VARCHAR(100)  NULL,           -- Telecom / Healthcare / Energy ...
    Currency      VARCHAR(10)   NULL,
    Region        VARCHAR(50)   NULL,           -- APAC / Europe / Americas
);
GO

-- ------------------------------------------------------------
--  Dim_Benchmark
--  Grain: One row per benchmark index (distinct codes only)
--  Note: The stg_Benchmarks table has one row per date;
--        Dim_Benchmark stores the benchmark metadata only.
--        Daily index values go to Fact_BenchmarkPrices (optional).
-- ------------------------------------------------------------
CREATE TABLE Dim_Benchmark (
    BenchmarkKey   INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    BenchmarkCode  VARCHAR(20)   NOT NULL,      -- e.g. SP500, MSCI_WORLD
    Description    VARCHAR(100)  NULL,          -- e.g. US Equity Broad
    Currency       VARCHAR(10)   NULL,
);
GO


-- ============================================================
--  SECTION 3 : FACT TABLES  (Fact_*)
--  Each fact table references dimension surrogate keys.
--  ADF Data Flow resolves natural keys → surrogate keys via joins.
-- ============================================================

-- ------------------------------------------------------------
--  Fact_Holdings  (AUM fact)
--  Grain: One row per Account × Security × ValuationDate
--  Source: stg_Holdings joined with Dim_Account + Dim_Security
-- ------------------------------------------------------------
CREATE TABLE Fact_Holdings (
    HoldingKey    INT            NOT NULL IDENTITY(1,1) PRIMARY KEY,
    AccountKey    INT            NOT NULL,
    SecurityKey   INT            NOT NULL,
    Quantity      DECIMAL(18,4)  NULL,
    ValuationDate DATE           NULL,
    MarketValue   DECIMAL(18,2)  NULL,

    CONSTRAINT FK_Holdings_Account  FOREIGN KEY (AccountKey)  REFERENCES Dim_Account(AccountKey),
    CONSTRAINT FK_Holdings_Security FOREIGN KEY (SecurityKey) REFERENCES Dim_Security(SecurityKey)
);
GO

-- ------------------------------------------------------------
--  Fact_Trades
--  Grain: One row per trade execution
--  Source: stg_Trades joined with Dim_Account + Dim_Security
-- ------------------------------------------------------------
CREATE TABLE Fact_Trades (
    TradeKey    INT            NOT NULL IDENTITY(1,1) PRIMARY KEY,
    TradeID     VARCHAR(20)    NULL,            -- kept for traceability / dedup
    AccountKey  INT            NOT NULL,
    SecurityKey INT            NOT NULL,
    TradeDate   DATE           NULL,
    SettleDate  DATE           NULL,
    Side        VARCHAR(10)    NULL,            -- BUY or SELL
    Price       DECIMAL(18,4)  NULL,
    Quantity    DECIMAL(18,4)  NULL,
    Amount      DECIMAL(18,2)  NULL,            -- negative = SELL proceeds

    CONSTRAINT FK_Trades_Account  FOREIGN KEY (AccountKey)  REFERENCES Dim_Account(AccountKey),
    CONSTRAINT FK_Trades_Security FOREIGN KEY (SecurityKey) REFERENCES Dim_Security(SecurityKey)
);
GO

-- ------------------------------------------------------------
--  Fact_Cashflows
--  Grain: One row per cashflow event
--  Source: stg_Cashflows joined with Dim_Account
-- ------------------------------------------------------------
CREATE TABLE Fact_Cashflows (
    CashflowKey   INT            NOT NULL IDENTITY(1,1) PRIMARY KEY,
    CashflowID    VARCHAR(20)    NULL,
    AccountKey    INT            NOT NULL,
    CashflowDate  DATE           NULL,
    Type          VARCHAR(50)    NULL,          -- Deposit / Withdrawal / Dividend
    Amount        DECIMAL(18,2)  NULL,

    CONSTRAINT FK_Cashflows_Account FOREIGN KEY (AccountKey) REFERENCES Dim_Account(AccountKey)
);
GO

-- ------------------------------------------------------------
--  Fact_Fees
--  Grain: One row per fee charge
--  Source: stg_Fees joined with Dim_Account
-- ------------------------------------------------------------
CREATE TABLE Fact_Fees (
    FeeKey      INT            NOT NULL IDENTITY(1,1) PRIMARY KEY,
    FeeID       VARCHAR(20)    NULL,
    AccountKey  INT            NOT NULL,
    FeeDate     DATE           NULL,
    FeeType     VARCHAR(50)    NULL,            -- Transaction / Management / Advisory
    Amount      DECIMAL(18,2)  NULL,

    CONSTRAINT FK_Fees_Account FOREIGN KEY (AccountKey) REFERENCES Dim_Account(AccountKey)
);
GO

-- ------------------------------------------------------------
--  Fact_Performance
--  Grain: One row per Account × Month
--  Source: stg_Performance joined with Dim_Account + Dim_Benchmark
-- ------------------------------------------------------------
CREATE TABLE Fact_Performance (
    PerfKey              INT            NOT NULL IDENTITY(1,1) PRIMARY KEY,
    AccountKey           INT            NOT NULL,
    BenchmarkKey         INT            NOT NULL,
    MonthStart           DATE           NULL,           -- first day of the month
    ReturnPct            DECIMAL(18,6)  NULL,           -- e.g. -0.003700
    BenchmarkReturnPct   DECIMAL(18,6)  NULL,
    ExcessReturnPct      DECIMAL(18,6)  NULL,           -- ReturnPct - BenchmarkReturnPct
    CumulativeReturnPct  DECIMAL(18,6)  NULL,

    CONSTRAINT FK_Perf_Account   FOREIGN KEY (AccountKey)   REFERENCES Dim_Account(AccountKey),
    CONSTRAINT FK_Perf_Benchmark FOREIGN KEY (BenchmarkKey) REFERENCES Dim_Benchmark(BenchmarkKey)
);
GO


-- ============================================================
--  SECTION 4 : ANALYTICAL VIEWS
--  Connect to Power BI using these views -- NOT raw tables.
--  Run AFTER at least one full pipeline execution.
-- ============================================================

-- AUM by Client / Advisor / Asset Class
CREATE OR ALTER VIEW vw_AUM_Summary AS
SELECT
    c.ClientName,
    c.Segment,
    c.Country,
    c.RiskProfile,
    adv.AdvisorName,
    adv.Region           AS AdvisorRegion,
    a.AccountType,
    a.BaseCurrency,
    s.AssetClass,
    s.Sector,
    h.ValuationDate,
    SUM(h.MarketValue)   AS TotalAUM,
    SUM(h.Quantity)      AS TotalUnits
FROM  Fact_Holdings h
JOIN  Dim_Account   a   ON h.AccountKey  = a.AccountKey
JOIN  Dim_Client    c   ON a.ClientID    = c.ClientID
JOIN  Dim_Advisor   adv ON c.PrimaryAdvisorID = adv.AdvisorID
JOIN  Dim_Security  s   ON h.SecurityKey = s.SecurityKey
GROUP BY
    c.ClientName, c.Segment, c.Country, c.RiskProfile,
    adv.AdvisorName, adv.Region,
    a.AccountType, a.BaseCurrency,
    s.AssetClass, s.Sector, h.ValuationDate;
GO

-- Advisor Performance Summary
CREATE OR ALTER VIEW vw_Advisor_Performance AS
SELECT
    adv.AdvisorID,
    adv.AdvisorName,
    adv.Region,
    adv.ExperienceYears,
    AVG(p.ReturnPct)           AS AvgMonthlyReturn,
    AVG(p.ExcessReturnPct)     AS AvgExcessReturn,
    AVG(p.BenchmarkReturnPct)  AS AvgBenchmarkReturn,
    COUNT(DISTINCT p.AccountKey) AS AccountCount
FROM  Fact_Performance p
JOIN  Dim_Account a   ON p.AccountKey = a.AccountKey
JOIN  Dim_Client  c   ON a.ClientID   = c.ClientID
JOIN  Dim_Advisor adv ON c.PrimaryAdvisorID = adv.AdvisorID
GROUP BY
    adv.AdvisorID, adv.AdvisorName, adv.Region, adv.ExperienceYears;
GO

-- Fee Revenue by Type and Month
CREATE OR ALTER VIEW vw_Fee_Summary AS
SELECT
    adv.AdvisorName,
    c.Segment,
    a.AccountType,
    f.FeeType,
    YEAR(f.FeeDate)   AS FeeYear,
    MONTH(f.FeeDate)  AS FeeMonth,
    SUM(f.Amount)     AS TotalFees,
    COUNT(*)          AS FeeCount
FROM  Fact_Fees   f
JOIN  Dim_Account a   ON f.AccountKey = a.AccountKey
JOIN  Dim_Client  c   ON a.ClientID   = c.ClientID
JOIN  Dim_Advisor adv ON c.PrimaryAdvisorID = adv.AdvisorID
GROUP BY
    adv.AdvisorName, c.Segment, a.AccountType,
    f.FeeType, YEAR(f.FeeDate), MONTH(f.FeeDate);
GO

-- Net Cashflow (Inflows - Outflows) by Account
CREATE OR ALTER VIEW vw_Cashflow_Summary AS
SELECT
    c.ClientName,
    c.Segment,
    adv.AdvisorName,
    a.AccountType,
    YEAR(cf.CashflowDate)                     AS CashflowYear,
    MONTH(cf.CashflowDate)                    AS CashflowMonth,
    SUM(CASE WHEN cf.Amount > 0 THEN cf.Amount ELSE 0 END) AS TotalInflows,
    SUM(CASE WHEN cf.Amount < 0 THEN cf.Amount ELSE 0 END) AS TotalOutflows,
    SUM(cf.Amount)                            AS NetCashflow
FROM  Fact_Cashflows cf
JOIN  Dim_Account    a   ON cf.AccountKey = a.AccountKey
JOIN  Dim_Client     c   ON a.ClientID    = c.ClientID
JOIN  Dim_Advisor    adv ON c.PrimaryAdvisorID = adv.AdvisorID
GROUP BY
    c.ClientName, c.Segment, adv.AdvisorName,
    a.AccountType, YEAR(cf.CashflowDate), MONTH(cf.CashflowDate);
GO


-- ============================================================
--  SECTION 5 : QUICK VERIFICATION QUERIES
--  Run these AFTER the ADF pipeline completes to confirm data loaded.
-- ============================================================

/*
-- 1. Check staging row counts (run after Copy Activities)
SELECT 'stg_Advisors'    AS TableName, COUNT(*) AS Rows FROM stg_Advisors
UNION ALL SELECT 'stg_Clients',     COUNT(*) FROM stg_Clients
UNION ALL SELECT 'stg_Accounts',    COUNT(*) FROM stg_Accounts
UNION ALL SELECT 'stg_Securities',  COUNT(*) FROM stg_Securities
UNION ALL SELECT 'stg_Benchmarks',  COUNT(*) FROM stg_Benchmarks
UNION ALL SELECT 'stg_Holdings',    COUNT(*) FROM stg_Holdings
UNION ALL SELECT 'stg_Trades',      COUNT(*) FROM stg_Trades
UNION ALL SELECT 'stg_Cashflows',   COUNT(*) FROM stg_Cashflows
UNION ALL SELECT 'stg_Fees',        COUNT(*) FROM stg_Fees
UNION ALL SELECT 'stg_Prices',      COUNT(*) FROM stg_Prices
UNION ALL SELECT 'stg_Performance', COUNT(*) FROM stg_Performance;

-- 2. Check DWH table counts (run after Data Flows)
SELECT 'Dim_Advisor'      AS TableName, COUNT(*) AS Rows FROM Dim_Advisor
UNION ALL SELECT 'Dim_Client',       COUNT(*) FROM Dim_Client
UNION ALL SELECT 'Dim_Account',      COUNT(*) FROM Dim_Account
UNION ALL SELECT 'Dim_Security',     COUNT(*) FROM Dim_Security
UNION ALL SELECT 'Dim_Benchmark',    COUNT(*) FROM Dim_Benchmark
UNION ALL SELECT 'Fact_Holdings',    COUNT(*) FROM Fact_Holdings
UNION ALL SELECT 'Fact_Trades',      COUNT(*) FROM Fact_Trades
UNION ALL SELECT 'Fact_Cashflows',   COUNT(*) FROM Fact_Cashflows
UNION ALL SELECT 'Fact_Fees',        COUNT(*) FROM Fact_Fees
UNION ALL SELECT 'Fact_Performance', COUNT(*) FROM Fact_Performance;

-- 3. Top 5 accounts by AUM
SELECT TOP 5 ClientName, AdvisorName, AssetClass, TotalAUM
FROM vw_AUM_Summary
ORDER BY TotalAUM DESC;

-- 4. Best performing advisors
SELECT TOP 10 AdvisorName, Region, AvgMonthlyReturn, AvgExcessReturn, AccountCount
FROM vw_Advisor_Performance
ORDER BY AvgExcessReturn DESC;
*/