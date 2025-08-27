const express = require('express');
const router = express.Router();
const cartController = require('../controllers/cartController');
const auth = require('../middleware/auth'); // <-- import auth

// Placeholder route
router.get('/', (req, res) => {
  res.send('Cart routes will go here');
});

// All routes below use auth middleware to ensure user is logged in

// Add item to cart
router.post('/add', auth, cartController.addToCart);

// Get cart by user ID
router.get('/:userId', auth, cartController.getCart);

// Update item quantity in cart
router.put('/update', auth, cartController.updateCartItem);

// Remove item from cart
router.delete('/remove', auth, cartController.removeCartItem);

// Clear entire cart
router.delete('/clear/:userId', auth, cartController.clearCart);

module.exports = router;
