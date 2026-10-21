# Enterprise Inventory Engine & Microservice

<div align="center">

<p align="center">
  <img src="https://img.shields.io/badge/Framework-Hono_v4-E36002?style=for-the-badge&logo=hono&logoColor=white" alt="Hono"/>
  <img src="https://img.shields.io/badge/API_Spec-OpenAPI_%2F_Swagger-85EA2D?style=for-the-badge&logo=swagger&logoColor=black" alt="OpenAPI"/>
  <img src="https://img.shields.io/badge/Validation-Zod_v4-3E67B1?style=for-the-badge&logo=zod&logoColor=white" alt="Zod"/>
  <img src="https://img.shields.io/badge/Database-MariaDB_%7C_MySQL2-003545?style=for-the-badge&logo=mariadb&logoColor=white" alt="MariaDB"/>
  <img src="https://img.shields.io/badge/Frontend-Svelte_UI-FF3E00?style=for-the-badge&logo=svelte&logoColor=white" alt="Svelte"/>
  <img src="https://img.shields.io/badge/Testing-Jest_%26_Supertest-C21325?style=for-the-badge&logo=jest&logoColor=white" alt="Jest"/>
</p>

**A high-throughput enterprise inventory microservice and reactive management console.**  
Powered by Hono, type-safe Zod OpenAPI schemas, MariaDB/MySQL stored procedures, and a responsive Svelte frontend.

</div>

---

## 🌟 Architecture & Features

- **Blazing-Fast Microservice:** Engineered with **Hono v4** running on Node Server with sub-millisecond route dispatch and modular middleware.
- **Contract-First OpenAPI Documentation:** Fully interactive Swagger UI generated automatically via `@hono/zod-openapi` and strict Zod runtime request/response validation.
- **High-Performance Stored Procedures:** Database heavy-lifting handled directly in MariaDB / MySQL via optimized stored procedures:
  - `getInventoryItem_proc.sql`: Multi-dimensional item classification, stock levels, and pricing.
  - `getItemImage_proc.sql`: Binary/URL asset resolution for inventory cataloging.
- **Reactive Svelte Console:** Dedicated frontend interface (`inventory-svelte-ui/`) for warehouse staff and stock managers.
- **Automated Test Coverage:** Complete integration and unit test suite built with Jest, Supertest, and TypeScript (`ts-jest`).

---

## 📁 Repository Structure

```
inventory-testing/
├── src/                           # Hono microservice routes, schemas & handlers
│   ├── routes/                    # API route definitions & OpenAPI endpoints
│   ├── schemas/                   # Zod request / response contracts
│   └── handlers/                  # Business logic & DB execution
├── inventory-svelte-ui/           # Svelte frontend management client
├── *.sql                          # Stored procedure definitions and database schemas
├── project_specs/                 # Architectural specifications & requirements
├── run-inventory.sh               # Concurrent development runner script
├── wrangler.toml                  # Cloudflare Workers deployment config
└── package.json                   # Server dependencies & scripts
```

---

## 🚀 Getting Started

### Prerequisites

- [Node.js](https://nodejs.org/) (v18+)
- MySQL 8.0+ or MariaDB 10.5+ instance

### Database Setup

```bash
# Execute schema and procedure definitions in your database
mysql -u root -p your_database < recreate_proc.sql
mysql -u root -p your_database < getInventoryItem_proc.sql
mysql -u root -p your_database < getItemImage_proc.sql
```

### Installation & Development

```bash
# Install backend dependencies
npm install

# Configure environment
cp .env.example .env  # configure DB credentials

# Run development server with watch mode
npm run start

# Or launch backend and frontend concurrently:
npm run dev:all
```

### Testing

```bash
# Run unit and integration tests
npm test

# Generate test coverage report
npm run test:coverage
```

---

## 📄 License

Proprietary © Medy Villarias. All rights reserved.
