# Maven Movies – Store, Inventory, and Revenue Analysis

## Project Overview
This project analyzes operational and financial performance for a two-store movie rental business using SQL. The goal is to evaluate store performance, inventory exposure, customer value, and content coverage to support data-driven operational and strategic decisions.

---

## Business Questions Addressed
- Which store is performing better in terms of rentals and revenue?
- How efficiently is inventory being utilized at each store?
- Where is inventory value concentrated, and what category risks exist?
- Which film categories generate strong revenue relative to inventory cost?
- Who are the most valuable customers, and how concentrated is revenue?
- How do rentals and revenue trend over time?
- How well does the catalog cover highly awarded actors?

---

## Key Analyses
- **Store performance scorecard:** rentals, revenue, average rental rate, and active spending customers  
- **Inventory exposure:** inventory mix by rating and category, replacement cost concentration  
- **Revenue efficiency:** revenue per inventory item and revenue per inventory dollar  
- **Customer analysis:** active customers, lifetime rentals, and total spend  
- **Seasonality:** monthly rentals and revenue by store  
- **Strategic content coverage:** percentage of award-winning actors represented in inventory  

---

## Tools & Technologies
- **SQL (MySQL / MySQL Workbench)**
- **Power BI**

---

## Data Model Notes
- Revenue is measured as the sum of rental payments collected.
- Inventory replacement cost is used as a proxy for inventory exposure.
- Efficiency metrics are calculated using store-level aggregates.
- Some metrics are derived in Power BI to maintain clean query grains and avoid double counting.

---

## Repository Contents
- `maven_movies_store_and_inventory_analysis.sql`  
  Contains all SQL queries used for store performance, inventory, customer, and strategic analyses.
- `README.md`  
  Project context, scope, and methodology.

---

## Status
Analysis complete. Visualizations and a stakeholder-style summary in progress.
