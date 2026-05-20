# aviation-disruption-analytics
# Global Civil Aviation Disruption Analysis During the 2026 Iran–US Conflict

## Project Overview

This project analyzes the operational, geopolitical, and financial impacts of the 2026 Iran–US conflict on global civil aviation.

The objective of the project was to build a complete analytical workflow capable of monitoring:

- flight cancellations,
- rerouted flights,
- airspace closures,
- airport disruptions,
- geopolitical conflict escalation,
- airline financial losses.

The project combines data engineering, dimensional modeling, and business intelligence techniques using PostgreSQL, dbt, SQL, and Power BI.

---

# Technologies Used

- PostgreSQL
- dbt (Data Build Tool)
- SQL
- Power BI
- DAX
- GitHub

---

# Data Architecture

The project follows a Star Schema architecture composed of:

## Fact Table
- dim_fact

## Dimension Tables
- dim_event
- dim_event_detail
- dim_airline
- dim_aircraft
- dim_airport
- dim_location
- dim_date
- dim_reason

The data pipeline includes:
- data cleaning,
- staging transformations,
- dimensional modeling,
- KPI creation,
- dashboard visualization.

---

# Dashboards

The Power BI solution contains multiple analytical pages:

## Conflict Analysis
Analysis of geopolitical escalation and aviation impact.

## Closure Monitoring
Analysis of airspace closures and affected flights.

## Cancellation Analysis
Monitoring cancelled flights and passenger impact.

## Reroute Analytics
Analysis of rerouting costs, delays, and additional fuel consumption.

## Disruption Monitoring
Operational disruption analysis across airports and regions.

## Financial Loss Analysis
Analysis of airline revenue loss and operational financial impact.

---

# Key Results

- More than 24,000 affected flights analyzed
- Nearly $10 billion estimated airline losses
- More than 120,000 impacted passengers
- Identification of the most affected regions and airports
- Severity escalation tracking during the conflict timeline

---

# Data Transformation with dbt

The project uses dbt for:
- staging models,
- data transformation,
- dimensional modeling,
- source management,
- schema testing.

---

# Power BI Features

- Interactive dashboards
- KPI monitoring
- Geographical analysis
- Severity trend analysis
- Operational and financial storytelling
- DAX measures and calculated metrics

---

# Repository Structure

```text
dbt/
powerbi/
data/
