const { Pool } = require('pg');
require('dotenv').config();

// PostgreSQL SSL configuration
// Use SSL only if explicitly needed (production with RDS, etc.)
const sslConfig = process.env.DATABASE_URL && process.env.DATABASE_URL.includes('rds') 
  ? { rejectUnauthorized: false } 
  : false;

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: sslConfig,
});

pool.on('connect', () => {
  console.log('Connected to PostgreSQL database');
});

pool.on('error', (err) => {
  console.error('Database connection error:', err);
});

module.exports = {
  query: (text, params) => pool.query(text, params),
  pool,
};