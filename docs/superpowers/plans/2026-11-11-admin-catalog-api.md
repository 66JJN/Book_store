# Admin Catalog and API Implementation Plan

> **For agentic workers:** Implement each task in order, with the named tests before the implementation change.

**Goal:** Add admin catalog/user management, Markets, a session-authenticated JSON API, and a runnable Bruno collection.

**Architecture:** Extend the existing Rails session authentication with JSON-aware API base controllers that return `401` and `403` rather than HTML redirects. Add `Market` and `MarketBook`; keep `Category` related to the existing `Book` model. Use standard ERB admin views and a project-local Bruno collection.

**Tech Stack:** Rails 8.1, PostgreSQL, ERB, Minitest, Bruno.

**Spec:** `docs/superpowers/specs/2026-11-11-admin-catalog-api-design.md`

## Global Constraints

- Retain session/cookie authentication; do not add token/JWT authentication.
- Do not expose `password_digest` in API responses.
- All mutation endpoints require admin; all API reads require a signed-in session.
- JSON failure statuses: `401`, `403`, `404`, `422`.

## Review Focus

- A reader session must never mutate catalog data or enumerate users.
- Duplicate category, market, ISBN, or email data must return validation errors instead of a `500`.
- Deleting a category or market connected to books must not remove book data.
- A book update with `market_ids` must replace its market assignments correctly.
- API error paths must return JSON, never a login redirect or an HTML exception page.

### Task 1: Market persistence and book associations

**Files:** migrations, `app/models/book.rb`, `app/models/market.rb`, `app/models/market_book.rb`, `db/seeds.rb`, model tests.

- [ ] Write migration/model tests for unique market names, unique join rows, and replacing `book.market_ids`.
- [ ] Add `markets` and `market_books` tables, associations, validations, and indexes.
- [ ] Seed idempotent markets and attach seeded books.
- [ ] Run migrations, seeds, and model tests.

### Task 2: Admin HTML management

**Files:** admin controllers/views/routes/layout/book form; controller tests.

- [ ] Write controller tests for admin-only category/market CRUD and user creation, including reader rejection and linked-record delete failure.
- [ ] Add admin routes, navigation, dashboard links, controllers, basic forms/indexes, and market selection on the book form.
- [ ] Run the admin controller tests.

### Task 3: JSON API and session behavior

**Files:** `app/controllers/api/`, API routes, serializers/response helpers, request tests.

- [ ] Write request tests for session login failure/success, authenticated reads, admin mutations, 401/403/404/422 responses, and safe user serialization.
- [ ] Add API base/session/resource controllers and routes for Book, Category, Market, and User.
- [ ] Run API request tests and full test suite.

### Task 4: Bruno collection and handoff

**Files:** `bruno/Book Store API/`, `README.md`.

- [ ] Create environment, session requests, and resource requests for every required success and failed case.
- [ ] Document startup, seed accounts, Bruno import, login-cookie flow, and request run order.
- [ ] Validate route inventory, migrations/seeds, asset build, and selected API calls.
