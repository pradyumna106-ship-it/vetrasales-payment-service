# Vetrasales Payment Service

A Spring Boot-based payment processing service that integrates with **Razorpay** to handle secure payment transactions for e-commerce operations.

## Overview

This service provides REST APIs to create payment orders and handle payment callbacks from the Razorpay payment gateway. It's built as part of the e-commerce API infrastructure, following the [roadmap.sh ecommerce-api](https://roadmap.sh/projects/ecommerce-api) design principles.

## Features

- 🔐 **Razorpay Integration**: Seamless payment gateway integration using the official Razorpay Java SDK
- 🌐 **CORS Support**: Pre-configured Cross-Origin Resource Sharing for frontend integration
- ✅ **Signature Verification**: Payment verification using cryptographic signatures
- 📦 **Order Management**: Create and track payment orders with configurable amounts
- 🐳 **Docker Ready**: Multi-stage Docker build for optimized containerization
- 🧪 **Spring Boot 3.4.3**: Built on the latest Spring Boot version with Java 17

## Tech Stack

- **Java 17**: Modern Java runtime
- **Spring Boot 3.4.3**: Application framework
- **Maven**: Build and dependency management
- **Razorpay SDK (v1.4.8)**: Payment gateway client library

## Project Structure

```
vetrasales-payment-service/
├── src/
│   ├── main/
│   │   ├── java/com/example/payment/
│   │   │   ├── RazorpayDemoApplication.java      # Spring Boot entry point
│   │   │   ├── PaymentController.java            # REST API endpoints
│   │   │   └── CorsConfig.java                   # CORS configuration
│   │   └── resources/
│   │       ├── application.properties            # Server configuration
│   │       └── static/                           # Frontend assets
│   └── test/                                     # Unit tests
├── pom.xml                                       # Maven configuration
├── Dockerfile.payment                            # Multi-stage Docker build
├── mvnw & mvnw.cmd                              # Maven wrapper scripts
└── README.md                                     # This file
```

## API Endpoints

### 1. Create Payment Order

**Endpoint:** `GET /create-order`

Creates a new payment order in Razorpay.

**Parameters:**
- `amount` (required, int): Amount in smallest currency unit (paise for INR)
  - Must be ≤ 100,000 (₹1,000)

**Response:**
- Returns JSON with order details including `id`, `amount`, `currency`, etc.

**Example:**
```bash
curl "http://localhost:8081/create-order?amount=50000"
```

### 2. Payment Callback Handler

**Endpoint:** `POST /payment-callback`

Handles payment callback from Razorpay after user completes payment.

**Parameters:**
- `razorpay_order_id` (required): Order ID from Razorpay
- `razorpay_payment_id` (required): Payment ID from Razorpay
- `razorpay_signature` (required): HMAC signature for verification

**Behavior:**
- Verifies payment signature using your Key Secret
- Redirects to `/success.html?orderId=<orderId>` on successful payment
- Redirects to `/failure.html` on failed payment

### 3. Get API Key

**Endpoint:** `POST /get-key`

Returns the Razorpay Key ID for frontend initialization.

**Response:**
```json
"rzp_test_90lAmUtfOQvFlI"
```

## Configuration

### Application Properties

Edit `src/main/resources/application.properties`:

```properties
spring.application.name=Razorpay Demo
server.port=8081
```

### Razorpay Credentials

In `PaymentController.java`, update your credentials:

```java
private static final String KEY_ID = "YOUR_KEY_ID";
private static final String KEY_SECRET = "YOUR_KEY_SECRET";
```

⚠️ **Security Note**: Never commit actual credentials to version control. Use environment variables in production:

```java
private static final String KEY_ID = System.getenv("RAZORPAY_KEY_ID");
private static final String KEY_SECRET = System.getenv("RAZORPAY_KEY_SECRET");
```

## Getting Started

### Prerequisites

- Java 17 or higher
- Maven 3.9+ (or use included `mvnw`)
- Razorpay account with API credentials

### Installation

1. **Clone the repository**
```bash
git clone https://github.com/pradyumna106-ship-it/vetrasales-payment-service.git
cd vetrasales-payment-service
```

2. **Update Razorpay credentials**
   - Edit `src/main/java/com/example/payment/PaymentController.java`
   - Replace `KEY_ID` and `KEY_SECRET` with your Razorpay test/live keys

3. **Build the project**
```bash
./mvnw clean package
```

4. **Run the application**
```bash
./mvnw spring-boot:run
```

The service will start on `http://localhost:8081`

## Docker Deployment

### Build Docker Image

```bash
docker build -f Dockerfile.payment -t vetrasales-payment-service:latest .
```

### Run Container

```bash
docker run -p 8081:8081 \
  -e RAZORPAY_KEY_ID=your_key_id \
  -e RAZORPAY_KEY_SECRET=your_key_secret \
  vetrasales-payment-service:latest
```

### Docker Compose (Optional)

```yaml
version: '3.8'
services:
  payment-service:
    build:
      context: .
      dockerfile: Dockerfile.payment
    ports:
      - "8081:8081"
    environment:
      RAZORPAY_KEY_ID: ${RAZORPAY_KEY_ID}
      RAZORPAY_KEY_SECRET: ${RAZORPAY_KEY_SECRET}
```

## CORS Configuration

The service allows requests from all origins by default:

```java
registry.addMapping("/**")
    .allowedOrigins("*")
    .allowedMethods("*");
```

For production, restrict to specific origins in `CorsConfig.java`:

```java
.allowedOrigins("https://yourdomain.com")
.allowedMethods("GET", "POST", "OPTIONS")
```

## Integration with Frontend

### Example React Integration

```javascript
// Step 1: Create Order
const response = await fetch('http://localhost:8081/create-order?amount=50000');
const order = await response.json();

// Step 2: Initialize Razorpay Checkout
const razorpay = new window.Razorpay({
  key: 'YOUR_KEY_ID',
  order_id: order.id,
  handler: function(response) {
    // Submit payment callback
    fetch('http://localhost:8081/payment-callback', {
      method: 'POST',
      body: new URLSearchParams({
        razorpay_order_id: response.razorpay_order_id,
        razorpay_payment_id: response.razorpay_payment_id,
        razorpay_signature: response.razorpay_signature
      })
    });
  }
});

razorpay.open();
```

## Development

### Building and Testing

```bash
# Build project
./mvnw clean package

# Run tests
./mvnw test

# Build without running tests
./mvnw clean package -DskipTests
```

### Key Classes

| Class | Purpose |
|-------|---------|
| `RazorpayDemoApplication` | Spring Boot application entry point |
| `PaymentController` | REST API endpoints for payment operations |
| `CorsConfig` | CORS and Spring Web configuration |

## Troubleshooting

### Common Issues

1. **"Amount Exceeds" error**
   - Ensure amount is ≤ 100,000 paise (₹1,000)

2. **Signature verification failure**
   - Verify `KEY_SECRET` is correct
   - Check signature format: `orderId|paymentId`

3. **CORS errors in browser**
   - Verify `CorsConfig.java` allows your frontend origin
   - Check browser console for exact CORS error message

4. **Connection refused on port 8081**
   - Check if port 8081 is already in use
   - Change port in `application.properties` if needed

## Security Considerations

- ✅ Validate all payment callbacks with signature verification
- ✅ Use environment variables for sensitive credentials
- ✅ Implement amount validation to prevent overcharging
- ⚠️ Restrict CORS to trusted origins in production
- ⚠️ Never log sensitive information (signatures, secrets)
- ⚠️ Use HTTPS in production

## Environment Variables

```bash
# For production deployment
export RAZORPAY_KEY_ID=your_production_key
export RAZORPAY_KEY_SECRET=your_production_secret
export SERVER_PORT=8081
```

## Dependencies

- **spring-boot-starter-web**: REST API and web framework
- **spring-boot-starter-test**: Testing framework
- **razorpay-java**: Official Razorpay Java SDK (v1.4.8)
- **json**: JSON parsing (included with Razorpay SDK)

## API Specification

For full e-commerce API specification, refer to [roadmap.sh ecommerce-api](https://roadmap.sh/projects/ecommerce-api).

## Contributing

Contributions are welcome! Please ensure:
- Code follows Spring Boot conventions
- New features include tests
- API endpoints are documented
- Credentials are never committed

## License

This project is part of the Vetrasales e-commerce platform.

## Support

For issues and questions:
- Open an issue in this repository
- Contact the development team
- Refer to [Razorpay Documentation](https://razorpay.com/docs/)

## Changelog

### v0.0.1-SNAPSHOT
- Initial release
- Razorpay payment integration
- Order creation and callback handling
- CORS support
- Docker containerization

---

**Last Updated:** February 2026  
**Status:** Active Development
