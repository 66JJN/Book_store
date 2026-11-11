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

## Bruno API testing

1. Start the app with `bin/dev`.
2. Open Bruno and select **Open Collection**.
3. Choose the folder `bruno/book-store-api` inside this project (select the folder, not an individual `.bru` file).
4. Select the **local** environment from Bruno's environment picker.
5. Run **Authentication / Admin login success** first. Bruno keeps the Rails session cookie and uses it in later requests.
6. Run the Book, Category, Market, and User folders in sequence. Create requests generate unique example data and save temporary IDs used by their matching update/delete requests.
7. To test a failed unauthenticated request, run **Logout success**, then **Books / List books failed unauthenticated**. To test `403`, run **Users / Reader login**, then **List users failed reader forbidden**.

The collection tests success (`200`, `201`, `204`) plus common failure cases (`401`, `403`, `422`). Rerun `bin/rails db:seed` if you need to reset the seeded admin and reader accounts.
