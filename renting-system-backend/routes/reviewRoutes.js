const express = require('express');
const router = express.Router();
const { addReview, getReviewsForProduct, getAverageRating, updateReview, deleteReview } = require('../controllers/reviewController');
const auth = require('../middleware/auth');

router.post('/', auth, addReview); // user must be logged in
router.get('/:productId', getReviewsForProduct);
router.get('/average/:productId', getAverageRating);
router.put('/:id', auth, updateReview);     // Edit review
router.delete('/:id', auth, deleteReview);  // Delete review


module.exports = router;
