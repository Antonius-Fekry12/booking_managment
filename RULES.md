# Studio Management System Rules

## Architecture Rules

- Use Clean Architecture.
- Separate Data, Domain, Presentation layers.
- No business logic inside UI widgets.
- Use Riverpod for state management.
- Use Repository Pattern.
- Use Dependency Injection.

---

## Flutter Rules

- Flutter Desktop Windows First.
- Responsive UI mandatory.
- Avoid hardcoded sizes.
- Use reusable widgets.
- Use Material 3.

---

## Code Quality Rules

- Follow SOLID principles.
- Follow DRY principles.
- No duplicate code.
- Use meaningful naming.
- Every feature must have documentation.

---

## Database Rules

- Use SQLite.
- Drift ORM preferred.
- Create migrations.
- Foreign keys required.
- Soft delete for bookings.

---

## UI Rules

- Arabic RTL support.
- English support.
- Responsive tables.
- Consistent spacing.
- Consistent typography.

---

## Booking Rules

- Validate date availability.
- Calculate remaining amount automatically.
- Prevent invalid payments.
- Support booking edit.
- Support booking cancel.

---

## Calendar Rules

- Highlight booked dates.
- Show booking details on click.
- Support month navigation.

---

## Notification Rules

- Notify 2 days before booking.
- Notify 1 day before booking.
- Prevent duplicate notifications.

---

## Invoice Rules

- PDF must contain:

  Studio Name
  Customer Information
  Booking Details
  Services
  Total Amount
  Paid Amount
  Remaining Amount

- Professional invoice layout.

---

## Documentation Rules

After each completed task:

Update PROJECT_LOG.md.

Include:

- What was implemented
- Files created
- Database changes
- Pending tasks

---

## Git Rules

Commit after each completed feature.

Commit format:

feat: booking module
feat: calendar module
feat: payment module
fix: booking validation
refactor: dashboard structure