const User = require('../models/User');
const Rental = require('../models/Rental');
const Product = require('../models/Product');

exports.getAllUsers = async (req, res) => {
  try {
    const users = await User.find({ role: 'user' }).select('-password');
    res.json(users);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getAllRentals = async (req, res) => {
  try {
    const rentals = await Rental.find()
      .populate('userId', 'firstName lastName email')
      .populate('productId', 'name');
    res.json(rentals);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
