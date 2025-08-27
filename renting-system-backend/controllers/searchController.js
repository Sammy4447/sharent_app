const Product = require('../models/Product');

exports.searchAndFilterProducts = async (req, res) => {
  const { name, categoryId, subcategoryId, minRent, maxRent, inStockOnly } = req.query;

  const filter = {};

  if (name) {
    filter.name = { $regex: name, $options: 'i' };
  }


  if (categoryId) {
    filter.category = { $regex: categoryId, $options: 'i' };
  }

  if (subcategoryId) {
    filter.subcategory = { $regex: subcategoryId, $options: 'i' };
  }
  
  if (minRent || maxRent) {
    filter.rentPerDay = {};
    if (minRent) filter.rentPerDay.$gte = Number(minRent);
    if (maxRent) filter.rentPerDay.$lte = Number(maxRent);
  }

  if (inStockOnly === 'true') {
    filter.stock = { $gt: 0 };
  }

  try {
    const products = await Product.find(filter).populate('category').populate('subcategory');
    res.json(products);
  } catch (err) {
    res.status(500).json({ message: "Failed to fetch products", error: err.message });
  }
};
