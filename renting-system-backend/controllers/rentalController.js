const Cart = require('../models/Cart');
const Rental = require('../models/Rental');
const Product = require('../models/Product');
const locations = require('../models/location');

exports.placeRental = async (req, res) => {
  const { products, startDate, endDate, termsAgreed, phone, address, city, district } = req.body;
  const userId = req.user.userId;
   
// Validation for cities and districts
const validDistricts = locations.map(loc => loc.district);
const validCities = locations.flatMap(loc => loc.cities);


  if (!termsAgreed) {
    return res.status(400).json({ message: 'You must agree to terms and conditions.' });
  }
//phone number validation
  if (!phone || !/^(98|97)\d{8}$/.test(phone)) {
  return res.status(400).json({ message: 'Invalid Nepali phone number. Must start with 98 or 97 and be 10 digits long.' });
}

//address validation
if (!address || address.trim().length < 25 || !/(street|road|near|opposite|house|tole|marg)/i.test(address)) {
  return res.status(400).json({
    message: 'Please enter a complete address including street, landmark, or nearby location (minimum 25 characters).'
  });
}

// City validation
if (!city || !validCities.includes(city)) {
  return res.status(400).json({
    message: 'Invalid or missing city. Please choose a valid city.'
  });
}

// District validation
if (!district || !validDistricts.includes(district)) {
  return res.status(400).json({
    message: 'Invalid or missing district. Please choose a valid district.'
  });
}

  const now = new Date();
  if (new Date(startDate) < now || new Date(endDate) <= new Date(startDate)) {
    return res.status(400).json({ message: 'Invalid rental dates.' });
  }

  if (!Array.isArray(products) || products.length === 0) {
    return res.status(400).json({ message: 'No products specified for rental.' });
  }

  try {
    const cart = await Cart.findOne({ userId }).populate('items.productId');
    if (!cart || cart.items.length === 0) {
      return res.status(400).json({ message: 'Cart is empty.' });
    }

    const rentals = [];

    for (const requestedProduct of products) {
      const { productId, quantity } = requestedProduct;

      if (!productId || !quantity || isNaN(quantity)) {
        return res.status(400).json({ message: 'Invalid product ID or quantity.' });
      }

      const cartItem = cart.items.find(item => item.productId && item.productId._id.toString() === productId);

      if (!cartItem) {
        return res.status(400).json({ message: `Product not found in cart.` });
      }

      if (cartItem.quantity < quantity) {
        return res.status(400).json({ message: `You only have ${cartItem.quantity} of this item in your cart.` });
      }

      const product = cartItem.productId;

      if (product.quantityAvailable < quantity) {
        return res.status(400).json({ message: `Insufficient quantity for ${product.name}` });
      }

     
const days = Math.ceil((new Date(endDate) - new Date(startDate)) / (1000 * 60 * 60 * 24));
const totalRent = days * product.rentPerDay * quantity;
const securityDeposit = Math.ceil(totalRent * 0.3);
const totalPaid = totalRent + securityDeposit;


// Determine rental status
      let status = 'pending';
      const today = new Date();
      if (new Date(startDate) <= today && new Date(endDate) >= today) {
        status = 'active';
      } else if (new Date(startDate) > today) {
        status = 'confirmed';
      } else if (new Date(endDate) < today) {
        status = 'completed';
      }

  
const rental = new Rental({
  userId,
  productId,
  quantity,
  startDate,
  endDate,
  totalRent,
  securityDeposit,   // Save 30% of rent
  totalPaid,               // Save total amount user is paying
  depositPaid: true,
  termsAgreed,
  status,
  phone,
  address,
  city,
  district
});


      rentals.push(rental.save());

// Update product
      product.quantityAvailable -= quantity;
      product.bookingsCount = (product.bookingsCount || 0) + quantity;
      await product.save();

// Update cart: reduce quantity or remove item
      if (cartItem.quantity > quantity) {
        cartItem.quantity -= quantity;
      } else {
        // remove item if fully rented
        cart.items = cart.items.filter(item => item.productId._id.toString() !== productId);
      }
    }

    await cart.save();
    await Promise.all(rentals);

    res.status(201).json({ message: 'Rental placed successfully.' });

  } catch (err) {
    console.error('Rental error:', err);
    res.status(500).json({ message: 'Something went wrong while placing the rental.' });
  }
};

//to get rental history
exports.getUserRentals = async (req, res) => {
  const userId = req.user.userId;

  try {
    const rentals = await Rental.find({ userId })
      .populate('productId', 'name image rentPerDay quantityAvailable description') // Fetch name, image, rent info and quantityAvailable
      .sort({ createdAt: -1 }); // Most recent first

    res.json(rentals);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};