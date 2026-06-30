package user

import (
	"context"
	"database/sql/driver"
	"fmt"
	"strconv"
	"strings"
	"time"

	"github.com/google/uuid"
)

type MemoryFragment struct {
	ID        uuid.UUID `db:"id" json:"id"`
	UserID    uuid.UUID `db:"user_id" json:"user_id"`
	Content   string    `db:"content" json:"content"`
	Embedding Vector    `db:"embedding" json:"-"`
	CreatedAt time.Time `db:"created_at" json:"created_at"`
	UpdatedAt time.Time `db:"updated_at" json:"updated_at"`
}

type Vector []float32

func (v Vector) Value() (driver.Value, error) {
	if len(v) == 0 {
		return nil, nil
	}
	var sb strings.Builder
	sb.WriteString("[")
	for i, f := range v {
		if i > 0 {
			sb.WriteString(",")
		}
		sb.WriteString(strconv.FormatFloat(float64(f), 'f', -1, 32))
	}
	sb.WriteString("]")
	return sb.String(), nil
}

func (v *Vector) Scan(src interface{}) error {
	if src == nil {
		return nil
	}
	s, ok := src.(string)
	if !ok {
		// lib/pq might return []byte
		b, ok := src.([]byte)
		if !ok {
			return fmt.Errorf("invalid type for vector: %T", src)
		}
		s = string(b)
	}

	s = strings.Trim(s, "[]")
	parts := strings.Split(s, ",")
	res := make(Vector, 0, len(parts))
	for _, p := range parts {
		p = strings.TrimSpace(p)
		if p == "" {
			continue
		}
		f, err := strconv.ParseFloat(p, 32)
		if err != nil {
			return err
		}
		res = append(res, float32(f))
	}
	*v = res
	return nil
}

func (r *Repository) AddMemory(ctx context.Context, userID uuid.UUID, content string, embedding []float32) (uuid.UUID, error) {
	id := uuid.New()
	query := `
		INSERT INTO user_memory (id, user_id, content, embedding)
		VALUES ($1, $2, $3, $4)
	`
	_, err := r.db.ExecContext(ctx, query, id, userID, content, Vector(embedding))
	return id, err
}

func (r *Repository) GetMemories(ctx context.Context, userID uuid.UUID) ([]MemoryFragment, error) {
	var fragments []MemoryFragment
	query := `SELECT id, user_id, content, created_at, updated_at FROM user_memory WHERE user_id = $1 ORDER BY created_at DESC`
	if err := r.db.SelectContext(ctx, &fragments, query, userID); err != nil {
		return nil, err
	}
	return fragments, nil
}

func (r *Repository) DeleteMemory(ctx context.Context, userID, memoryID uuid.UUID) error {
	query := `DELETE FROM user_memory WHERE id = $1 AND user_id = $2`
	_, err := r.db.ExecContext(ctx, query, memoryID, userID)
	return err
}

func (r *Repository) SearchMemory(ctx context.Context, userID uuid.UUID, queryEmbedding []float32, limit int) ([]MemoryFragment, error) {
	var fragments []MemoryFragment
	// Vector similarity search using cosine distance (<=> operator in pgvector)
	query := `
		SELECT id, user_id, content, created_at, updated_at
		FROM user_memory
		WHERE user_id = $1
		ORDER BY embedding <=> $2
		LIMIT $3
	`
	if err := r.db.SelectContext(ctx, &fragments, query, userID, Vector(queryEmbedding), limit); err != nil {
		// Fallback for non-pgvector (like SQLite) - just return latest for now to not crash
		if strings.Contains(err.Error(), "operator does not exist") || strings.Contains(err.Error(), "no such function") {
			return r.GetMemories(ctx, userID)
		}
		return nil, err
	}
	return fragments, nil
}
