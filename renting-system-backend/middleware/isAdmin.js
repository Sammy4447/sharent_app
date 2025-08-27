// middleware/isAdmin.js
module.exports = (req, res, next) => {
  if (req.user && req.user.role === 'admin') {
    return next();  // Proceed if user is admin
  } else {
    return res.status(403).json({ message: 'Access Denied. Admin Only.' });
  }
};
