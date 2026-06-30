package db

import (
    "context"
    "fmt"
    "strings"
    "time"

    "github.com/jmoiron/sqlx"
    _ "github.com/lib/pq"
    _ "github.com/mattn/go-sqlite3"
)

type DB struct {
    *sqlx.DB
}

func NewDB(dsn string) (*DB, error) {
    var driver string
    if strings.HasPrefix(dsn, "postgres://") || strings.HasPrefix(dsn, "postgresql://") {
        driver = "postgres"
    } else {
        driver = "sqlite3"
    }

    db, err := sqlx.Open(driver, dsn)
    if err != nil {
        return nil, fmt.Errorf("error opening db: %w", err)
    }

    if driver == "postgres" {
        db.SetMaxOpenConns(25)
        db.SetMaxIdleConns(25)
        db.SetConnMaxLifetime(5 * time.Minute)
    }

    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
    defer cancel()

    if err := db.PingContext(ctx); err != nil {
        return nil, fmt.Errorf("error pinging db: %w", err)
    }

    return &DB{db}, nil
}

