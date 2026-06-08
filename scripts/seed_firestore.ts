#!/usr/bin/env node

/**
 * Firestore Seeding Script for Smart Shopping
 *
 * This script populates the Firestore database with demo products
 * for testing and development purposes.
 *
 * Prerequisites:
 * - Node.js installed
 * - Firebase CLI installed and authenticated
 * - Service account key downloaded from Firebase Console
 *
 * Usage:
 * npm install firebase-admin
 * node scripts/seed_firestore.js
 */

const admin = require('firebase-admin');

// Initialize Firebase Admin SDK
// Make sure to set GOOGLE_APPLICATION_CREDENTIALS environment variable
// or place serviceAccountKey.json in the project root
const serviceAccount = require('../serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: `https://${serviceAccount.project_id}-default-rtdb.firebaseio.com`
});

const db = admin.firestore();

// Demo products data
const demoProducts = [
  {
    name: 'Lait demi-écrémé',
    description: 'Lait frais demi-écrémé 1L, parfaite pour le petit-déjeuner',
    price: 1.25,
    barcode: '3017620422003',
    imageUrl: 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400',
    category: 'Produits laitiers',
    stock: 50,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Pain de campagne',
    description: 'Pain artisanal au levain, 500g',
    price: 2.80,
    barcode: '3017620422004',
    imageUrl: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400',
    category: 'Boulangerie',
    stock: 25,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Pommes Golden',
    description: 'Pommes golden délicieuses, sac de 1kg',
    price: 3.50,
    barcode: '3017620422005',
    imageUrl: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400',
    category: 'Fruits et légumes',
    stock: 30,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Yaourt nature',
    description: 'Yaourt nature bio, pot de 125g',
    price: 0.60,
    barcode: '3017620422006',
    imageUrl: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',
    category: 'Produits laitiers',
    stock: 40,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Café moulu',
    description: 'Café arabica moulu, paquet 250g',
    price: 4.20,
    barcode: '3017620422007',
    imageUrl: 'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400',
    category: 'Épicerie',
    stock: 20,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Pâtes spaghetti',
    description: 'Spaghetti de qualité supérieure, paquet 500g',
    price: 1.15,
    barcode: '3017620422008',
    imageUrl: 'https://images.unsplash.com/photo-1621996346565-e3dbc353d2e5?w=400',
    category: 'Épicerie',
    stock: 35,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Bananes',
    description: 'Bananes bio, régime d\'environ 1kg',
    price: 2.30,
    barcode: '3017620422009',
    imageUrl: 'https://images.unsplash.com/photo-1571771019784-3ff35f4f4277?w=400',
    category: 'Fruits et légumes',
    stock: 45,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Fromage cheddar',
    description: 'Fromage cheddar affiné, 200g',
    price: 3.80,
    barcode: '3017620422010',
    imageUrl: 'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=400',
    category: 'Produits laitiers',
    stock: 15,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Tomates cerises',
    description: 'Tomates cerises bio, barquette 250g',
    price: 2.90,
    barcode: '3017620422011',
    imageUrl: 'https://images.unsplash.com/photo-1546470427-e9e826f9e6a1?w=400',
    category: 'Fruits et légumes',
    stock: 28,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
  {
    name: 'Jus d\'orange',
    description: 'Jus d\'orange pressé, bouteille 1L',
    price: 2.45,
    barcode: '3017620422012',
    imageUrl: 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400',
    category: 'Boissons',
    stock: 22,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  },
];

// Categories for reference
const categories = [
  'Produits laitiers',
  'Boulangerie',
  'Fruits et légumes',
  'Épicerie',
  'Boissons',
  'Viandes et poissons',
  'Surgelés',
  'Hygiène et beauté'
];

/**
 * Seed products collection with demo data
 */
async function seedProducts() {
  console.log('🌱 Starting to seed products...');

  const batch = db.batch();
  const productsRef = db.collection('products');

  // Clear existing products (optional - uncomment if needed)
  // const existingProducts = await productsRef.get();
  // existingProducts.forEach(doc => {
  //   batch.delete(doc.ref);
  // });

  // Add demo products
  demoProducts.forEach(product => {
    const docRef = productsRef.doc(); // Auto-generated ID
    batch.set(docRef, product);
  });

  try {
    await batch.commit();
    console.log(`✅ Successfully seeded ${demoProducts.length} products`);
  } catch (error) {
    console.error('❌ Error seeding products:', error);
    throw error;
  }
}

/**
 * Seed categories collection (optional)
 */
async function seedCategories() {
  console.log('🌱 Starting to seed categories...');

  const batch = db.batch();
  const categoriesRef = db.collection('categories');

  categories.forEach(category => {
    const docRef = categoriesRef.doc(); // Auto-generated ID
    batch.set(docRef, {
      name: category,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });

  try {
    await batch.commit();
    console.log(`✅ Successfully seeded ${categories.length} categories`);
  } catch (error) {
    console.error('❌ Error seeding categories:', error);
    throw error;
  }
}

/**
 * Create a demo admin user (optional)
 */
async function createDemoAdmin() {
  console.log('🌱 Creating demo admin user...');

  try {
    const userRecord = await admin.auth().createUser({
      email: 'admin@smartshopping.com',
      password: 'Admin123!',
      displayName: 'Admin User',
    });

    // Add admin role to Firestore
    await db.collection('admins').doc(userRecord.uid).set({
      email: userRecord.email,
      role: 'admin',
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    console.log('✅ Demo admin created:', userRecord.email);
    console.log('📧 Admin credentials: admin@smartshopping.com / Admin123!');
  } catch (error) {
    if (error.code === 'auth/email-already-exists') {
      console.log('ℹ️  Demo admin already exists');
    } else {
      console.error('❌ Error creating demo admin:', error);
      throw error;
    }
  }
}

/**
 * Main seeding function
 */
async function seedDatabase() {
  console.log('🚀 Starting Smart Shopping database seeding...');
  console.log('📅 Timestamp:', new Date().toISOString());

  try {
    // Seed in order
    await seedCategories();
    await seedProducts();
    await createDemoAdmin();

    console.log('🎉 Database seeding completed successfully!');
    console.log('\n📊 Summary:');
    console.log(`   • ${categories.length} categories created`);
    console.log(`   • ${demoProducts.length} products created`);
    console.log('   • 1 admin user created');
    console.log('\n💡 You can now run the Flutter app and test with demo data');

  } catch (error) {
    console.error('💥 Database seeding failed:', error);
    process.exit(1);
  } finally {
    // Close the Firebase app
    await admin.app().delete();
  }
}

// Handle script execution
if (require.main === module) {
  seedDatabase().catch(error => {
    console.error('💥 Unexpected error:', error);
    process.exit(1);
  });
}

module.exports = {
  seedDatabase,
  seedProducts,
  seedCategories,
  createDemoAdmin,
  demoProducts,
  categories
};