# Payment History & Record Management Plan

### Overview
The "Pay Now" functionality will serve as a **Payment Recorder** rather than a financial gateway. It allows the plant owner to log manual payments (Cash or Online) made to farmers, track balances, and maintain a verifiable history with optional proof (screenshots).

---

### 1. Data Model (`PaymentRecord`)
To track payments accurately, a new domain entity is required:
- `id`: Unique identifier.
- `farmerId`: Reference to the farmer.
- `sessionId`: Reference to the active session (to keep financial ledger scoped).
- `amount`: The amount paid.
- `date`: Transaction date.
- `method`: enum `[Cash, Online]`.
- `referenceId`: Optional (UTR number or transaction ID for online payments).
- `screenshotPath`: Optional (Local path to the receipt/screenshot image).
- `notes`: Optional remarks.

---

### 2. UI Triggers & Entry Points
- **Primary Trigger**: The "PAY NOW" button on the `FarmerLedgerScreen` summary card.
- **Secondary Entry**: A "Record Payment" option in the Global FAB or Farmer List long-press.
- **Contextual Action**: "Add Payment" within the Payment History list view.

---

### 3. Proposed Workflow

#### A. Recording a Payment (`AddPaymentScreen`)
- **Input Fields**: Amount (pre-filled with remaining balance), Date (default: today), Method (Toggle: Cash/Online).
- **Online Specifics**: If "Online" is selected, show a field for "Transaction ID / UTR".
- **Proof of Payment**: An "Attach Screenshot" button using `image_picker`.
- **Validation**: Ensure amount doesn't exceed balance (warning) or allow partial payments.

#### B. Viewing History (`PaymentHistoryScreen` or Section)
- **Location**: A new section in `FarmerLedgerScreen` below "Recent Supply" called "Payment History".
- **Visuals**: List cards showing Date, Amount, Method (Icon), and a "View Receipt" thumbnail if a screenshot exists.
- **Navigation**: "See All" redirects to a dedicated Ledger-style list for payments.

#### C. Management (Edit/Delete)
- **Edit**: Tap on a history item to update details (e.g., adding a missing UTR or fixing a date).
- **Delete**: Swipe-to-delete or "Delete" button inside Edit mode (with confirmation) to reverse accidental entries.
- **Impact**: Deleting/Editing a payment must automatically update the "SESSION BALANCE" on the Farmer Ledger.

---

### 4. Technical Requirements
- **Storage**: Update `DemoCatalog` (or local database) to include a `payments` collection.
- **Calculations**: Update `totalPaid` logic in `FarmerLedgerScreen` to sum both `procurement.amountPaid` (old system) and the new `PaymentRecord` entries.
- **Image Handling**: Use `path_provider` to save screenshots locally to the app's document directory.

---

### 5. Integration with Ledger
- The "SESSION BALANCE" will now be: 
  `Total Procurement Amount - (Sum of Direct Paid in Logs + Sum of Manual PaymentRecords)`
