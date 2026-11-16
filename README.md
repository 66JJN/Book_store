# Book Store

Rails Book Store project with authentication, book search/filter, admin CRUD, JSON API, and Bruno requests.

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

Open the `bruno/book-store-api` folder in Bruno and select the `local` environment. `password` (the seeded admin/reader password) and `newUserPassword` are secret variables: set them in Bruno's environment settings, they are not stored in the repo. Run **Admin login success** before other protected API requests.
