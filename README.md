# 🍽️ Restaurant Order App (Waiter Panel)

A lightweight Flutter app built for restaurant waiters to manage dine-in table orders efficiently. This app focuses on core features and can be implemented within 2–4 hours for prototyping or small-scale use.

## 🚀 Core Features

- 🪑 View a list of tables with live status:
  - `Free`
  - `Occupied`
  - `Requesting Bill`
- 📲 Tap a table to:
  - Start a new order
  - Continue an existing order
- 🍔 Add order items with:
  - Quantity
  - Optional notes/instructions
- 🧾 View a basic **bill summary**:
  - Total items
  - Total cost
- ✅ Mark orders as **Completed** when served

## 📱 Screens Overview

- **Home Screen**: List of tables with their current status.
- **Order Screen**: Add/update items for a selected table.
- **Summary Screen**: Basic billing and option to complete the order.

## 🛠️ Tech Stack

- **Framework**: Flutter
- **State Management**: `setState` (or optionally `Provider`/`GetX`)
- **Storage**: In-memory or local state (for demo purposes)

> Firebase or backend integration is **not required** in this simplified version.

## 🧱 Folder Structure

