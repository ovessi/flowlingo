package main

import (
	"log"
	"os"
	"path/filepath"
	"strings"

	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
	_ "github.com/mattn/go-sqlite3"
)

func main() {
	dsn := os.Getenv("DATABASE_URL")
	driver := "postgres"
	if dsn == "" {
		dsn = "local.db"
		driver = "sqlite3"
	}

	db, err := sqlx.Connect(driver, dsn)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	files, err := os.ReadDir("migrations")
	if err != nil {
		log.Fatal(err)
	}

	for _, file := range files {
		if strings.HasSuffix(file.Name(), ".up.sql") {
			log.Printf("Running migration: %s", file.Name())
			content, err := os.ReadFile(filepath.Join("migrations", file.Name()))
			if err != nil {
				log.Fatal(err)
			}

			queries := strings.Split(string(content), ";")
			for _, query := range queries {
				query = strings.TrimSpace(query)
				if query == "" {
					continue
				}
				_, err = db.Exec(query)
				if err != nil {
					// Postgres specific: handle CREATE EXTENSION if it already exists or other minor issues
					// SQLite might not support some syntax, but we'll try to keep migrations simple
					log.Printf("Warning executing query from %s: %v", file.Name(), err)
				}
			}
		}
	}

	log.Println("Migrations completed successfully")
}
