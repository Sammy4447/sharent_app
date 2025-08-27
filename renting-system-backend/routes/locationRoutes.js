// routes/locationRoutes.js
const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { getCitiesAndDistricts } = require('../controllers/locationController');


router.get('/locations', auth,  getCitiesAndDistricts);


module.exports = router;
