const express = require('express');
const router = express.Router();
const {
  placeRental,
  getUserRentals
} = require('../controllers/rentalController');

const {
  addToCart,
  getCart,
  removeCartItem 
} = require('../controllers/cartController');

const auth = require('../middleware/auth');

router.post('/cart', auth, addToCart);
router.get('/cart', auth, getCart);
router.delete('/cart', auth, removeCartItem );

//user ley rent ma lina lai
router.post('/rent', auth, placeRental);

// Get user's rental history
router.get('/my-rentals', auth, getUserRentals);

module.exports = router;
