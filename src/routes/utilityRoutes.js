const express = require('express');
const router = express.Router();
const { getAircraftAvailability } = require('../controllers/utilityController');

const asyncHandler = (fn) => (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next);

router.get('/aircraft/availability', asyncHandler(getAircraftAvailability));

module.exports = router;
