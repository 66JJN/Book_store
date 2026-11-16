# Book Store

Rails Book Store project with authentication, book search/filter, admin CRUD, JSON API, and Bruno requests.

## Requirements

- Ruby 4.0.9 (see `.ruby-version`), Node.js + Yarn
- PostgreSQL running locally (databases `book_store_development` / `book_store_test` are created by `db:prepare`)

## Run

```sh
bundle install
yarn install
cp .env.example .env   # fill in ADMIN_* and READER_* (passwords: 6+ characters)
bin/rails db:prepare
bin/rails db:seed
bin/dev
```

Open `http://localhost:3000`.


## Auth and admin

| Gem | Used for |
|---|---|
| Devise | Sign in / sign up / forgot password / my account (`/users/...`), and the API login cookie |
| Rolify | Roles `admin` and `reader` (new users become `reader`) |
| Pundit | `app/policies`: readers can browse the catalog, only admins can change it |
| ActiveAdmin v4 | `/admin` (admins only): books, categories, markets, users + roles, dashboard |

The JSON API still uses `email_address` and a single `role` field (`"user"` or `"admin"`).

Guests can browse books; the JSON API always needs a login. Emails sent in development
(password reset) are not really sent: read them at `http://localhost:3000/letter_opener`.

## Bruno

1. Create the collection's own env file (git-ignored) and fill it in:
   ```sh
   cp bruno/book-store-api/.env.example bruno/book-store-api/.env
   ```
   `ADMIN_PASSWORD` / `READER_PASSWORD` must match the project `.env`; `NEW_USER_PASSWORD` is any 6+ characters.
2. Open the `bruno/book-store-api` folder in Bruno (reopen it after editing `.env`) and select the `local` environment.
3. Start the app with `bin/dev`, then right-click the collection and choose **Run**: it logs in first and logs out last (folder `zz-logout`), so all 30 requests pass in one run.

## Tests

```sh
bin/rails test
```
