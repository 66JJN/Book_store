# Book Store

Minimal Rails Book Store scaffold. The markup is intentionally plain so the UI can be redesigned freely.

## Features

- Sign up, sign in, and sign out
- Signed-in book catalogue with title/author/ISBN search and category filtering
- Book detail page
- Admin-only dashboard and book create, edit, delete pages
- Seeded categories, books, and two demo accounts

## Run locally

```sh
bundle install
yarn install
bin/rails db:prepare
bin/rails db:seed
bin/dev
```

Open `http://localhost:3000`.

## Demo accounts

| Role | Email | Password |
| --- | --- | --- |
| Admin | `admin@bookstore.test` | `password123` |
| Reader | `reader@bookstore.test` | `password123` |

## Main routes

- `/books` — catalogue, search, and filters
- `/books/:id` — details
- `/admin` — admin dashboard
- `/admin/books` — book CRUD for admin users
