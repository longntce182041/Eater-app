# AI Meal Planner - Admin Dashboard

A React + Vite admin dashboard for managing the AI Meal Planning system.

## Tech Stack

- **Framework**: React 18 with TypeScript
- **Build Tool**: Vite
- **State Management**: Redux Toolkit
- **Routing**: React Router v6
- **HTTP Client**: Axios
- **Forms**: React Hook Form
- **Styling**: Tailwind CSS (ready to configure)

## Project Structure

```
admin-dashboard/
├── src/
│   ├── pages/                    # Page components
│   │   ├── auth/                 # Login, authentication pages
│   │   ├── users/                # User management
│   │   ├── nutritionists/        # Nutritionist management & verification
│   │   ├── recipes/              # Recipe management
│   │   ├── ingredients/          # Ingredient management
│   │   ├── micronutrients/       # Micronutrient management
│   │   ├── knowledge-base/       # Nutrition knowledge articles
│   │   ├── reviews/              # Reviews & content moderation
│   │   └── analytics/            # System analytics
│   │
│   ├── components/               # Reusable components
│   │   ├── common/               # Buttons, inputs, modals, cards
│   │   ├── layout/               # MainLayout, Sidebar, Header
│   │   ├── forms/                # Form components
│   │   ├── tables/               # Table components
│   │   ├── charts/               # Chart components
│   │   └── modals/               # Modal components
│   │
│   ├── features/                 # Redux slices by feature
│   │   ├── auth/                 # Authentication state
│   │   ├── users/                # Users state
│   │   ├── nutritionists/        # Nutritionists state
│   │   ├── recipes/              # Recipes state
│   │   ├── ingredients/          # Ingredients state
│   │   ├── micronutrients/       # Micronutrients state
│   │   ├── knowledge-base/       # Knowledge base state
│   │   ├── reviews/              # Reviews state
│   │   └── analytics/            # Analytics state
│   │
│   ├── services/                 # API service layer
│   │   ├── apiClient.ts          # Axios client configuration
│   │   ├── authService.ts        # Authentication API
│   │   ├── usersService.ts       # Users API
│   │   ├── nutritionistsService.ts
│   │   ├── recipesService.ts
│   │   ├── ingredientsService.ts
│   │   ├── micronutrientsService.ts
│   │   ├── knowledgeBaseService.ts
│   │   ├── reviewsService.ts
│   │   └── analyticsService.ts
│   │
│   ├── store/                    # Redux store configuration
│   │   ├── index.ts              # Store setup
│   │   └── hooks.ts              # Typed hooks
│   │
│   ├── hooks/                    # Custom React hooks
│   │   ├── usePagination.ts
│   │   ├── useModal.ts
│   │   └── useDebounce.ts
│   │
│   ├── types/                    # TypeScript type definitions
│   │   ├── auth.ts
│   │   ├── user.ts
│   │   ├── nutritionist.ts
│   │   ├── recipe.ts
│   │   ├── ingredient.ts
│   │   ├── micronutrient.ts
│   │   ├── knowledge-base.ts
│   │   ├── review.ts
│   │   └── analytics.ts
│   │
│   ├── utils/                    # Utility functions
│   │   ├── dateUtils.ts
│   │   └── formatUtils.ts
│   │
│   ├── constants/                # Application constants
│   │   ├── apiRoutes.ts
│   │   └── appConstants.ts
│   │
│   ├── assets/                   # Static assets
│   │   ├── images/
│   │   └── icons/
│   │
│   ├── App.tsx                   # Main app with routing
│   ├── main.tsx                  # Entry point
│   └── index.css                 # Global styles
│
├── public/                       # Static public files
├── package.json                  # Dependencies
├── tsconfig.json                 # TypeScript config
├── vite.config.ts                # Vite config
└── README.md                     # This file
```

## Features

### User Management
- View all registered users
- User details and activity
- Ban/unban users

### Nutritionist Management
- View all nutritionists
- Verify credentials
- Request additional documents
- Suspend accounts

### Recipe Management
- View all recipes
- Approve/reject submissions
- Edit recipe details
- Feature recipes

### Ingredient & Micronutrient Management
- CRUD operations for ingredients
- CRUD operations for micronutrients
- Bulk import support

### Nutrition Knowledge Base
- Manage educational articles
- Categorize content
- Publish/archive articles

### Reviews & Moderation
- View all reviews
- Handle flagged content
- Take moderation actions

### Analytics Dashboard
- User growth metrics
- Content statistics
- Real-time data

## Getting Started

### Prerequisites
- Node.js 18+
- npm or yarn

### Installation

```bash
cd admin-dashboard
npm install
```

### Development

```bash
npm run dev
```

The app will be available at `http://localhost:3000`

### Build

```bash
npm run build
```

### Linting

```bash
npm run lint
```

## Environment Variables

Create a `.env` file:

```env
VITE_API_BASE_URL=http://localhost:8000/api/v1
```

## Path Aliases

The project uses path aliases for cleaner imports:

```typescript
import { Button } from '@components/common';
import { usersService } from '@services/usersService';
import { useAppSelector } from '@store/hooks';
import type { User } from '@types/user';
```
