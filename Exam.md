# Exam Requirement: Fee Management App
A group of users is managing their financial budget related to library fees and costs using a mobile application. Each user can track and analyze their expenses and unpaid fines.

On the server side, at least the following details are maintained:
- `id`: The unique identifier for the fee. Integer value greater than zero.
- `date`: The date when the fee was incurred. A string in the format "YYYY-MM-DD".
- `amount`: The amount of the fee. A decimal value.
- `type`: The type of fee (e.g., fine, membership, service). A string of characters.
- `category`: The category of the fee (e.g., late_return, damaged_book, printing). A string of characters.
- `description`: A description of the fee or reason. A string of characters.

The application should provide at least the following features:

## Main Section (Separate Screen/Activity)
> **Note:** Each feature in this section should be implemented in a separate screen unless otherwise specified.

- A. **(1p) View the list of fees**: Using the `GET /fees` call, users can retrieve all their fees. If offline, the app will display an offline message and provide a retry option. Once retrieved, the data should be available on the device, regardless of whether online or offline.
- B. **(2p) View Fee Details**: By selecting a fee from the list, the user can view its details. The `GET /fee/:id` call will retrieve specific fee details. Once retrieved, the data should be available on the device, regardless of whether online or offline.
- C. **(1p) Add a new fee**: Users can create a new fee using the `POST /fee` call by specifying all fee details. This feature is available online only.
- D. **(1p) Delete a fee**: Users can delete a fee using the `DELETE /fee/:id` call by selecting it from the list. This feature is available online only.

## Reports Section (Separate Screen/Activity)

**(1p) Monthly Fee Analysis**: Using the `GET /allFees` call, the app will retrieve all fees and compute the list of monthly totals, displayed in descending order of value.

## Insights Section (Separate Screen/Activity)

**(1p) Top Categories**: View the top 3 fee categories (e.g. which type of fine is most common). Using the same `GET /allFees` call, the app will compute and display the top 3 categories and their total amounts in descending order.

## Additional Features
- **(1p) WebSocket Notifications**: When a new fee is added, the server will use a WebSocket channel to send the fee details to all connected clients. The app will display the received data in human-readable form (e.g., as a toast, snackbar, or dialog).
- **(0.5p) Progress Indicator**: A progress indicator will be displayed during server operations.
- **(0.5p) Error Handling & Logging**: Any server interaction errors will be displayed using a toast or snackbar, and all interactions (server or DB) will log a message.

## Server Info
- Location: `./server`
- Install: `npm install`
- Run: `npm start`
- Port: 2620
