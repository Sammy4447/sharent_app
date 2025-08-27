const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { signup, login } = require('../controllers/authController');
const { updateProfile, deleteAccount } = require('../controllers/authController');

// POST /api/auth/signup
router.post('/signup', signup);

// POST /api/auth/login
router.post('/login', login);

//update profile and delete account
router.put('/me', auth, updateProfile);
router.delete('/me', auth, deleteAccount);

module.exports = router;
