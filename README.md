# Book Store

Rails Book Store project with authentication, book search/filter, admin CRUD, JSON API, and Bruno requests.

## Run

```sh
bundle install
yarn install
bin/rails db:prepare
bin/dev
```

Open `http://localhost:3000`.

Set the seed account environment variables provided separately before running `bin/rails db:seed`.

## Bruno

Open the `bruno/book-store-api` folder in Bruno and select the `local` environment. Add the account variables provided separately, then run **Admin login success** before other protected API requests.
