# shortener

A toy URL shortener API project for trying out `haskell-servant` and `persistent` libraries.

## Configuration

The application expects a `app.cfg` file. See `app.cfg.example` for reference.

## Development

### Build

    stack build

### Tests

    docker-compose up -d
    stack test

### Run

Start:

    docker-compose up -d
    stack exec shortener-exe

Example:

    curl -X POST --header "Content-Type: application/json" --data '{"url": "a.com"}' 'localhost:8080/short'

### Formatting

Format with `hlint` and `stylish-haskell`.
