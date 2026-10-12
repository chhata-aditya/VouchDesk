# VouchDesk

> Expense Voucher Management System with role-based access control (Employee, Director, Accounts) for expense claim submission, digital signatures, director approvals, and accounts auditing.

---

## Table of Contents

- [Project Setup Instructions](#project-setup-instructions)
  - [Prerequisites](#prerequisites)
  - [Environment Configuration](#environment-configuration)
  - [Database Initialization & Seeding](#database-initialization--seeding)
  - [Running the Application](#running-the-application)
  - [Demo User Credentials](#demo-user-credentials)
- [Database Schema Explanation](#database-schema-explanation)
  - [Entity Relationship Overview](#entity-relationship-overview)
  - [Table Definitions](#table-definitions)
  - [Voucher Number Generation](#voucher-number-generation)
- [API Documentation](#api-documentation)
  - [Authentication](#authentication)
  - [Auth Endpoints](#auth-endpoints)
  - [Dashboard Endpoints](#dashboard-endpoints)
  - [Voucher Endpoints](#voucher-endpoints)
  - [Voucher Query Parameters](#voucher-query-parameters)
- [Assumptions Made During Development](#assumptions-made-during-development)
- [Project Structure](#project-structure)

---

## Project Setup Instructions

### Prerequisites
- **Node.js**: v18.0.0 or higher
- **npm**: v9.0.0 or higher
- **PostgreSQL**: v14.0 or higher (running locally or accessible via network)

---

### Environment Configuration

1. Create a `.env` file in the `server` directory by copying the provided template:
   ```bash
   cd server
   cp .env.example .env
   ```

2. Open `server/.env` and update the PostgreSQL connection details to match your local setup:
   ```env
   PORT=4000
   DATABASE_URL=postgres://postgres:your_password@localhost:5432/vouchdesk
   JWT_SECRET=vouchdesk_jwt_secret_2026
   ```

| Variable | Description | Default |
|---|---|---|
| `PORT` | Backend server port | `4000` |
| `DATABASE_URL` | PostgreSQL connection URL | `postgres://postgres:password@localhost:5432/vouchdesk` |
| `JWT_SECRET` | Secret key for signing and verifying JWT tokens | `vouchdesk_jwt_secret_2026` |

*(A matching `.env.example` is also located in the project root for reference.)*

---

### Database Initialization & Seeding

Run the seed script from the `server` directory:
```bash
cd server
node seed.js
```

This automated script will:
1. Connect to the default PostgreSQL database.
2. Check if the `vouchdesk` database exists and create it if necessary.
3. Execute [`server/schema.sql`](server/schema.sql) to create tables, constraints, and sequences.
4. Hash passwords using `bcrypt` and seed initial accounts for each role (`DIRECTOR`, `ACCOUNTS`, `EMPLOYEE`).

---

### Running the Application

#### Option A: Quick Start (Windows 1-Click)
If you are on Windows:
1. Double-click **`start.bat`** (or execute `.\start.bat` in PowerShell / Command Prompt).
2. The batch script starts both the backend API server and the frontend client in separate windows.
3. Open **`http://localhost:5173`** in your browser.

#### Option B: Manual Setup (Cross-Platform)

1. **Install dependencies**:
   ```bash
   # Install server dependencies
   cd server
   npm install

   # Install client dependencies
   cd ../client
   npm install
   ```

2. **Start the backend server**:
   ```bash
   cd server
   npm run dev
   # Runs on http://localhost:4000
   ```

3. **Start the frontend client** (in a separate terminal):
   ```bash
   cd client
   npm run dev
   # Runs on http://localhost:5173
   ```

4. Navigate to **`http://localhost:5173`** in your web browser.

---

### Demo User Credentials

The database seeder pre-configures test accounts for each role:

| Role | Name | Email | Password | Employee Code | Notes |
|---|---|---|---|---|---|
| **Director** | Diana Director | `director@company.com` | `director123` | `DIR-001` | Review, sign approvals, reject with reason |
| **Accounts** | Alice Accounts | `accounts@company.com` | `accounts123` | `ACC-001` | Organization-wide viewing & voucher printing |
| **Employee** | Bob Employee | `bob@company.com` | `employee123` | `EMP-001` | Create claims, edit drafts, submit with signature |
| **Employee** | Carol Employee | `carol@company.com` | `employee123` | `EMP-002` | Additional employee for multi-user testing |

---

## Database Schema Explanation

The schema is defined in [`server/schema.sql`](server/schema.sql). It enforces referential integrity through foreign keys, validates data with check constraints, and uses sequences for identifier generation.

### Entity Relationship Overview

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

### Table Definitions

#### `users` Table
Stores user accounts, hashed credentials, and role privileges.

| Column | Type | Constraints | Description |
|---|---|---|---|
| `id` | `SERIAL` | `PRIMARY KEY` | Unique numeric identifier for the user. |
| `name` | `VARCHAR(255)` | `NOT NULL` | User full name. |
| `email` | `VARCHAR(255)` | `NOT NULL UNIQUE` | User login email. |
| `password_hash` | `VARCHAR(255)` | `NOT NULL` | `bcrypt` hash (10 salt rounds) of the password. Plaintext is never stored. |
| `role` | `VARCHAR(20)` | `CHECK (role IN ('EMPLOYEE', 'DIRECTOR', 'ACCOUNTS'))` | User role controlling accessible routes and actions. |
| `employee_code` | `VARCHAR(50)` | Nullable | Organization employee identifier (e.g. `EMP-001`). |
| `signature_path` | `VARCHAR(500)` | Nullable | File path to user's saved default signature image in `uploads/`. |
| `created_at` | `TIMESTAMP` | `DEFAULT NOW()` | Record creation timestamp. |

#### `vouchers` Table
Stores expense claims, review states, digital signature references, and audit logs.

| Column | Type | Constraints | Description |
|---|---|---|---|
| `id` | `SERIAL` | `PRIMARY KEY` | Internal database surrogate key. |
| `voucher_number` | `VARCHAR(50)` | `NOT NULL UNIQUE` | Unique reference code generated as `VCH-YYYY-NNNN`. |
| `voucher_date` | `DATE` | `DEFAULT CURRENT_DATE` | Date the voucher was created. |
| `expense_date` | `DATE` | `NOT NULL` | Date when the expense occurred. |
| `department` | `VARCHAR(255)` | `NOT NULL` | Submitting department (e.g. Engineering, Sales). |
| `expense_title` | `VARCHAR(255)` | `NOT NULL` | Short title summarizing the expense claim. |
| `expense_category` | `VARCHAR(255)` | `NOT NULL` | Category (Travel, Food, Accommodation, Office Supplies, etc.). |
| `description` | `TEXT` | Nullable | Optional detailed notes from the submitter. |
| `amount` | `NUMERIC(12,2)` | `CHECK (amount > 0)` | Claim amount; uses fixed-point `NUMERIC` to avoid floating-point errors. Must be $> 0$. |
| `status` | `VARCHAR(30)` | `CHECK (status IN ('DRAFT', 'PENDING_APPROVAL', 'APPROVED', 'REJECTED'))` | Current lifecycle state (defaults to `DRAFT`). |
| `employee_id` | `INTEGER` | `REFERENCES users(id)` | Foreign key referencing the creating employee. |
| `employee_signature_path` | `VARCHAR(500)` | Nullable | Path to employee signature image attached on submission. |
| `director_id` | `INTEGER` | `REFERENCES users(id)` | Foreign key referencing the director who approved or rejected. |
| `director_signature_path` | `VARCHAR(500)` | Nullable | Path to director signature image attached on approval. |
| `approval_date` | `TIMESTAMP` | Nullable | Timestamp of director approval. |
| `rejection_reason` | `TEXT` | Nullable | Mandatory justification text provided upon rejection. |
| `created_at` | `TIMESTAMP` | `DEFAULT NOW()` | Record creation timestamp. |
| `updated_at` | `TIMESTAMP` | `DEFAULT NOW()` | Record last modification timestamp. |

---

### Voucher Number Generation

Voucher numbers are generated using a PostgreSQL sequence (`voucher_number_seq`):

```sql
CREATE SEQUENCE IF NOT EXISTS voucher_number_seq START 1;
```

The `vouchers` table default expression formats this sequence into a human-readable identifier:
```sql
DEFAULT ('VCH-' || TO_CHAR(NOW(), 'YYYY') || '-' || LPAD(NEXTVAL('voucher_number_seq')::TEXT, 4, '0'))
```

This ensures unique, zero-padded identifiers (e.g. `VCH-2026-0001`, `VCH-2026-0002`) generated at the database level, preventing collision during concurrent submissions.

---

## API Documentation

Base URL: `http://localhost:4000/api`

### Authentication
Protected endpoints require a JSON Web Token sent in the authorization header:
```http
Authorization: Bearer <token>
```
Tokens are generated upon login and expire after 24 hours.

---

### Auth Endpoints

| Method | Endpoint | Auth Required | Description |
|---|---|---|---|
| `POST` | `/api/auth/login` | No | Authenticates user; returns JWT token and user info |
| `GET` | `/api/auth/me` | Yes (Any role) | Returns current authenticated user profile |
| `POST` | `/api/auth/signature` | Yes (Any role) | Uploads profile signature image (`multipart/form-data`) |

#### `POST /api/auth/login`
- **Request Body**:
  ```json
  {
    "email": "bob@company.com",
    "password": "employee123"
  }
  ```
- **Response (`200 OK`)**:
  ```json
  {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "user": {
      "id": 3,
      "name": "Bob Employee",
      "email": "bob@company.com",
      "role": "EMPLOYEE",
      "employee_code": "EMP-001",
      "signature_path": null
    }
  }
  ```

---

### Dashboard Endpoints

#### `GET /api/dashboard`
- **Auth Required**: Yes (Any role)
- **Description**: Returns role-tailored summary statistics.
- **Responses by Role**:
  - **Employee**: Total count, count by status (`draft`, `pending`, `approved`, `rejected`), and `total_amount_claimed`.
  - **Director**: `pending_count`, `approved_today`, `rejected_today`, `total_pending_amount`, and list of 5 recent decisions (`last_activity`).
  - **Accounts**: Total count, status counts, `total_approved_amount`, and list of 5 recently approved vouchers (`last_approved`).

---

### Voucher Endpoints

| Method | Endpoint | Allowed Roles | Description |
|---|---|---|---|
| `GET` | `/api/vouchers` | Any | List vouchers (filtered by role and query params) |
| `GET` | `/api/vouchers/:id` | Any | Fetch single voucher details by ID |
| `POST` | `/api/vouchers` | `EMPLOYEE` | Create a new voucher in `DRAFT` status |
| `PUT` | `/api/vouchers/:id` | `EMPLOYEE` | Update a `DRAFT` voucher (author only) |
| `DELETE` | `/api/vouchers/:id` | `EMPLOYEE` | Delete a `DRAFT` voucher (author only) |
| `POST` | `/api/vouchers/:id/submit` | `EMPLOYEE` | Submit `DRAFT` for approval with signature |
| `POST` | `/api/vouchers/:id/approve` | `DIRECTOR` | Approve pending voucher with signature file |
| `POST` | `/api/vouchers/:id/reject` | `DIRECTOR` | Reject pending voucher with reason |

#### `POST /api/vouchers`
- **Request Body**:
  ```json
  {
    "expense_date": "2026-10-10",
    "department": "Engineering",
    "expense_title": "Cloud Server Hosting",
    "expense_category": "Office Supplies",
    "description": "Monthly compute and storage costs.",
    "amount": "4500.00"
  }
  ```
- **Response (`201 Created`)**: Returns the created voucher with `status: "DRAFT"`.

#### `POST /api/vouchers/:id/submit`
- **Content-Type**: `multipart/form-data`
- **Field**: `signature` (optional if employee has saved profile signature).
- **Response (`200 OK`)**: Transitions voucher to `PENDING_APPROVAL` and stores `employee_signature_path`.

#### `POST /api/vouchers/:id/approve`
- **Content-Type**: `multipart/form-data`
- **Field**: `signature` (image file required).
- **Response (`200 OK`)**: Transitions voucher to `APPROVED`, records `director_id`, `director_signature_path`, and `approval_date`.

#### `POST /api/vouchers/:id/reject`
- **Request Body**:
  ```json
  {
    "rejection_reason": "Receipt was missing itemized tax breakdown."
  }
  ```
- **Response (`200 OK`)**: Transitions voucher to `REJECTED`, records `director_id` and `rejection_reason`.

---

### Voucher Query Parameters

`GET /api/vouchers` supports the following query parameters:

| Parameter | Type | Description |
|---|---|---|
| `search` | String | Case-insensitive match on `voucher_number` or `expense_title` |
| `status` | String | Filter by status (`DRAFT`, `PENDING_APPROVAL`, `APPROVED`, `REJECTED`) |
| `department` | String | Partial match on department name |
| `category` | String | Exact match on expense category |
| `employeeName` | String | Substring match on submitter name (Director & Accounts only) |
| `dateFrom` | Date (`YYYY-MM-DD`) | Filter expense date $\ge$ specified date |
| `dateTo` | Date (`YYYY-MM-DD`) | Filter expense date $\le$ specified date |
| `minAmount` | Number | Filter vouchers with amount $\ge$ min |
| `maxAmount` | Number | Filter vouchers with amount $\le$ max |
| `sortBy` | String | Column to sort by (`created_at`, `updated_at`, `amount`, `voucher_date`, `expense_date`, `voucher_number`) |
| `order` | String | Sort order: `asc` or `desc` (default: `desc`) |

---

## Assumptions Made During Development

1. **Status Progression ("Submitted" vs. "Pending Approval")**:
   - The statuses "Submitted" and "Pending Approval" describe the same lifecycle phase (`PENDING_APPROVAL`). When an employee submits a voucher, it moves directly from `DRAFT` to `PENDING_APPROVAL` without an intermediate queue.

2. **Draft Access & Privacy**:
   - Vouchers in `DRAFT` status are visible only to the employee who created them. Directors and Accounts users do not see draft vouchers in lists or dashboard metrics.
   - Only the creating employee can update (`PUT`) or delete (`DELETE`) a voucher, and only while it is in `DRAFT` status.

3. **Immutability of Final States**:
   - Once a voucher reaches a terminal status (`APPROVED` or `REJECTED`), its data cannot be modified or deleted by any user or role. This guarantees a reliable audit trail.

4. **Digital Signature Rules**:
   - Employees can submit a voucher using either a pre-saved profile signature or by uploading a fresh signature at submission time.
   - Directors must upload their signature freshly at the time of each approval to confirm explicit executive sign-off.
   - Uploaded signatures are saved locally in `server/uploads/` with 32-character randomized filenames to prevent collisions and path traversal.

5. **Mandatory Rejection Reason**:
   - A voucher cannot be rejected without providing an explanatory `rejection_reason`. This ensures the employee receives clear feedback on why the claim was denied.

6. **Accounts Role Responsibilities**:
   - The Accounts role has read-only access to all non-draft vouchers across the organization for auditing purposes.
   - Accounts personnel cannot approve or reject vouchers.
   - Accounts personnel can view and print approved vouchers using the built-in print layout (`window.print()`) formatted via print-specific CSS.

7. **Monetary Precision & Currency**:
   - Amounts are represented using `NUMERIC(12, 2)` to avoid IEEE floating-point inaccuracies. All amounts are displayed in INR (₹) and must be strictly positive (`> 0`).

---

## Project Structure

```
VouchDesk/
├── .env.example                # Root environment template
├── .gitignore                  # Git ignore rules
├── README.md                   # Project documentation
├── start.bat                   # 1-Click launcher for Windows
├── server/                     # Backend Express.js REST API
│   ├── .env.example            # Server environment template
│   ├── index.js                # Express app entry point
│   ├── db.js                   # PostgreSQL connection pool
│   ├── schema.sql              # Database schema & sequence definitions
│   ├── seed.js                 # Database initialization & user seeder
│   ├── middleware.js           # JWT auth, role validation & multer upload
│   ├── package.json            # Server dependencies and scripts
│   ├── routes/
│   │   ├── auth.js             # Authentication & profile routes
│   │   ├── vouchers.js         # Voucher CRUD, submission, approval routes
│   │   └── dashboard.js        # Dashboard metric aggregation routes
│   └── uploads/                # Directory for uploaded signature images
└── client/                     # Frontend Vite + React application
    ├── index.html              # HTML entry point
    ├── vite.config.js          # Vite config with API proxy
    ├── tailwind.config.js      # Tailwind CSS configuration
    ├── package.json            # Client dependencies and scripts
    └── src/
        ├── main.jsx            # React root mount
        ├── App.jsx             # Router, navbar & protected route guards
        ├── AuthContext.jsx      # Authentication context & session storage
        ├── api.js              # Fetch wrapper with JWT injection
        ├── styles.css          # Global styling & print stylesheet
        ├── components/ui/      # UI components
        └── pages/
            ├── Login.jsx       # Login view
            ├── Dashboard.jsx   # Role-based dashboard view
            ├── VoucherForm.jsx # Voucher creation & draft edit view
            ├── VoucherList.jsx # Filterable voucher list view
            └── VoucherDetails.jsx # Voucher detail view, approval actions & print
```
