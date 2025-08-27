const User = require('../models/User');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const Rental = require('../models/Rental');
const Cart = require('../models/Cart');

// SIGNUP ROUTE
exports.signup = async (req, res) => {
  try {
    const { firstName, lastName, email, password, isAdmin } = req.body;

    // Basic field validation
    if (!firstName || !lastName || !email || !password) {
      return res.status(400).json({ message: 'All fields are required.' });
    }

// Name validation (only letters, spaces, hyphens, apostrophes)
   const nameRegex = /^(?!.*(.)\1{2,})[A-Za-z][A-Za-z\s\-']{1,19}$/;
    if (!firstName || !nameRegex.test(firstName)) {
      return res.status(400).json({ message: 'Invalid first name. Use only letters, spaces, hyphens, or apostrophes. and do not repeat letters more than twice' });
    }
    if (!lastName || !nameRegex.test(lastName)) {
      return res.status(400).json({ message: 'Invalid last name. Use only letters, spaces, hyphens, or apostrophes. and do not repeat letters more than twice' });
    }

// Email format validation - Only allow gmail.com
const emailRegex = /^[a-zA-Z0-9](\.?[a-zA-Z0-9_-]){5,63}@gmail\.com$/;;
if (!emailRegex.test(email)) {
  return res.status(400).json({ message: 'Only Gmail addresses are allowed.' });
}

// Password strength validation (minimum 8 characters, at least one letter and one number and one special character)
   const passwordRegex = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
if (!passwordRegex.test(password)) {
  return res.status(400).json({ message: 'Password must be at least 8 characters long and include letters, numbers, and special characters.' });
}

// Create user (password is hashed in pre-save middleware)
    const newUser = new User({
      firstName,
      lastName,
      email,
      password,
      isAdmin: isAdmin || false
    });

    await newUser.save();

    res.status(201).json({ message: 'User registered successfully' });

  } catch (err) {
  if (err.name === 'ValidationError') {
    const messages = Object.values(err.errors).map(e => e.message);
    return res.status(400).json({ message: messages.join(', ') });
  }
    // Handle duplicate email
    if (err.code === 11000) {
      const field = Object.keys(err.keyValue)[0];
      return res.status(400).json({ message: `${field} already exists.` });
    }

    res.status(500).json({ message: 'Something went wrong during registration.' });
  }
};


// LOGIN LOGIC
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Find the user by email
    const user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ message: 'Invalid email or password' });
    }

    // Log the password comparison for debugging
    console.log('Password from user input:', password);
    console.log('Hashed password from DB:', user.password);

    // Compare the hashed password with the input password
    const isMatch = await bcrypt.compare(password, user.password);
    console.log('Password match result:', isMatch);

    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid email or password' });
    }

    // If passwords match, generate JWT token
    const token = jwt.sign({ userId: user._id, role: user.isAdmin ? 'admin' : 'user' }, process.env.JWT_SECRET, {
      expiresIn: '7d'
    });

    res.status(200).json({
      token,
      user: { firstName: user.firstName, lastName: user.lastName, email: user.email, isAdmin: user.isAdmin }
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: err.message });
  }
};


//update profile 

exports.updateProfile = async (req, res) => {
  const userId = req.user.userId;
  const { firstName, lastName, email, phone, address, password, oldPassword } = req.body;

  try {
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: 'User not found.' });

    const updates = {};

    // First name & Last name
    if (firstName) updates.firstName = firstName.trim();
    if (lastName) updates.lastName = lastName.trim();

    // Email validation and uniqueness
    if (email) {
      const emailRegex = /^[a-zA-Z0-9](\.?[a-zA-Z0-9_-]){5,63}@gmail\.com$/;
      if (!emailRegex.test(email)) {
        return res.status(400).json({ message: 'Invalid email format.' });
      }

      const existingEmailUser = await User.findOne({ email });
      if (existingEmailUser && existingEmailUser._id.toString() !== userId) {
        return res.status(400).json({ message: 'Email already in use.' });
      }

      updates.email = email;
    }

    // Phone validation and uniqueness
    if (phone) {
      const phoneRegex = /^(98|97)\d{8}$/;
      if (!phoneRegex.test(phone)) {
        return res.status(400).json({ message: 'Invalid phone number. Must be 10 digits.' });
      }

      const existingPhoneUser = await User.findOne({ phone });
      if (existingPhoneUser && existingPhoneUser._id.toString() !== userId) {
        return res.status(400).json({ message: 'Phone number already in use.' });
      }

      updates.phone = phone;
    }

    // Address
    if (address) updates.address = address.trim();

    // Password update: require old password to verify first
    if (password) {
      if (!oldPassword) {
        return res.status(400).json({ message: 'Old password is required to change your password.' });
      }
    
      const isMatch = await bcrypt.compare(oldPassword, user.password);
      if (!isMatch) {
        return res.status(400).json({ message: 'Old password is incorrect.' });
      }
    
      const passwordRegex = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
      if (!passwordRegex.test(password)) {
        return res.status(400).json({
          message: 'New password must be at least 8 characters long and include at least one letter, one number, and one special character (@$!%*?&).'
        });
      }
    
      updates.password = await bcrypt.hash(password, 10); // <- only after validation
    }
    

    // Apply updates
    const updatedUser = await User.findByIdAndUpdate(
      userId,
      { $set: updates },
      { new: true, runValidators: true }
    );

    res.json({ message: 'Profile updated', user: updatedUser });
  } catch (error) {
    console.error('Profile update error:', error);

    // Mongoose validation error catch
    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map(err => err.message);
      return res.status(400).json({ message: messages.join(', ') });
    }

    res.status(500).json({ message: 'Failed to update profile' });
  }
};

// delete profile


exports.deleteAccount = async (req, res) => {
  const userId = req.user.userId;
  const { password } = req.body;

  try {
    // 1. Find user
    const user = await User.findById(userId);
    if (!user) return res.status(404).json({ message: 'User not found' });

    // 2. Compare password
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(400).json({ message: 'Incorrect password' });

    // 3. Clean up user-related data (optional but good practice)
    await Rental.deleteMany({ userId });
    await Cart.deleteOne({ userId });

    // 4. Delete user account
    await User.findByIdAndDelete(userId);

    res.json({ message: 'Account and related data deleted successfully' });

  } catch (error) {
    console.error('Delete account error:', error);
    res.status(500).json({ message: 'Failed to delete account' });
  }
};

