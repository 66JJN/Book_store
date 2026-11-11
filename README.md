# Book Store

Minimal Rails Book Store scaffold. The markup is intentionally plain so the UI can be redesigned freely.

## Features

- Admin-created user accounts, sign in, and sign out
- Signed-in book catalogue with title/author/ISBN search and category filtering
- Book detail page
- Admin-only dashboard and book create, edit, delete pages
- Admin-only Category, Market, and User create, edit, delete pages
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
| Admin | `admin@bks.test` | `1234` |
| Reader | `user@bks.test` | `1234` |

## Main routes

- `/books` — catalogue, search, and filters
- `/books/:id` — details
- `/admin` — admin dashboard
- `/admin/books` — book CRUD for admin users
- `/admin/categories` — category CRUD for admin users
- `/admin/markets` — market CRUD for admin users
- `/admin/users` — user CRUD for admin users

## Bruno API testing

1. Start the app with `bin/dev`.
2. Open Bruno and select **Open Collection**.
3. Choose the folder `bruno/book-store-api` inside this project (select the folder, not an individual `.bru` file).
4. Select the **local** environment from Bruno's environment picker.
5. Run **Authentication / Admin login success** first. Bruno keeps the Rails session cookie and uses it in later requests.
6. Run **Categories / List categories success** and **Markets / List markets success** first. These requests set the category and market IDs used by the Book requests. Then run the Book, Category, Market, and User folders in sequence. Create requests generate unique example data and save temporary IDs used by their matching update/delete requests.
7. To test a failed unauthenticated request, run **Logout success**, then **Books / List books failed unauthenticated**. To test `403`, run **Users / Reader login**, then **List users failed reader forbidden**.

The collection tests success (`200`, `201`, `204`) plus common failure cases (`401`, `403`, `422`). Rerun `bin/rails db:seed` if you need to reset the seeded admin and reader accounts.

## Reviewer checklist

```sh
bundle install
yarn install
bin/rails db:prepare
bin/rails db:seed
bin/dev
```

Then open `http://localhost:3000`, sign in as `admin@bks.test` with password `1234`, and visit `/admin`.

- `/admin/books` — add, edit, and delete books
- `/admin/categories` — add, edit, and delete categories
- `/admin/markets` — add, edit, and delete markets
- `/admin/users` — add, edit, and delete users (the signed-in admin cannot delete itself)
- `bruno/book-store-api` — open this folder as a Bruno collection and select the `local` environment
