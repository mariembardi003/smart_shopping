# Firestore Schema for Smart Shopping

## Database Architecture

This Firestore architecture is designed for three user roles:
- `client`
- `admin`
- `caissier`

It uses a professional, role-aware security model and optimized collections for shopping, orders, carts, complaints, and cashier sales.

---

## Collections

### 1. `users`

Stores application users and their roles.

Document path:
```
/users/{uid}
```

Fields:
- `uid` (string)
- `nom` (string)
- `email` (string)
- `role` (string) // `client`, `admin`, `caissier`
- `phone` (string)
- `imageProfile` (string)
- `createdAt` (timestamp)

Example:
```json
{
  "uid": "uid123",
  "nom": "Mariem",
  "email": "mariem@gmail.com",
  "role": "client",
  "phone": "12345678",
  "imageProfile": "https://example.com/profiles/mariem.jpg",
  "createdAt": "2026-06-07T12:00:00Z"
}
```

---

### 2. `products`

Stores catalog products for search, scanning, and checkout.

Document path:
```
/products/{productId}
```

Fields:
- `productId` (string)
- `name` (string)
- `description` (string)
- `category` (string)
- `price` (number)
- `stock` (number)
- `imageUrl` (string)
- `barcode` (string)
- `qrCode` (string)
- `createdAt` (timestamp)

Example:
```json
{
  "productId": "prod001",
  "name": "Lait",
  "description": "Lait frais",
  "category": "Produits laitiers",
  "price": 2.5,
  "stock": 50,
  "imageUrl": "https://example.com/products/lait.jpg",
  "barcode": "123456789",
  "qrCode": "QR001",
  "createdAt": "2026-06-07T12:00:00Z"
}
```

---

### 3. `carts`

Stores each client cart as a document with a nested `items` subcollection.

Document path:
```
/carts/{userId}
/carts/{userId}/items/{itemId}
```

Cart item fields:
- `productId` (string)
- `name` (string)
- `quantity` (number)
- `price` (number)
- `imageUrl` (string)
- `totalPrice` (number)

Example item:
```json
{
  "productId": "prod001",
  "name": "Lait",
  "quantity": 2,
  "price": 2.5,
  "imageUrl": "https://example.com/products/lait.jpg",
  "totalPrice": 5.0
}
```

---

### 4. `orders`

Stores completed or pending client orders.

Document path:
```
/orders/{orderId}
```

Fields:
- `orderId` (string)
- `userId` (string)
- `products` (array)
- `total` (number)
- `status` (string) // `en attente`, `validée`, `annulée`, `livrée`
- `paymentMethod` (string)
- `createdAt` (timestamp)

Example:
```json
{
  "orderId": "order123",
  "userId": "uid123",
  "products": [
    {
      "productId": "prod001",
      "name": "Lait",
      "quantity": 2,
      "price": 2.5,
      "totalPrice": 5.0
    }
  ],
  "total": 5.0,
  "status": "en attente",
  "paymentMethod": "Carte bancaire",
  "createdAt": "2026-06-07T12:30:00Z"
}
```

---

### 5. `complaints`

Stores customer support requests.

Document path:
```
/complaints/{complaintId}
```

Fields:
- `complaintId` (string)
- `userId` (string)
- `sujet` (string)
- `message` (string)
- `status` (string) // `ouverte`, `en cours`, `résolue`
- `adminResponse` (string)
- `createdAt` (timestamp)

Example:
```json
{
  "complaintId": "cmp001",
  "userId": "uid123",
  "sujet": "Produit manquant",
  "message": "Le produit n'a pas été livré.",
  "status": "ouverte",
  "adminResponse": "",
  "createdAt": "2026-06-07T12:45:00Z"
}
```

---

### 6. `sales`

Stores cashier sales transactions.

Document path:
```
/sales/{saleId}
```

Fields:
- `saleId` (string)
- `cashierId` (string)
- `products` (array)
- `total` (number)
- `paymentType` (string)
- `createdAt` (timestamp)

Example:
```json
{
  "saleId": "sale001",
  "cashierId": "uidCashier",
  "products": [
    {
      "productId": "prod001",
      "name": "Lait",
      "quantity": 1,
      "price": 2.5,
      "totalPrice": 2.5
    }
  ],
  "total": 2.5,
  "paymentType": "Espèces",
  "createdAt": "2026-06-07T13:00:00Z"
}
```

---

## Firestore Relationships

- Each `order` references a `userId` for relation between users and orders.
- Each `cart` document is keyed by `userId` and contains a subcollection `items`.
- Each `sale` references `cashierId`.
- `complaints` are linked to `userId` for client support workflows.

---

## Search and Scan Use Cases

### Product search
- Search by `name`
- Filter by `category`
- Match `barcode`
- Match `qrCode`

### Scanner workflow
1. Scan barcode or QR code
2. Query `products` where `barcode == scannedValue` or `qrCode == scannedValue`
3. Add matched product to `/carts/{userId}/items`

### Stock management
- After order validation, update `products/{productId}.stock`
- Use a transaction or Cloud Function to decrement stock and confirm order atomically

---

## Role Responsibilities

- `client`
  - Browse products
  - Manage own cart
  - Create own orders
  - Submit complaints

- `admin`
  - Full access to products, orders, complaints, and users
  - Manage product catalog
  - Respond to complaints
  - Oversee sales and user roles

- `caissier`
  - Create sales records
  - Scan products and add them to sale
  - View own sale history

---

## Security Overview

- Clients can only read products, manage their own cart, create orders, and create complaints.
- Admins can perform all actions and manage the catalog and support workflows.
- Cashiers can create and read sales data and scan products.

See `firebase/firestore.rules` for the enforced security policy.
