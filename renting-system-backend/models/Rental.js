const mongoose = require('mongoose');

const rentalSchema = new mongoose.Schema({
  userId:       { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  productId:    { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true },
  quantity:     { type: Number, required: true },
  startDate:    { type: Date, required: true },
  endDate:      { type: Date, required: true },
  totalRent:    { type: Number, required: true },
  depositPaid:  { type: Boolean, default: false },
  termsAgreed:  { type: Boolean, default: false },
  securityDeposit: {
  type: Number,
  required: true
},
totalPaid: {
  type: Number,
  required: true
},
  phone: {
  type: String,
  required: true,
  match: [/^\d{10}$/, 'Phone number must be 10 digits'] 
},
address: {
  type: String,
  required: true
},
city: { type: String, required: true },
district: { type: String, required: true },

status:       { type: String, enum: ['pending', 'approved', 'returned', 'confirmed', 'active', 'completed'], default: 'pending' }
}, { timestamps: true });

module.exports = mongoose.model('Rental', rentalSchema);
