const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { submitContactForm } = require('../controllers/contactController');

// Only logged-in users can submit contact form
router.post('/contact', auth, submitContactForm);

module.exports = router;
