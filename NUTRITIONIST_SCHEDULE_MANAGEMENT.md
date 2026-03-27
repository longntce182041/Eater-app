# Nutritionist Schedule Management System

## Overview

The Nutritionist Schedule Management System is a comprehensive solution that allows administrators to create and manage work schedules for nutritionists, and enables nutritionists to view their schedules and propose changes. The system includes approval workflows for schedule change requests.

## Features

### Admin Dashboard
- **Create Schedules**: Create work schedules for nutritionists with weekly hours and special dates
- **View All Schedules**: See all active and inactive nutritionist schedules
- **Update Schedules**: Edit existing schedules with new work hours or special dates
- **Delete Schedules**: Remove schedules that are no longer needed
- **Manage Change Requests**: Review and approve/reject schedule change requests from nutritionists
- **Filter Requests**: View pending, approved, or rejected requests

### Nutritionist Features
- **View My Schedule**: See your assigned work schedule with weekly hours
- **Request Changes**: Submit requests to change your work schedule
- **Track Requests**: View the status of all your schedule change requests
- **Proposed Changes**: Include detailed information about why you need the change

## Technical Architecture

### Backend Components

#### Models

1. **NutritionistSchedule** (`nutritionist_schedule.js`)
   - Stores the work schedule for each nutritionist
   - Weekly schedule details (day, start time, end time, availability)
   - Special dates (vacations, holidays, off days)
   - Status tracking (active, inactive, on_leave)
   - Effective dates for schedule validity

2. **ScheduleChangeRequest** (`schedule_change_request.js`)
   - Tracks schedule change requests from nutritionists
   - Request types: modify_hours, take_day_off, vacation, special_request
   - Status workflow: pending → approved/rejected
   - Admin notes and approval tracking

#### Controllers

**nutritionist.schedule.controller.js** provides the following endpoints:

**Admin Operations:**
- `POST /create` - Create new schedule
- `GET /all` - Get all schedules
- `PUT /:scheduleId` - Update schedule
- `DELETE /:scheduleId` - Delete schedule
- `GET /change-requests/all` - View all change requests
- `PATCH /change-requests/:requestId/approve` - Approve request
- `PATCH /change-requests/:requestId/reject` - Reject request

**Nutritionist Operations:**
- `GET /nutritionist/:nutritionistId` - View own schedule
- `POST /change-requests/request` - Submit change request
- `GET /change-requests/nutritionist/:nutritionistId` - View own requests

#### Routes

All endpoints are under `/api/nutritionist-schedules`:

```
POST   /                                          # Create schedule (Admin)
GET    /all                                       # Get all schedules (Admin)
GET    /nutritionist/:nutritionistId              # Get nutritionist schedule
GET    /:scheduleId                               # Get schedule by ID
PUT    /:scheduleId                               # Update schedule (Admin)
DELETE /:scheduleId                               # Delete schedule (Admin)

POST   /change-requests/request                   # Request change (Nutritionist)
GET    /change-requests/nutritionist/:nutritionistId  # Get my requests
GET    /change-requests/all                       # Get all requests (Admin)
PATCH  /change-requests/:requestId/approve        # Approve (Admin)
PATCH  /change-requests/:requestId/reject         # Reject (Admin)
```

### Frontend Components

#### Admin Pages

1. **NutritionistScheduleManagement.jsx**
   - Main admin schedule management page
   - Create, view, edit, and delete schedules
   - Display schedules in card grid
   - Detailed modal for schedule information
   - Weekly schedule configuration

2. **ScheduleChangeRequests.jsx**
   - Manage nutritionist schedule change requests
   - Filter by status (pending, approved, rejected)
   - Review requests with detailed information
   - Approve or reject with admin notes
   - Track request history

#### Nutritionist Pages

3. **MySchedule.jsx**
   - View personal work schedule
   - Display weekly hours and special dates
   - Submit schedule change requests
   - Track request status and history
   - Receive admin feedback on requests

#### Services

**nutritionistScheduleApi.js** provides API client functions:
```javascript
// Admin functions
createNutritionistSchedule(data)
getAllNutritionistSchedules()
getNutritionistScheduleById(scheduleId)
updateNutritionistSchedule(scheduleId, data)
deleteNutritionistSchedule(scheduleId)

// Nutritionist functions
getNutritionistScheduleByNutritionistId(nutritionistId)
requestScheduleChange(data)
getNutritionistChangeRequests(nutritionistId, status)

// Admin request management
getAllChangeRequests(status)
approveChangeRequest(requestId, data)
rejectChangeRequest(requestId, data)
```

## Usage Guide

### For Administrators

#### Creating a Schedule

1. Navigate to **Nutritionist Schedule Management**
2. Click **Create New Schedule**
3. Fill in the form:
   - Select nutritionist
   - Set effective date range
   - Configure weekly work hours for each day
   - Add special dates (vacations, holidays) if needed
4. Click **Create Schedule**

#### Managing Change Requests

1. Go to **Schedule Change Requests** page
2. View pending requests in the default filter
3. For each request:
   - Click **View Details** to see full information
   - Click **Review** to process the request
4. In the review modal:
   - Add admin notes (optional)
   - Click **Approve** or **Reject**
5. The schedule updates automatically if approved

#### Example Request Types

- **Take Day Off**: Single day absence
- **Vacation**: Multi-day absence period
- **Modify Hours**: Change working hours on a specific day
- **Special Request**: Any other schedule change request

### For Nutritionists

#### Viewing Your Schedule

1. Go to **My Work Schedule**
2. View your weekly working hours
3. Check special dates like vacations or off days
4. See your current employment status

#### Requesting a Schedule Change

1. Click **Request Schedule Change** button
2. Select request type:
   - **Take Day Off**: For a single day
   - **Vacation**: For multiple days
   - **Modify Hours**: To change working hours on specific day
   - **Special Request**: For other changes

3. Fill in required information:
   - Reason for the change
   - Affected dates
   - For "Modify Hours": Select day and new time range

4. Submit the request
5. Track status under **Change Requests** tab

#### Request Status

- **Pending**: Waiting for admin review
- **Approved**: Request accepted, schedule updated
- **Rejected**: Request denied (check admin notes)

## Data Structure Examples

### Create Schedule Request
```json
{
  "nutritionistId": "507f1f77bcf86cd799439011",
  "scheduleDetails": [
    {
      "dayOfWeek": "Monday",
      "startTime": "09:00",
      "endTime": "17:00",
      "isAvailable": true
    },
    // ... more days
  ],
  "specialDates": [],
  "effectiveFrom": "2024-04-01",
  "effectiveUntil": null
}
```

### Request Schedule Change
```json
{
  "scheduleId": "507f1f77bcf86cd799439012",
  "requestType": "take_day_off",
  "reason": "Medical appointment",
  "affectedDates": {
    "startDate": "2024-04-15",
    "endDate": null
  },
  "proposedChanges": {}
}
```

## Integration Points

### Route Integration

Add these routes to your router configuration:

```javascript
import { 
  NutritionistScheduleManagement, 
  MySchedule, 
  ScheduleChangeRequests 
} from "@/pages/nutritionist-schedules";

// Admin routes
<Route path="/admin/schedules" element={<NutritionistScheduleManagement />} />
<Route path="/admin/schedule-requests" element={<ScheduleChangeRequests />} />

// Nutritionist routes
<Route path="/nutritionist/my-schedule" element={<MySchedule nutritionistId={...} />} />
```

### Middleware

The backend uses authentication middleware to protect routes:
- `protect`: Requires authentication
- `adminOnly`: Requires admin role
- `nutritionistOnly`: Requires nutritionist role

## Styling

All components use custom CSS with the following design elements:

- **Colors**: 
  - Primary: #FF9800 (Orange)
  - Success: #4CAF50 (Green)
  - Danger: #D32F2F (Red)
  - Warning: #FFC107 (Amber)

- **Typography**: Clean, modern sans-serif fonts
- **Layout**: Responsive grid-based layouts
- **Animations**: Smooth transitions and fade-ins

## API Response Examples

### Successful Schedule Creation
```json
{
  "success": true,
  "message": "Schedule created successfully",
  "data": {
    "_id": "507f1f77bcf86cd799439012",
    "nutritionistId": "507f1f77bcf86cd799439011",
    "status": "active",
    "effectiveFrom": "2024-04-01T00:00:00Z",
    "scheduleDetails": [...]
  }
}
```

### Successful Request Approval
```json
{
  "success": true,
  "message": "Schedule change request approved successfully",
  "data": {
    "_id": "507f1f77bcf86cd799439020",
    "status": "approved",
    "adminNotes": "Approved",
    "approvedAt": "2024-04-10T10:30:00Z"
  }
}
```

## Error Handling

The system handles various error scenarios:

- **404 Not Found**: Nutritionist or schedule doesn't exist
- **400 Bad Request**: Invalid input data or duplicate active schedule
- **403 Forbidden**: Unauthorized access (e.g., nutritionist modifying another's schedule)
- **500 Server Error**: Internal server errors with detailed error messages

Error messages are displayed in the UI with clear explanations and suggestions for resolution.

## Future Enhancements

Potential improvements for the scheduling system:

1. **Calendar View**: Interactive calendar for schedule visualization
2. **Conflict Detection**: Automatic detection of overlapping schedules
3. **Templates**: Schedule templates for quick setup
4. **Notifications**: Email/SMS alerts for schedule changes
5. **Export**: PDF/Excel export of schedules
6. **Analytics**: Schedule utilization and availability reports
7. **Team Coverage**: Ensure minimum coverage for operations
8. **Client Booking**: Integration with client booking system

## Troubleshooting

### Common Issues

**1. Schedule not showing up**
- Verify the nutritionist exists
- Check if the schedule is marked as "active"
- Ensure the effective date range is current

**2. Change request not submitting**
- Verify all required fields are filled
- Check if the schedule ID is valid
- Ensure you're logged in as a nutritionist

**3. Admin can't approve requests**
- Verify you have admin role
- Check if the request status is "pending"
- Ensure the schedule still exists

## Support

For issues or questions about the scheduling system, please refer to:
- API Documentation: `/eater-backend/AI_SERVICE_API.md`
- Database Schema: Check model files in `/eater-backend/src/models/`
- Component documentation: Check JSDoc comments in component files
