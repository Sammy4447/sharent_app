const express = require('express');
const router = express.Router();
const { getAllUsers, getAllRentals } = require('../controllers/adminController');

const auth = require('../middleware/auth');
const isAdmin = require('../middleware/isAdmin');

router.get('/users', auth, isAdmin, getAllUsers);          // View all users
router.get('/rentals', auth, isAdmin, getAllRentals);      // View all rental history

module.exports = router;
