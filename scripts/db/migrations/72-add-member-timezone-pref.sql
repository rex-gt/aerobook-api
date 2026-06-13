-- Migration: Add timezone_pref column to members table
-- Issue: #72

-- 1. Add the column with a default of 'local'
-- Using IF NOT EXISTS makes the script idempotent (runnable multiple times safely)
ALTER TABLE members ADD COLUMN IF NOT EXISTS timezone_pref VARCHAR(50) DEFAULT 'local';

-- 2. Ensure all existing rows have the default value
UPDATE members SET timezone_pref = 'local' WHERE timezone_pref IS NULL;

-- 3. Verify the change (optional, just for logging in psql)
DO $$
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM information_schema.columns 
        WHERE table_name='members' AND column_name='timezone_pref'
    ) THEN
        RAISE NOTICE '✓ Column timezone_pref successfully added to members table.';
    ELSE
        RAISE EXCEPTION '❌ Column timezone_pref was not added.';
    END IF;
END $$;
