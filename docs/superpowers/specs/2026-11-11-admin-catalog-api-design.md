# Admin Catalog and API Design

## Intent

Extend the existing Book Store training project with admin management for categories, markets, and users; connect books and markets with a many-to-many relationship; and expose a testable JSON API. Keep the existing plain ERB/Tailwind-style UI and session-based login.

## Goals

- Keep `Category` as one-to-many with `Book`: each book belongs to one category and a category has many books.
- Let only signed-in admin users create, edit, and delete categories and markets, and create users from the web UI.
- Add `Market` and a join table so a book can be assigned to many markets and a market can contain many books.
- Expose JSON endpoints for Book, Category, Market, and User.
- Supply a Bruno collection with successful and failed requests.
- Seed a known admin account, plus representative categories, books, and markets.

## Non-goals

- No redesign of the existing UI.
- No public user profile, account editing, or password-reset feature.
- No separate API token/JWT system.
- No category or market image upload.

## Approaches considered

1. **Session/cookie API (chosen).** The API login request creates the same signed session cookie used by the web pages. Bruno logs in once and sends that cookie on subsequent requests. This keeps one authentication system and matches the current Rails app.
2. **Bearer-token API.** Convenient for external clients but would require a new token lifecycle, storage, and revocation design. It is unnecessary for this course project.

## Data model

### Existing relationship

`Category has_many :books`; `Book belongs_to :category`.

The original requirement says "product", but this application names the model `Book`; no `Product` model will be introduced.

### New relationship

`Market has_many :market_books`, `has_many :books, through: :market_books`.

`Book has_many :market_books`, `has_many :markets, through: :market_books`.

`MarketBook belongs_to :market` and `belongs_to :book`, with a unique composite index to prevent a book being attached to the same market twice.

`Market` has a required, unique `name`.

## Web UI and permissions

- Extend the existing admin navigation and dashboard with links for Books, Categories, Markets, and Users.
- `Admin::CategoriesController` and `Admin::MarketsController` provide full HTML CRUD.
- `Admin::UsersController` provides only `new` and `create`, because the requested web feature is admin-only user creation. The form accepts email, password, password confirmation, and role.
- Only admins can reach all of these controllers. Non-admin signed-in users return to the book list with an alert; unauthenticated visitors go to login.
- The book form gains a multi-select/checkbox field for `market_ids`, allowing assignment to zero or more markets.
- A category or market that is still linked to books cannot be deleted; display its model validation error rather than silently deleting book relationships.

## JSON API

Prefix: `/api`.

All routes return JSON. API authentication reads the existing signed session cookie.

- `POST /api/session` accepts `email_address` and `password`, returns the signed-in user and creates the cookie. Invalid credentials return `401`.
- `DELETE /api/session` removes the session cookie and returns `204`.
- `GET /api/books`, `GET /api/books/:id`, `GET /api/categories`, `GET /api/categories/:id`, `GET /api/markets`, and `GET /api/markets/:id` require any signed-in user.
- `POST`, `PATCH`, and `DELETE` for `/api/books`, `/api/categories`, and `/api/markets` require an admin.
- `/api/users` supports `GET`, `GET /:id`, `POST`, `PATCH`, and `DELETE`, all admin-only. The create/update payload accepts email, password, password confirmation, and role. Password digests are never serialized.
- Book JSON includes its category and markets. Book write payloads accept `category_id` and `market_ids`.
- Successful reads return `200`; creates return `201`; successful deletes return `204`; malformed or invalid records return `422` with `{ errors: [...] }`; missing records return `404`; unauthenticated requests return `401`; authenticated non-admin requests return `403`.

## Bruno collection

Store a project-local collection under `bruno/Book Store API/` with an environment containing `baseUrl = http://localhost:3000`.

Folders:

- `Authentication`: admin login success, login failed, logout.
- `Books`: list/detail success, unauthenticated failed, admin create/update/delete success, invalid create failed.
- `Categories`: list success, admin create/update/delete success, duplicate/invalid create failed.
- `Markets`: list success, admin create/update/delete success, duplicate/invalid create failed.
- `Users`: admin list/detail/create success, invalid user create failed, reader forbidden failed.

Login success extracts the session cookie for the remaining requests. Requests that create temporary records save their IDs in Bruno variables so update/delete use the newly created records.

## Seed data

Keep `admin@bookstore.test` / `password123` with role `admin`; retain a reader account for forbidden API cases. Add sample markets and attach selected seeded books to them. Seeds remain idempotent.

## Acceptance checks

- Migrations create the market and join-table schema without affecting current books, categories, or users.
- Admin can manage categories and markets in HTML, create users, and assign markets to books.
- Reader cannot access admin pages or mutating/admin API endpoints.
- API produces each listed status code and JSON shape.
- Every Bruno request can run against a seeded development database after `bin/rails db:prepare db:seed` and `bin/dev`.
