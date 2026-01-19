/**
 * Application-wide constants
 */

export const APP_NAME = 'AI Meal Planner Admin';

export const PAGINATION = {
  DEFAULT_PAGE_SIZE: 20,
  PAGE_SIZE_OPTIONS: [10, 20, 50, 100],
} as const;

export const USER_ROLES = {
  USER: 'user',
  PREMIUM: 'premium',
  NUTRITIONIST: 'nutritionist',
} as const;

export const USER_STATUSES = {
  ACTIVE: 'active',
  INACTIVE: 'inactive',
  BANNED: 'banned',
  PENDING: 'pending',
} as const;

export const RECIPE_STATUSES = {
  DRAFT: 'draft',
  PENDING: 'pending',
  APPROVED: 'approved',
  REJECTED: 'rejected',
} as const;

export const VERIFICATION_STATUSES = {
  PENDING: 'pending',
  APPROVED: 'approved',
  REJECTED: 'rejected',
  REQUIRES_INFO: 'requires_info',
} as const;

export const MODERATION_ACTIONS = {
  APPROVE: 'approve',
  REMOVE: 'remove',
  WARN_USER: 'warn_user',
  BAN_USER: 'ban_user',
} as const;
