const express = require('express');
const userRoutes = require('./routes/userRoutes');
const memberRoutes = require('./routes/memberRoutes');
const aircraftRoutes = require('./routes/aircraftRoutes');
const reservationsRoutes = require('./routes/reservationsRoutes');
const flightLogsRoutes = require('./routes/flightLogsRoutes');
const billingRoutes = require('./routes/billingRoutes');
const utilityRoutes = require('./routes/utilityRoutes');
const pool = require('./config/database');
const bodyParser = require('body-parser');

const app = express();
const cors = require('cors');

app.use(cors({
  origin: [
    'http://localhost:4200',        // For local development
    'https://aviation-club-scheduler.vercel.app' // For Vercel deployment
  ],
  credentials: true
}));

// Middleware
app.use(express.json());
app.use(bodyParser.json());

// Routes
app.use('/api/users', userRoutes);
app.use('/api/members', memberRoutes);
app.use('/api/aircraft', aircraftRoutes);
app.use('/api/reservations', reservationsRoutes);
app.use('/api/flight-logs', flightLogsRoutes);
app.use('/api/billing', billingRoutes);
app.use('/api', utilityRoutes);

// Middleware for error handling
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    error: 'Internal server error',
    message: err.message
  });
});

module.exports = app;
