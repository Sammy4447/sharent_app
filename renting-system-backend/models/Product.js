//Handling String References

const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  name: { type: String, required: true ,trim: true },
  category: { type: String, required: true },
  subcategory: { type: String},
  stock: { type: Number, required: true },
  quantityAvailable: {
    type: Number,
    required: true,
    default: 0,
    validate: {
      validator: function(value) {
        return !isNaN(value) && value >= 0;  // Ensuring it's a number and not negative
      },
      message: 'Invalid quantityAvailable value'
    }
  },
  rentPerDay: { type: Number, required: true },
  securityDeposit: { type: Number},
  description: { type: String },
  image: { type: String, required:true}, // URL or base64 string
  timesRented: { type: Number, default: 0 },
  bookingsCount: { type: Number, default: 0 }, 
  averageRating: { type: Number, default: 0 },
  totalReviews: { type: Number, default: 0 },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Product', productSchema);

