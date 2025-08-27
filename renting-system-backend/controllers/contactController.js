const Contact = require('../models/Contact');
const User = require('../models/User');

exports.submitContactForm = async (req, res) => {
  const { message } = req.body;
  const userId = req.user.userId;

  try {
    if (!message) {
      return res.status(400).json({ message: 'Message is required.' });
    }

    // Get user's name and email from database
    const user = await User.findById(userId).select('firstName lastName email');
    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

    const newContact = new Contact({
      userId,
      name: `${user.firstName} ${user.lastName}`,
      email: user.email,
      message,
    });

    await newContact.save();
    res.status(201).json({ message: 'Your message has been submitted successfully!' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

