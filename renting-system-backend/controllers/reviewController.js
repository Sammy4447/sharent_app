const mongoose = require('mongoose');
const Review = require('../models/Review');
const Product = require('../models/Product');
const Rental = require('../models/Rental');


exports.addReview = async (req, res) => {
  const { productId, rating, comment } = req.body;
  const userId = req.user.userId;

  try {
    //Check if user has rented this product
    const rental = await Rental.findOne({
      userId,
      'items.productId': productId
    });

    if (!rental) {
      return res.status(403).json({ message: 'You can only review products you have rented.' });
    }

    // Check if the user already reviewed this product
    const existingReview = await Review.findOne({ userId, productId });
    if (existingReview) {
      return res.status(400).json({ message: 'You have already reviewed this product.' });
    }

    // If not reviewed yet, create the review
    const review = new Review({ userId, productId, rating, comment });
    await review.save();

    // Update product rating
    await updateProductRating(productId);

    res.status(201).json({ message: 'Review added successfully.' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


exports.getReviewsForProduct = async (req, res) => {
  const { productId } = req.params;
  try {
    const reviews = await Review.find({ productId })
      .populate('userId', 'firstName lastName');
    res.json(reviews);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


// to get average rating per product

exports.getAverageRating = async (req, res) => {
  const { productId } = req.params;

  try {
    const result = await Review.aggregate([
      { $match: { productId: new mongoose.Types.ObjectId(productId) } },
      {
        $group: {
          _id: '$productId',
          averageRating: { $avg: '$rating' },
          totalReviews: { $sum: 1 }
        }
      }
    ]);

    if (result.length === 0) {
      return res.json({ averageRating: 0, totalReviews: 0 });
    }

    const { averageRating, totalReviews } = result[0];
    res.json({ averageRating, totalReviews });

  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

//to update the average rating inside the product document whenever a review is added or updated
const updateProductRating = async (productId) => {
  const reviews = await Review.find({ productId });

  const totalReviews = reviews.length;
  const averageRating = totalReviews === 0
    ? 0
    : reviews.reduce((sum, r) => sum + r.rating, 0) / totalReviews;

  await Product.findByIdAndUpdate(productId, {
    averageRating,
    totalReviews,
  });
};

// edit review 
exports.updateReview = async (req, res) => {
  const { rating, comment } = req.body;
  const reviewId = req.params.id;

  try {
    const review = await Review.findById(reviewId);
    if (!review) return res.status(404).json({ message: 'Review not found' });

    // Optional: restrict edit to owner
    if (review.userId.toString() !== req.user.userId) {
      return res.status(403).json({ message: 'Unauthorized' });
    }

    review.rating = rating ?? review.rating;
    review.comment = comment ?? review.comment;

    await review.save();
    await updateProductRating(review.productId);

    res.json({ message: 'Review updated successfully' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


//delete review 
exports.deleteReview = async (req, res) => {
  const reviewId = req.params.id;

  try {
    const review = await Review.findById(reviewId);
    if (!review) return res.status(404).json({ message: 'Review not found' });

    // Optional: restrict delete to owner
    if (review.userId.toString() !== req.user.userId) {
      return res.status(403).json({ message: 'Unauthorized' });
    }

    await Review.findByIdAndDelete(reviewId);
    await updateProductRating(review.productId);

    res.json({ message: 'Review deleted successfully' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


 