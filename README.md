# VouchDesk

> A secure, role-based Expense Voucher Management System designed for modern organizations to streamline expense claims, director approvals, digital signature workflows, and accounts auditing.

[![React](https://img.shields.io/badge/Frontend-React_18_%7C_Vite-61DAFB?logo=react&logoColor=black)](https://react.dev/)
[![Tailwind CSS](https://img.shields.io/badge/Styling-Tailwind_CSS-38B2AC?logo=tailwind-css&logoColor=white)](https://tailwindcss.com/)
[![Node.js](https://img.shields.io/badge/Backend-Node.js_Express-339933?logo=node.js&logoColor=white)](https://nodejs.org/)
[![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![JWT](https://img.shields.io/badge/Auth-JWT_%26_Bcrypt-000000?logo=json-web-tokens&logoColor=white)](https://jwt.io/)

---

## Table of Contents

1. [Overview](#overview)
2. [Project Setup Instructions](#project-setup-instructions)
   - [Prerequisites](#prerequisites)
   - [Environment Configuration](#environment-configuration)
   - [Quick Start (Windows 1-Click)](#quick-start-windows-1-click)
   - [Step-by-Step Manual Setup (All Platforms)](#step-by-step-manual-setup-all-platforms)
   - [Demo User Credentials](#demo-user-credentials)
3. [Database Schema Explanation](#database-schema-explanation)
   - [Architecture & ER Overview](#architecture--er-overview)
   - [Entity Breakdown & Schema Definitions](#entity-breakdown--schema-definitions)
   - [Auto-Incrementing Voucher Number Sequence](#auto-incrementing-voucher-number-sequence)
   - [Database Migration & Seed Script](#database-migration--seed-script)
4. [API Documentation](#api-documentation)
   - [Authentication & Session Flow](#authentication--session-flow)
   - [Auth & Profile Endpoints](#auth--profile-endpoints)
   - [Dashboard Analytics Endpoints](#dashboard-analytics-endpoints)
   - [Vouchers Endpoints](#vouchers-endpoints)
   - [Search, Filtering & Sorting Parameters](#search-filtering--sorting-parameters)
5. [Assumptions Made During Development](#assumptions-made-during-development)
6. [Key Features by Role](#key-features-by-role)
7. [Voucher Lifecycle & Workflow](#voucher-lifecycle--workflow)
8. [Project Structure](#project-structure)
9. [Submission Checklist Compliance](#submission-checklist-compliance)

---

## Overview

**VouchDesk** is an enterprise-grade Expense Voucher Management System engineered to eliminate the inefficiencies and errors of paper-based expense reporting. The system models a real-world enterprise hierarchy with strict **Role-Based Access Control (RBAC)** across three personas:

- 🧑‍💼 **Employee**: Drafts, edits, signs, and submits expense claims.
- 👔 **Director**: Evaluates pending vouchers, approving with executive signature or rejecting with feedback.
- 📑 **Accounts**: Audits organizational expenses, applies multi-criteria filters, and prints physical voucher receipts.

The application combines a modern **React 18 (Vite)** single-page application with an **Express.js** REST backend and a **PostgreSQL** relational database.

---

## Project Setup Instructions

### Prerequisites
Ensure your local development environment meets the following minimum requirements:
- **Node.js**: `v18.0.0` or higher
- **npm**: `v9.0.0` or higher
- **PostgreSQL**: `v14.0` or higher (running as a local service or remote instance)

---

### Environment Configuration

1. Copy the example environment file into `server/.env` (and optionally in project root):
   ```bash
   cd server
   cp .env.example .env
   ```

2. Open `server/.env` in your text editor and adjust credentials to match your PostgreSQL instance:
   ```env
   PORT=4000
   DATABASE_URL=postgres://postgres:your_password@localhost:5432/vouchdesk
   JWT_SECRET=vouchdesk_jwt_secret_2026
   ```

| Variable | Description | Default |
|---|---|---|
| `PORT` | Port for the Express backend server | `4000` |
| `DATABASE_URL` | PostgreSQL connection string (`postgres://<user>:<password>@<host>:<port>/<dbname>`) | `postgres://postgres:password@localhost:5432/vouchdesk` |
| `JWT_SECRET` | Secret key used to sign and verify JSON Web Tokens | `vouchdesk_jwt_secret_2026` |

---

### Quick Start (Windows 1-Click)

On Windows systems, you can launch both backend and frontend concurrently:
1. Ensure your PostgreSQL service is running and `server/.env` is configured.
2. Double-click **`start.bat`** in the repository root (or execute `.\start.bat` in PowerShell/CMD).
3. The script will automatically launch:
   - Backend API server on `http://localhost:4000`
   - Frontend Vite development server on `http://localhost:5173`
4. Access the web interface at **`http://localhost:5173`**.

---

### Step-by-Step Manual Setup (All Platforms)

#### 1. Install Dependencies
Install packages for both the server and the client:
```bash
# Install backend dependencies
cd server
npm install

# Install frontend dependencies
cd ../client
npm install
```

#### 2. Initialize and Seed the Database
Run the automated initialization and seed script:
```bash
cd server
node seed.js
```
What `seed.js` does:
- Connects to your PostgreSQL server's default database.
- Checks if the `vouchdesk` database exists and creates it automatically if it does not.
- Executes [`server/schema.sql`](server/schema.sql) to provision tables, check constraints, indexes, and sequences.
- Hashes passwords using `bcrypt` (10 salt rounds) and seeds default test users for all three roles.

#### 3. Start the Development Servers

Open two terminal sessions:

**Terminal 1 — Backend API Server:**
```bash
cd server
npm run dev
# Server starts on http://localhost:4000 (hot reload enabled via node --watch)
```

**Terminal 2 — Frontend Application:**
```bash
cd client
npm run dev
# Client starts on http://localhost:5173 (proxied to port 4000 for /api and /uploads)
```

Open **`http://localhost:5173`** in your browser to start using VouchDesk.

---

### Demo User Credentials

The following demo accounts are seeded automatically by `node seed.js`:

| Role | User Name | Email | Password | Employee Code | Intended Use |
|---|---|---|---|---|---|
| **Director** | Diana Director | `director@company.com` | `director123` | `DIR-001` | Review pending queue, sign approvals, reject vouchers |
| **Accounts** | Alice Accounts | `accounts@company.com` | `accounts123` | `ACC-001` | Organization-wide auditing, filtering & voucher printing |
| **Employee** | Bob Employee | `bob@company.com` | `employee123` | `EMP-001` | Create claims, edit drafts, upload signature, submit claims |
| **Employee** | Carol Employee | `carol@company.com` | `employee123` | `EMP-002` | Test multi-employee isolation and independent claim queues |

---

## Database Schema Explanation

The schema is defined in [`server/schema.sql`](server/schema.sql) and executed automatically via [`server/seed.js`](server/seed.js). It is normalized, enforces referential integrity through foreign keys, and protects data validity via column-level constraints.

### Architecture & ER Overview

```
 ┌─────────────────────────────────────────┐
 │                  users                  │
 ├─────────────────────────────────────────┤
 │ id                  SERIAL PRIMARY KEY  │◄────────────┐
 │ name                VARCHAR(255)        │             │
 │ email               VARCHAR(255) UNIQUE │             │
 │ password_hash       VARCHAR(255)        │             │
 │ role                VARCHAR(20)         │             │
 │ employee_code       VARCHAR(50)         │             │
 │ signature_path      VARCHAR(500)        │             │
 │ created_at          TIMESTAMP           │             │
 └─────────────────────────────────────────┘             │
                                                         │
                                                         │ 1:N
 ┌─────────────────────────────────────────┐             │
 │                vouchers                 │             │
 ├─────────────────────────────────────────┤             │
 │ id                       SERIAL PK      │             │
 │ voucher_number           VARCHAR(50) UNQ│             │
 │ voucher_date             DATE           │             │
 │ expense_date             DATE           │             │
 │ department               VARCHAR(255)   │             │
 │ expense_title            VARCHAR(255)   │             │
 │ expense_category         VARCHAR(255)   │             │
 │ description              TEXT           │             │
 │ amount                   NUMERIC(12,2)  │             │
 │ status                   VARCHAR(30)    │             │
 │ employee_id              INTEGER FK     ├─────────────┤ (Creator)
 │ employee_signature_path  VARCHAR(500)   │             │
 │ director_id              INTEGER FK     ├─────────────┘ (Reviewer)
 │ director_signature_path  VARCHAR(500)   │
 │ approval_date            TIMESTAMP      │
 │ rejection_reason         TEXT           │
 │ created_at               TIMESTAMP      │
 │ updated_at               TIMESTAMP      │
 └─────────────────────────────────────────┘
```

---

### Entity Breakdown & Schema Definitions

#### 1. `users` Table
Stores authentication credentials, persona roles, and identity metadata.

| Column | Type | Constraints | Explanation |
|---|---|---|---|
| `id` | `SERIAL` | `PRIMARY KEY` | Auto-incrementing identifier for the user. |
| `name` | `VARCHAR(255)` | `NOT NULL` | Employee or executive's full display name. |
| `email` | `VARCHAR(255)` | `NOT NULL UNIQUE` | Unique email used as the login username. |
| `password_hash` | `VARCHAR(255)` | `NOT NULL` | One-way encrypted password hash generated with `bcrypt` (10 rounds). Plaintext passwords are never stored. |
| `role` | `VARCHAR(20)` | `CHECK (role IN ('EMPLOYEE', 'DIRECTOR', 'ACCOUNTS'))` | Strict enum constraint restricting system permissions to valid personas. |
| `employee_code` | `VARCHAR(50)` | Nullable | Organization employee identifier (e.g. `EMP-001`, `DIR-001`). Displayed on voucher audit cards and printouts. |
| `signature_path` | `VARCHAR(500)` | Nullable | Relative path (e.g. `/uploads/abc.png`) to the user's default signature image on disk. |
| `created_at` | `TIMESTAMP` | `DEFAULT NOW()` | Record creation timestamp. |

#### 2. `vouchers` Table
Core transaction table tracking expense claims through their lifecycle.

| Column | Type | Constraints | Explanation |
|---|---|---|---|
| `id` | `SERIAL` | `PRIMARY KEY` | Internal database surrogate primary key. |
| `voucher_number` | `VARCHAR(50)` | `NOT NULL UNIQUE` | Public, business-facing reference code automatically generated via sequence as `VCH-YYYY-NNNN`. |
| `voucher_date` | `DATE` | `DEFAULT CURRENT_DATE` | Date the voucher record was created. Defaults to the system date. |
| `expense_date` | `DATE` | `NOT NULL` | Historical date on which the actual expenditure occurred. |
| `department` | `VARCHAR(255)` | `NOT NULL` | Submitting organizational unit (e.g. Engineering, Marketing, Sales). |
| `expense_title` | `VARCHAR(255)` | `NOT NULL` | Brief title summarizing the claim (e.g. "Client Lunch Meeting"). |
| `expense_category` | `VARCHAR(255)` | `NOT NULL` | Expense classification (Travel, Food, Accommodation, Office Supplies, etc.). |
| `description` | `TEXT` | Nullable | Additional context or justification notes from the employee. |
| `amount` | `NUMERIC(12,2)` | `CHECK (amount > 0)` | Monetary claim amount. Uses fixed-point numeric representation to avoid floating-point inaccuracies. Constrained to positive values. |
| `status` | `VARCHAR(30)` | `CHECK (status IN ('DRAFT', 'PENDING_APPROVAL', 'APPROVED', 'REJECTED'))` | Current lifecycle state. Defaults to `DRAFT`. |
| `employee_id` | `INTEGER` | `REFERENCES users(id)` | Foreign key identifying the employee who authored the voucher. Enforces user isolation. |
| `employee_signature_path` | `VARCHAR(500)` | Nullable | Disk path to the submitter's digital signature captured at submission. |
| `director_id` | `INTEGER` | `REFERENCES users(id)` | Foreign key identifying the director who approved or rejected the voucher. |
| `director_signature_path` | `VARCHAR(500)` | Nullable | Disk path to the director's signature captured during the approval action. |
| `approval_date` | `TIMESTAMP` | Nullable | Exact timestamp when director approved the voucher. |
| `rejection_reason` | `TEXT` | Nullable | Compulsory explanation recorded when a director rejects a voucher. |
| `created_at` | `TIMESTAMP` | `DEFAULT NOW()` | Timestamp of record creation. |
| `updated_at` | `TIMESTAMP` | `DEFAULT NOW()` | Timestamp of the most recent record modification. |

---

### Auto-Incrementing Voucher Number Sequence

To avoid race conditions and generate human-readable, sequential identifiers, a PostgreSQL sequence `voucher_number_seq` is utilized:

```sql
CREATE SEQUENCE IF NOT EXISTS voucher_number_seq START 1;
```

In the `vouchers` table definition, the default value evaluates:
```sql
DEFAULT ('VCH-' || TO_CHAR(NOW(), 'YYYY') || '-' || LPAD(NEXTVAL('voucher_number_seq')::TEXT, 4, '0'))
```
This guarantees unique, sequentially padded identifiers such as `VCH-2026-0001`, `VCH-2026-0002`, independent of transaction rollbacks or concurrent inserts.

---

### Database Migration & Seed Script

The complete migration and seed logic lives in [`server/seed.js`](server/seed.js). It is idempotent:
- Connects to `postgres` to ensure target database creation.
- Applies [`server/schema.sql`](server/schema.sql) with `CREATE TABLE IF NOT EXISTS` clauses.
- Applies `ON CONFLICT (email) DO NOTHING` when inserting seed users to prevent duplication on multiple runs.

---

## API Documentation

All API routes are prefixed with `/api`. Protected routes require the standard Authorization Bearer header:
```http
Authorization: Bearer <jwt_token>
```

### Authentication & Session Flow

- **Login**: `POST /api/auth/login` verifies email and bcrypt password hash, then issues a signed JWT token containing `{ id, role, email }` with a 24-hour expiration.
- **Client Storage**: The token is stored in `localStorage` and automatically appended to outgoing requests via [`client/src/api.js`](client/src/api.js).
- **Session Expiry**: When a request encounters an HTTP 401 response, client-side session storage is cleared and the user is redirected to `/login`.

---

### Auth & Profile Endpoints

#### 1. Authenticate User
- **Method / Path**: `POST /api/auth/login`
- **Access**: Public
- **Request Body**:
  ```json
  {
    "email": "director@company.com",
    "password": "director123"
  }
  ```
- **Success Response (`200 OK`)**:
  ```json
  {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 1,
      "name": "Diana Director",
      "email": "director@company.com",
      "role": "DIRECTOR",
      "employee_code": "DIR-001",
      "signature_path": null
    }
  }
  ```
- **Error Responses**: `400 Bad Request` (missing fields), `401 Unauthorized` (invalid credentials).

#### 2. Get Current Authenticated Profile
- **Method / Path**: `GET /api/auth/me`
- **Access**: Any Authenticated Role
- **Success Response (`200 OK`)**:
  ```json
  {
    "id": 1,
    "name": "Diana Director",
    "email": "director@company.com",
    "role": "DIRECTOR",
    "employee_code": "DIR-001",
    "signature_path": "/uploads/a8f2...png",
    "created_at": "2026-10-12T11:45:00.000Z"
  }
  ```

#### 3. Upload User Profile Signature
- **Method / Path**: `POST /api/auth/signature`
- **Access**: Any Authenticated Role
- **Content-Type**: `multipart/form-data`
- **Form Field**: `signature` (image file: `.png`, `.jpg`, `.jpeg`, max 2MB)
- **Success Response (`200 OK`)**:
  ```json
  {
    "signature_path": "/uploads/4f19b26e0ca117.png"
  }
  ```

---

### Dashboard Analytics Endpoints

#### Get Role-Tailored Dashboard Metrics
- **Method / Path**: `GET /api/dashboard`
- **Access**: Any Authenticated Role
- **Responses (Role-Specific)**:
  - **`EMPLOYEE`**:
    ```json
    {
      "total": "4",
      "draft": "1",
      "pending": "1",
      "approved": "2",
      "rejected": "0",
      "total_amount_claimed": "14500.00"
    }
    ```
  - **`DIRECTOR`**:
    ```json
    {
      "pending_count": "3",
      "approved_today": "2",
      "rejected_today": "1",
      "total_pending_amount": "28400.00",
      "last_activity": [
        {
          "id": 5,
          "voucher_number": "VCH-2026-0005",
          "status": "APPROVED",
          "updated_at": "2026-10-12T12:00:00.000Z",
          "employee_name": "Bob Employee",
          "amount": "3200.00"
        }
      ]
    }
    ```
  - **`ACCOUNTS`**:
    ```json
    {
      "total": "12",
      "pending": "3",
      "approved": "8",
      "rejected": "1",
      "total_approved_amount": "94200.00",
      "last_approved": [
        {
          "id": 4,
          "voucher_number": "VCH-2026-0004",
          "amount": "8900.00",
          "approval_date": "2026-10-12T11:15:00.000Z",
          "employee_name": "Carol Employee"
        }
      ]
    }
    ```

---

### Vouchers Endpoints

| Method | Endpoint | Allowed Role(s) | Description |
|---|---|---|---|
| `GET` | `/api/vouchers` | All Roles | List vouchers matching role context & filters |
| `GET` | `/api/vouchers/:id` | All Roles | Fetch single voucher details with creator & director info |
| `POST` | `/api/vouchers` | `EMPLOYEE` | Create a new voucher in `DRAFT` status |
| `PUT` | `/api/vouchers/:id` | `EMPLOYEE` | Update an existing `DRAFT` voucher (author only) |
| `DELETE` | `/api/vouchers/:id` | `EMPLOYEE` | Delete an existing `DRAFT` voucher (author only) |
| `POST` | `/api/vouchers/:id/submit` | `EMPLOYEE` | Submit `DRAFT` for director approval (requires signature) |
| `POST` | `/api/vouchers/:id/approve` | `DIRECTOR` | Approve `PENDING_APPROVAL` voucher (requires signature) |
| `POST` | `/api/vouchers/:id/reject` | `DIRECTOR` | Reject `PENDING_APPROVAL` voucher (requires reason) |

#### 1. Create Voucher Draft
- **`POST /api/vouchers`** (Role: `EMPLOYEE`)
- **Body**:
  ```json
  {
    "expense_date": "2026-10-10",
    "department": "Engineering",
    "expense_title": "Annual AWS Cloud Architecture Summit",
    "expense_category": "Travel",
    "description": "Registration ticket and round-trip transport.",
    "amount": "12500.00"
  }
  ```
- **Response (`201 Created`)**: Returns newly created voucher record with `status: "DRAFT"`.

#### 2. Submit Voucher for Approval
- **`POST /api/vouchers/:id/submit`** (Role: `EMPLOYEE`)
- **Content-Type**: `multipart/form-data`
- **Form Field**: `signature` *(optional if employee already has a profile signature)*
- **Response (`200 OK`)**: Updates status to `PENDING_APPROVAL` and records `employee_signature_path`.

#### 3. Approve Voucher
- **`POST /api/vouchers/:id/approve`** (Role: `DIRECTOR`)
- **Content-Type**: `multipart/form-data`
- **Form Field**: `signature` *(required)*
- **Response (`200 OK`)**: Updates status to `APPROVED`, records `director_id`, `director_signature_path`, and `approval_date: NOW()`.

#### 4. Reject Voucher
- **`POST /api/vouchers/:id/reject`** (Role: `DIRECTOR`)
- **Body**:
  ```json
  {
    "rejection_reason": "Receipt was missing VAT breakdown. Please re-submit with full invoice."
  }
  ```
- **Response (`200 OK`)**: Updates status to `REJECTED`, records `director_id` and `rejection_reason`.

---

### Search, Filtering & Sorting Parameters

`GET /api/vouchers` supports the following query parameters:

| Parameter | Type | Example | Description |
|---|---|---|---|
| `search` | String | `?search=VCH-2026` | Case-insensitive substring match against `voucher_number` or `expense_title`. |
| `status` | String | `?status=PENDING_APPROVAL` | Filter by `DRAFT`, `PENDING_APPROVAL`, `APPROVED`, or `REJECTED`. |
| `department` | String | `?department=Marketing` | Partial match on department name. |
| `category` | String | `?category=Travel` | Exact match on expense category. |
| `employeeName` | String | `?employeeName=Bob` | Filter by employee name (applicable for Director and Accounts). |
| `dateFrom` | Date | `?dateFrom=2026-10-01` | Filter expenses occurring on or after date (`YYYY-MM-DD`). |
| `dateTo` | Date | `?dateTo=2026-10-31` | Filter expenses occurring on or before date (`YYYY-MM-DD`). |
| `minAmount` | Number | `?minAmount=1000` | Filter expenses with amount $\ge$ min. |
| `maxAmount` | Number | `?maxAmount=50000` | Filter expenses with amount $\le$ max. |
| `sortBy` | String | `?sortBy=amount` | Sort column: `created_at`, `updated_at`, `amount`, `voucher_date`, `expense_date`, or `voucher_number`. |
| `order` | String | `?order=asc` | Sorting direction: `asc` or `desc` (default: `desc`). |

---

## Assumptions Made During Development

1. **Workflow State Mapping**:
   - "Submitted" and "Pending Approval" describe the identical state (`PENDING_APPROVAL`). When an employee submits their voucher, it transitions immediately from `DRAFT` to `PENDING_APPROVAL`. There is no intermediate multi-tier queue.

2. **Draft Ownership & Data Privacy**:
   - Vouchers in `DRAFT` status are private to the employee who created them.
   - Other employees, Directors, and Accounts cannot see or query draft vouchers created by someone else.
   - Only the creator of a voucher can modify (`PUT`) or delete (`DELETE`) it, and only while it remains in `DRAFT` state.

3. **Immutability of Terminal Decisions**:
   - Once a voucher is marked as `APPROVED` or `REJECTED`, its core details (amount, category, department, dates) become permanently **read-only** across all roles to ensure an unalterable audit trail.
   - A rejected voucher cannot be re-opened; if corrections are required, the employee submits a new claim referencing the previous claim.

4. **Digital Signature Handling**:
   - Employees may upload a reusable signature to their account profile or provide a signature upon submission.
   - Directors must provide an explicit signature at the time of each approval action to confirm executive review of that specific claim.
   - Signature files are stored on disk in `server/uploads/` with 32-character cryptographically random filenames to prevent overwrite collisions and path traversal attacks.

5. **Mandatory Rejection Feedback**:
   - Directors cannot reject a voucher without submitting a non-empty `rejection_reason`. This ensures accountability and clear feedback for the submitting employee.

6. **Accounts Persona Role & Printing**:
   - The `ACCOUNTS` persona serves an auditing and record-keeping function. Accounts users have read-only visibility into all non-draft vouchers across the organization.
   - Accounts cannot approve or reject vouchers. They are provided a dedicated print action (`window.print()`) with print-optimized CSS rules to generate paper receipts or PDF records.

7. **Monetary Precision & Currency**:
   - Amounts are stored using PostgreSQL `NUMERIC(12, 2)` to eliminate floating-point arithmetic errors. All claims are displayed with two decimal places formatted in INR (₹). Amounts must be strictly positive (`> 0`).

---

## Key Features by Role

| Feature | Employee | Director | Accounts |
|---|:---:|:---:|:---:|
| Create & Save Voucher Drafts | ✅ | ❌ | ❌ |
| Edit & Delete Own Drafts | ✅ | ❌ | ❌ |
| Submit Voucher with Signature | ✅ | ❌ | ❌ |
| View Own Voucher History | ✅ | ❌ | ❌ |
| View Pending Approvals Queue | ❌ | ✅ | ❌ |
| Approve Vouchers (with Signature) | ❌ | ✅ | ❌ |
| Reject Vouchers (with Reason) | ❌ | ✅ | ❌ |
| View All Company Vouchers | ❌ | ✅ | ✅ |
| Advanced Multi-Field Filtering & Sorting | ✅ *(own)* | ✅ *(all)* | ✅ *(all)* |
| Print Formal Voucher Document | ❌ | ❌ | ✅ |
| Role-Tailored Metrics Dashboard | ✅ | ✅ | ✅ |

---

## Voucher Lifecycle & Workflow

```mermaid
flowchart TD
    A([Employee Creates Claim]) --> B[DRAFT]
    B -->|Edit / Delete| B
    B -->|Attach Signature & Submit| C[PENDING_APPROVAL]
    C -->|Director Review| D{Decision}
    D -->|Upload Signature & Approve| E[APPROVED]
    D -->|Provide Rejection Reason| F[REJECTED]
    E --> G([Accounts Auditing & Printing])
    F --> H([Read-only Record])
```

---

## Project Structure

```
VouchDesk/
├── .env.example                # Root environment template
├── .gitignore                  # Git ignore rules
├── README.md                   # Complete system documentation
├── start.bat                   # 1-Click launcher for Windows
├── server/                     # Backend Express.js REST API
│   ├── .env.example            # Backend environment template
│   ├── index.js                # App bootstrap & static file routes
│   ├── db.js                   # PostgreSQL connection pool
│   ├── schema.sql              # Database schema & sequence creation
│   ├── seed.js                 # Automatic DB creator & demo user seeder
│   ├── middleware.js           # JWT auth, role validation & multer upload
│   ├── package.json            # Backend scripts and dependencies
│   ├── routes/
│   │   ├── auth.js             # Authentication & signature endpoints
│   │   ├── vouchers.js         # Voucher CRUD, submission & approval endpoints
│   │   └── dashboard.js        # Aggregated role-based dashboard statistics
│   └── uploads/                # Local storage directory for digital signatures
└── client/                     # Frontend Vite + React application
    ├── index.html              # Single page entry HTML
    ├── vite.config.js          # Vite config with API proxy
    ├── tailwind.config.js      # Tailwind CSS configuration
    ├── package.json            # Frontend scripts and dependencies
    └── src/
        ├── main.jsx            # React root DOM mount
        ├── App.jsx             # Navigation bar & protected routes
        ├── AuthContext.jsx      # Global auth context & token storage
        ├── api.js              # Fetch client with automatic JWT header
        ├── styles.css          # Styles and print stylesheet (@media print)
        ├── components/ui/      # Reusable UI primitives
        └── pages/
            ├── Login.jsx       # Authentication login screen
            ├── Dashboard.jsx   # Role-based dashboard analytics cards
            ├── VoucherForm.jsx # Expense entry, draft saving & submit form
            ├── VoucherList.jsx # Multi-field filterable voucher table
            └── VoucherDetails.jsx # Detailed voucher view, director action & print
```

---

## Submission Checklist Compliance

This repository fulfills all stated assignment submission requirements:

| Submission Requirement | Repository Location / Verification |
|---|---|
| **GitHub Repository** | Contains full, runnable source code for both client and server. |
| **Project Setup Instructions** | Included in [Project Setup Instructions](#project-setup-instructions) with prerequisites, 1-click Windows launcher, and cross-platform manual steps. |
| **Database Schema Explanation** | Included in [Database Schema Explanation](#database-schema-explanation) with ER diagram, constraints, sequence explanation, and column definitions. |
| **API Documentation** | Included in [API Documentation](#api-documentation) detailing endpoints, request/response bodies, query parameters, and auth headers. |
| **Assumptions Made During Development** | Included in [Assumptions Made During Development](#assumptions-made-during-development) detailing workflow states, role boundaries, immutability, and signatures. |
| **Database Schema or Migration Files** | Provisioned in [`server/schema.sql`](server/schema.sql) and executed via [`server/seed.js`](server/seed.js). |
| **`.env.example` File** | Included in both [`.env.example`](.env.example) (root) and [`server/.env.example`](server/.env.example). |
| **Screenshots / Demo Walkthrough** | UI components, print styles, and role workflows can be tested directly with the pre-seeded [Demo Credentials](#demo-user-credentials). |

---

## License

This project is licensed under the [MIT License](LICENSE).
