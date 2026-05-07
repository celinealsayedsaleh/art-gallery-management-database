# Art Gallery Management Database

A PostgreSQL database design project for an art gallery management system. The system manages users, artists, collectors, curators, galleries, artworks, editions, listings, offers, orders, shipments, insurance plans, and exhibitions.

## Project Overview

This project covers the full database design process, starting from conceptual modeling and ending with SQL implementation. It includes an ER diagram, relational schema, table creation scripts, indexing, views, stored procedures, and a trigger for business logic.

## Technologies Used

- PostgreSQL
- SQL
- ERD Modeling
- Relational Database Design

## Database Features

- Normalized relational database schema
- Primary key and foreign key constraints
- User specialization into Artist, Collector, and Curator
- Weak entity implementation for Shipment
- Many-to-many relationship tables
- Indexes for foreign keys and query performance
- Views for reporting and listing overview
- Stored procedures for listing expiration, shipment creation, and artist social links
- Trigger to automatically reject other pending offers when one offer is accepted

## Repository Structure

```text
art-gallery-management-database/
│
├── README.md
│
├── sql/
│   ├── 01_schema.sql
│   ├── 02_indexes.sql
│   ├── 03_views.sql
│   ├── 04_procedures.sql
│   └── 05_trigger.sql
│
└── diagrams/
    ├── erd.png
    └── relational-schema.png
