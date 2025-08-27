const mongoose = require('mongoose');
const Category = require('../models/Category');
const Subcategory = require('../models/Subcategory');
const Product = require('../models/Product');

// ----------- CATEGORY -----------

exports.createCategory = async (req, res) => {
  try {
    const { name } = req.body;
    const category = new Category({ name });
    await category.save();
    res.status(201).json(category);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

exports.getCategories = async (req, res) => {
  try {
    const categories = await Category.find();
    res.json(categories);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};




// ----------- SUBCATEGORY -----------

exports.createSubcategory = async (req, res) => {
  try {
    const { name, categoryId } = req.body;
    const subcategory = new Subcategory({ name, categoryId });
    await subcategory.save();
    res.status(201).json(subcategory);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

exports.getSubcategoriesByCategory = async (req, res) => {
  try {
    const subcategories = await Subcategory.find({ categoryId: req.params.categoryId });
    res.json(subcategories);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


//products

exports.createProduct = async (req, res) => {
  try {
    const { name, category, subcategory, description, rentPerDay, securityDepsit, stock, image } = req.body;
    
    const imagePath = req.file ? req.file.path : '';
    
const product = new Product({
  name: req.body.name,
  category: req.body.category,
  subcategory: req.body.subcategory,
  stock: parseInt(req.body.stock),
  quantityAvailable: parseInt(req.body.quantityAvailable),
  rentPerDay: parseFloat(req.body.rentPerDay),
  securityDeposit: parseFloat(req.body.securityDeposit),
  description: req.body.description,
  image: imagePath
});

await product.save();
res.status(201).json(product);
} catch (err) {
  res.status(400).json({ message: err.message });
}
};


exports.getProductsBySubcategory = async (req, res) => {
  try {
    const products = await Product.find({ subcategoryId: req.params.subcategoryId });
    res.json(products);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


exports.getProductById = async (req, res) => {
  try {
    const product = await Product.findById(req.params.productId);
    if (!product) return res.status(404).json({ message: "Product not found" });
    res.json(product);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


exports.getProductsByCategoryName = async (req, res) => {
  try {
    const categoryName = req.params.categoryName;

    const products = await Product.find({
      category: { $regex: new RegExp('^' + categoryName + '$', 'i') }
    });    
    res.json(products);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};


// GET all products /api/products
exports.getAllProducts = async (req, res) => {
  try {
     const products = await Product.find();
    res.status(200).json(products);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};




// Create a controller method to fetch most booked items
exports.getMostBookedProducts = async (req, res) => {
  try {
    // const products = await Product.find().sort({ timesRented: -1 }).limit(10);
    const products = await Product.find().sort({ bookingsCount: -1 }).limit(10);
    res.json(products);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Create a controller method to fetch newly added items
exports.getNewlyAddedProducts = async (req, res) => {
  try {
    const products = await Product.find()
      .sort({ createdAt: -1 }) // Newest first
      .limit(10); // Optional: limit to latest 10 products

    res.json(products);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Delete Category, Subcategory, and Product
exports.deleteCategory = async (req, res) => {
  try {
    await Category.findByIdAndDelete(req.params.categoryId);
    await Subcategory.deleteMany({ categoryId: req.params.categoryId }); // optional: clean subcategories
    await Product.deleteMany({ category: req.params.categoryId }); // optional: clean products
    res.json({ message: 'Category and related data deleted' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.deleteSubcategory = async (req, res) => {
  try {
    await Subcategory.findByIdAndDelete(req.params.subcategoryId);
    await Product.deleteMany({ subcategory: req.params.subcategoryId }); // optional: clean products
    res.json({ message: 'Subcategory and related products deleted' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.deleteProduct = async (req, res) => {
  try {
    await Product.findByIdAndDelete(req.params.productId);
    res.json({ message: 'Product deleted successfully' });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Update Category, Subcategory, and Product
exports.updateCategory = async (req, res) => {
  try {
    const updated = await Category.findByIdAndUpdate(
      req.params.categoryId,
      { name: req.body.name },
      { new: true }
    );
    res.json(updated);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

exports.updateSubcategory = async (req, res) => {
  try {
    const updated = await Subcategory.findByIdAndUpdate(
      req.params.subcategoryId,
      { name: req.body.name, categoryId: req.body.categoryId },
      { new: true }
    );
    res.json(updated);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};

exports.updateProduct = async (req, res) => {
  try {
    const updates = req.body;
    if (req.file) {
      updates.image = req.file.path;
    }

    const updated = await Product.findByIdAndUpdate(
      req.params.productId,
      updates,
      { new: true }
    );
    res.json(updated);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
};
