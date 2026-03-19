# Technical Requirements Document: Logistics Management System (LMS)

## 1. Project Overview
The Logistics Management System (LMS) is a comprehensive solution designed to streamline fleet operations, order fulfillment, and driver management. This document focuses on the **Admin Dashboard**, the central command center for real-time logistics oversight.

---

## 2. Target Users
*   **System Administrator:** Oversees all operations, manages users, and analyzes performance data.
*   **Fleet Manager:** Monitors vehicle health, maintenance schedules, and real-time locations.
*   **Dispatcher:** Manages order assignments and driver scheduling.

---

## 3. Functional Requirements: Admin Dashboard

### 3.1. Fleet Status Oversight
*   **Real-time Tracking:** Integration with GPS to monitor vehicle positions on a live map.
*   **Vehicle Status Categories:**
    *   *Active:* Currently on a delivery.
    *   *Idle:* Available for assignment.
    *   *Maintenance:* Undergoing repairs/service.
    *   *Out of Service:* Long-term unavailability.
*   **Maintenance Alerts:** Automated notifications for upcoming service intervals (based on mileage or time).
*   **Fuel/Efficiency Monitoring:** Basic reporting on fuel consumption and route efficiency.

### 3.2. Pending Orders Management
*   **Order Lifecycle Management:**
    *   *Pending:* New orders awaiting assignment.
    *   *Assigned:* Orders linked to a driver/vehicle.
    *   *In Transit:* Orders currently being delivered.
    *   *Delivered:* Successfully completed orders.
    *   *Exceptions:* Delayed or cancelled orders with reason codes.
*   **Automated/Manual Dispatching:** Tools to assign orders to drivers based on proximity and vehicle capacity.
*   **Urgency Levels:** Color-coded priority indicators (e.g., Express vs. Standard).

### 3.3. Driver Performance Tracking
*   **KPI Dashboard:**
    *   *On-Time Delivery Rate (OTD).*
    *   *Average Delivery Time.*
    *   *Customer Rating/Feedback.*
    *   *Safety Score (based on harsh braking, speeding - if sensor data is available).*
*   **Shift Logs:** Monitoring clock-in/out times and active driving hours.
*   **Incentive Management:** Data-driven ranking of top-performing drivers for rewards.

---

## 4. Technical Architecture

### 4.1. Frontend (Flutter)
*   **Framework:** Flutter (Mobile & Web compatibility).
*   **State Management:** Provider, Riverpod, or Bloc (standard Flutter patterns).
*   **UI Components:**
    *   `google_maps_flutter` for live tracking.
    *   `fl_chart` for performance visualizations.
    *   `data_table_2` for order and fleet lists.

### 4.2. Backend (Recommended)
*   **API:** REST or GraphQL (Node.js/Express or Firebase).
*   **Database:** 
    *   PostgreSQL (Structured order/driver data).
    *   Redis (Real-time location updates).
*   **Real-time Communication:** WebSockets or Firebase Cloud Messaging (FCM) for live updates.

---

## 5. Non-Functional Requirements
*   **Scalability:** Support for up to 500+ simultaneous vehicles and thousands of daily orders.
*   **Security:** Role-Based Access Control (RBAC), JWT authentication, and SSL/TLS encryption.
*   **Latency:** Real-time map updates must have < 5-second latency.
*   **Offline Support:** Drivers' mobile apps must cache data for sync upon reconnection.

---

## 6. Data Model (Key Entities)

### Fleet
*   `id`: UUID
*   `license_plate`: String
*   `vehicle_type`: Enum (Truck, Van, Bike)
*   `status`: Enum
*   `current_location`: LatLng

### Order
*   `id`: UUID
*   `customer_details`: Object
*   `pickup_location`: LatLng
*   `delivery_location`: LatLng
*   `assigned_driver_id`: UUID (FK)
*   `priority`: Enum

### Driver
*   `id`: UUID
*   `name`: String
*   `license_info`: String
*   `performance_score`: Float
*   `is_active`: Boolean
